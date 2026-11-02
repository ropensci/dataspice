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
