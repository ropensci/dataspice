context("write_spice")

test_that("write spice creates a dataspice.json in the right place", {
  tmp <- tempdir()
  on.exit(unlink(tmp, recursive = TRUE))

  unlink(file.path(tmp, "metadata"), recursive = TRUE)
  dir.create(file.path(tmp, "metadata"))

  files_to_copy <- dir(system.file("metadata-tables", package = "dataspice"),
                       pattern = ".csv",
                       full.names = TRUE)

  lapply(files_to_copy, function(path) {
    file.copy(path, file.path(tmp, "metadata", basename(path)),
              overwrite = TRUE)
  })

  write_spice(file.path(tmp, "metadata"))
  dataspice_path <- file.path(tmp, "metadata", "dataspice.json")

  expect_true(file.exists(dataspice_path))
  expect_true(file.size(dataspice_path) > 0)
})
