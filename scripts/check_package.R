required_version <- package_version("0.1.1")

if (!requireNamespace("aqdatapipeline", quietly = TRUE)) {
  stop(
    "The aqdatapipeline package is not installed. Run ",
    "`devtools::install(upgrade = \"never\")` from the repository root."
  )
}

installed_version <- utils::packageVersion("aqdatapipeline")
if (installed_version < required_version) {
  stop(
    "The installed aqdatapipeline package is out of date (installed: ",
    installed_version, "; required: ", required_version, "). Run ",
    "`devtools::install(upgrade = \"never\")` from the repository root."
  )
}
