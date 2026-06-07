test_that("status log supports exact successful chunk matching", {
  path <- tempfile(fileext = ".csv")
  append_status(path, "hourly|no2|2020", "success")
  append_status(path, "hourly|no2|2021", "failed", "network")
  status <- read_status_log(path)

  expect_equal(status$chunk_id[status$status == "success"], "hourly|no2|2020")
})

test_that("latest status determines whether resume skips a chunk", {
  path <- tempfile(fileext = ".csv")
  append_status(path, "hourly|no2|2020", "success")
  append_status(path, "hourly|no2|2020", "failed")
  status <- read_status_log(path)
  latest <- status[!duplicated(status$chunk_id, fromLast = TRUE), ]

  expect_equal(latest$status, "failed")
})
