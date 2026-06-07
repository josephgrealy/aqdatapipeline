test_that("run_means rejects unknown pollutant identifiers before reading data", {
  expect_error(
    run_means(default_config(), pollutants = "carbon"),
    "Unsupported pollutants"
  )
})
