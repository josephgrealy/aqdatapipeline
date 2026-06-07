#' Prepare an openair download for storage
#'
#' @param data Downloaded openair data.
#' @param data_type Download data type.
#' @param pollutant Openair pollutant identifier.
#' @param metadata Site metadata containing a `site` column.
#'
#' @return A normalised tibble ready for writing.
#' @export
prepare_download_data <- function(data, data_type, pollutant, metadata) {
  if (pollutant == "o3" && data_type == "annual" && "species" %in% names(data)) {
    data <- dplyr::filter(data, .data$species == "o3")
  }
  averaging <- switch(
    data_type,
    hourly = "None", daily = "Daily", monthly = "Monthly", annual = "Annual"
  )
  measurement <- if (
    data_type == "daily" && pollutant %in% c("gr_pm2.5", "gr_pm10")
  ) "Daily" else "Hourly"

  data |>
    dplyr::left_join(metadata, by = "site") |>
    dplyr::mutate(
      year = as.integer(lubridate::year(.data$date)),
      site = dplyr::if_else(
        .data$site == "Dewsbury Ashworth Grove",
        "Dewsbury Ashworth Grange",
        .data$site
      ),
      pollutant = toupper(sub("^gr_", "", pollutant)),
      source = "openair",
      network = "aurn",
      averaging = averaging,
      measurement = measurement
    ) |>
    normalise_schema()
}
