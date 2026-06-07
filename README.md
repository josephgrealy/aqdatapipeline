# Air Quality Data Pipeline

This repository is an R package and command-line workflow for downloading data
from the UK Automatic Urban and Rural Network (AURN) with
[`openair`](https://davidcarslaw.github.io/openair/) and storing it in a local,
partitioned Parquet database.

`openair` is an amazing tool to access air quality data, but downloading the data
can be a time consuming, and frustrating process. This package takes into account
the quirks of how `openair` stores data, and makes it easy to download specific
data types for specific pollutants over specific time periods. By storing the data
in a Parquet database, it makes it quick and easy to load data facilitating
further analysis.

The pipeline retains openair-provided hourly, daily, monthly,
and annual data, but can also calculates daily, monthly, and
annual arithmetic means from the hourly observations and stores
them separately for comparison. The calculation/rounding rules applied
in this package match those used for compliance calculations (e.g.
the England Fine Particulate Matter Targets).

## Installation

Install R 4.2 or later, then install the package dependencies and this package:

```r
install.packages(c(
  "arrow", "dplyr", "lubridate", "openair", "readr", "rlang", "tibble",
  "testthat", "devtools", "renv"
))

devtools::install()
```

For reproducible dependency versions, initialise and restore an `renv`
environment:

```r
renv::init()
renv::snapshot()
# On another machine:
renv::restore()
```

The commands below expect the package to have been installed with
`devtools::install()`.

## Run the Pipeline

Commands are run from the repository root after installing the package with
`devtools::install()`.

### Download Data

Download all supported openair data through the configured latest year:

```bash
Rscript scripts/download_data.R --type all --latest-year 2025
```

Download selected data types:

```bash
Rscript scripts/download_data.R --type hourly daily --latest-year 2025
```

Download only selected pollutants using their openair identifiers:

```bash
Rscript scripts/download_data.R --pollutant no2 pm2.5
Rscript scripts/download_data.R --pollutant o3 --type hourly
Rscript scripts/download_data.R --pollutant pm10 --type hourly daily annual
```

`--pollutant` accepts one or more of:

| Identifier | Description                   |
| ---------- | ----------------------------- |
| `no2`      | Nitrogen dioxide              |
| `pm2.5`    | Fine particulate matter       |
| `pm10`     | Particulate matter            |
| `o3`       | Ozone                         |
| `so2`      | Sulphur dioxide               |
| `gr_pm2.5` | Gravimetric PM2.5, daily only |
| `gr_pm10`  | Gravimetric PM10, daily only  |
| `all`      | All supported identifiers     |

Values after `--pollutant` or `--type` continue until the next `--` flag. Write
each flag once:

```bash
Rscript scripts/download_data.R \
  --pollutant no2 pm2.5 pm10 \
  --type hourly daily \
  --latest-year 2025
```

If `--pollutant` is omitted, every supported pollutant is downloaded. If
`--type` is omitted, hourly, daily, monthly, and annual data are downloaded.

Resume an interrupted download, skipping only chunks with an exact successful
status record:

```bash
Rscript scripts/download_data.R --type all --latest-year 2025 --resume
```

Resume can be combined with pollutant selection:

```bash
Rscript scripts/download_data.R --pollutant no2 o3 --type hourly --resume
```

### Calculate Means

Calculate daily, monthly, and annual means from downloaded hourly data:

```bash
Rscript scripts/calculate_means.R --averaging all
Rscript scripts/calculate_means.R --averaging daily annual
```

Calculate means for selected pollutants:

```bash
Rscript scripts/calculate_means.R --pollutant no2 pm2.5 --averaging annual
Rscript scripts/calculate_means.R --pollutant o3 --averaging daily monthly
```

Calculated means require previously downloaded hourly data. Gravimetric
particulate identifiers are skipped because their source data is daily rather
than hourly.

### Run Everything

Run downloading followed by all active mean calculations:

```bash
Rscript scripts/run_pipeline.R --type all --latest-year 2025 --resume
```

Run the full workflow for selected pollutants:

```bash
Rscript scripts/run_pipeline.R \
  --pollutant no2 pm2.5 \
  --type hourly daily monthly annual \
  --latest-year 2025 \
  --resume
```

Use `--output` to choose another local database directory:

```bash
Rscript scripts/run_pipeline.R --output /path/to/air_quality_database --type hourly daily
```

### Command Options

| Option               | Used by       | Default                     | Description                                         |
| -------------------- | ------------- | --------------------------- | --------------------------------------------------- |
| `--output PATH`      | All scripts   | `data/air_quality_database` | Local Parquet database directory                    |
| `--latest-year YEAR` | All scripts   | `2025`                      | Last year included in downloads                     |
| `--type VALUES`      | Download/full | All types                   | `hourly`, `daily`, `monthly`, `annual`, or `all`    |
| `--pollutant VALUES` | All scripts   | All pollutants              | One or more pollutant identifiers listed above      |
| `--resume`           | Download/full | Off                         | Skip chunks whose latest exact status is successful |
| `--averaging VALUES` | Means only    | All periods                 | `daily`, `monthly`, `annual`, or `all`              |
| `--threshold NUMBER` | Means/full    | `0.001`                     | QA comparison difference threshold                  |

The latest year is deliberately explicit rather than automatically using the
current year. This avoids unexpectedly requesting incomplete future/reporting
periods. Pass the required year with `--latest-year`.

### Use from R

The same selections can be made directly through the package API:

```r
library(aqdatapipeline)

config <- default_config(
  output_dir = "data/air_quality_database",
  latest_year = 2025
)

run_download(
  config,
  data_types = c("hourly", "daily"),
  pollutants = c("no2", "pm2.5"),
  resume = TRUE
)

run_means(
  config,
  averaging = c("Daily", "Annual"),
  pollutants = c("no2", "pm2.5")
)
```

## Download Rules and Refreshes

The original pollutant availability and memory-management rules are preserved:

- Hourly and daily data are downloaded and written one year at a time.
- Monthly and annual data are downloaded as one multi-year chunk.
- PM2.5 starts in 1998, PM10 in 1992, ground PM10 in 2001, and ground PM2.5
  in 2006.
- Ground particulate data is downloaded only for the daily data type.
- Mace Head is excluded from the site list.

Each successful write uses Arrow's `delete_matching` behavior. Every partition
represented by the refreshed chunk is deleted and replaced, while unrelated
pollutants, years, sources, measurements, and averaging periods are left
untouched. The pipeline validates the expected partition values before writing.

Empty and failed chunks are recorded but are not considered complete by resume
mode.

Selecting a pollutant or data type limits which chunks are requested and
refreshed. It does not remove unrelated data already present in the database.

## Database Layout

The default database is `data/air_quality_database`. The generic name allows
other monitoring networks to be added alongside AURN data in future. It is
partitioned by:

```text
network/source/averaging/measurement/pollutant/year
```

- `source = "openair"` contains data downloaded directly from openair.
- `source = "calculated"` contains daily, monthly, and annual means calculated
  from `source = "openair"`, `measurement = "Hourly"`, `averaging = "None"`.

Read a filtered subset without loading the full database:

```r
library(arrow)
library(dplyr)

data <- open_dataset("data/air_quality_database") |>
  filter(
    source == "calculated",
    averaging == "Annual",
    pollutant == "PM2.5",
    year == 2025
  ) |>
  collect()
```

## Logs and QA

- `logs/download_status.csv` records exact chunk identifiers and their latest
  success, empty, or failed status.
- `logs/means_qa/` contains discrepancy reports comparing calculated means and
  data capture against matching openair aggregates.

Calculated means report data capture as valid hourly observations divided by
the expected hours in the period. No minimum data-capture threshold is applied.

The chunk identifier in `download_status.csv` has the form:

```text
data_type|pollutant|year_or_years
```

For example, `hourly|no2|2025` is a single-year hourly chunk, while an annual
chunk contains its complete comma-separated year range. Resume mode uses the
latest record for the exact identifier; failed and empty latest records are
retried.

## Development

Regenerate documentation and run the test suite:

```r
devtools::document()
devtools::test()
devtools::check()
```

Every reusable function lives in its own file under `R/` and has roxygen2
documentation. Tests cover availability rules, chunking, schema consistency,
means, resume status, QA comparisons, and partition replacement.

## Future Work

Maximum daily 8-hour ozone means, DAQI calculations, and weekday/weekend means
are intentionally disabled. They are listed in `R/future_means.R` and should
only be enabled once implemented as documented, tested package functions.
