test_that("matching partitions are replaced and unrelated partitions remain", {
  path <- tempfile()
  first <- normalise_schema(data.frame(
    network = "aurn", source = "openair", year = c(2020L, 2021L),
    date = as.POSIXct(c("2020-01-01", "2021-01-01"), tz = "UTC"),
    site = "A", pollutant = "NO2", measurement = "Hourly",
    averaging = "None", value = c(1, 2)
  ))
  write_partitioned_data(first, path, list(
    network = "aurn", source = "openair", averaging = "None",
    measurement = "Hourly", pollutant = "NO2", year = c(2020L, 2021L)
  ))
  replacement <- first[1, ]
  replacement$value <- 9
  write_partitioned_data(replacement, path, list(
    network = "aurn", source = "openair", averaging = "None",
    measurement = "Hourly", pollutant = "NO2", year = 2020L
  ))
  result <- arrow::open_dataset(path) |>
    dplyr::collect() |>
    dplyr::arrange(.data$year)

  expect_equal(result$value, c(9, 2))
})
