context("validate_metadata")

test_that("validate_biblio throws an error when biblio.csv is empty", {
  expect_error(validate_biblio(data.frame()))
})

test_that("validate_attributes throws an error when biblio.csv is empty", {
  expect_error(validate_attributes(data.frame()))
})

test_that("validate_access throws an error when biblio.csv is empty", {
  expect_error(validate_access(data.frame()))
})

test_that("validate_creators throws an error when biblio.csv is empty", {
  expect_error(validate_creators(data.frame()))
})
