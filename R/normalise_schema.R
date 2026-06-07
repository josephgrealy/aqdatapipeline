#' Normalise data to the AURN database schema
#'
#' Renames known openair columns, removes non-database columns, adds typed
#' missing columns, and returns columns in their standard order.
#'
#' @param data A data frame.
#'
#' @return A tibble using the standard database schema.
#' @export
normalise_schema <- function(data) {
  data <- tibble::as_tibble(data)
  rename_map <- c(qc = "ratified", poll_index = "value")
  rename_from <- intersect(names(rename_map), names(data))
  names(data)[match(rename_from, names(data))] <- rename_map[rename_from]

  typed_missing <- list(
    network = NA_character_, source = NA_character_, year = NA_integer_,
    date = as.POSIXct(NA), site = NA_character_, code = NA_character_,
    latitude = NA_real_, longitude = NA_real_, site_type = NA_character_,
    local_authority = NA_character_, zone = NA_character_,
    agglomeration = NA_character_, pollutant = NA_character_,
    measurement = NA_character_, averaging = NA_character_,
    data_capture = NA_real_, value = NA_real_, ratified = NA
  )
  for (column in setdiff(standard_columns(), names(data))) {
    data[[column]] <- rep(typed_missing[[column]], nrow(data))
  }
  data |>
    dplyr::mutate(
      network = as.character(.data$network),
      source = as.character(.data$source),
      year = as.integer(.data$year),
      date = as.POSIXct(.data$date),
      site = as.character(.data$site),
      code = as.character(.data$code),
      latitude = as.numeric(.data$latitude),
      longitude = as.numeric(.data$longitude),
      site_type = as.character(.data$site_type),
      local_authority = as.character(.data$local_authority),
      zone = as.character(.data$zone),
      agglomeration = as.character(.data$agglomeration),
      pollutant = as.character(.data$pollutant),
      measurement = as.character(.data$measurement),
      averaging = as.character(.data$averaging),
      data_capture = as.numeric(.data$data_capture),
      value = as.numeric(.data$value),
      ratified = as.logical(.data$ratified)
    ) |>
    dplyr::select(dplyr::all_of(standard_columns()))
}
