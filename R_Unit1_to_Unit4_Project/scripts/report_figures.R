# REPORT FIGURES: the seven figures embedded in the FA-II report.
# Built from the same tables as problem_statements.R, after that script runs.

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

# Figure 1: total revenue by product line (precomputed values -> geom_col)
fig1 <- ggplot2::ggplot(ps1, ggplot2::aes(x = stats::reorder(`Product line`, Revenue),
                                          y = Revenue, fill = `Product line`)) +
  ggplot2::geom_col(color = "white", show.legend = FALSE) +
  ggplot2::coord_flip() +
  ggplot2::geom_text(ggplot2::aes(label = round(Revenue, 0)), hjust = -0.1, size = 3) +
  ggplot2::labs(title = "Figure 1. Total revenue by product line",
                subtitle = "Sum of invoice Total for the 1,000 supplied transactions",
                x = "Product line", y = "Total revenue (currency units)") +
  ggplot2::theme_minimal() +
  ggplot2::expand_limits(y = max(ps1$Revenue) * 1.15)
save_report_figure(fig1, "fig1_revenue_by_product_line.png", 8, 5)

# Figure 2: total revenue by branch (precomputed values -> geom_col)
fig2 <- ggplot2::ggplot(ps2, ggplot2::aes(x = Branch, y = Revenue, fill = City)) +
  ggplot2::geom_col(color = "white") +
  ggplot2::geom_text(ggplot2::aes(label = round(Revenue, 0)), vjust = -0.4, size = 3) +
  ggplot2::labs(title = "Figure 2. Total revenue by branch",
                subtitle = "Branch C = Naypyitaw, Branch A = Yangon, Branch B = Mandalay",
                x = "Branch", y = "Total revenue (currency units)", fill = "City") +
  ggplot2::theme_minimal() +
  ggplot2::expand_limits(y = max(ps2$Revenue) * 1.12)
save_report_figure(fig2, "fig2_revenue_by_branch.png", 8, 5)

# Figure 3: filtered boxplots of invoice total by customer type (grid viewport)
fig3 <- ggplot2::ggplot(dplyr::filter(sales_clean, !is.na(Total)),
                        ggplot2::aes(x = `Customer type`, y = Total,
                                     fill = `Customer type`)) +
  ggplot2::geom_boxplot(outlier.color = "red", outlier.size = 0.6, show.legend = FALSE) +
  ggplot2::labs(title = "Figure 3. Invoice total by customer type",
                subtitle = "Box = interquartile range, line = median, points = potential outliers",
                x = "Customer type", y = "Invoice Total") +
  ggplot2::theme_minimal()
save_report_figure(fig3, "fig3_customer_type_boxplot.png", 8, 5)

# Figure 4: payment-method usage counts (row counts -> geom_bar)
fig4 <- ggplot2::ggplot(sales_clean, ggplot2::aes(x = Payment, fill = Payment)) +
  ggplot2::geom_bar(color = "white", show.legend = FALSE) +
  ggplot2::geom_text(ggplot2::aes(label = after_stat(count)), stat = "count",
                     vjust = -0.6, size = 3.2) +
  ggplot2::labs(title = "Figure 4. Number of transactions by payment method",
                x = "Payment method", y = "Number of transactions") +
  ggplot2::theme_minimal() +
  ggplot2::expand_limits(y = max(table(sales_clean$Payment)) * 1.15)
save_report_figure(fig4, "fig4_payment_methods.png", 8, 5)

# Figure 5: quantity vs invoice total scatter with fitted line
fig5 <- ggplot2::ggplot(sales_clean, ggplot2::aes(x = Quantity, y = Total)) +
  ggplot2::geom_point(color = "steelblue", alpha = 0.6, size = 1.4) +
  ggplot2::geom_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE) +
  ggplot2::labs(title = "Figure 5. Quantity purchased versus invoice total",
                subtitle = paste0("Pearson r = ", round(unname(ps5_cor$estimate), 3),
                                  ", n = ", sum(!is.na(sales_clean$Quantity))),
                x = "Quantity of items on the invoice", y = "Invoice Total") +
  ggplot2::theme_minimal()
save_report_figure(fig5, "fig5_quantity_vs_total.png", 8, 5)

# Figure 6: distribution of customer ratings
fig6 <- ggplot2::ggplot(sales_clean, ggplot2::aes(x = Rating)) +
  ggplot2::geom_histogram(binwidth = 0.5, fill = "lightgreen", color = "darkgreen") +
  ggplot2::geom_vline(xintercept = mean(sales_clean$Rating, na.rm = TRUE),
                      color = "red", linetype = "dashed", linewidth = 0.8) +
  ggplot2::annotate("text", x = mean(sales_clean$Rating, na.rm = TRUE) + 0.1,
                    y = Inf, label = "mean", color = "red", hjust = 0, vjust = 1.6) +
  ggplot2::labs(title = "Figure 6. Distribution of customer ratings",
                subtitle = paste0("n = ", sum(!is.na(sales_clean$Rating)),
                                  ", median = ", median(sales_clean$Rating, na.rm = TRUE)),
                x = "Customer rating (0-10)", y = "Number of transactions") +
  ggplot2::theme_minimal()
save_report_figure(fig6, "fig6_rating_distribution.png", 8, 5)

# Figure 7: monthly revenue over the three supplied months
fig7 <- ggplot2::ggplot(ps7_month, ggplot2::aes(x = Month, y = Revenue,
                                                group = 1)) +
  ggplot2::geom_col(fill = "steelblue", color = "white") +
  ggplot2::geom_line(color = "darkred", linewidth = 0.8) +
  ggplot2::geom_point(color = "darkred", size = 2) +
  ggplot2::geom_text(ggplot2::aes(label = round(Revenue, 0)), vjust = -0.5, size = 3) +
  ggplot2::labs(title = "Figure 7. Revenue by month (supplied period only)",
                subtitle = "Data cover 2019-01-01 to 2019-03-30; no long-term trend implied",
                x = "Month", y = "Total revenue (currency units)") +
  ggplot2::theme_minimal() +
  ggplot2::expand_limits(y = max(ps7_month$Revenue) * 1.15)
save_report_figure(fig7, "fig7_monthly_revenue.png", 8, 5)

cat("\n[REPORT FIGURES] Completed.\n")
