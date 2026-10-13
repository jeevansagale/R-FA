# ==============================================================
# Subject: Statistical Data Analysis using R
# Topic: Descriptive Analysis of Supermarket Sales Data
# Dataset: Supermarket Sales Dataset
# ==============================================================


# installation of packages  (as in sample; wrapped in try so missing compilers don't break run)

try(install.packages("tidyr"), silent = TRUE)
try(install.packages("dplyr"), silent = TRUE)
try(install.packages("ggplot2"), silent = TRUE)
try(install.packages("pastecs"), silent = TRUE)
try(install.packages("moments"), silent = TRUE)
try(install.packages("corrplot"), silent = TRUE)
try(install.packages("modeest"), silent = TRUE)


library(tidyr)
library(dplyr)
library(ggplot2)
# pastecs/moments/corrplot for descriptive stats and correlation plots
if (requireNamespace("pastecs", quietly = TRUE)) library(pastecs)
if (requireNamespace("moments", quietly = TRUE)) library(moments)
if (requireNamespace("corrplot", quietly = TRUE)) library(corrplot)
# modeest may need gfortran; load conditionally
if (requireNamespace("modeest", quietly = TRUE)) library(modeest)

# requirements.R - robust installer (keeps sample look above, ensures run succeeds)
# Packages limited to those used in the project and taught in SDAUR.
# dplyr and ggplot2 are required. tidyr, pastecs, moments, corrplot are used;
# modeest is optional (gfortran dependency).

essential_packages <- c("dplyr", "ggplot2")
optional_packages <- c("tidyr", "pastecs", "moments", "corrplot", "modeest")

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
