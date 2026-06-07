#' Run the AURN download pipeline
#'
#' @param config Pipeline configuration.
#' @param data_types Data types to download.
#' @param pollutants Openair pollutant identifiers to download.
#' @param resume Skip chunks with an exact successful status record.
#' @param import_fun Function compatible with [openair::importAURN()].
#' @param meta_fun Function compatible with [openair::importMeta()].
#'
#' @return A summary tibble, invisibly.
#' @export
run_download <- function(
    config = default_config(), data_types = config$data_types,
    pollutants = config$pollutants, resume = FALSE,
    import_fun = openair::importAURN, meta_fun = openair::importMeta) {
  validate_config(config)
  invalid <- setdiff(data_types, config$data_types)
  if (length(invalid) > 0L) {
    stop("Unsupported data types: ", paste(invalid, collapse = ", "))
  }
  invalid_pollutants <- setdiff(pollutants, config$pollutants)
  if (length(invalid_pollutants) > 0L) {
    stop("Unsupported pollutants: ", paste(invalid_pollutants, collapse = ", "))
  }
  status_path <- file.path(config$log_dir, "download_status.csv")
  completed <- read_status_log(status_path)
  latest_status <- completed[!duplicated(completed$chunk_id, fromLast = TRUE), ]
  completed_ids <- latest_status$chunk_id[latest_status$status == "success"]

  raw_meta <- meta_fun(source = "aurn", all = TRUE)
  metadata <- raw_meta |>
    dplyr::select(dplyr::all_of(c(
      "site", "site_type", "latitude", "longitude", "zone", "agglomeration",
      "local_authority"
    ))) |>
    dplyr::distinct(.data$site, .keep_all = TRUE) |>
    dplyr::mutate(
      local_authority = dplyr::coalesce(.data$local_authority, "Unknown Local Authority"),
      zone = dplyr::coalesce(.data$zone, "Unknown Zone"),
      agglomeration = dplyr::coalesce(.data$agglomeration, "Non-Agglomeration")
    )
  sitecodes <- setdiff(tolower(as.character(unique(raw_meta$code))), "mh")
  results <- list()

  for (data_type in data_types) {
    for (pollutant in pollutants) {
      for (years in make_download_chunks(pollutant, data_type, config)) {
        id <- chunk_id(data_type, pollutant, years)
        if (resume && id %in% completed_ids) {
          next
        }
        message("Downloading ", id)
        downloaded <- download_chunk(sitecodes, years, pollutant, data_type, import_fun)
        status <- downloaded$status
        diagnostic <- downloaded$messages
        if (status == "success") {
          status <- tryCatch({
            prepared <- prepare_download_data(
              downloaded$data, data_type, pollutant, metadata
            )
            write_partitioned_data(
              prepared,
              config$output_dir,
              expected = list(
                network = "aurn", source = "openair",
                averaging = unique(prepared$averaging),
                measurement = unique(prepared$measurement),
                pollutant = toupper(sub("^gr_", "", pollutant)),
                year = years
              )
            )
            "success"
          }, error = function(e) {
            diagnostic <<- c(diagnostic, conditionMessage(e))
            "failed"
          })
        }
        append_status(status_path, id, status, diagnostic)
        results[[length(results) + 1L]] <- tibble::tibble(chunk_id = id, status = status)
      }
    }
  }
  invisible(dplyr::bind_rows(results))
}
