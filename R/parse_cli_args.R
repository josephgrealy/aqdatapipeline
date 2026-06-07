#' Parse command-line arguments
#'
#' Supported flags are `--output`, `--latest-year`, `--type`, `--pollutant`,
#' `--resume`, `--averaging`, and `--threshold`. Values following `--type`,
#' `--pollutant`, or `--averaging` continue until the next flag.
#'
#' @param args Character vector, usually from [commandArgs()].
#'
#' @return A named list of parsed values.
#' @export
parse_cli_args <- function(args) {
  result <- list(
    output = file.path("data", "air_quality_database"),
    latest_year = 2025L,
    type = NULL,
    pollutant = NULL,
    resume = FALSE,
    averaging = NULL,
    threshold = 1e-3
  )
  i <- 1L
  while (i <= length(args)) {
    flag <- args[[i]]
    if (flag == "--resume") {
      result$resume <- TRUE
      i <- i + 1L
      next
    }
    if (!flag %in% c(
      "--output", "--latest-year", "--type", "--pollutant", "--averaging",
      "--threshold"
    )) {
      stop("Unknown argument: ", flag)
    }
    if (i == length(args)) {
      stop("Missing value after ", flag)
    }
    if (flag %in% c("--type", "--pollutant", "--averaging")) {
      end <- i + 1L
      while (end <= length(args) && !startsWith(args[[end]], "--")) {
        end <- end + 1L
      }
      result[[sub("^--", "", flag)]] <- args[(i + 1L):(end - 1L)]
      i <- end
      next
    }
    value <- args[[i + 1L]]
    name <- sub("^--", "", flag)
    name <- gsub("-", "_", name)
    result[[name]] <- value
    i <- i + 2L
  }
  result$latest_year <- as.integer(result$latest_year)
  result$threshold <- as.numeric(result$threshold)
  result
}
