#' AURN Parquet partition columns
#'
#' @return A character vector of partition column names.
#' @keywords internal
partition_columns <- function() {
  c("network", "source", "averaging", "measurement", "pollutant", "year")
}
