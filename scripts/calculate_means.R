#!/usr/bin/env Rscript

source("scripts/check_package.R")

args <- aqdatapipeline::parse_cli_args(commandArgs(trailingOnly = TRUE))
config <- aqdatapipeline::default_config(
  output_dir = args$output,
  latest_year = args$latest_year
)
averaging <- args$averaging
if (is.null(averaging) || "all" %in% tolower(averaging)) {
  averaging <- c("Daily", "Monthly", "Annual")
}
pollutants <- args$pollutant
if (is.null(pollutants) || "all" %in% pollutants) {
  pollutants <- c("no2", "pm2.5", "pm10", "o3", "so2")
}
aqdatapipeline::run_means(
  config,
  averaging = tools::toTitleCase(tolower(averaging)),
  pollutants = pollutants,
  threshold = args$threshold
)
