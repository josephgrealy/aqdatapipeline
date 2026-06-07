#' Get years available for a pollutant and data type
#'
#' @param pollutant An openair pollutant identifier.
#' @param data_type One of `hourly`, `daily`, `monthly`, or `annual`.
#' @param config Pipeline configuration.
#'
#' @return An integer vector. Ground-based particulate measurements return no
#'   years for data types other than daily.
#' @export
get_valid_years <- function(pollutant, data_type, config = default_config()) {
  validate_config(config)
  if (pollutant %in% c("gr_pm2.5", "gr_pm10") && data_type != "daily") {
    return(integer())
  }
  first_year <- unname(config$pollutant_start_year[pollutant])
  if (length(first_year) == 0L || is.na(first_year)) {
    first_year <- config$start_year
  }
  years <- seq.int(config$start_year, config$latest_year)
  years[years >= first_year]
}
