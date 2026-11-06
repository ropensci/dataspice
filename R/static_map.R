# Transform longitude/latitude coordinate pairs using sf/PROJ.
utils::globalVariables(c("x", "y", "group", "label"))

parse_static_map_box <- function(box) {
  if (inherits(box, "static_map_bbox")) return(box)

  if (!is.character(box) || length(box) != 1L || is.na(box) ||
      !nzchar(trimws(box))) {
    stop("`box` must contain four finite values: north east south west.",
         call. = FALSE)
  }

  coordinates <- as.numeric(strsplit(trimws(box), "\\s+")[[1]])
  if (length(coordinates) != 4L || any(!is.finite(coordinates))) {
    stop("`box` must contain four finite values: north east south west.",
         call. = FALSE)
  }

  north <- coordinates[1]
  east <- coordinates[2]
  south <- coordinates[3]
  west <- coordinates[4]
  if (north <= south || north > 90 || south < -90 ||
      any(c(east, west) < -180 | c(east, west) > 180)) {
    stop("`box` must have valid latitude and longitude bounds.", call. = FALSE)
  }

  span <- if (east < west) east + 360 - west else east - west
  if (span <= 0 || span > 360) {
    stop("`box` must have a positive longitude span no greater than 360 degrees.",
         call. = FALSE)
  }
  structure(list(
    north = north,
    east = east,
    south = south,
    west = west,
    span = span,
    east_continuous = west + span,
    center = ((west + span / 2 + 180) %% 360) - 180
  ), class = "static_map_bbox")
}

project_map_coordinates <- function(lon, lat, crs) {
  x <- rep(NA_real_, length(lon))
  y <- rep(NA_real_, length(lat))
  keep <- is.finite(lon) & is.finite(lat)

  if (any(keep)) {
    points <- sf::st_as_sf(
      data.frame(lon = lon[keep], lat = lat[keep]),
      coords = c("lon", "lat"), crs = 4326)
    transformed <- sf::st_coordinates(
      sf::st_transform(points, sf::st_crs(crs)))
    x[keep] <- transformed[, 1]
    y[keep] <- transformed[, 2]
  }

  data.frame(x = x, y = y)
}

static_map_crs <- function(method, west, east_continuous, south, north,
                           center, span) {
  if (identical(method, "equalearth")) {
    return(sprintf(
      "+proj=eqearth +lon_0=%.8f +datum=WGS84 +units=m +no_defs +over",
      center))
  }

  if (identical(method, "default")) {
    center_lat <- (south + north) / 2
    lat_span <- north - south
    width_km <- 111.195 * span * max(0.05, cos(center_lat * pi / 180))
    height_km <- 111.195 * lat_span
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
      return(sprintf(
        paste0("+proj=laea +lon_0=%.8f +lat_0=%.8f ",
               "+datum=WGS84 +units=m +no_defs +over"),
        center, polar_lat))
    }
    if (span >= 160 || (north >= 75 && south <= -75)) {
      return(sprintf(
        "+proj=eqearth +lon_0=%.8f +datum=WGS84 +units=m +no_defs +over",
        center))
    }
    if (max(width_km, height_km) < 1000) {
      return(sprintf(
        paste0("+proj=laea +lon_0=%.8f +lat_0=%.8f ",
               "+datum=WGS84 +units=m +no_defs +over"),
        center, center_lat))
    }
    if (ratio >= 1.25 && abs(center_lat) < 75 &&
        !(south < 0 && north > 0)) {
      return(sprintf(
        paste0("+proj=aea +lon_0=%.8f +lat_0=%.8f +lat_1=%.8f ",
               "+lat_2=%.8f +datum=WGS84 +units=m +no_defs +over"),
        center, center_lat, south + lat_span / 6, north - lat_span / 6))
    }
    return(sprintf(
      paste0("+proj=laea +lon_0=%.8f +lat_0=%.8f ",
             "+datum=WGS84 +units=m +no_defs +over"),
      center, center_lat))
  }

  if (startsWith(method, "+proj=")) {
    if (is.na(sf::st_crs(method))) {
      stop("`static_map_method` is not a valid PROJ string.", call. = FALSE)
    }
    return(method)
  }

  crossing_antimeridian <- east_continuous > 180 || west < -180
  selection_west <- west
  selection_east <- east_continuous
  if (crossing_antimeridian) {
    selection_west <- -span / 2
    selection_east <- span / 2
  }

  if (identical(method, "crsuggest")) {
    coords <- rbind(c(selection_west, south), c(selection_east, south),
                    c(selection_east, north), c(selection_west, north),
                    c(selection_west, south))
    area <- sf::st_sfc(sf::st_polygon(list(coords)), crs = 4326)
    suggestion <- crsuggest::suggest_crs(
      area, type = "projected", limit = 1)
    if (!nrow(suggestion)) {
      stop("crsuggest returned no projected CRS for this extent.",
           call. = FALSE)
    }
    code <- as.character(suggestion$crs_code[1])
    crs <- sf::st_crs(paste0("EPSG:", code))
    if (is.na(crs)) {
      crs <- sf::st_crs(suggestion$crs_proj4[1])
    }
    if (is.na(crs)) {
      stop("crsuggest returned a CRS that sf could not read.", call. = FALSE)
    }
    selected <- crs$proj4string
    if (crossing_antimeridian) {
      selected <- sub("\\+lon_0=[^ ]+", paste0("+lon_0=", center), selected)
      if (!grepl("\\+lon_0=", selected)) {
        selected <- paste(selected, paste0("+lon_0=", center))
      }
    }
    return(paste(selected, "+over"))
  }

  stop("Unknown static-map projection method: ", method, call. = FALSE)
}

static_map_data_uri <- function(box, method = "default",
                                width = 8, height = 5, dpi = 110) {
  bbox <- parse_static_map_box(box)
  north <- bbox$north
  east <- bbox$east
  south <- bbox$south
  west <- bbox$west
  span <- bbox$span
  east_continuous <- bbox$east_continuous
  center <- bbox$center
  shift_longitude <- function(lon) {
    center + ((lon - center + 180) %% 360) - 180
  }
  crs <- static_map_crs(method, west, east_continuous, south, north,
                         center, span)

  world <- ggplot2::map_data("world")
  world$lon <- shift_longitude(world$long)
  segments <- stats::ave(world$lon, world$group, FUN = function(x) {
    cumsum(c(0L, as.integer(abs(diff(x)) > 180))) + 1L
  })
  world$group <- interaction(world$group, segments, drop = TRUE)
  world_xy <- project_map_coordinates(world$lon, world$lat, crs)
  world$x <- world_xy$x
  world$y <- world_xy$y

  sides <- 80L
  box_lon <- c(seq(west, east_continuous, length.out = sides),
               rep(east_continuous, sides),
               seq(east_continuous, west, length.out = sides),
               rep(west, sides))
  box_lat <- c(rep(south, sides),
               seq(south, north, length.out = sides),
               rep(north, sides),
               seq(north, south, length.out = sides))
  box_xy <- project_map_coordinates(shift_longitude(box_lon), box_lat, crs)
  coverage <- data.frame(box_xy, group = 1)

  step <- 10
  longitude_start <- ceiling(west / step) * step
  longitude_end <- floor(east_continuous / step) * step
  latitude_start <- ceiling(south / step) * step
  latitude_end <- floor(north / step) * step
  longitude_lines <- if (longitude_start <= longitude_end) {
    seq(longitude_start, longitude_end, by = step)
  } else {
    numeric()
  }
  latitude_lines <- if (latitude_start <= latitude_end) {
    seq(latitude_start, latitude_end, by = step)
  } else {
    numeric()
  }
  graticule <- c(
    lapply(seq_along(longitude_lines), function(i) {
      data.frame(lon = rep(longitude_lines[i], 100),
                 lat = seq(south, north, length.out = 100),
                 group = paste0("lon", i))
    }),
    lapply(seq_along(latitude_lines), function(i) {
      data.frame(lon = seq(west, east_continuous, length.out = 100),
                 lat = rep(latitude_lines[i], 100),
                 group = paste0("lat", i))
    })
  )
  graticule <- if (length(graticule)) {
    do.call(rbind, graticule)
  } else {
    data.frame(lon = numeric(), lat = numeric(), group = character())
  }
  grid_xy <- project_map_coordinates(shift_longitude(graticule$lon),
                                     graticule$lat, crs)
  graticule$x <- grid_xy$x
  graticule$y <- grid_xy$y

  format_degrees <- function(value, axis) {
    if (axis == "longitude") {
      value <- ((value + 180) %% 360) - 180
      suffix <- if (value < 0) "W" else if (value > 0) "E" else ""
    } else {
      suffix <- if (value < 0) "S" else if (value > 0) "N" else ""
    }
    paste0(format(abs(value), trim = TRUE, scientific = FALSE), "\u00b0", suffix)
  }
  longitude_labels <- data.frame(
    lon = longitude_lines,
    lat = rep(south, length(longitude_lines)),
    label = vapply(longitude_lines, format_degrees, character(1),
                   axis = "longitude")
  )
  longitude_label_xy <- project_map_coordinates(
    shift_longitude(longitude_labels$lon), longitude_labels$lat, crs)
  longitude_labels$x <- longitude_label_xy$x
  longitude_labels$y <- longitude_label_xy$y

  latitude_labels <- data.frame(
    lon = rep(west, length(latitude_lines)),
    lat = latitude_lines,
    label = vapply(latitude_lines, format_degrees, character(1),
                   axis = "latitude")
  )
  latitude_label_xy <- project_map_coordinates(
    shift_longitude(latitude_labels$lon), latitude_labels$lat, crs)
  latitude_labels$x <- latitude_label_xy$x
  latitude_labels$y <- latitude_label_xy$y

  all_x <- c(coverage$x, graticule$x)
  all_y <- c(coverage$y, graticule$y)
  dx <- diff(range(all_x, finite = TRUE))
  dy <- diff(range(all_y, finite = TRUE))
  limits <- c(
    xmin = min(all_x, na.rm = TRUE) - dx * 0.08,
    xmax = max(all_x, na.rm = TRUE) + dx * 0.08,
    ymin = min(all_y, na.rm = TRUE) - dy * 0.08,
    ymax = max(all_y, na.rm = TRUE) + dy * 0.08
  )

  locator_crs <- "+proj=eqearth +lon_0=0 +datum=WGS84 +units=m +no_defs +over"
  locator_world <- ggplot2::map_data("world")
  locator_xy <- project_map_coordinates(locator_world$long, locator_world$lat,
                                        locator_crs)
  locator_world$x <- locator_xy$x
  locator_world$y <- locator_xy$y

  locator_box <- list()
  cursor <- west
  while (cursor < east_continuous) {
    wrap <- floor((cursor + 180) / 360)
    edge <- min(east_continuous, 180 + 360 * wrap)
    left <- cursor - 360 * wrap
    right <- edge - 360 * wrap
    locator_box[[length(locator_box) + 1L]] <- data.frame(
      lon = c(seq(left, right, length.out = sides), rep(right, sides),
              seq(right, left, length.out = sides), rep(left, sides)),
      lat = c(rep(south, sides), seq(south, north, length.out = sides),
              rep(north, sides), seq(north, south, length.out = sides)),
      group = length(locator_box) + 1L
    )
    cursor <- edge
  }
  locator_box <- do.call(rbind, locator_box)
  locator_box_xy <- project_map_coordinates(locator_box$lon, locator_box$lat,
                                            locator_crs)
  locator_box$x <- locator_box_xy$x
  locator_box$y <- locator_box_xy$y

  locator_x <- range(locator_world$x, finite = TRUE)
  locator_y <- range(locator_world$y, finite = TRUE)
  locator_plot <- ggplot2::ggplot(
    locator_world, ggplot2::aes(x, y, group = group)) +
    ggplot2::geom_polygon(fill = "grey92", colour = "grey65", linewidth = 0.15,
                          na.rm = TRUE) +
    ggplot2::geom_polygon(data = locator_box,
                          ggplot2::aes(x, y, group = group), inherit.aes = FALSE,
                          fill = "#e6550d", alpha = 0.35,
                          colour = "#a63603", linewidth = 0.35, na.rm = TRUE) +
    ggplot2::coord_fixed(xlim = locator_x, ylim = locator_y, expand = FALSE) +
    ggplot2::theme_void() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = "white", colour = "grey45",
                                                linewidth = 0.4),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.margin = grid::unit(c(1, 1, 1, 1), "mm")
    )

  plot <- ggplot2::ggplot(world, ggplot2::aes(x, y, group = group)) +
    ggplot2::geom_polygon(fill = "grey92", colour = "grey65", linewidth = 0.2,
                          na.rm = TRUE) +
    ggplot2::geom_polygon(data = coverage,
                          ggplot2::aes(x, y, group = group), inherit.aes = FALSE,
                          fill = "#e6550d", alpha = 0.22,
                          colour = "#a63603", linewidth = 0.7, na.rm = TRUE) +
    ggplot2::geom_path(data = graticule,
                       ggplot2::aes(x, y, group = group), inherit.aes = FALSE,
                       colour = "#59666d", linewidth = 0.45, alpha = 0.9,
                       na.rm = TRUE) +
    ggplot2::geom_text(
      data = longitude_labels,
      ggplot2::aes(x, y, label = label), inherit.aes = FALSE,
      colour = "black", size = 6, vjust = 1.5, na.rm = TRUE
    ) +
    ggplot2::geom_text(
      data = latitude_labels,
      ggplot2::aes(x, y, label = label), inherit.aes = FALSE,
      colour = "black", size = 6, hjust = 1.15, na.rm = TRUE
    ) +
    ggplot2::coord_fixed(xlim = limits[c("xmin", "xmax")],
                         ylim = limits[c("ymin", "ymax")], expand = FALSE) +
    ggplot2::annotation_custom(
      ggplot2::ggplotGrob(locator_plot),
      xmin = limits[["xmax"]] - dx * 0.31,
      xmax = limits[["xmax"]] - dx * 0.02,
      ymin = limits[["ymax"]] - dy * 0.24,
      ymax = limits[["ymax"]] - dy * 0.02
    ) +
    ggplot2::theme_void()

  path <- tempfile(fileext = ".png")
  on.exit(unlink(path), add = TRUE)
  ggplot2::ggsave(path, plot, width = width, height = height, dpi = dpi,
                  bg = "white")
  paste0("data:image/png;base64,", base64enc::base64encode(path))
}
