context("edit_file")

test_that("edit_file fails when it can't find anything", {
  expect_error(edit_file(tempdir()))
})
