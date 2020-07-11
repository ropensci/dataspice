context("as_emld")

test_that("an empty doc converts", {
  expect_is(as_emld(list()), "list")
})
