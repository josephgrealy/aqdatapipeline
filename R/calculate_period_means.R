#' Calculate period means from hourly observations
#'
#' @param hourly_data Hourly AURN observations.
#' @param averaging One of `Daily`, `Monthly`, or `Annual`.
#'
#' @return A normalised tibble of calculated means.
#' @export
calculate_period_means <- function(hourly_data, averaging) {
  averaging <- match.arg(averaging, c("Daily", "Monthly", "Annual"))
  unit <- switch(averaging, Daily = "day", Monthly = "month", Annual = "year")
  hourly_data |>
    dplyr::mutate(period_date = lubridate::floor_date(.data$date, unit = unit)) |>
    dplyr::group_by(
      .data$site, .data$code, .data$latitude, .data$longitude,
      .data$site_type, .data$local_authority, .data$zone, .data$agglomeration,
      .data$network, .data$pollutant, .data$period_date
    ) |>
    dplyr::summarise(
      number_of_observations = sum(!is.na(.data$value)),
      value = if (all(is.na(.data$value))) NA_real_ else mean(.data$value, na.rm = TRUE),
      ratified = if (all(is.na(.data$ratified))) NA else all(.data$ratified, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      expected_hours = dplyr::case_when(
        averaging == "Daily" ~ 24,
        averaging == "Monthly" ~ lubridate::days_in_month(.data$period_date) * 24,
        TRUE ~ dplyr::if_else(
          lubridate::leap_year(.data$period_date), 366 * 24, 365 * 24
        )
      ),
      date = as.POSIXct(.data$period_date),
      data_capture = .data$number_of_observations / .data$expected_hours,
      year = as.integer(lubridate::year(.data$date)),
      source = "calculated",
      measurement = "Hourly",
      averaging = averaging
    ) |>
    normalise_schema()
}
