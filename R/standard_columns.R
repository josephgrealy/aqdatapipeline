#' Standard AURN database columns
#'
#' @return A character vector containing the ordered database schema.
#' @keywords internal
standard_columns <- function() {
  c(
    "network", "source", "year", "date", "site", "code", "latitude",
    "longitude", "site_type", "local_authority", "zone", "agglomeration",
    "pollutant", "measurement", "averaging", "data_capture", "value",
    "ratified"
  )
}
