#' Validate partition values before writing
#'
#' @param data Prepared database rows.
#' @param expected Named list of permitted values for partition columns.
#'
#' @return `data`, invisibly.
#' @export
validate_partition_data <- function(data, expected) {
  unknown_columns <- setdiff(names(expected), partition_columns())
  if (length(unknown_columns) > 0L) {
    stop("Expected values include non-partition columns: ",
         paste(unknown_columns, collapse = ", "))
  }
  for (column in names(expected)) {
    actual <- unique(data[[column]])
    if (any(is.na(actual)) || !all(actual %in% expected[[column]])) {
      stop("Unexpected ", column, " partition value before write.")
    }
  }
  invisible(data)
}
