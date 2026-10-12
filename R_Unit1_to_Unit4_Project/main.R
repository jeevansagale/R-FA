# ==============================================================================
# MAIN ENTRY POINT: R UNIT 1 TO UNIT 4 PROJECT
# Open R_Unit1_to_Unit4_Project.Rproj in RStudio, then run this file.
# ==============================================================================

cat("\n============================================================\n")
cat("R PROGRAMMING PROJECT: UNIT 1 TO UNIT 4\n")
cat("Dataset: Supermarket Sales\n")
cat("Execution order: Unit 1 -> Unit 2 -> Unit 3 -> Unit 4 -> Problem Statements\n")
cat("============================================================\n")

# ---------------------------------------------------------------------------
# Project root.
# Derive the root from this file's location so main.R works even when the
# working directory is not the project root (e.g. Rscript /full/path/main.R).
# ---------------------------------------------------------------------------
main_arguments <- commandArgs(trailingOnly = FALSE)
main_file <- sub("^--file=", "", main_arguments[grepl("^--file=", main_arguments)])
if (length(main_file) == 0) {
  # Interactive / sourced execution: fall back to the current directory.
  project_root <- getwd()
} else {
  project_root <- dirname(normalizePath(main_file, mustWork = FALSE))
}
# When main.R is sourced from another script, commandArgs() still reports the
# top-level file, so verify the expected layout and correct the root if needed.
if (!file.exists(file.path(project_root, "scripts", "unit1.R")) &&
    file.exists(file.path(getwd(), "scripts", "unit1.R"))) {
  project_root <- normalizePath(getwd())
}
cat("\nProject root:", project_root, "\n")

required_paths <- c(
  "data/supermarket_sales.csv",
  "scripts/unit1.R",
  "scripts/course_concept_demos.R",
  "scripts/unit2.R",
  "scripts/unit3.R",
  "scripts/unit4.R",
  "scripts/problem_statements.R",
  "scripts/report_figures.R",
  "scripts/verify_results.R",
  "functions/helper_functions.R",
  "requirements.R"
)
missing_paths <- required_paths[!file.exists(file.path(project_root, required_paths))]
if (length(missing_paths) > 0) {
  stop(
    paste0(
      "Required project file(s) not found relative to: ", project_root, "\n",
      paste(missing_paths, collapse = "\n"),
      "\nOpen R_Unit1_to_Unit4_Project.Rproj in RStudio and run main.R again."
    )
  )
}

# Load/install packages through the separate requirements file.
source(file.path(project_root, "requirements.R"), local = .GlobalEnv)
library(dplyr)
library(ggplot2)
if (requireNamespace("tidyr", quietly = TRUE)) library(tidyr)

# Create output directories if a user deleted them.
output_dirs <- c("outputs/plots", "outputs/reports", "report/figures")
for (dir in output_dirs) {
  dir.create(file.path(project_root, dir), recursive = TRUE, showWarnings = FALSE)
}

# Load shared helper functions.
source(file.path(project_root, "functions", "helper_functions.R"),
       local = .GlobalEnv)

# ---------------------------------------------------------------------------
# Dataset resolution.
# Search order: (1) the project-local copy, (2) the documented Windows location
# used for this practical, (3) the file name next to this project. The file
# actually used is reported so results are always traceable.
# ---------------------------------------------------------------------------
candidate_dataset_paths <- c(
  file.path(project_root, "data", "supermarket_sales.csv"),
  "D:/PCCOE/sem3/R/units/project/supermarket_sales.csv",
  file.path(project_root, "supermarket_sales.csv"),
  file.path(dirname(project_root), "supermarket_sales.csv")
)
dataset_path <- candidate_dataset_paths[file.exists(candidate_dataset_paths)][1]
if (is.na(dataset_path)) {
  stop(
    "No dataset found. Searched:\n  ",
    paste(candidate_dataset_paths, collapse = "\n  "),
    "\nPlace supermarket_sales.csv in the project's data/ folder and re-run."
  )
}
cat("\nLoading dataset:", dataset_path, "\n")
supermarket_data <- read.csv(dataset_path, stringsAsFactors = FALSE,
                             check.names = FALSE)

if (nrow(supermarket_data) == 0 || ncol(supermarket_data) == 0) {
  stop("The CSV was loaded but contains no rows or columns.")
}

cat("Dataset loaded successfully:", nrow(supermarket_data), "rows and",
    ncol(supermarket_data), "columns.\n")

# Execute all units in the required order. The scripts use shared objects and
# helper functions created above and in earlier unit scripts.
script_sequence <- c(
  "scripts/unit1.R",
  "scripts/course_concept_demos.R",
  "scripts/unit2.R",
  "scripts/unit3.R",
  "scripts/unit4.R",
  "scripts/problem_statements.R",
  "scripts/report_figures.R",
  "scripts/verify_results.R"
)

for (script_relative_path in script_sequence) {
  cat("\n------------------------------------------------------------\n")
  cat("Running:", script_relative_path, "\n")
  cat("------------------------------------------------------------\n")
  source(file.path(project_root, script_relative_path), local = .GlobalEnv)
}

cat("\n============================================================\n")
cat("PROJECT RUN FINISHED\n")
cat("Review tables in outputs/reports/ and plots in outputs/plots/.\n")
cat("Report figures in report/figures/; verification table in\n")
cat("outputs/reports/verification_results.csv.\n")
cat("============================================================\n")
