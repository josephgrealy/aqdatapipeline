test_that("package version includes targeted connection cleanup", {
  expect_true(utils::packageVersion("aqdatapipeline") >= package_version("0.1.2"))
})
