# ggplot2 static-map renderer. The output is a self-contained data URI suitable
# for an <img>.

utils::globalVariables(c("long", "lat", "group"))

# Schema.org GeoShape box order: north, east, south, west.
normalize_bbox <- function(box) {
  values <- as.numeric(strsplit(box, "\\s+")[[1]])
  stopifnot(length(values) == 4L, all(is.finite(values)))
  c(north = values[1], east = values[2], south = values[3], west = values[4])
}

bbox_limits <- function(bbox, padding = 0.08) {
  dx <- bbox["east"] - bbox["west"]
  dy <- bbox["north"] - bbox["south"]
  if (dx <= 0 || dy <= 0) stop("Antimeridian-crossing or empty boxes need handling")
  c(xmin = max(-180, bbox["west"] - dx * padding),
    xmax = min(180, bbox["east"] + dx * padding),
    ymin = max(-90, bbox["south"] - dy * padding),
    ymax = min(90, bbox["north"] + dy * padding))
}

# Shared image/data-URI writer. Plot callback draws the main map and inset.
write_map_data_uri <- function(draw, width = 1200, height = 760, res = 144) {
  path <- tempfile(fileext = ".png")
  on.exit(unlink(path))
  grDevices::png(path, width = width, height = height, res = res,
                 bg = "white")
  device <- grDevices::dev.cur()
  closed <- FALSE
  on.exit({
    if (!closed && grDevices::dev.cur() == device) grDevices::dev.off()
    unlink(path)
  })
  draw()
  grDevices::dev.off()
  closed <- TRUE
  paste0("data:image/png;base64,", base64enc::base64encode(path))
}

# ggplot2 draws the main and locator maps from its map_data() interface. The
# locator is drawn in a grid viewport, avoiding a layout-package dependency.
static_map_ggplot <- function(box) {
  if (!requireNamespace("maps", quietly = TRUE)) {
    stop("Install the 'maps' package to provide world map data.", call. = FALSE)
  }
  bbox <- normalize_bbox(box)
  lim <- bbox_limits(bbox)
  world <- ggplot2::map_data("world")
  main <- ggplot2::ggplot(world, ggplot2::aes(long, lat, group = group)) +
    ggplot2::geom_polygon(fill = "grey92", colour = "grey65", linewidth = 0.2) +
    ggplot2::annotate("rect", xmin = bbox["west"], xmax = bbox["east"],
                      ymin = bbox["south"], ymax = bbox["north"],
                      fill = "#e6550d", alpha = 0.22,
                      colour = "#a63603", linewidth = 0.7) +
    ggplot2::coord_quickmap(xlim = lim[c("xmin", "xmax")],
                            ylim = lim[c("ymin", "ymax")], expand = FALSE) +
    ggplot2::theme_void() +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white"))
  locator <- ggplot2::ggplot(world, ggplot2::aes(long, lat, group = group)) +
    ggplot2::geom_polygon(fill = "grey92", colour = "grey65", linewidth = 0.1) +
    ggplot2::annotate("rect", xmin = bbox["west"], xmax = bbox["east"],
                      ymin = bbox["south"], ymax = bbox["north"],
                      fill = "#e6550d", alpha = 0.35,
                      colour = "#a63603", linewidth = 0.3) +
    ggplot2::coord_quickmap(xlim = c(-180, 180), ylim = c(-90, 90),
                            expand = FALSE) +
    ggplot2::theme_void() +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white"),
                   panel.border = ggplot2::element_rect(fill = NA,
                                                        colour = "grey50"))
  write_map_data_uri(function() {
    grid::grid.newpage()
    print(main, vp = grid::viewport(x = 0.5, y = 0.5, width = 0.96,
                                    height = 0.94))
    print(locator, vp = grid::viewport(x = 0.84, y = 0.81, width = 0.27,
                                      height = 0.27))
  })
}

# Example: Alaska box from inst/examples/annual-escapement.json.
# ggplot_uri <- static_map_ggplot("78 -131 47 -171")
