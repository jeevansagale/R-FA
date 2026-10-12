# INTEGRATED ANALYSIS: cleaning, grouped summaries, tests, regression.

cat("\n[INTEGRATED PROJECT] Starting combined supermarket analysis\n")

# Confirm that the dataset has the expected fields; do not invent columns.
expected_fields <- c("Invoice ID", "Branch", "City", "Customer type", "Gender",
                     "Product line", "Unit price", "Quantity", "Total",
                     "Payment", "cogs", "gross income", "Rating")
missing_fields <- setdiff(expected_fields, names(supermarket_data))
if (length(missing_fields) > 0) {
  stop(paste("Required dataset fields not found:", paste(missing_fields, collapse = ", ")))
}

# 1. Data quality and basic dimensions.
data_quality_report <- data.frame(
  Rows = nrow(supermarket_data),
  Columns = ncol(supermarket_data),
  Missing_Cells = sum(is.na(supermarket_data)),
  Duplicate_Rows = sum(duplicated(supermarket_data)),
  Distinct_Invoices = length(unique(supermarket_data$`Invoice ID`))
)
print(data_quality_report)
write.csv(data_quality_report,
  file.path(project_root, "outputs/reports/integrated_data_quality_report.csv"),
  row.names = FALSE)

# 2. Grouped product line performance.
integrated_product_summary <- supermarket_data %>%
  dplyr::group_by(`Product line`) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Total_Revenue = sum(Total, na.rm = TRUE),
    Average_Invoice = mean(Total, na.rm = TRUE),
    Median_Invoice = median(Total, na.rm = TRUE),
    Average_Gross_Income = mean(`gross income`, na.rm = TRUE),
    Average_Rating = mean(Rating, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::arrange(dplyr::desc(Total_Revenue))
print(integrated_product_summary)
write.csv(integrated_product_summary,
  file.path(project_root, "outputs/reports/integrated_product_performance.csv"),
  row.names = FALSE)

# Plot: total revenue by product line.
p_integrated_revenue <- ggplot2::ggplot(integrated_product_summary,
  ggplot2::aes(x = reorder(`Product line`, Total_Revenue),
               y = Total_Revenue, fill = `Product line`)) +
  ggplot2::geom_col(color = "white") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Integrated Analysis: Revenue by Product Line",
                x = "Product Line", y = "Total Revenue") +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "none")
save_project_plot(p_integrated_revenue, "integrated_revenue_by_product_line.png")
# Inferences:
# The chart ranks product lines by revenue in the supplied dataset. Revenue
# combines transaction frequency and transaction size; it is not the same as
# profit. Use the summary table's gross-income measure for additional context.

# 3. A descriptive relationship check between quantity and total.
quantity_total_correlation <- cor(supermarket_data$Quantity,
                                  supermarket_data$Total,
                                  use = "complete.obs")
cat("Correlation between Quantity and Total:", quantity_total_correlation, "\n")
write.csv(data.frame(
  Relationship = "Quantity and Total",
  Pearson_Correlation = quantity_total_correlation
), file.path(project_root, "outputs/reports/integrated_quantity_total_correlation.csv"),
row.names = FALSE)

# Plot: quantity against invoice total.
p_integrated_quantity <- ggplot2::ggplot(supermarket_data,
  ggplot2::aes(x = Quantity, y = Total)) +
  ggplot2::geom_point(alpha = 0.55, color = "steelblue") +
  ggplot2::geom_smooth(method = "lm", formula = y ~ x,
                       color = "red", se = TRUE) +
  ggplot2::labs(title = "Integrated Analysis: Quantity vs Invoice Total",
                x = "Quantity of Items", y = "Invoice Total") +
  ggplot2::theme_minimal()
save_project_plot(p_integrated_quantity, "integrated_quantity_vs_total.png")
# Inferences:
# The fitted line summarizes the average linear association between quantity
# and invoice total. Scatter around the line reflects differences in unit prices
# and product mix. Correlation is not proof of causation.

# 4. Hypothesis test: total invoice value differs across branches (one-way ANOVA).
anova_data <- supermarket_data[complete.cases(supermarket_data[, c("Total", "Branch")]),
                               c("Total", "Branch")]
anova_data$Branch <- as.factor(anova_data$Branch)
if (nlevels(droplevels(anova_data$Branch)) >= 2) {
  branch_anova <- aov(Total ~ Branch, data = anova_data)
  anova_result <- summary(branch_anova)
  print(anova_result)
  capture.output(anova_result,
    file = file.path(project_root, "outputs/reports/integrated_branch_anova.txt"))
}

p_branch_total <- ggplot2::ggplot(anova_data,
  ggplot2::aes(x = Branch, y = Total, fill = Branch)) +
  ggplot2::geom_boxplot(outlier.color = "red") +
  ggplot2::labs(title = "Integrated Analysis: Invoice Total by Branch",
                x = "Branch", y = "Invoice Total") +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "none")
save_project_plot(p_branch_total, "integrated_total_by_branch.png")
# Inferences:
# The boxplots compare medians, middle spreads, and potential outliers across
# branches. The ANOVA p-value in the saved report tests whether all branch means
# are equal; a significant result means at least one mean differs, not which one.

# 5. Export a small human-readable report.
report_lines <- c(
  "SUPERMARKET SALES - INTEGRATED PROJECT SUMMARY",
  paste("Rows:", nrow(supermarket_data)),
  paste("Columns:", ncol(supermarket_data)),
  paste("Missing cells:", sum(is.na(supermarket_data))),
  paste("Duplicate rows:", sum(duplicated(supermarket_data))),
  paste("Mean invoice total:", round(mean(supermarket_data$Total, na.rm = TRUE), 2)),
  paste("Median invoice total:", round(median(supermarket_data$Total, na.rm = TRUE), 2)),
  paste("Mean gross income:", round(mean(supermarket_data$`gross income`, na.rm = TRUE), 2)),
  paste("Mean customer rating:", round(mean(supermarket_data$Rating, na.rm = TRUE), 2)),
  "",
  "Interpret all tests using their p-values and assumptions.",
  "The data represents the supplied dataset and may not represent all supermarket customers."
)
writeLines(report_lines, file.path(project_root, "outputs/reports/integrated_project_summary.txt"))
cat("[INTEGRATED PROJECT] Completed.\n")
