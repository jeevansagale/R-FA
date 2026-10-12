# REPORT FIGURES: fig1-fig5 embedded in the FA-II report.
# Built from the same tables as scripts/problem_statements.R, after that script runs.

cat("\n[REPORT FIGURES] Building report figures\n")

figures_dir <- file.path(project_root, "report", "figures")
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

save_report_figure <- function(plot_object, file_name, width = 8.0, height = 5.0) {
  output_file <- file.path(figures_dir, file_name)
  ggplot2::ggsave(filename = output_file, plot = plot_object,
                  width = width, height = height, dpi = 200)
  message("Saved figure: ", output_file)
  invisible(plot_object)
}

save_grid_figure <- function(top_plot, bottom_plot, file_name,
                             width_in = 8.0, height_in = 6.4) {
  output_file <- file.path(figures_dir, file_name)
  grDevices::png(output_file, width = width_in * 200, height = height_in * 200, res = 200)
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(2, 1)))
  print(top_plot, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1))
  print(bottom_plot, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1))
  grDevices::dev.off()
  message("Saved figure: ", output_file)
  invisible(output_file)
}

# Figure 1: mean rating and total gross income by product line.
fig1_top <- ggplot2::ggplot(ps1, ggplot2::aes(x = stats::reorder(`Product line`, Mean_Rating),
                                              y = Mean_Rating, fill = `Product line`)) +
  ggplot2::geom_col(color = "white", show.legend = FALSE) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Figure 1a. Mean customer rating by product line",
                x = "Product line", y = "Mean rating (0-10)") +
  ggplot2::theme_minimal()
fig1_bottom <- ggplot2::ggplot(ps1, ggplot2::aes(x = stats::reorder(`Product line`, Total_Gross_Income),
                                                 y = Total_Gross_Income, fill = `Product line`)) +
  ggplot2::geom_col(color = "white", show.legend = FALSE) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Figure 1b. Total gross income by product line",
                x = "Product line", y = "Total gross income") +
  ggplot2::theme_minimal()
save_grid_figure(fig1_top, fig1_bottom, "fig1_product_line_performance.png")

# Figure 2: branch revenue and customer-type mix by branch.
fig2_top <- ggplot2::ggplot(ps2_rev, ggplot2::aes(x = Branch, y = Revenue, fill = City)) +
  ggplot2::geom_col(color = "white") +
  ggplot2::geom_text(ggplot2::aes(label = round(Revenue, 0)), vjust = -0.4, size = 3) +
  ggplot2::labs(title = "Figure 2a. Total revenue by branch",
                subtitle = "C = Naypyitaw, A = Yangon, B = Mandalay",
                x = "Branch", y = "Total revenue", fill = "City") +
  ggplot2::theme_minimal() +
  ggplot2::expand_limits(y = max(ps2_rev$Revenue) * 1.12)
fig2_counts <- sales_clean %>%
  dplyr::group_by(Branch, `Customer type`) %>%
  dplyr::summarise(Transactions = dplyr::n(), .groups = "drop")
fig2_bottom <- ggplot2::ggplot(fig2_counts,
  ggplot2::aes(x = Branch, y = Transactions, fill = `Customer type`)) +
  ggplot2::geom_bar(stat = "identity", position = "dodge", color = "white") +
  ggplot2::labs(title = "Figure 2b. Member vs Normal transactions by branch",
                x = "Branch", y = "Transactions", fill = "Customer type") +
  ggplot2::theme_minimal()
save_grid_figure(fig2_top, fig2_bottom, "fig2_branch_comparison.png")

# Figure 3: payment preference by gender, faceted by customer type.
fig3_data <- sales_clean %>%
  dplyr::group_by(Payment, Gender, `Customer type`) %>%
  dplyr::summarise(Transactions = dplyr::n(), .groups = "drop")
fig3 <- ggplot2::ggplot(fig3_data,
  ggplot2::aes(x = Payment, y = Transactions, fill = Gender)) +
  ggplot2::geom_col(position = "dodge", color = "white") +
  ggplot2::facet_wrap(~`Customer type`) +
  ggplot2::labs(title = "Figure 3. Payment method by gender and customer type",
                x = "Payment method", y = "Transactions", fill = "Gender") +
  ggplot2::theme_minimal()
save_report_figure(fig3, "fig3_payment_demographics.png")

# Figure 4: hourly volume and weekday revenue.
fig4_top <- ggplot2::ggplot(ps4_hour, ggplot2::aes(x = factor(Hour), y = Transactions)) +
  ggplot2::geom_col(fill = "steelblue", color = "white") +
  ggplot2::geom_text(ggplot2::aes(label = Transactions), vjust = -0.4, size = 3) +
  ggplot2::labs(title = "Figure 4a. Transactions by hour of day",
                x = "Hour", y = "Transactions") +
  ggplot2::theme_minimal() +
  ggplot2::expand_limits(y = max(ps4_hour$Transactions) * 1.12)
fig4_bottom <- ggplot2::ggplot(ps4_day,
  ggplot2::aes(x = stats::reorder(Weekday, Revenue), y = Revenue)) +
  ggplot2::geom_col(fill = "darkorange", color = "white") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Figure 4b. Revenue by weekday",
                x = "Weekday", y = "Total revenue") +
  ggplot2::theme_minimal()
save_grid_figure(fig4_top, fig4_bottom, "fig4_peak_hours_days.png")

# Figure 5: unit price vs quantity, coloured by product line.
fig5 <- ggplot2::ggplot(sales_clean,
  ggplot2::aes(x = `Unit price`, y = Quantity, color = `Product line`)) +
  ggplot2::geom_point(alpha = 0.6, size = 1.4) +
  ggplot2::geom_smooth(method = "lm", formula = y ~ x, color = "black",
                       linetype = "dashed", se = FALSE) +
  ggplot2::labs(title = "Figure 5. Unit price versus quantity purchased",
                subtitle = paste0("Pearson r = ", round(unname(ps5_qty$estimate), 3),
                                  " (n = 1000): no linear link in this sample"),
                x = "Unit price", y = "Quantity", color = "Product line") +
  ggplot2::theme_minimal()
save_report_figure(fig5, "fig5_price_vs_quantity.png")

cat("\n[REPORT FIGURES] Completed.\n")
