test_that("schema normalisation renames and types missing columns", {
  result <- normalise_schema(data.frame(qc = TRUE, poll_index = 2))

  expect_named(result, c(
    "network", "source", "year", "date", "site", "code", "latitude",
    "longitude", "site_type", "local_authority", "zone", "agglomeration",
    "pollutant", "measurement", "averaging", "data_capture", "value",
    "ratified"
  ))
  expect_type(result$value, "double")
  expect_type(result$ratified, "logical")
  expect_s3_class(result$date, "POSIXct")
})
