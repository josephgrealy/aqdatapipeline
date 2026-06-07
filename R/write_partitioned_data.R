#' Safely replace matching Parquet partitions
#'
#' Existing partitions represented by `data` are deleted and replaced. Other
#' partitions in the dataset are left untouched.
#'
#' @param data Prepared database rows.
#' @param path Local Parquet dataset directory.
#' @param expected Named list of permitted partition values.
#'
#' @return `data`, invisibly.
#' @export
write_partitioned_data <- function(data, path, expected) {
  if (nrow(data) == 0L) {
    stop("Refusing to write an empty data chunk.")
  }
  validate_partition_data(data, expected)
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  arrow::write_dataset(
    data,
    path = path,
    partitioning = partition_columns(),
    format = "parquet",
    existing_data_behavior = "delete_matching"
  )
  invisible(data)
}
