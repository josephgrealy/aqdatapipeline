#' Close connections opened after a snapshot
#'
#' Closes only connections that were not present in `existing_ids`. Connections
#' that have already been closed are silently ignored.
#'
#' @param existing_ids Character vector returned by `open_connection_ids()`.
#'
#' @return Invisibly returns `NULL`.
#' @keywords internal
close_new_connections <- function(existing_ids) {
  new_ids <- setdiff(open_connection_ids(), existing_ids)

  for (id in new_ids) {
    try(close(getConnection(as.integer(id))), silent = TRUE)
  }

  gc(verbose = FALSE)
  invisible(NULL)
}
