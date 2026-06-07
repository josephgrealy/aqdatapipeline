#' Create an exact download chunk identifier
#'
#' @param data_type Download data type.
#' @param pollutant Openair pollutant identifier.
#' @param years Integer vector of years in the chunk.
#'
#' @return A stable character identifier.
#' @export
chunk_id <- function(data_type, pollutant, years) {
  paste(data_type, pollutant, paste(as.integer(years), collapse = ","), sep = "|")
}
