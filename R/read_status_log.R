#' Read the structured chunk status log
#'
#' @param path Status CSV path.
#'
#' @return A tibble.
#' @export
read_status_log <- function(path) {
  if (!file.exists(path)) {
    return(tibble::tibble(
      timestamp = character(), chunk_id = character(), status = character(),
      message = character()
    ))
  }
  readr::read_csv(path, show_col_types = FALSE)
}
