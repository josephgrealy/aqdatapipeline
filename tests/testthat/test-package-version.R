test_that("package version includes pollutant-selection support", {
  expect_true(utils::packageVersion("aqdatapipeline") >= package_version("0.1.1"))
})
