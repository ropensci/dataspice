# Generate a self-contained tabbed HTML comparison for the bbox test cases.
# Projection and figure helpers are scoped within the generator so package load
# itself has no side effects.
utils::globalVariables(c("x", "y", "group", "label", "xend", "yend"))

generate_projection_comparison <- function(
    output_file = file.path("reports", "projection-method-comparison.html"),
    bbox_file = system.file("extdata", "test-bboxes.csv", package = "staticmaps")) {
  required <- c("crsuggest", "htmltools", "maps", "projWiz")
  missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Install required report packages: ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  if (length(bbox_file) != 1L || is.na(bbox_file) || !nzchar(bbox_file) ||
      !file.exists(bbox_file)) {
    stop("Bounding-box CSV not found: ", bbox_file, call. = FALSE)
  }

  bbox_cases <- utils::read.csv(bbox_file, stringsAsFactors = FALSE)
  world_data <- ggplot2::map_data("world")
  world_groups <- split(world_data, world_data$group)
  world_polygons <- lapply(world_groups, function(part) {
    coords <- as.matrix(part[c("long", "lat")])
    if (nrow(coords) < 4L) return(NULL)
    if (!all(coords[1, ] == coords[nrow(coords), ])) {
      coords <- rbind(coords, coords[1, ])
    }
    sf::st_polygon(list(coords))
  })
  world_polygons <- world_polygons[!vapply(world_polygons, is.null, logical(1))]
  world_sfc <- sf::st_sfc(world_polygons, crs = 4326)
  clipped_world_cache <- new.env(parent = emptyenv())
  extent_count <- nrow(bbox_cases)
  extent_id_range <- paste0(bbox_cases$example_id[1], "\u2013",
                            bbox_cases$example_id[extent_count])

  bbox_extent <- function(row, padding = 0.12) {
    west <- as.numeric(row$west)
    east <- as.numeric(row$east)
    span <- as.numeric(row$longitude_span_deg)
    if (east < west || span > (east - west)) east <- west + span
    south <- as.numeric(row$south)
    north <- as.numeric(row$north)
    dx <- span * padding
    dy <- (north - south) * padding
    center <- west + span / 2
    c(west = max(west - dx, center - 180), east = min(east + dx, center + 180),
      south = max(-90, south - dy), north = min(90, north + dy),
      center_lon = center, center_lat = (south + north) / 2,
      box_west = west, box_east = east, box_south = south, box_north = north)
  }

  shift_longitude <- function(lon, center) {
    center + ((lon - center + 180) %% 360) - 180
  }

  format_degrees <- function(value, axis) {
    if (axis == "longitude") {
      value <- ((value + 180) %% 360) - 180
      suffix <- if (value < 0) "W" else if (value > 0) "E" else ""
    } else {
      suffix <- if (value < 0) "S" else if (value > 0) "N" else ""
    }
    paste0(format(abs(value), trim = TRUE, scientific = FALSE), "\u00b0", suffix)
  }

  clip_world_to_extent <- function(extent) {
    bounds <- unname(extent[c("west", "east", "south", "north")])
    key <- paste(format(bounds, digits = 12), collapse = ":")
    if (exists(key, envir = clipped_world_cache, inherits = FALSE)) {
      return(get(key, envir = clipped_world_cache, inherits = FALSE))
    }

    masks <- list()
    west <- unname(extent["west"])
    east <- unname(extent["east"])
    south <- unname(extent["south"])
    north <- unname(extent["north"])
    cursor <- west
    while (cursor < east - 1e-9) {
      wrap <- floor((cursor + 180) / 360)
      edge <- min(east, 180 + 360 * wrap)
      left <- cursor - 360 * wrap
      right <- edge - 360 * wrap
      ring <- rbind(c(left, south), c(right, south), c(right, north),
                    c(left, north), c(left, south))
      masks[[length(masks) + 1L]] <- sf::st_polygon(list(ring))
      cursor <- edge
    }
    mask <- sf::st_union(sf::st_sfc(masks, crs = 4326))
    clipped <- suppressWarnings(sf::st_intersection(world_sfc, mask))
    clipped <- suppressWarnings(
      sf::st_collection_extract(clipped, "POLYGON", warn = FALSE))
    assign(key, clipped, envir = clipped_world_cache)
    clipped
  }

  project_clipped_world <- function(extent, center, crs) {
    clipped <- clip_world_to_extent(extent)
    coords <- sf::st_coordinates(clipped)
    if (!nrow(coords)) {
      return(data.frame(x = numeric(), y = numeric(), group = integer()))
    }
    group_cols <- grep("^L[0-9]+$", colnames(coords), value = TRUE)
    group <- apply(coords[, group_cols, drop = FALSE], 1, paste,
                   collapse = "_")
    xy <- project_xy(shift_longitude(coords[, "X"], center),
                     coords[, "Y"], crs)
    data.frame(x = xy$x, y = xy$y, group = group)
  }

  method_crs <- function(method, row, extent) {
    span <- as.numeric(row$longitude_span_deg)
    latspan <- as.numeric(row$latitude_span_deg)
    center_lon <- unname(extent["center_lon"])
    center_lat <- unname(extent["center_lat"])
    west <- unname(extent["box_west"])
    east <- unname(extent["box_east"])
    south <- unname(extent["box_south"])
    north <- unname(extent["box_north"])

    if (method == "equal-earth") {
      return(list(crs = sprintf(
        "+proj=eqearth +lon_0=%.8f +datum=WGS84 +units=m +no_defs +over",
        shift_longitude(center_lon, 0)),
        title = "Equal Earth (main map)", detail = "Equal Earth, centered on bbox"))
    }

    if (method == "crsuggest") {
      coords <- rbind(c(west, south), c(east, south), c(east, north),
                      c(west, north), c(west, south))
      area <- sf::st_sfc(sf::st_polygon(list(coords)), crs = 4326)
      suggestion <- crsuggest::suggest_crs(area, type = "projected", limit = 1)
      if (!nrow(suggestion)) stop("crsuggest returned no projected CRS")
      code <- as.character(suggestion$crs_code[1])
      crs <- sf::st_crs(paste0("EPSG:", code))
      if (is.na(crs)) crs <- sf::st_crs(suggestion$crs_proj4[1])
      return(list(crs = paste(crs$proj4string, "+over"),
                  title = "crsuggest \u00b7 top-ranked CRS",
                  detail = paste0(suggestion$crs_name[1], " (EPSG:", code, ")")))
    }

    if (method == "projWiz") {
      # projWiz accepts conventional longitudes only. For a dateline-crossing
      # bbox, recenter its shape at zero for selection, then move lon_0 back to
      # the actual bbox center. If its documented extent limits reject a case,
      # the page shows that limitation and uses Equal Earth as a visible fallback.
      select_west <- west
      select_east <- east
      if (select_east > 180 || select_west < -180) {
        select_west <- -span / 2
        select_east <- span / 2
      }
      projection <- NULL
      utils::capture.output(suppressMessages(
        projection <- projWiz::proj_region(
          c(xmin = select_west, xmax = select_east,
            ymin = south, ymax = north), property = "Equal area")
      ))
      selected <- as.character(projection)[1]
      selected <- sub("\\+lon_0=[^ ]+", paste0("+lon_0=", center_lon), selected)
      if (!grepl("\\+lon_0=", selected)) {
        selected <- paste(selected, paste0("+lon_0=", center_lon))
      }
      return(list(crs = paste(selected, "+over"), title = "projWiz \u00b7 Equal area",
                  detail = paste("projWiz::proj_region(property = 'Equal area'):",
                                 selected)))
    }

    if (method == "custom") {
      # Extent-aware rule set: single-hemisphere polar extents use LAEA centered
      # on the relevant pole; broad non-polar extents use Equal Earth; compact
      # extents use local LAEA; wide mid-latitude regions use Albers. Thresholds
      # are explicit prototype choices.
      width_km <- 111.195 * span * max(0.05, cos(center_lat * pi / 180))
      height_km <- 111.195 * latspan
      ratio <- width_km / height_km
      polar_lat <- if (north >= 75 && south > -75) {
        90
      } else if (south <= -75 && north < 75) {
        -90
      } else if (abs(center_lat) >= 75) {
        if (center_lat > 0) 90 else -90
      } else {
        NA_real_
      }
      if (!is.na(polar_lat)) {
        selected <- sprintf(
          paste0("+proj=laea +lon_0=%.8f +lat_0=%.8f ",
                 "+datum=WGS84 +units=m +no_defs +over"),
          shift_longitude(center_lon, 0), polar_lat)
        why <- sprintf("Polar extent \u2192 LAEA centered at %.0f\u00b0", polar_lat)
      } else if (span >= 160 || (north >= 75 && south <= -75)) {
        selected <- sprintf(
          "+proj=eqearth +lon_0=%.8f +datum=WGS84 +units=m +no_defs +over",
          shift_longitude(center_lon, 0))
        why <- "Broad global extent \u2192 Equal Earth"
      } else if (max(width_km, height_km) < 1000) {
        selected <- sprintf(
          "+proj=laea +lon_0=%.8f +lat_0=%.8f +datum=WGS84 +units=m +no_defs +over",
          center_lon, center_lat)
        why <- "Compact extent (<1,000 km) \u2192 locally centered LAEA"
      } else if (ratio >= 1.25 && abs(center_lat) < 75 &&
                 !(south < 0 && north > 0)) {
        selected <- sprintf(
          "+proj=aea +lon_0=%.8f +lat_0=%.8f +lat_1=%.8f +lat_2=%.8f +datum=WGS84 +units=m +no_defs +over",
          center_lon, center_lat, south + latspan / 6, north - latspan / 6)
        why <- sprintf("Wide extent (width/height %.2f) \u2192 Albers equal-area conic", ratio)
      } else {
        selected <- sprintf(
          "+proj=laea +lon_0=%.8f +lat_0=%.8f +datum=WGS84 +units=m +no_defs +over",
          center_lon, center_lat)
        why <- sprintf("Tall/square extent (width/height %.2f) \u2192 local LAEA", ratio)
      }
      return(list(crs = selected, title = "Custom \u00b7 extent-aware equal area",
                  detail = why))
    }
    stop("Unknown method: ", method)
  }

  sampled_box <- function(extent, sides = 80) {
    lon <- c(seq(extent["box_west"], extent["box_east"], length.out = sides),
             rep(extent["box_east"], sides),
             seq(extent["box_east"], extent["box_west"], length.out = sides),
             rep(extent["box_west"], sides))
    lat <- c(rep(extent["box_south"], sides),
             seq(extent["box_south"], extent["box_north"], length.out = sides),
             rep(extent["box_north"], sides),
             seq(extent["box_north"], extent["box_south"], length.out = sides))
    data.frame(lon = lon, lat = lat, group = 1)
  }

  make_graticule <- function(extent, step = 10, n = 100) {
    west <- extent["west"]; east <- extent["east"]
    south <- extent["south"]; north <- extent["north"]
    lon_lines <- seq(ceiling(west / step) * step, floor(east / step) * step,
                     by = step)
    lat_lines <- seq(ceiling(south / step) * step, floor(north / step) * step,
                     by = step)
    parts <- lapply(seq_along(lon_lines), function(i) {
      data.frame(lon = rep(lon_lines[i], n),
                 lat = seq(south, north, length.out = n),
                 group = paste0("lon", i))
    })
    parts <- c(parts, lapply(seq_along(lat_lines), function(i) {
      data.frame(lon = seq(west, east, length.out = n),
                 lat = rep(lat_lines[i], n), group = paste0("lat", i))
    }))
    do.call(rbind, parts)
  }

  render_method_map <- function(row, method, output) {
    extent <- bbox_extent(row)
    choice <- method_crs(method, row, extent)
    center <- extent["center_lon"]
    world <- project_clipped_world(extent, center, choice$crs)
    box <- sampled_box(extent)
    box_xy <- project_xy(shift_longitude(box$lon, center), box$lat, choice$crs)
    box$x <- box_xy$x; box$y <- box_xy$y
    grid <- make_graticule(extent)
    grid_xy <- project_xy(shift_longitude(grid$lon, center), grid$lat, choice$crs)
    grid$x <- grid_xy$x; grid$y <- grid_xy$y

    lon_lines <- seq(ceiling(extent["west"] / 10) * 10,
                     floor(extent["east"] / 10) * 10, by = 10)
    lat_lines <- seq(ceiling(extent["south"] / 10) * 10,
                     floor(extent["north"] / 10) * 10, by = 10)
    tick_height <- diff(range(c(box$y, grid$y), finite = TRUE)) * 0.02
    tick_width <- diff(range(c(box$x, grid$x), finite = TRUE)) * 0.02

    label_step <- if (extent["east"] - extent["west"] >= 300) {
      60
    } else if (extent["east"] - extent["west"] >= 80) {
      30
    } else if (extent["east"] - extent["west"] >= 60) {
      20
    } else {
      10
    }
    lon_label_lines <- lon_lines[lon_lines %% label_step == 0]
    lon_label_text <- vapply(
      lon_label_lines, format_degrees, character(1), axis = "longitude")
    keep_label <- !duplicated(lon_label_text)
    lon_label_lines <- lon_label_lines[keep_label]
    lon_label_text <- lon_label_text[keep_label]

    lon_tick_xy <- project_xy(
      shift_longitude(lon_lines, center), rep(extent["south"], length(lon_lines)),
      choice$crs)
    longitude_ticks <- data.frame(
      x = lon_tick_xy$x, y = lon_tick_xy$y - tick_height / 2,
      xend = lon_tick_xy$x, yend = lon_tick_xy$y + tick_height / 2
    )
    lon_label_xy <- project_xy(
      shift_longitude(lon_label_lines, center),
      rep(extent["south"], length(lon_label_lines)), choice$crs)
    longitude_labels <- data.frame(
      x = lon_label_xy$x, y = lon_label_xy$y, label = lon_label_text
    )

    # At an exact pole, all longitudes converge to one point and a latitude
    # label would collide with the meridian labels there.
    lat_label_lines <- lat_lines[abs(lat_lines) < 90]
    lat_label_xy <- project_xy(
      shift_longitude(rep(extent["west"], length(lat_label_lines)), center),
      lat_label_lines, choice$crs)
    latitude_labels <- data.frame(
      x = lat_label_xy$x, y = lat_label_xy$y,
      label = vapply(lat_label_lines, format_degrees, character(1),
                     axis = "latitude")
    )
    latitude_ticks <- data.frame(
      x = lat_label_xy$x - tick_width / 2, y = lat_label_xy$y,
      xend = lat_label_xy$x + tick_width / 2, yend = lat_label_xy$y
    )

    allx <- c(box$x, grid$x); ally <- c(box$y, grid$y)
    dx <- diff(range(allx, finite = TRUE)); dy <- diff(range(ally, finite = TRUE))
    left_pad <- max(dx * 0.16, dy * 0.20)
    bottom_pad <- max(dy * 0.08, dx * 0.12)
    lim <- c(xmin = min(allx, na.rm = TRUE) - left_pad,
             xmax = max(allx, na.rm = TRUE) + dx * 0.08,
             ymin = min(ally, na.rm = TRUE) - bottom_pad,
             ymax = max(ally, na.rm = TRUE) + dy * 0.08)
    p <- ggplot2::ggplot(world, ggplot2::aes(x, y, group = group)) +
      ggplot2::geom_polygon(fill = "grey92", colour = "grey65", linewidth = 0.2,
                            na.rm = TRUE) +
      ggplot2::geom_polygon(data = box,
                            ggplot2::aes(x, y, group = group), inherit.aes = FALSE,
                            fill = "#e6550d", alpha = 0.22,
                            colour = "#a63603", linewidth = 0.7, na.rm = TRUE) +
      ggplot2::geom_path(data = grid,
                         ggplot2::aes(x, y, group = group), inherit.aes = FALSE,
                         colour = "#59666d", linewidth = 0.45, alpha = 0.9,
                         na.rm = TRUE) +
      ggplot2::geom_segment(
        data = longitude_ticks,
        ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
        inherit.aes = FALSE, colour = "black", linewidth = 0.8,
        na.rm = TRUE
      ) +
      ggplot2::geom_segment(
        data = latitude_ticks,
        ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
        inherit.aes = FALSE, colour = "black", linewidth = 0.8,
        na.rm = TRUE
      ) +
      ggplot2::geom_text(
        data = longitude_labels,
        ggplot2::aes(x, y, label = label), inherit.aes = FALSE,
        colour = "black", size = 6, vjust = 1.5, na.rm = TRUE
      ) +
      ggplot2::geom_text(
        data = latitude_labels,
        ggplot2::aes(x, y, label = label), inherit.aes = FALSE,
        colour = "black", size = 6, hjust = 1.15, vjust = 1,
        na.rm = TRUE
      ) +
      ggplot2::coord_fixed(xlim = lim[c("xmin", "xmax")],
                           ylim = lim[c("ymin", "ymax")], expand = FALSE) +
      ggplot2::theme_void() +
      ggplot2::theme(plot.margin = ggplot2::margin(4, 4, 4, 4))
    ggplot2::ggsave(output, p, width = 8, height = 5, dpi = 110, bg = "white")
    list(choice = choice, limits = lim)
  }

  encode_png <- function(path) {
    paste0("data:image/png;base64,", base64enc::base64encode(path))
  }

  locator_box <- function(extent, n = 60) {
    west <- extent["box_west"]
    east <- extent["box_east"]
    south <- extent["box_south"]
    north <- extent["box_north"]
    parts <- list()
    cursor <- west
    part <- 1L
    while (cursor < east - 1e-9) {
      wrap <- floor((cursor + 180) / 360)
      edge <- min(east, 180 + 360 * wrap)
      left <- cursor - 360 * wrap
      right <- edge - 360 * wrap
      lon <- c(seq(left, right, length.out = n), rep(right, n),
               seq(right, left, length.out = n), rep(left, n))
      lat <- c(rep(south, n), seq(south, north, length.out = n),
               rep(north, n), seq(north, south, length.out = n))
      parts[[part]] <- data.frame(lon = lon, lat = lat, group = part)
      cursor <- edge
      part <- part + 1L
    }
    do.call(rbind, parts)
  }

  render_equal_earth_locator <- function(row, output) {
    extent <- bbox_extent(row, padding = 0)
    # Keep one fixed world view (projection, central meridian, limits, and size)
    # for every case and method; only the highlighted bbox changes.
    crs <- "+proj=eqearth +lon_0=0 +datum=WGS84 +units=m +no_defs +over"
    world <- world_data
    xy <- project_xy(world$long, world$lat, crs)
    world$x <- xy$x; world$y <- xy$y
    path <- locator_box(extent)
    boxxy <- project_xy(path$lon, path$lat, crs)
    path$x <- boxxy$x; path$y <- boxxy$y
    lim <- c(xmin = min(world$x, na.rm = TRUE), xmax = max(world$x, na.rm = TRUE),
             ymin = min(world$y, na.rm = TRUE), ymax = max(world$y, na.rm = TRUE))
    p <- ggplot2::ggplot(world, ggplot2::aes(x, y, group = group)) +
      ggplot2::geom_polygon(fill = "grey92", colour = "grey65", linewidth = 0.15,
                            na.rm = TRUE) +
      ggplot2::geom_polygon(data = path,
                            ggplot2::aes(x, y, group = group), inherit.aes = FALSE,
                            fill = "#e6550d", alpha = 0.35,
                            colour = "#a63603", linewidth = 0.45, na.rm = TRUE) +
      ggplot2::coord_fixed(xlim = lim[c("xmin", "xmax")],
                           ylim = lim[c("ymin", "ymax")], expand = FALSE) +
      ggplot2::theme_void() +
      ggplot2::theme(panel.border = ggplot2::element_rect(
        fill = NA, colour = "grey50", linewidth = 0.4),
        plot.margin = ggplot2::margin(2, 2, 2, 2))
    ggplot2::ggsave(output, p, width = 3.2, height = 2.1, dpi = 110, bg = "white")
    invisible(p)
  }

  methods <- c("equal-earth", "crsuggest", "projWiz", "custom")
  method_ids <- sprintf("m%02d", seq_along(methods))
  method_labels <- c("Equal Earth", "crsuggest top-ranked CRS",
                     "projWiz equal-area selection", "Custom extent-aware equal-area")
  method_descriptions <- c(
    "Equal Earth projection for the main map, centered on the bounding-box midpoint.",
    "The first projected CRS returned by crsuggest::suggest_crs() for the extent; the EPSG suggestion is used as returned.",
    "projWiz::proj_region(property = 'Equal area'); dateline extents are recentered for selection, and unsupported extents are marked with an Equal Earth fallback.",
    "Prototype rule: pole-centered LAEA for single-hemisphere polar extents; Equal Earth for broad non-polar global extents; local LAEA below 1,000 km; Albers equal-area conic for wide mid-latitude extents; local LAEA otherwise.")
  method_table <- paste(vapply(seq_along(methods), function(j) sprintf(
    '<tr><th scope="row" class="identifier">%s</th><td>%s</td><td>%s</td></tr>',
    method_ids[j], htmltools::htmlEscape(method_labels[j]),
    htmltools::htmlEscape(method_descriptions[j])), character(1)), collapse = "")
  method_views <- vector("list", nrow(bbox_cases))
  grid_thumbs <- character(nrow(bbox_cases))
  grid_projections <- character(nrow(bbox_cases))
  locator_uris <- character(nrow(bbox_cases))

  for (i in seq_len(nrow(bbox_cases))) {
    inset_path <- tempfile(fileext = ".png")
    render_equal_earth_locator(bbox_cases[i, ], inset_path)
    locator_uris[i] <- encode_png(inset_path)
    unlink(inset_path)
  }

  for (j in seq_along(methods)) {
    method <- methods[j]
    for (i in seq_len(nrow(bbox_cases))) {
      row <- bbox_cases[i, ]
      map_path <- tempfile(fileext = ".png")
      rendered <- tryCatch({
        result <- render_method_map(row, method, map_path)
        list(uri = encode_png(map_path), note = result$choice$detail,
             crs = result$choice$crs)
      }, error = function(e) {
        list(uri = NULL, note = paste(
          "Projection method could not handle this extent:",
          conditionMessage(e)), crs = NULL)
      })
      map_uri <- rendered$uri
      note <- rendered$note
      projection_label <- if (is.null(map_uri)) {
        "Equal Earth (visualization fallback)"
      } else if (method == "crsuggest") {
        note
      } else {
        rendered$crs
      }
      if (file.exists(map_path)) unlink(map_path)
      if (is.null(map_uri)) {
        # Keep every case visible while clearly identifying unsupported extents.
        fallback <- tempfile(fileext = ".png")
        render_method_map(row, "equal-earth", fallback)
        map_uri <- encode_png(fallback)
        unlink(fallback)
        note <- paste(note, "Displayed map uses an Equal Earth visualization fallback.")
      }
      if (j == 1) {
        grid_thumbs[i] <- map_uri
        grid_projections[i] <- projection_label
      }
      active <- if (j == 1) " active" else ""
      method_views[[i]][j] <- sprintf(
        '<div class="method-view%s" data-method="%s"><h3>Figure %s \u00b7 %s \u2014 %s</h3><p class="method-note">%s</p><div class="map-wrap"><img class="main-map" data-projection="%s" src="%s" alt="%s map for %s"><img class="inset" src="%s" alt="Equal Earth world locator"></div></div>',
        active, method_ids[j], row$example_id, method_ids[j],
        htmltools::htmlEscape(method_labels[j]), htmltools::htmlEscape(note),
        htmltools::htmlEscape(projection_label), map_uri,
        paste("Figure", row$example_id, method_ids[j], method_labels[j]),
        htmltools::htmlEscape(row$label), locator_uris[i])
    }
  }

  method_buttons <- vapply(seq_along(methods), function(j) sprintf(
    '<button class="method-tab%s" data-method="%s" data-label="%s"><span class="identifier">%s</span> %s</button>',
    if (j == 1) " active" else "", method_ids[j],
    htmltools::htmlEscape(method_labels[j]), method_ids[j],
    htmltools::htmlEscape(method_labels[j])), character(1))

  example_grid <- vapply(seq_len(nrow(bbox_cases)), function(i) sprintf(
    '<a class="grid-item" href="#example-%s"><img data-example-id="%s" src="%s" alt=""><span><b class="identifier">%s</b> %s</span><span class="grid-projection">%s</span></a>',
    bbox_cases$example_id[i], bbox_cases$example_id[i], grid_thumbs[i],
    bbox_cases$example_id[i], htmltools::htmlEscape(bbox_cases$label[i]),
    htmltools::htmlEscape(grid_projections[i])), character(1))

  details <- vapply(seq_len(nrow(bbox_cases)), function(i) sprintf(
    '<article class="case-detail" id="example-%s" data-example-id="%s"><h2><span class="identifier">%s</span> \u2014 %s</h2><p class="bbox"><code>north=%s, east=%s, south=%s, west=%s</code> \u00b7 center %s\u00b0 \u00b7 %s</p><a class="back-to-grid" href="#example-grid">Back to example grid \u2191</a>%s</article>',
    bbox_cases$example_id[i], bbox_cases$example_id[i], bbox_cases$example_id[i],
    htmltools::htmlEscape(bbox_cases$label[i]), bbox_cases$north[i],
    bbox_cases$east[i], bbox_cases$south[i], bbox_cases$west[i],
    bbox_cases$center_lat[i], htmltools::htmlEscape(bbox_cases$case[i]),
    paste(method_views[[i]], collapse = "\n")), character(1))

  # Projection selector precedes the catalogue and updates both the grid previews
  # and all detailed figures. Grid links use native fragment navigation for Back.
  page <- paste0(
    '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Static map projection comparison for dataspice</title><style>',
    'body{font:16px/1.55 system-ui,-apple-system,sans-serif;max-width:1120px;margin:2rem auto;padding:0 1.25rem;color:#20252b}h1,h2,h3{line-height:1.25;color:#152536}h1{font-size:2rem;margin-bottom:.2rem}.subtitle{color:#53616d;margin-top:0}.report-section{margin:1.8rem 0}.abstract{border-left:4px solid #315a78;background:#f4f7f9;padding:.9rem 1.1rem}.abstract h2{font-size:1.1rem;margin:.1rem 0 .35rem}.method-table{width:100%;border-collapse:collapse;margin:1rem 0}.method-table th,.method-table td{border:1px solid #d4dbe0;padding:.6rem .7rem;text-align:left;vertical-align:top}.method-table thead{background:#edf1f4}.method-table tbody th{white-space:nowrap}.identifier{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-weight:700;color:#254f70}.example-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:.8rem;margin:1rem 0 2rem}.grid-item{display:flex;flex-direction:column;gap:.35rem;padding:.55rem;border:1px solid #d4dbe0;border-radius:4px;color:inherit;text-decoration:none;background:#fff}.grid-item:hover,.grid-item:focus{border-color:#567;background:#f7f9fb}.grid-item img{width:100%;height:120px;object-fit:contain;background:#fff}.grid-item span{font-size:.9rem}.grid-projection{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:.72rem!important;overflow-wrap:anywhere;color:#53616d}.method-tabs{position:sticky;top:0;z-index:20;display:flex;flex-wrap:wrap;gap:.35rem;border-bottom:1px solid #aeb9c2;margin:1rem 0;padding:.5rem 0;background:#fff}.method-tab{border:1px solid #aeb9c2;background:#f3f5f6;border-radius:3px;padding:.55rem .8rem;cursor:pointer}.method-tab.active{background:#e5edf3;border-color:#315a78;font-weight:700}.method-view{display:none}.method-view.active{display:block}.case-detail{scroll-margin-top:5rem;padding:1.2rem 0 1.8rem;border-bottom:1px solid #d4dbe0}.case-detail h2{font-size:1.35rem;margin:.25rem 0}.method-view h3{font-size:1.05rem;font-weight:600;margin:.9rem 0 .4rem}.bbox,.figure-note{color:#45525e}.back-to-grid{display:inline-block;margin:.2rem 0 .7rem;font-size:.9rem}.method-note{font-size:.93rem;color:#333;background:#f4f6f7;padding:.65rem;border-left:3px solid #789;overflow-wrap:anywhere}.map-wrap{position:relative;min-height:420px;display:flex;align-items:center;justify-content:center;border:1px solid #d4dbe0;background:white}.main-map{max-width:100%;max-height:480px;width:auto;height:auto}.inset{position:absolute;right:.5rem;top:.5rem;width:24%;max-width:260px;border:1px solid #777;background:white}.small-note{font-size:.9rem;color:#53616d}.method-tabs-label{font-weight:600;margin-bottom:.2rem}',
    paste0('</style></head><body><header><h1>Static map projection comparison</h1><p class="subtitle">Dataspice metadata reports \u00b7 Projection-selection prototype \u00b7 ', extent_count, ' test extents</p></header>'),
    sprintf('<section class="abstract"><h2>Abstract</h2><p>Archived dataspice HTML reports can lose their interactive maps when browser restrictions or OpenStreetMap tile-policy blocks prevent Leaflet tiles from loading. This report compares four static-map projection strategies across %d bounding boxes, using a shared map background, coverage outline, graticule, and Equal Earth locator inset. This research addresses <a href="https://github.com/ropensci/dataspice/issues/123">dataspice issue #123</a>; map images are embedded for offline viewing.</p></section>', extent_count),
    paste0('<section class="report-section"><h2>Methods</h2><p>Every main map uses the same world geometry and coverage box, plus a 10\u00b0 latitude/longitude graticule with labeled ticks, with longitude labels thinned for broad extents and exact-pole labels omitted where meridians converge; the inset uses a fixed Equal Earth view. The selector below changes the grid previews and all detailed maps together. IDs <span class="identifier">', extent_id_range, '</span> identify test extents; <span class="identifier">m01\u2013m04</span> identify projection methods.</p><table class="method-table"><thead><tr><th>ID</th><th>Method</th><th>Selection rule</th></tr></thead><tbody>'),
    method_table,
    '</tbody></table></section>',
    '<p class="method-tabs-label">Select main-map projection method</p><nav class="method-tabs" aria-label="Projection method">',
    paste(method_buttons, collapse = ""), '</nav>',
    '<section class="report-section" id="example-grid"><h2>Test extent catalogue</h2><p class="small-note">Select a thumbnail to jump to its detailed figure. Browser Back returns to the catalogue.</p><div class="example-grid">',
    paste(example_grid, collapse = "\n"), '</div></section>',
    '<section class="report-section"><h2>Detailed figures</h2>',
    paste(details, collapse = "\n"), '</section>',
    '<script>document.querySelectorAll(".method-tab").forEach(b=>b.addEventListener("click",()=>{const method=b.dataset.method;document.querySelectorAll(".method-tab").forEach(x=>x.classList.remove("active"));document.querySelectorAll(".method-view").forEach(x=>x.classList.toggle("active",x.dataset.method===method));b.classList.add("active");document.querySelectorAll(".grid-item").forEach(item=>{const img=item.querySelector("img");const detail=Array.from(document.querySelectorAll(".case-detail")).find(x=>x.dataset.exampleId===img.dataset.exampleId);const view=Array.from(detail.querySelectorAll(".method-view")).find(x=>x.dataset.method===method);const map=view.querySelector(".main-map");img.src=map.src;item.querySelector(".grid-projection").textContent=map.dataset.projection})}));</script>',
    '</body></html>')
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  writeLines(page, output_file)
  message("Wrote ", normalizePath(output_file, mustWork = TRUE))
  invisible(normalizePath(output_file, mustWork = TRUE))
}
