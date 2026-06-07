#' Create the default pipeline configuration
#'
#' The defaults preserve the pollutant availability and chunking decisions from
#' the original pipeline. Change `latest_year` explicitly when a newer reporting
#' year should be downloaded.
#'
#' @param output_dir Local directory containing the partitioned Parquet dataset.
#' @param latest_year Last year to request from openair.
#' @param start_year First possible AURN year.
#' @param log_dir Directory for status, error, and QA logs.
#'
#' @return A configuration list.
#' @export
default_config <- function(
    output_dir = file.path("data", "air_quality_database"),
    latest_year = 2025L,
    start_year = 1986L,
    log_dir = "logs") {
  list(
    output_dir = output_dir,
    latest_year = as.integer(latest_year),
    start_year = as.integer(start_year),
    log_dir = log_dir,
    pollutants = c("no2", "pm2.5", "pm10", "o3", "so2", "gr_pm2.5", "gr_pm10"),
    data_types = c("hourly", "daily", "monthly", "annual"),
    pollutant_start_year = c(
      "pm2.5" = 1998L,
      "pm10" = 1992L,
      "gr_pm10" = 2001L,
      "gr_pm2.5" = 2006L
    )
  )
}
