test_that("run_download writes a chunk and exact resume skips it", {
  root <- tempfile()
  config <- default_config(
    output_dir = file.path(root, "data"),
    start_year = 2020,
    latest_year = 2020,
    log_dir = file.path(root, "logs")
  )
  config$pollutants <- "no2"
  config$data_types <- "hourly"
  calls <- 0L
  fake_import <- function(...) {
    calls <<- calls + 1L
    data.frame(
      site = "Site A",
      date = as.POSIXct("2020-01-01", tz = "UTC"),
      value = 10,
      qc = TRUE
    )
  }
  fake_meta <- function(...) {
    data.frame(
      site = "Site A", code = "AAA", site_type = "Urban",
      latitude = 1, longitude = 2, zone = "Zone", agglomeration = "Agg",
      local_authority = "Authority"
    )
  }

  run_download(
    config, "hourly", pollutants = "no2",
    import_fun = fake_import, meta_fun = fake_meta
  )
  run_download(
    config, "hourly", pollutants = "no2", resume = TRUE,
    import_fun = fake_import, meta_fun = fake_meta
  )

  expect_equal(calls, 1L)
  expect_true(dir.exists(config$output_dir))
})

test_that("run_download requests only selected pollutants", {
  root <- tempfile()
  config <- default_config(
    output_dir = file.path(root, "data"),
    start_year = 2020,
    latest_year = 2020,
    log_dir = file.path(root, "logs")
  )
  config$pollutants <- c("no2", "o3")
  config$data_types <- "hourly"
  requested <- character()
  fake_import <- function(pollutant, ...) {
    requested <<- c(requested, pollutant)
    data.frame(
      site = "Site A", date = as.POSIXct("2020-01-01", tz = "UTC"),
      value = 10, qc = TRUE
    )
  }
  fake_meta <- function(...) {
    data.frame(
      site = "Site A", code = "AAA", site_type = "Urban",
      latitude = 1, longitude = 2, zone = "Zone", agglomeration = "Agg",
      local_authority = "Authority"
    )
  }

  run_download(
    config, data_types = "hourly", pollutants = "o3",
    import_fun = fake_import, meta_fun = fake_meta
  )

  expect_equal(requested, "o3")
})

test_that("run_download rejects unknown pollutant identifiers", {
  expect_error(
    run_download(default_config(), pollutants = "carbon"),
    "Unsupported pollutants"
  )
})
