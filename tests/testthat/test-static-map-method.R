test_that("static-map projection methods return usable CRS definitions", {
  bbox <- list(
    west = -171,
    east_continuous = -131,
    south = 47,
    north = 78,
    center = -151,
    span = 40
  )

  equalearth <- static_map_crs(
    "equalearth", bbox$west, bbox$east_continuous, bbox$south,
    bbox$north, bbox$center, bbox$span
  )
  expect_match(equalearth, "\\+proj=eqearth")
  expect_false(is.na(sf::st_crs(equalearth)))

  custom <- "+proj=laea +lon_0=-151 +lat_0=62 +datum=WGS84 +units=m +no_defs"
  expect_identical(
    static_map_crs("+proj=laea +lon_0=-151 +lat_0=62 +datum=WGS84 +units=m +no_defs",
                   bbox$west, bbox$east_continuous, bbox$south,
                   bbox$north, bbox$center, bbox$span),
    custom
  )
  expect_false(is.na(sf::st_crs(custom)))
})

test_that("static maps render when the extent has no 10-degree graticule lines", {
  uri <- static_map_data_uri("45.7 -122.6 45.4 -122.8")
  expect_match(uri, "^data:image/png;base64,")
})

test_that("default method uses the built-in extent-aware projection rules", {
  alaska <- static_map_crs(
    "default", west = -171, east_continuous = -131, south = 47,
    north = 78, center = -151, span = 40
  )
  expect_match(alaska, "\\+proj=laea")

  wide_midlatitude <- static_map_crs(
    "default", west = 5.1, east_continuous = 20.2, south = 49.9,
    north = 52, center = 12.65, span = 15.1
  )
  expect_match(wide_midlatitude, "\\+proj=aea")

  north_pole <- static_map_crs(
    "default", west = -90, east_continuous = 90, south = 75,
    north = 85, center = 0, span = 180
  )
  expect_match(north_pole, "\\+proj=laea")
  expect_match(north_pole, "\\+lat_0=90")
})

test_that("optional CRS selectors produce valid projections", {
  bbox <- list(
    west = -171,
    east_continuous = -131,
    south = 47,
    north = 78,
    center = -151,
    span = 40
  )

  skip_if_not_installed("crsuggest")
  crsuggest_crs <- static_map_crs(
    "crsuggest", bbox$west, bbox$east_continuous, bbox$south,
    bbox$north, bbox$center, bbox$span
  )
  expect_false(is.na(sf::st_crs(crsuggest_crs)))

  skip_if_not_installed("projWiz")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  projwiz_crs <- static_map_crs(
    "projwiz", bbox$west, bbox$east_continuous, bbox$south,
    bbox$north, bbox$center, bbox$span
  )
  expect_false(is.na(sf::st_crs(projwiz_crs)))
})
