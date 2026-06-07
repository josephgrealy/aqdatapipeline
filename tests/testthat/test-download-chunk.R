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

test_that("download chunks close connections leaked by successful imports", {
  leaked <- new.env(parent = emptyenv())
  success <- function(...) {
    leaked$connection <- file(tempfile(), open = "w")
    leaked$id <- as.character(leaked$connection)
    data.frame(site = "A", value = 1)
  }

  result <- download_chunk("a", 2020, "no2", "hourly", success)

  expect_equal(result$status, "success")
  expect_false(leaked$id %in% rownames(showConnections(all = TRUE)))
})

test_that("download chunks close connections leaked by failing imports", {
  leaked <- new.env(parent = emptyenv())
  failure <- function(...) {
    leaked$connection <- file(tempfile(), open = "w")
    leaked$id <- as.character(leaked$connection)
    stop("network failed")
  }

  result <- download_chunk("a", 2020, "no2", "hourly", failure)

  expect_equal(result$status, "failed")
  expect_false(leaked$id %in% rownames(showConnections(all = TRUE)))
})

test_that("download chunks leave pre-existing connections open", {
  existing <- file(tempfile(), open = "w")
  on.exit(close(existing), add = TRUE)
  success <- function(...) data.frame(site = "A", value = 1)

  result <- download_chunk("a", 2020, "no2", "hourly", success)

  expect_equal(result$status, "success")
  expect_true(isOpen(existing))
})
