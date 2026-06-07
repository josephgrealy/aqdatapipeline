#' Download one AURN data chunk
#'
#' @param sitecodes Lower-case AURN site codes.
#' @param years Integer vector of years.
#' @param pollutant Openair pollutant identifier.
#' @param data_type Download data type.
#' @param import_fun Function compatible with [openair::importAURN()].
#'
#' @return A list with `status`, `data`, and `messages`.
#' @export
download_chunk <- function(
    sitecodes, years, pollutant, data_type,
    import_fun = openair::importAURN) {
  warnings <- character()
  result <- tryCatch(
    withCallingHandlers(
      import_fun(
        site = sitecodes, year = years, pollutant = pollutant,
        data_type = data_type, meta = FALSE, meteo = FALSE, verbose = FALSE,
        to_narrow = TRUE, ratified = TRUE
      ),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) e
  )
  if (inherits(result, "error")) {
    return(list(status = "failed", data = NULL, messages = conditionMessage(result)))
  }
  if (is.null(result) || nrow(result) == 0L) {
    return(list(status = "empty", data = NULL, messages = warnings))
  }
  list(status = "success", data = result, messages = warnings)
}
