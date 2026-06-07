#' Append a chunk status record
#'
#' @param path Status CSV path.
#' @param id Exact chunk identifier.
#' @param status One of `success`, `empty`, or `failed`.
#' @param message Optional diagnostic message.
#'
#' @return The written record, invisibly.
#' @export
append_status <- function(path, id, status, message = "") {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  record <- tibble::tibble(
    timestamp = format(Sys.time(), tz = "UTC", usetz = TRUE),
    chunk_id = id,
    status = status,
    message = paste(message, collapse = " | ")
  )
  readr::write_csv(record, path, append = file.exists(path))
  invisible(record)
}
