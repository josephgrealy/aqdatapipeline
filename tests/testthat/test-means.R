make_hourly <- function(date, values, ratified = rep(TRUE, length(values))) {
  normalise_schema(data.frame(
    network = "aurn", source = "openair", date = date, site = "Site A",
    code = "AAA", latitude = 1, longitude = 2, site_type = "Urban",
    local_authority = "Authority", zone = "Zone", agglomeration = "Agg",
    pollutant = "NO2", measurement = "Hourly", averaging = "None",
    value = values, ratified = ratified
  ))
}

test_that("daily means calculate value, capture, and ratification", {
  hourly <- make_hourly(
    as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:23 * 3600,
    c(1:12, rep(NA, 12)),
    c(rep(TRUE, 11), FALSE, rep(NA, 12))
  )
  result <- calculate_period_means(hourly, "Daily")

  expect_equal(result$value, mean(1:12))
  expect_equal(result$data_capture, 0.5)
  expect_false(result$ratified)
})

test_that("annual means account for leap years and missing ratification", {
  hourly <- make_hourly(as.POSIXct("2024-01-01", tz = "UTC"), 10, NA)
  result <- calculate_period_means(hourly, "Annual")

  expect_equal(result$data_capture, 1 / (366 * 24))
  expect_true(is.na(result$ratified))
})
