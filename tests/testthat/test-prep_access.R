context("prep_access")

test_that("prep_access fails when it can't find things", {
  workdir <- tempdir()
  oldworkdir <- getwd()
  setwd(workdir)
  on.exit({
    setwd(oldworkdir)
  })

  expect_error(prep_access())
})

test_that("prep_access errors when no valid file paths are found", {
  workdir <- tempdir()
  oldworkdir <- getwd()
  setwd(workdir)
  on.exit({
    setwd(oldworkdir)
  })

  create_spice()
  expect_error(prep_access())
})

test_that("prep_access works correctly", {
  workdir <- tempdir()
  oldworkdir <- getwd()
  setwd(workdir)
  on.exit({
    setwd(oldworkdir)
  })

  data_path <- file.path("data", "mydata.csv")
  file.create(data_path)
  writeLines(c("a,b,c", "1,2,3"), data_path)
  create_spice()
  prep_access()

  expect_length(readLines("data/metadata/access.csv"), 2)
})
