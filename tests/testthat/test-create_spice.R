context("test-create_spice")

test_that("create_spice creates metadata subdir", {
  tmp <- tempdir()
  on.exit(unlink(tmp, recursive = TRUE))

  create_spice(tmp)
  expect_true(dir.exists(file.path(tmp, "metadata")))
  
})

test_that("create_spice puts template files in metadata folder", {
  tmp <- tempdir()
  on.exit(unlink(tmp, recursive = TRUE))
  
  file_names <- c(
    "access.csv",
    "attributes.csv",
    "biblio.csv",
    "creators.csv"
  )
  create_spice(tmp)

  files <- file.path(tmp, "metadata", file_names)
  expect_true(all(fs::file_exists(files)))
  
})

test_that("create_spice doesn't overrite existing files", {
  tmp <- tempdir()
  on.exit(unlink(tmp, recursive = TRUE))
  metadata_folder <- file.path(tmp, "metadata")
  fs::dir_create(metadata_folder)
  access_file <- file.path(metadata_folder, "access.csv")
  fs::file_create(access_file)
  suppressWarnings(create_spice(tmp))
  
  expect_equal(readLines(access_file), character(0))
})
