test_that("CLI parser reads vectors and flags", {
  parsed <- parse_cli_args(c(
    "--output", "tmp/data", "--latest-year", "2024",
    "--type", "hourly", "daily", "--pollutant", "no2", "pm10", "--resume"
  ))

  expect_equal(parsed$output, "tmp/data")
  expect_equal(parsed$latest_year, 2024L)
  expect_equal(parsed$type, c("hourly", "daily"))
  expect_equal(parsed$pollutant, c("no2", "pm10"))
  expect_true(parsed$resume)
})

test_that("CLI parser rejects unknown arguments", {
  expect_error(parse_cli_args("--unknown"), "Unknown argument")
})

test_that("CLI defaults to the generic air quality database path", {
  expect_equal(
    parse_cli_args(character())$output,
    file.path("data", "air_quality_database")
  )
})
