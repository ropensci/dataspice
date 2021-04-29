context("crosswalks")

test_that("test crosswalk_datetime", {
  expect_equal(
    crosswalk_datetime("FOO"),
    list(calendarDate = "FOO", time = NULL)
  )
  expect_equal(
    crosswalk_datetime("1990"),
    list(calendarDate = "1990", time = NULL)
  )
  expect_equal(
    crosswalk_datetime("1990-01-01"),
    list(calendarDate = "1990-01-01", time = NULL)
  )
  expect_equal(
    crosswalk_datetime("1990-01-01 00:00:00"),
    list(calendarDate = "1990-01-01", time = "00:00:00")
  )
  expect_equal(
    crosswalk_datetime("1990-01-01T00:00:00.000Z"),
    list(calendarDate = "1990-01-01", time = "00:00:00.000Z")
  )
})

test_that("a basic crosswalk succeeds", {
  spice <- system.file(
    file.path("examples", "annual-escapement.json"),
    package = "dataspice"
  )
  expect_warning(spice_to_eml(spice))
})

test_that("you get an warning when you try to crosswalk a non-existent term", {
  expect_warning(crosswalk(list(), "foobar"))
})

test_that("crosswalk variables works", {
  # From disk
  spice <- system.file(
    file.path("examples", "annual-escapement.json"),
    package = "dataspice"
  )
  expect_is(crosswalk_variables(spice), "data.frame")

  # From memory
  spice <- jsonlite::read_json(
    system.file(
      file.path("examples", "annual-escapement.json"),
      package = "dataspice"
    )
  )
  expect_is(crosswalk_variables(spice), "data.frame")
})

test_that("crosswalking a creator warnings when missing a type", {
  expect_warning(crosswalk_creator(list("name" = "foo")))
})

test_that("crosswalking creators works", {
  expect_is(crosswalk_creator(list("name" = "foo", "type" = "Person")), "list")
  expect_is(crosswalk_creator(
    list("name" = "foo", "type" = "Organization")
  ), "list")
})

test_that("crosswalking a creator with an unknown type errors", {
  expect_warning(crosswalk_creator(list("name" = "foo", "type" = "Foo")))
})
