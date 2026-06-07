test_that("download chunks report success, empty data, warnings, and failures", {
  success <- function(...) data.frame(site = "A", value = 1)
  empty <- function(...) data.frame()
  warning_result <- function(...) {
    warning("partial data")
    data.frame(site = "A", value = 1)
  }
  failure <- function(...) stop("network failed")

  expect_equal(download_chunk("a", 2020, "no2", "hourly", success)$status, "success")
  expect_equal(download_chunk("a", 2020, "no2", "hourly", empty)$status, "empty")
  expect_match(
    download_chunk("a", 2020, "no2", "hourly", warning_result)$messages,
    "partial data"
  )
  expect_equal(download_chunk("a", 2020, "no2", "hourly", failure)$status, "failed")
})
