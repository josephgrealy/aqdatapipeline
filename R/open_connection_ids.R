#' Get identifiers for all open R connections
#'
#' @return A character vector of open connection identifiers.
#' @keywords internal
open_connection_ids <- function() {
  rownames(showConnections(all = TRUE))
}
