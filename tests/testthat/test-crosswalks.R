context("crosswalks")

test_that("test crosswalk_datetime", {
  expect_equal(crosswalk_datetime("FOO"), list(calendarDate = "FOO", time = NULL))
  expect_equal(crosswalk_datetime("1990"), list(calendarDate = "1990", time = NULL))
  expect_equal(crosswalk_datetime("1990-01-01"), list(calendarDate = "1990-01-01", time = NULL))
  expect_equal(crosswalk_datetime("1990-01-01 00:00:00"), list(calendarDate = "1990-01-01", time = "00:00:00"))
  expect_equal(crosswalk_datetime("1990-01-01T00:00:00.000Z"), list(calendarDate = "1990-01-01", time = "00:00:00.000Z"))
})
