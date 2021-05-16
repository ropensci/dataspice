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
  expect_equal(readLines(out_file)[1], "<html>")
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
