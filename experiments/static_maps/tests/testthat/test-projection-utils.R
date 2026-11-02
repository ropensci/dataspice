test_that("report generator is part of the package API", {
  expect_type(generate_projection_comparison, "closure")
})

test_that("project_xy delegates projection to sf and preserves missing values", {
  projected <- project_xy(
    lon = c(0, NA_real_),
    lat = c(0, NA_real_),
    crs = "+proj=eqearth +lon_0=0 +datum=WGS84 +units=m +no_defs"
  )

  expect_equal(projected$x[1], 0, tolerance = 1e-8)
  expect_equal(projected$y[1], 0, tolerance = 1e-8)
  expect_true(is.na(projected$x[2]))
  expect_true(is.na(projected$y[2]))
})
