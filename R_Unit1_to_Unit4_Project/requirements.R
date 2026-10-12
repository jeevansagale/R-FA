# requirements.R
# Run this file once if any required package is not installed.
# Packages are limited to those used in the project and taught in SDAUR.
#
# Only dplyr and ggplot2 are required by the supermarket analysis. tidyr is used
# by one toy teaching example in scripts/course_concept_demos.R, so the project
# can still complete if tidyr cannot be installed (e.g. no internet access).

essential_packages <- c("dplyr", "ggplot2")
optional_packages <- c("tidyr")

check_package <- function(package_name) {
  ok <- requireNamespace(package_name, quietly = TRUE)
  cat(if (ok) "  available: " else "  MISSING:   ", package_name, "\n", sep = "")
  ok
}

cat("Checking R packages\n")
missing_essential <- essential_packages[
  !vapply(essential_packages, requireNamespace, logical(1), quietly = TRUE)
]
missing_optional <- optional_packages[
  !vapply(optional_packages, requireNamespace, logical(1), quietly = TRUE)
]

installable <- function(packages) {
  if (length(packages) == 0) return(invisible(TRUE))
  cat("Installing:", paste(packages, collapse = ", "), "\n")
  try(install.packages(packages, repos = "https://cloud.r-project.org"),
      silent = TRUE)
  vapply(packages, requireNamespace, logical(1), quietly = TRUE)
}

if (length(missing_essential) > 0) {
  ok <- installable(missing_essential)
  if (!all(ok)) {
    stop("Required package(s) could not be installed: ",
         paste(missing_essential[!ok], collapse = ", "),
         ".\nInstall them manually (install.packages(c(\"dplyr\",\"ggplot2\"))) and re-run.")
  }
}

if (length(missing_optional) > 0) {
  ok <- installable(missing_optional)
  if (!all(ok)) {
    warning("Optional package(s) not available: ",
            paste(missing_optional[!ok], collapse = ", "),
            ". The toy tidyr demo in scripts/course_concept_demos.R will be skipped.",
            call. = FALSE)
  }
}

cat("Required packages are available:\n")
invisible(lapply(essential_packages, check_package))
invisible(lapply(optional_packages, check_package))
