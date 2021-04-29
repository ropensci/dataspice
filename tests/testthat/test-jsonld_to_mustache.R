context("jsonld_to_mustache")

test_that("templating a GeoShape_points errors", {
  expect_error(parse_GeoShape_points())
})

test_that("parsingn a GeoShape_box errors on bad data", {
  expect_error(parse_GeoShape_box(NULL))
})

test_that(
  paste(
    "parse_spatialCoverage fails when a",
    "non-shape/non-points coverage is passed in"
  ),
  {
    expect_error(parse_spatialCoverage(list("geo" = list("type" = "GeoFoo"))))
  }
)

test_that("parse_spatialCoverage fails to parse GeoPoints", {
  expect_error(parse_spatialCoverage(list("geo" = list("type" = "GeoPoints"))))
})
