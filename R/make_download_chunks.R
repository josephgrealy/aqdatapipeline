#' Create download chunks
#'
#' Hourly and daily data are downloaded one year at a time to limit memory use.
#' Monthly and annual data are downloaded as one multi-year chunk.
#'
#' @param pollutant An openair pollutant identifier.
#' @param data_type One of `hourly`, `daily`, `monthly`, or `annual`.
#' @param config Pipeline configuration.
#'
#' @return A list of integer year vectors.
#' @export
make_download_chunks <- function(pollutant, data_type, config = default_config()) {
  years <- get_valid_years(pollutant, data_type, config)
  if (length(years) == 0L) {
    return(list())
  }
  if (data_type %in% c("monthly", "annual")) {
    list(years)
  } else {
    as.list(years)
  }
}
