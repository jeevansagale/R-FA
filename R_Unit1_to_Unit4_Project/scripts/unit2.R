# UNIT 2: cleaning, descriptive statistics, dplyr, visualization
# Sources: descriptive-stats, dplyr, missing-value and plotting practicals in SDAUR.zip.

cat("\n[UNIT 2] Data cleaning, summaries, and visualization\n")

# Work on a copy; keep the imported source object unchanged.
sales_clean <- supermarket_data

# Remove accidental whitespace from text columns.
text_columns <- names(sales_clean)[vapply(sales_clean, is.character, logical(1))]
for (nm in text_columns) sales_clean[[nm]] <- trimws(sales_clean[[nm]])

# Convert types using the actual dataset columns.
if ("Date" %in% names(sales_clean)) {
  sales_clean$Date <- as.Date(sales_clean$Date, format = "%m/%d/%Y")
}
factor_columns <- intersect(
  c("Branch", "City", "Customer type", "Gender", "Product line", "Payment"),
  names(sales_clean)
)
for (nm in factor_columns) sales_clean[[nm]] <- as.factor(sales_clean[[nm]])

# Check duplicates; retain all rows in the main analysis but export the duplicate
# count. This avoids silently deleting valid repeated-looking transactions.
duplicate_rows <- duplicated(sales_clean)
duplicate_audit <- data.frame(
  Total_Rows = nrow(sales_clean),
  Duplicate_Rows_After_First_Occurrence = sum(duplicate_rows)
)
print(duplicate_audit)
write.csv(duplicate_audit,
          file.path(project_root, "outputs/reports/unit2_duplicate_audit.csv"),
          row.names = FALSE)

# Missing values: show counts, percentages and a complete-case version for
# analyses that require complete observations.
missing_audit <- data.frame(
  Variable = names(sales_clean),
  Missing_Count = colSums(is.na(sales_clean)),
  Missing_Percent = round(colSums(is.na(sales_clean)) / nrow(sales_clean) * 100, 2)
)
print(missing_audit)
write.csv(missing_audit,
          file.path(project_root, "outputs/reports/unit2_missing_value_audit.csv"),
          row.names = FALSE)

# Course-style select(), filter(), mutate(), arrange(), group_by(), summarise().
# City is kept in the selection because the branch summary groups by Branch and
# City (the two columns are one-to-one in this dataset).
selected_sales <- dplyr::select(sales_clean, Branch, City, `Product line`, Total,
                                Quantity, `gross income`, Rating)
filtered_sales <- dplyr::filter(selected_sales, Total > 0, Quantity > 0)
mutated_sales <- dplyr::mutate(
  filtered_sales,
  Average_Amount_Per_Item = Total / Quantity,
  High_Value_Transaction = Total >= median(Total, na.rm = TRUE)
)
ordered_sales <- dplyr::arrange(mutated_sales, dplyr::desc(Total))
print(head(ordered_sales, 10))

product_summary <- mutated_sales %>%
  dplyr::group_by(`Product line`) %>%
  dplyr::summarise(
    Transaction_Count = dplyr::n(),
    Mean_Total = mean(Total, na.rm = TRUE),
    Median_Total = median(Total, na.rm = TRUE),
    SD_Total = sd(Total, na.rm = TRUE),
    IQR_Total = IQR(Total, na.rm = TRUE),
    Mean_Gross_Income = mean(`gross income`, na.rm = TRUE),
    Mean_Rating = mean(Rating, na.rm = TRUE),
    Total_Revenue = sum(Total, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::arrange(dplyr::desc(Total_Revenue))
print(product_summary)
write.csv(product_summary,
          file.path(project_root, "outputs/reports/unit2_product_line_summary.csv"),
          row.names = FALSE)

branch_summary <- mutated_sales %>%
  dplyr::group_by(Branch, City) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Revenue = sum(Total, na.rm = TRUE),
    Average_Total = mean(Total, na.rm = TRUE),
    Average_Rating = mean(Rating, na.rm = TRUE),
    .groups = "drop"
  )
print(branch_summary)
write.csv(branch_summary,
          file.path(project_root, "outputs/reports/unit2_branch_summary.csv"),
          row.names = FALSE)

# Course practical: central tendency and dispersion.
numeric_vars <- intersect(c("Unit price", "Quantity", "Tax 5%", "Total",
                            "cogs", "gross income", "Rating"), names(sales_clean))
descriptive_table <- data.frame(
  Variable = numeric_vars,
  N = vapply(sales_clean[numeric_vars], function(x) sum(!is.na(x)), integer(1)),
  Mean = vapply(sales_clean[numeric_vars], mean, numeric(1), na.rm = TRUE),
  Median = vapply(sales_clean[numeric_vars], median, numeric(1), na.rm = TRUE),
  SD = vapply(sales_clean[numeric_vars], sd, numeric(1), na.rm = TRUE),
  Variance = vapply(sales_clean[numeric_vars], var, numeric(1), na.rm = TRUE),
  IQR = vapply(sales_clean[numeric_vars], IQR, numeric(1), na.rm = TRUE),
  CV_Percent = vapply(sales_clean[numeric_vars], function(x) {
    avg <- mean(x, na.rm = TRUE)
    if (is.na(avg) || avg == 0) NA_real_ else sd(x, na.rm = TRUE) / avg * 100
  }, numeric(1))
)
print(descriptive_table)
write.csv(descriptive_table,
          file.path(project_root, "outputs/reports/unit2_descriptive_statistics.csv"),
          row.names = FALSE)

# Base-R skewness and excess kurtosis, matching the concepts in the course
# moments practical without requiring moments as an extra package.
base_skewness <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 3 || sd(x) == 0) return(NA_real_)
  mean((x - mean(x))^3) / sd(x)^3
}
base_excess_kurtosis <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 4 || var(x) == 0) return(NA_real_)
  mean((x - mean(x))^4) / var(x)^2 - 3
}
shape_table <- data.frame(
  Variable = numeric_vars,
  Skewness = vapply(sales_clean[numeric_vars], base_skewness, numeric(1)),
  Excess_Kurtosis = vapply(sales_clean[numeric_vars], base_excess_kurtosis, numeric(1))
)
print(shape_table)
write.csv(shape_table,
          file.path(project_root, "outputs/reports/unit2_skewness_kurtosis.csv"),
          row.names = FALSE)

# Plot 1: histogram of Total.
p_total_hist <- ggplot2::ggplot(sales_clean, ggplot2::aes(x = Total)) +
  ggplot2::geom_histogram(bins = 30, fill = "steelblue", color = "white",
                          na.rm = TRUE) +
  ggplot2::labs(title = "Distribution of Supermarket Invoice Totals",
                x = "Invoice Total", y = "Frequency") +
  ggplot2::theme_minimal()
save_project_plot(p_total_hist, "unit2_total_histogram.png")
# Inferences:
# The histogram reveals where invoice totals are concentrated and whether the
# distribution has a long tail. Confirm apparent skew using the numeric
# skewness, mean, and median tables rather than assuming a shape.

# Plot 2: density plot of Total.
p_total_density <- ggplot2::ggplot(sales_clean, ggplot2::aes(x = Total)) +
  ggplot2::geom_density(fill = "darkseagreen3", color = "darkgreen",
                        alpha = 0.65, na.rm = TRUE) +
  ggplot2::labs(title = "Density of Invoice Totals",
                x = "Invoice Total", y = "Estimated Density") +
  ggplot2::theme_minimal()
save_project_plot(p_total_density, "unit2_total_density.png")
# Inferences:
# The density curve smooths the distribution and identifies the region of
# greatest concentration. Broadness reflects spread; tails suggest asymmetry.
# The plot is descriptive and does not itself test statistical significance.

# Plot 3: boxplot of Total.
p_total_box <- ggplot2::ggplot(sales_clean, ggplot2::aes(y = Total)) +
  ggplot2::geom_boxplot(fill = "lightblue", color = "navy",
                        outlier.color = "red", na.rm = TRUE) +
  ggplot2::labs(title = "Boxplot of Invoice Totals",
                x = "All transactions", y = "Invoice Total") +
  ggplot2::theme_minimal()
save_project_plot(p_total_box, "unit2_total_boxplot.png")
# Inferences:
# The box spans the middle 50% of invoice totals and its center line is the
# median. Points beyond whiskers are potential outliers, not automatic errors;
# review source records before removing them.

# Plot 4: product line frequency bar chart.
p_product_count <- ggplot2::ggplot(sales_clean,
  ggplot2::aes(x = `Product line`, fill = `Product line`)) +
  ggplot2::geom_bar(color = "white") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Transaction Frequency by Product Line",
                x = "Product Line", y = "Number of Transactions") +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "none")
save_project_plot(p_product_count, "unit2_product_line_bar.png")
# Inferences:
# Longer bars indicate more transactions, not necessarily greater revenue or
# profit. Compare with the product summary's revenue and gross-income measures
# to make a more balanced performance assessment.

# Plot 5: boxplot of total by product line.
p_product_box <- ggplot2::ggplot(sales_clean,
  ggplot2::aes(x = `Product line`, y = Total, fill = `Product line`)) +
  ggplot2::geom_boxplot(na.rm = TRUE, outlier.color = "red") +
  ggplot2::labs(title = "Invoice Totals by Product Line",
                x = "Product Line", y = "Invoice Total") +
  ggplot2::theme_minimal() +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1),
                 legend.position = "none")
save_project_plot(p_product_box, "unit2_total_by_product_line.png")
# Inferences:
# Compare group medians and interquartile ranges for typical value and spread.
# Potential outliers may be genuine large purchases. Visual group differences
# are descriptive and require an appropriate test for inferential claims.

# Plot 6: branch revenue.
p_branch_revenue <- ggplot2::ggplot(branch_summary,
  ggplot2::aes(x = Branch, y = Revenue, fill = Branch)) +
  ggplot2::geom_col(color = "white") +
  ggplot2::labs(title = "Total Revenue by Branch",
                x = "Branch", y = "Total Revenue") +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "none")
save_project_plot(p_branch_revenue, "unit2_branch_revenue.png")
# Inferences:
# Bar height compares aggregate revenue in the supplied data. Revenue depends
# on transaction volume and customer mix, so it should not be interpreted as
# a direct measure of branch efficiency without additional context.

# Plot 7: scatterplot of Unit price and Total, a course scatterplot practical.
p_price_total <- ggplot2::ggplot(sales_clean,
  ggplot2::aes(x = `Unit price`, y = Total)) +
  ggplot2::geom_point(color = "blue", alpha = 0.65) +
  ggplot2::labs(title = "Unit Price vs Invoice Total",
                x = "Unit Price", y = "Invoice Total") +
  ggplot2::theme_minimal()
save_project_plot(p_price_total, "unit2_unit_price_vs_total_scatter.png")
# Inferences:
# Each point represents a transaction. A positive trend may occur because unit
# price contributes to total spending, but quantity and product mix also affect
# the total. This association is not a causal conclusion.

# Export the cleaned working dataset.
write.csv(sales_clean,
          file.path(project_root, "outputs/reports/supermarket_sales_cleaned.csv"),
          row.names = FALSE)
cat("[UNIT 2] Completed.\n")
