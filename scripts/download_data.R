#!/usr/bin/env Rscript

source("scripts/check_package.R")

args <- aqdatapipeline::parse_cli_args(commandArgs(trailingOnly = TRUE))
config <- aqdatapipeline::default_config(
  output_dir = args$output,
  latest_year = args$latest_year
)
data_types <- args$type
if (is.null(data_types) || "all" %in% data_types) {
  data_types <- config$data_types
}
pollutants <- args$pollutant
if (is.null(pollutants) || "all" %in% pollutants) {
  pollutants <- config$pollutants
}
aqdatapipeline::run_download(
  config,
  data_types = data_types,
  pollutants = pollutants,
  resume = args$resume
)
