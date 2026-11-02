# Transform longitude/latitude coordinates with sf/PROJ and preserve NA breaks.
# Projection definitions are CRS strings selected by the comparison methods;
# sf::st_transform() delegates the actual projection mathematics to PROJ.
project_xy <- function(lon, lat, crs) {
  out_x <- rep(NA_real_, length(lon))
  out_y <- rep(NA_real_, length(lat))
  keep <- is.finite(lon) & is.finite(lat)

  if (any(keep)) {
    points <- sf::st_as_sf(
      data.frame(lon = lon[keep], lat = lat[keep]),
      coords = c("lon", "lat"), crs = 4326)
    transformed <- sf::st_coordinates(
      sf::st_transform(points, sf::st_crs(crs)))
    out_x[keep] <- transformed[, 1]
    out_y[keep] <- transformed[, 2]
  }

  data.frame(x = out_x, y = out_y)
}
