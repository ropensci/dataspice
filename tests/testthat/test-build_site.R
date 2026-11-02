test_that("build_site generates an html file", {
  out_file <- tempfile()

  build_site(
    path = system.file(
      file.path("examples", "annual-escapement.json"),
      package = "dataspice"
    ),
    out_path = out_file
  )

  expect_true(file.exists(out_file))
  expect_equal(readLines(out_file)[1], "<!DOCTYPE html>")
})

test_that("build_site can create a self-contained static map", {
  skip_if_not_installed("base64enc")
  skip_if_not_installed("maps")
  skip_if_not_installed("sf")

  out_file <- tempfile()
  build_site(
    path = system.file(
      file.path("examples", "annual-escapement.json"),
      package = "dataspice"
    ),
    out_path = out_file,
    static_map = TRUE
  )

  html <- paste(readLines(out_file), collapse = "\\n")
  expect_match(html, '<img id="map" src="data:image/png;base64,')
  expect_false(grepl("tile.openstreetmap.org", html, fixed = TRUE))
  expect_false(grepl("unpkg.com/leaflet", html, fixed = TRUE))
  expect_true(grepl(
    'alt="Map of Compiled annual statewide Alaskan salmon escapement counts, 1921-2017, covering 47\u00b0 N to 78\u00b0 N and 171\u00b0 W to 131\u00b0 W."',
    html,
    fixed = TRUE
  ))
})

test_that("build_site preserves case in custom PROJ strings", {
  out_file <- tempfile()
  build_site(
    path = system.file(
      file.path("examples", "annual-escapement.json"),
      package = "dataspice"
    ),
    out_path = out_file,
    static_map = TRUE,
    static_map_method = paste(
      "+proj=laea +lat_0=62.5 +lon_0=-151 +datum=NAD83",
      "+units=m +no_defs"
    )
  )

  html <- paste(readLines(out_file), collapse = "\\n")
  expect_match(html, '<img id="map" src="data:image/png;base64,')
})

test_that("build_site creates a docs dir if needed", {
  out_dir <- tempdir()
  old_wd <- getwd()
  on.exit(setwd(old_wd))
  setwd(out_dir)

  build_site(
    path = system.file(
      file.path("examples", "annual-escapement.json"),
      package = "dataspice"
    )
  )

  expect_true(dir.exists("docs"))
})

test_that("build_site accepts and creates a difference dir when provided", {
  out_dir <- tempdir()
  old_wd <- getwd()
  on.exit(setwd(old_wd))
  setwd(out_dir)

  indexdir <- "public"
  indexpath <- file.path(indexdir, "index.html")

  build_site(
    path = system.file(
      file.path("examples", "annual-escapement.json"),
      package = "dataspice"
    ),
    out_path = indexpath
  )

  expect_true(dir.exists(indexdir))
})
