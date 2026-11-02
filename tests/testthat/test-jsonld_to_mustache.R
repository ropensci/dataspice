context("jsonld_to_mustache")

test_that("templating a GeoShape_points errors", {
  expect_error(parse_GeoShape_points())
})

test_that("parsingn a GeoShape_box errors on bad data", {
  expect_error(parse_GeoShape_box(NULL))
})

test_that("spatial coverage properties are converted to table rows", {
  box <- parse_spatialCoverage(list(
    name = "Study area",
    geo = list(type = "GeoShape", box = "-10 -20 10 20")
  ))
  expect_equal(vapply(box$spatialCoverageRows, `[[`, character(1), "label"),
               c("Name", "Geo / Type", "Geo / Box"))
  expect_equal(vapply(box$spatialCoverageRows, `[[`, character(1), "value"),
               c("Study area", "GeoShape", "-10 -20 10 20"))
  expect_equal(box$mapbox, "-10 -20 10 20")
  expect_equal(box$mappolystring, "[[ -10, -20], [ 10, -20], [ 10, 20], [ -10, 20]]")

  coordinates <- parse_spatialCoverage(list(geo = list(
    `@type` = "GeoCoordinates", latitude = 42, longitude = -71
  )))
  expect_equal(vapply(coordinates$spatialCoverageRows, `[[`, character(1), "label"),
               c("Geo / @type", "Geo / Latitude", "Geo / Longitude"))
  expect_equal(coordinates$mappolystring, "[]")

  shape <- parse_spatialCoverage(list(geo = list(
    type = "GeoShape", circle = "42 -71 5", polygon = "1,2 3,4"
  )))
  expect_equal(vapply(shape$spatialCoverageRows, `[[`, character(1), "label"),
               c("Geo / Type", "Geo / Circle", "Geo / Polygon"))
  expect_equal(shape$mappolystring, "[]")

  unknown <- parse_spatialCoverage(list(geo = list(type = "GeoFoo", area = "somewhere")))
  expect_equal(vapply(unknown$spatialCoverageRows, `[[`, character(1), "value"),
               c("GeoFoo", "somewhere"))
  expect_equal(unknown$mappolystring, "[]")
})

test_that("missing and multiple spatial coverage values are handled", {
  expect_equal(parse_spatialCoverage(NULL)$spatialCoverageRows,
               list(list(label = "Coverage", value = "No spatial coverage specified.")))
  many <- parse_spatialCoverage(list(
    list(name = "North", geo = list(type = "GeoShape", box = "1 2 3 4")),
    list(name = "South", geo = list(type = "GeoShape", box = "-4 -3 -2 -1"))
  ))
  many_values <- vapply(many$spatialCoverageRows, `[[`, character(1), "value")
  expect_true(any(grepl("North", many_values)))
  expect_true(any(grepl("South", many_values)))
  expect_equal(many$mappolystring, "[]")
})

test_that("HTML shows the spatial coverage table and map with or without a supported shape", {
  json_path <- tempfile(fileext = ".json")
  html_path <- tempfile(fileext = ".html")
  on.exit(unlink(c(json_path, html_path)))

  writeLines(c(
    '{',
    '  "name": "Example",',
    '  "keywords": [],',
    '  "temporalCoverage": "2020-01-01/2020-12-31",',
    '  "spatialCoverage": {',
    '    "name": "<em>North</em>",',
    '    "geo": { "type": "GeoShape", "circle": "42 -71 5" }',
    '  }',
    '}'
  ), json_path)

  build_site(json_path, out_path = html_path)
  html <- paste(readLines(html_path), collapse = "\n")
  expect_match(html, "&lt;em&gt;North&lt;/em&gt;")
  expect_match(html, "Geo / Circle")
  expect_match(html, "42 -71 5")
  expect_match(html, "L.map\\('map'\\)")
  expect_match(html, "L.polygon\\(\\[\\]\\)")

  # A valid box has both its table representation and the interactive map.
  coverage <- jsonlite::read_json(json_path)
  coverage$spatialCoverage$geo <- list(`@type` = "GeoShape", box = "1 2 3 4")
  jsonlite::write_json(coverage, json_path, auto_unbox = TRUE)
  build_site(json_path, out_path = html_path)
  html <- paste(readLines(html_path), collapse = "\n")
  expect_match(html, "Geo / Box")
  expect_match(html, "1 2 3 4")
  expect_match(html, "L.map\\('map'\\)")
  expect_match(html, "L.polygon\\(\\[\\[ 1, 2\\]")
})
