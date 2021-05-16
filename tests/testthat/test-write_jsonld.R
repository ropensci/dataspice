context("write_jsonld")

test_that("as_jsonld works", {
  expect_is(as_jsonld(list("name" = "test")), "json")
})
