#' Compare calculated and openair aggregates
#'
#' @param calculated Calculated aggregate rows.
#' @param openair_data Matching openair aggregate rows.
#' @param threshold Numeric difference threshold.
#'
#' @return A tibble containing changed or unmatched rows.
#' @export
compare_aggregates <- function(calculated, openair_data, threshold = 1e-3) {
  keys <- c("site", "pollutant", "date")
  dplyr::full_join(
    dplyr::select(calculated, dplyr::all_of(keys), value_calculated = "value",
                  capture_calculated = "data_capture"),
    dplyr::select(openair_data, dplyr::all_of(keys), value_openair = "value",
                  capture_openair = "data_capture"),
    by = keys
  ) |>
    dplyr::mutate(
      value_difference = abs(.data$value_calculated - .data$value_openair),
      capture_difference = abs(.data$capture_calculated - .data$capture_openair),
      discrepancy = is.na(.data$value_calculated) != is.na(.data$value_openair) |
        (!is.na(.data$value_difference) & .data$value_difference > threshold) |
        (!is.na(.data$capture_difference) & .data$capture_difference > threshold)
    ) |>
    dplyr::filter(.data$discrepancy)
}
