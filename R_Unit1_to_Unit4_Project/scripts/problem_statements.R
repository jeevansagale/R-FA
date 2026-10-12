# PROBLEM STATEMENTS PS1-PS7: run after unit scripts.
# Everything below is computed from the supplied CSV; nothing is typed in by hand.

cat("\n[PROBLEM STATEMENTS] Running seven distinct questions\n")

report_dir <- file.path(project_root, "outputs", "reports")
plots_dir <- file.path(project_root, "outputs", "plots")

# Small local helper so every question prints a heading and a clear message.
section <- function(title) {
  cat("\n------------------------------------------------------------\n")
  cat(title, "\n")
  cat("------------------------------------------------------------\n")
}

inferential_rows <- list()   # collected for the consolidated test table

# ANOVA summary tables label the term row with backticks when the column name
# contains a space (e.g. "`Product line`") and pad row names with trailing
# spaces, so rows are matched after removing backticks and trimming.
anova_term_row <- function(anova_summary, term) {
  row_names <- trimws(gsub("`", "", rownames(anova_summary[[1]])))
  matches <- which(row_names == term)
  if (length(matches) != 1) {
    stop("Could not find a unique ANOVA row for term: ", term)
  }
  anova_summary[[1]][matches, ]
}
anova_statistics <- function(anova_summary, term) {
  term_row <- anova_term_row(anova_summary, term)
  list(
    test_type = "F",
    statistic = unname(term_row["F value"]),
    df = unname(term_row["Df"]),
    p_value = unname(term_row["Pr(>F)"])
  )
}

# -----------------------------------------------------------------------------
# PS1. Which product lines generate the greatest total revenue?
# -----------------------------------------------------------------------------
section("PS1: Revenue, volume and rating by product line")
ps1 <- sales_clean %>%
  dplyr::group_by(`Product line`) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Revenue = sum(Total, na.rm = TRUE),
    Mean_Total = mean(Total, na.rm = TRUE),
    Median_Total = median(Total, na.rm = TRUE),
    Mean_Quantity = mean(Quantity, na.rm = TRUE),
    Mean_Gross_Income = mean(`gross income`, na.rm = TRUE),
    Mean_Rating = mean(Rating, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::arrange(dplyr::desc(Revenue))
print(ps1)
write.csv(ps1, file.path(report_dir, "ps1_product_line_revenue.csv"), row.names = FALSE)

ps1_anova <- stats::aov(Total ~ `Product line`, data = sales_clean)
ps1_anova_summary <- summary(ps1_anova)
cat("One-way ANOVA of invoice total by product line:\n")
print(ps1_anova_summary)
capture.output(ps1_anova_summary,
               file = file.path(report_dir, "ps1_product_line_anova.txt"))
ps1_f <- anova_statistics(ps1_anova_summary, "Product line")
inferential_rows[["ps1_product_line_anova"]] <- data.frame(
  Problem_statement = "PS1: product line",
  Question = "Does mean invoice total differ across the six product lines?",
  Test = "One-way ANOVA (Total ~ Product line)",
  Null_hypothesis = "All six product-line mean invoice totals are equal",
  Alternative = "At least one product-line mean invoice total differs",
  Alpha = 0.05,
  Statistic_type = "F",
  Statistic = ps1_f$statistic,
  DF = ps1_f$df,
  P_value = ps1_f$p_value,
  stringsAsFactors = FALSE
)

# -----------------------------------------------------------------------------
# PS2. How do the branches compare in total revenue and average invoice amount?
# -----------------------------------------------------------------------------
section("PS2: Branch comparison (Branch and City are one-to-one in this dataset)")
ps2 <- sales_clean %>%
  dplyr::group_by(Branch, City) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Revenue = sum(Total, na.rm = TRUE),
    Mean_Total = mean(Total, na.rm = TRUE),
    Median_Total = median(Total, na.rm = TRUE),
    Mean_Rating = mean(Rating, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::arrange(dplyr::desc(Revenue))
print(ps2)
write.csv(ps2, file.path(report_dir, "ps2_branch_comparison.csv"), row.names = FALSE)

ps2_anova <- stats::aov(Total ~ Branch, data = sales_clean)
ps2_anova_summary <- summary(ps2_anova)
cat("One-way ANOVA of invoice total by branch:\n")
print(ps2_anova_summary)
capture.output(ps2_anova_summary, file = file.path(report_dir, "ps2_branch_anova.txt"))
ps2_f <- anova_statistics(ps2_anova_summary, "Branch")
inferential_rows[["ps2_branch_anova"]] <- data.frame(
  Problem_statement = "PS2: branch",
  Question = "Does mean invoice total differ across the three branches?",
  Test = "One-way ANOVA (Total ~ Branch)",
  Null_hypothesis = "All three branch mean invoice totals are equal",
  Alternative = "At least one branch mean invoice total differs",
  Alpha = 0.05,
  Statistic_type = "F",
  Statistic = ps2_f$statistic,
  DF = ps2_f$df,
  P_value = ps2_f$p_value,
  stringsAsFactors = FALSE
)

# -----------------------------------------------------------------------------
# PS3. Do Member and Normal customers have different average invoice totals?
#      The filtered-boxplot comparison is the pattern used in the instructor's
#      sample FA-II script (filter -> ggplot boxplot -> grid viewport panel).
# -----------------------------------------------------------------------------
section("PS3: Member vs Normal customer invoice totals")
ps3 <- sales_clean %>%
  dplyr::group_by(`Customer type`) %>%
  dplyr::summarise(
    N = dplyr::n(),
    Mean_Total = mean(Total, na.rm = TRUE),
    Median_Total = median(Total, na.rm = TRUE),
    SD_Total = sd(Total, na.rm = TRUE),
    Revenue = sum(Total, na.rm = TRUE),
    Mean_Rating = mean(Rating, na.rm = TRUE),
    .groups = "drop"
  )
print(ps3)
write.csv(ps3, file.path(report_dir, "ps3_customer_type.csv"), row.names = FALSE)

ps3_test <- stats::t.test(Total ~ `Customer type`, data = sales_clean)  # Welch by default
print(ps3_test)
capture.output(ps3_test, file = file.path(report_dir, "ps3_customer_type_t_test.txt"))
cat("Welch two-sample t-test of Member vs Normal invoice totals: t =",
    round(unname(ps3_test$statistic), 4),
    ", df =", round(unname(ps3_test$parameter), 2),
    ", p =", format.pval(ps3_test$p.value, digits = 4), "\n")
inferential_rows[["ps3_customer_type_t_test"]] <- data.frame(
  Problem_statement = "PS3: customer type",
  Question = "Do Member and Normal customers differ in mean invoice total?",
  Test = "Welch two-sample t-test (unequal variances not assumed)",
  Null_hypothesis = "Mean invoice total is the same for Member and Normal customers",
  Alternative = "Mean invoice total differs between the two customer types",
  Alpha = 0.05,
  Statistic_type = "t",
  Statistic = unname(ps3_test$statistic),
  DF = unname(ps3_test$parameter),
  P_value = ps3_test$p.value,
  stringsAsFactors = FALSE
)

# Filtered boxplots for the two groups, arranged with grid viewport.
member_n <- sum(sales_clean$`Customer type` == "Member", na.rm = TRUE)
normal_n <- sum(sales_clean$`Customer type` == "Normal", na.rm = TRUE)
ps3_box_member <- ggplot2::ggplot(
  dplyr::filter(sales_clean, `Customer type` == "Member"),
  ggplot2::aes(y = Total)) +
  ggplot2::geom_boxplot(fill = "lightblue", color = "navy", outlier.color = "red") +
  ggplot2::labs(title = paste0("Member customers (n = ", member_n, ")"),
                y = "Invoice Total")
ps3_box_normal <- ggplot2::ggplot(
  dplyr::filter(sales_clean, `Customer type` == "Normal"),
  ggplot2::aes(y = Total)) +
  ggplot2::geom_boxplot(fill = "lightgreen", color = "darkgreen", outlier.color = "red") +
  ggplot2::labs(title = paste0("Normal customers (n = ", normal_n, ")"),
                y = "Invoice Total")
save_project_plot(ps3_box_member, "ps3_customer_type_boxplot_member.png", 5, 4)
save_project_plot(ps3_box_normal, "ps3_customer_type_boxplot_normal.png", 5, 4)

# Two-row combined figure produced with grid viewports (instructor sample pattern).
grDevices::png(file.path(plots_dir, "ps3_customer_type_boxplot_grid.png"),
               width = 1500, height = 1000, res = 130)
grid::pushViewport(grid::viewport(layout = grid::grid.layout(2, 1)))
print(ps3_box_member,
      vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1))
print(ps3_box_normal,
      vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1))
grDevices::dev.off()
message("Saved plot: ", file.path(plots_dir, "ps3_customer_type_boxplot_grid.png"))
message("Boxplot titles computed from the data: n(Member) = ", member_n,
        ", n(Normal) = ", normal_n)

# -----------------------------------------------------------------------------
# PS4. How are transactions distributed across payment methods, and do mean
#      invoice totals differ?
# -----------------------------------------------------------------------------
section("PS4: Payment-method usage and invoice totals")
ps4 <- sales_clean %>%
  dplyr::group_by(Payment) %>%
  dplyr::summarise(
    N = dplyr::n(),
    Revenue = sum(Total, na.rm = TRUE),
    Mean_Total = mean(Total, na.rm = TRUE),
    Median_Total = median(Total, na.rm = TRUE),
    Mean_Rating = mean(Rating, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::arrange(dplyr::desc(N))
print(ps4)
write.csv(ps4, file.path(report_dir, "ps4_payment_method.csv"), row.names = FALSE)

ps4_anova <- stats::aov(Total ~ Payment, data = sales_clean)
ps4_anova_summary <- summary(ps4_anova)
cat("One-way ANOVA of invoice total by payment method:\n")
print(ps4_anova_summary)
capture.output(ps4_anova_summary, file = file.path(report_dir, "ps4_payment_anova.txt"))
ps4_f <- anova_statistics(ps4_anova_summary, "Payment")
inferential_rows[["ps4_payment_anova"]] <- data.frame(
  Problem_statement = "PS4: payment method",
  Question = "Does mean invoice total differ across the three payment methods?",
  Test = "One-way ANOVA (Total ~ Payment)",
  Null_hypothesis = "All three payment-method mean invoice totals are equal",
  Alternative = "At least one payment-method mean invoice total differs",
  Alpha = 0.05,
  Statistic_type = "F",
  Statistic = ps4_f$statistic,
  DF = ps4_f$df,
  P_value = ps4_f$p_value,
  stringsAsFactors = FALSE
)

# -----------------------------------------------------------------------------
# PS5. How strongly is quantity associated with invoice total?
#      NOTE: in this dataset Total = 1.05 * Quantity * Unit price exactly, so a
#      regression on both components is a mechanical fit and is labelled as such.
# -----------------------------------------------------------------------------
section("PS5: Association between quantity purchased and invoice total")
ps5_cor <- stats::cor.test(sales_clean$Quantity, sales_clean$Total, method = "pearson")
print(ps5_cor)
capture.output(ps5_cor,
               file = file.path(report_dir, "ps5_quantity_total_correlation.txt"))
cat("Pearson correlation Quantity vs Total: r =",
    round(unname(ps5_cor$estimate), 4),
    ", n =", ps5_cor$parameter + 2,
    ", p =", format.pval(ps5_cor$p.value, digits = 4), "\n")
inferential_rows[["ps5_quantity_total_cor"]] <- data.frame(
  Problem_statement = "PS5: quantity vs total",
  Question = "Is invoice total linearly associated with quantity purchased?",
  Test = "Pearson correlation test (cor.test)",
  Null_hypothesis = "True correlation between Quantity and Total is zero",
  Alternative = "The correlation differs from zero",
  Alpha = 0.05,
  Statistic_type = "r",
  Statistic = unname(ps5_cor$estimate),
  DF = ps5_cor$parameter,
  P_value = ps5_cor$p.value,
  stringsAsFactors = FALSE
)

# Effect of quantity on the invoice total, with unit price held in the model.
ps5_model <- lm(Total ~ Quantity + `Unit price`, data = sales_clean)
cat("Regression Total ~ Quantity + Unit price:\n")
print(summary(ps5_model))
capture.output(summary(ps5_model),
               file = file.path(report_dir, "ps5_invoice_total_model.txt"))
cat("NOTE: Total = 1.05 * Quantity * Unit price in every row of this dataset, so this\n")
cat("model reproduces the invoice formula rather than discovering a new driver.\n")

# -----------------------------------------------------------------------------
# PS6. What does the rating distribution show, and is rating linearly associated
#      with invoice total?
# -----------------------------------------------------------------------------
section("PS6: Customer ratings and their association with invoice total")
ps6 <- data.frame(
  N = sum(!is.na(sales_clean$Rating)),
  Mean_Rating = mean(sales_clean$Rating, na.rm = TRUE),
  Median_Rating = median(sales_clean$Rating, na.rm = TRUE),
  SD_Rating = sd(sales_clean$Rating, na.rm = TRUE),
  Min_Rating = min(sales_clean$Rating, na.rm = TRUE),
  Max_Rating = max(sales_clean$Rating, na.rm = TRUE),
  IQR_Rating = IQR(sales_clean$Rating, na.rm = TRUE)
)
print(ps6, row.names = FALSE)
write.csv(ps6, file.path(report_dir, "ps6_rating_summary.csv"), row.names = FALSE)

ps6_cor <- stats::cor.test(sales_clean$Rating, sales_clean$Total, method = "pearson")
print(ps6_cor)
capture.output(ps6_cor,
               file = file.path(report_dir, "ps6_rating_total_correlation.txt"))
cat("Pearson correlation Rating vs Total: r =",
    round(unname(ps6_cor$estimate), 4),
    ", n =", ps6_cor$parameter + 2,
    ", p =", format.pval(ps6_cor$p.value, digits = 4), "\n")
inferential_rows[["ps6_rating_total_cor"]] <- data.frame(
  Problem_statement = "PS6: rating vs total",
  Question = "Is invoice total linearly associated with the customer rating?",
  Test = "Pearson correlation test (cor.test)",
  Null_hypothesis = "True correlation between Rating and Total is zero",
  Alternative = "The correlation differs from zero",
  Alpha = 0.05,
  Statistic_type = "r",
  Statistic = unname(ps6_cor$estimate),
  DF = ps6_cor$parameter,
  P_value = ps6_cor$p.value,
  stringsAsFactors = FALSE
)

# -----------------------------------------------------------------------------
# PS7. How does revenue vary across the available months and weekdays?
# -----------------------------------------------------------------------------
section("PS7: Revenue by month and weekday (data cover 2019-01-01 to 2019-03-30)")
sales_clean$Month <- format(sales_clean$Date, "%Y-%m")
sales_clean$Weekday <- weekdays(sales_clean$Date)

ps7_month <- sales_clean %>%
  dplyr::group_by(Month) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Revenue = sum(Total, na.rm = TRUE),
    Mean_Total = mean(Total, na.rm = TRUE),
    .groups = "drop"
  )
print(ps7_month)
write.csv(ps7_month, file.path(report_dir, "ps7_monthly_revenue.csv"), row.names = FALSE)

ps7_day <- sales_clean %>%
  dplyr::group_by(Weekday) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Revenue = sum(Total, na.rm = TRUE),
    Mean_Total = mean(Total, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::arrange(dplyr::desc(Revenue))
print(ps7_day)
write.csv(ps7_day, file.path(report_dir, "ps7_weekday_revenue.csv"), row.names = FALSE)

# Consolidated table of every inferential test performed above.
inferential_tests <- dplyr::bind_rows(inferential_rows)
inferential_tests$Significant_at_5pct <- inferential_tests$P_value < 0.05
inferential_tests$Conclusion <- ifelse(
  inferential_tests$Significant_at_5pct,
  "Reject H0 at alpha = 0.05: evidence of a difference/association in this sample.",
  "Fail to reject H0 at alpha = 0.05: no statistically significant evidence in this sample (not proof of equality)."
)
write.csv(inferential_tests, file.path(report_dir, "ps_inferential_tests.csv"),
          row.names = FALSE)
cat("\nConsolidated inferential tests:\n")
print(as.data.frame(inferential_tests[, c("Problem_statement", "Test", "Statistic",
                                          "DF", "P_value", "Significant_at_5pct")]),
      row.names = FALSE)

cat("\n[PROBLEM STATEMENTS] Completed. Tables in outputs/reports/ps*.csv,\n")
cat("test outputs in outputs/reports/ps*_*.txt, plots in outputs/plots/.\n")
