#' Validate pipeline configuration
#'
#' @param config A configuration list created by [default_config()].
#'
#' @return `config`, invisibly.
#' @export
validate_config <- function(config) {
  required <- c(
    "output_dir", "latest_year", "start_year", "log_dir", "pollutants",
    "data_types", "pollutant_start_year"
  )
  missing <- setdiff(required, names(config))
  if (length(missing) > 0L) {
    stop("Missing configuration values: ", paste(missing, collapse = ", "))
  }
  if (config$latest_year < config$start_year) {
    stop("latest_year must be greater than or equal to start_year.")
  }
  unknown <- setdiff(config$data_types, c("hourly", "daily", "monthly", "annual"))
  if (length(unknown) > 0L) {
    stop("Unsupported data types: ", paste(unknown, collapse = ", "))
  }
  invisible(config)
}
