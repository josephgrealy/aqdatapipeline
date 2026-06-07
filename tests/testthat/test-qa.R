test_that("QA reports changed and unmatched aggregates", {
  calculated <- tibble::tibble(
    site = c("A", "B"), pollutant = "NO2",
    date = as.POSIXct(c("2024-01-01", "2024-01-01"), tz = "UTC"),
    value = c(10, 20), data_capture = c(1, 1)
  )
  openair <- tibble::tibble(
    site = c("A", "C"), pollutant = "NO2",
    date = as.POSIXct(c("2024-01-01", "2024-01-01"), tz = "UTC"),
    value = c(11, 30), data_capture = c(1, 1)
  )
  result <- compare_aggregates(calculated, openair)

  expect_equal(nrow(result), 3)
})
