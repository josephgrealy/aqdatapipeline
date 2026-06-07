test_that("pollutant start years are preserved", {
  config <- default_config(latest_year = 2007)

  expect_equal(get_valid_years("pm2.5", "hourly", config), 1998:2007)
  expect_equal(get_valid_years("pm10", "hourly", config), 1992:2007)
  expect_equal(get_valid_years("gr_pm10", "daily", config), 2001:2007)
  expect_equal(get_valid_years("gr_pm2.5", "daily", config), 2006:2007)
  expect_length(get_valid_years("gr_pm2.5", "hourly", config), 0)
  expect_length(get_valid_years("gr_pm10", "annual", config), 0)
})

test_that("chunk boundaries are preserved", {
  config <- default_config(start_year = 2005, latest_year = 2007)

  expect_equal(make_download_chunks("no2", "hourly", config), as.list(2005:2007))
  expect_equal(make_download_chunks("no2", "daily", config), as.list(2005:2007))
  expect_equal(make_download_chunks("no2", "monthly", config), list(2005:2007))
  expect_equal(make_download_chunks("no2", "annual", config), list(2005:2007))
})

test_that("default configuration uses the generic database path", {
  expect_equal(
    default_config()$output_dir,
    file.path("data", "air_quality_database")
  )
})
