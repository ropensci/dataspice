context("spice_to_eml")

test_that("an empty doc converts", {
  expect_is(spice_to_eml(list()), "list")
})

test_that("you get an error when the file isn't found or the wrong type", {
  expect_error(spice_to_eml())
  expect_error(spice_to_eml(NULL))
})

test_that("a simple document crosswalks", {
  user <- list("type" = "Person",
               givenName = "Example",
               familyName = "User")

  myspice <- list(
    name = "My example spice",
    creator = list(user),
    contact = (user))

  eml <- spice_to_eml(myspice)

  expect_equal(eml$dataset$title, "My example spice")
  expect_equal(eml$dataset$creator[[1]]$individualName$givenName, "Example")
  expect_equal(eml$dataset$creator[[1]]$individualName$surName, "User")
  expect_equal(eml$dataset$contact[[1]]$individualName$givenName, "Example")
  expect_equal(eml$dataset$contact[[1]]$individualName$surName, "User")
})
