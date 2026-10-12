# Shared helper functions for R_Unit1_to_Unit4_Project.

# Save a ggplot object in the project's plots folder and return it invisibly.
save_project_plot <- function(plot_object, file_name, width = 9, height = 6, dpi = 300) {
  output_file <- file.path(project_root, "outputs", "plots", file_name)
  ggplot2::ggsave(filename = output_file, plot = plot_object,
                  width = width, height = height, dpi = dpi)
  message("Saved plot: ", output_file)
  invisible(plot_object)
}

# Safe numeric summary used by student exercises.
safe_numeric_summary <- function(x) {
  x <- x[!is.na(x) & is.finite(x)]
  if (length(x) == 0) {
    return(c(n = 0, mean = NA, median = NA, sd = NA, IQR = NA))
  }
  c(n = length(x), mean = mean(x), median = median(x),
    sd = if (length(x) > 1) sd(x) else NA_real_, IQR = IQR(x))
}
