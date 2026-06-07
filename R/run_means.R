#' Calculate and store daily, monthly, and annual means
#'
#' @param config Pipeline configuration.
#' @param averaging Character vector selected from `Daily`, `Monthly`, `Annual`.
#' @param pollutants Openair pollutant identifiers. Ground particulate
#'   identifiers are skipped because the pipeline has no hourly source data for
#'   them.
#' @param threshold Difference threshold used by QA comparisons.
#'
#' @return A summary tibble, invisibly.
#' @export
run_means <- function(
    config = default_config(),
    averaging = c("Daily", "Monthly", "Annual"),
    pollutants = c("no2", "pm2.5", "pm10", "o3", "so2"),
    threshold = 1e-3) {
  validate_config(config)
  averaging <- match.arg(averaging, c("Daily", "Monthly", "Annual"), several.ok = TRUE)
  supported_pollutants <- c("no2", "pm2.5", "pm10", "o3", "so2")
  invalid_pollutants <- setdiff(pollutants, config$pollutants)
  if (length(invalid_pollutants) > 0L) {
    stop("Unsupported pollutants: ", paste(invalid_pollutants, collapse = ", "))
  }
  skipped_pollutants <- setdiff(pollutants, supported_pollutants)
  if (length(skipped_pollutants) > 0L) {
    message(
      "Skipping calculated means without hourly source data: ",
      paste(skipped_pollutants, collapse = ", ")
    )
  }
  pollutants <- toupper(intersect(pollutants, supported_pollutants))
  dataset <- arrow::open_dataset(config$output_dir)
  results <- list()

  for (pollutant in pollutants) {
    hourly <- dataset |>
      dplyr::filter(
        .data$source == "openair", .data$measurement == "Hourly",
        .data$averaging == "None", .data$pollutant == pollutant
      ) |>
      dplyr::collect()
    if (nrow(hourly) == 0L) {
      next
    }
    for (period in averaging) {
      message("Calculating ", period, " ", pollutant, " means")
      calculated <- calculate_period_means(hourly, period)
      write_partitioned_data(
        calculated,
        config$output_dir,
        expected = list(
          network = "aurn", source = "calculated", averaging = period,
          measurement = "Hourly", pollutant = pollutant,
          year = unique(calculated$year)
        )
      )
      openair_data <- dataset |>
        dplyr::filter(
          .data$source == "openair", .data$measurement == "Hourly",
          .data$averaging == period, .data$pollutant == pollutant
        ) |>
        dplyr::collect()
      qa <- compare_aggregates(calculated, openair_data, threshold)
      qa_path <- file.path(
        config$log_dir, "means_qa",
        paste0(tolower(period), "_", tolower(pollutant), ".csv")
      )
      dir.create(dirname(qa_path), recursive = TRUE, showWarnings = FALSE)
      readr::write_csv(qa, qa_path)
      results[[length(results) + 1L]] <- tibble::tibble(
        pollutant = pollutant, averaging = period, discrepancies = nrow(qa)
      )
    }
  }
  invisible(dplyr::bind_rows(results))
}
