# PROBLEM STATEMENTS PS1-PS5 (supermarket sales)
# Run after the unit scripts. Uses supermarket_data, sales_clean, project_root.
# Everything below is computed from the supplied CSV; nothing is typed by hand.

cat("\n[PROBLEM STATEMENTS] Running five project questions\n")

report_dir <- file.path(project_root, "outputs", "reports")
plots_dir <- file.path(project_root, "outputs", "plots")

section <- function(title) {
  cat("\n------------------------------------------------------------\n")
  cat(title, "\n")
  cat("------------------------------------------------------------\n")
}

# ANOVA term rows are backticked/padded when names contain spaces.
anova_term_row <- function(anova_summary, term) {
  row_names <- trimws(gsub("`", "", rownames(anova_summary[[1]])))
  matches <- which(row_names == term)
  if (length(matches) != 1) stop("No unique ANOVA row for term: ", term)
  anova_summary[[1]][matches, ]
}
anova_stats <- function(anova_summary, term) {
  r <- anova_term_row(anova_summary, term)
  list(statistic = unname(r[["F value"]]), df = unname(r[["Df"]]),
       p_value = unname(r[["Pr(>F)"]]))
}

inferential_rows <- list()
add_test <- function(id, ps, question, test, h0, h1, type, stat, df, p) {
  inferential_rows[[id]] <<- data.frame(
    Problem_statement = ps, Question = question, Test = test,
    Null_hypothesis = h0, Alternative = h1, Alpha = 0.05,
    Statistic_type = type, Statistic = stat, DF = df, P_value = p,
    stringsAsFactors = FALSE)
}

# --- PS0. Data-quality guard (moved from the retired integrated script) ---
section("PS0: Data-quality guard")
expected_fields <- c("Invoice ID", "Branch", "City", "Customer type", "Gender",
                     "Product line", "Unit price", "Quantity", "Total",
                     "Date", "Time", "Payment", "cogs", "gross income", "Rating")
missing_fields <- setdiff(expected_fields, names(supermarket_data))
if (length(missing_fields) > 0) {
  stop("Required dataset fields not found: ", paste(missing_fields, collapse = ", "))
}
data_quality <- data.frame(
  Rows = nrow(supermarket_data), Columns = ncol(supermarket_data),
  Missing_Cells = sum(is.na(supermarket_data)),
  Duplicate_Rows = sum(duplicated(supermarket_data)),
  Distinct_Invoices = length(unique(supermarket_data$`Invoice ID`)))
print(data_quality, row.names = FALSE)
write.csv(data_quality, file.path(report_dir, "ps0_data_quality.csv"), row.names = FALSE)

# ==============================================================
# visualization - problem statements (supermarket version, sample style)
# ==============================================================

#problem statement 1
#How do average customer Rating scores and gross income vary across different Product line categories?

#statistical analysis
section("PS1: Rating and gross income by product line")
ps1 <- sales_clean %>%
  dplyr::group_by(`Product line`) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Mean_Rating = mean(Rating, na.rm = TRUE),
    SD_Rating = sd(Rating, na.rm = TRUE),
    Mean_Gross_Income = mean(`gross income`, na.rm = TRUE),
    Total_Gross_Income = sum(`gross income`, na.rm = TRUE),
    Total_Revenue = sum(Total, na.rm = TRUE),
    .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(Mean_Rating))
View(ps1)
print(as.data.frame(ps1), row.names = FALSE)
write.csv(ps1, file.path(report_dir, "ps1_product_line_performance.csv"), row.names = FALSE)

ps1_rating_aov <- summary(stats::aov(Rating ~ `Product line`, data = sales_clean))
print(ps1_rating_aov)
capture.output(ps1_rating_aov, file = file.path(report_dir, "ps1_rating_anova.txt"))
r1 <- anova_stats(ps1_rating_aov, "Product line")
add_test("ps1_rating", "PS1: product line ratings",
  "Do mean customer ratings differ across product lines?",
  "One-way ANOVA (Rating ~ Product line)",
  "All six product-line mean ratings are equal",
  "At least one product-line mean rating differs",
  "F", r1$statistic, r1$df, r1$p_value)

ps1_gross_aov <- summary(stats::aov(`gross income` ~ `Product line`, data = sales_clean))
print(ps1_gross_aov)
capture.output(ps1_gross_aov, file = file.path(report_dir, "ps1_gross_income_anova.txt"))
g1 <- anova_stats(ps1_gross_aov, "Product line")
add_test("ps1_gross", "PS1: product line gross income",
  "Do mean invoice gross incomes differ across product lines?",
  "One-way ANOVA (gross income ~ Product line)",
  "All six product-line mean gross incomes are equal",
  "At least one product-line mean gross income differs",
  "F", g1$statistic, g1$df, g1$p_value)

#problem statement 2
#Is there a statistically significant difference in revenue (Total) and Customer type distribution among the three branches?

#statistical analysis
section("PS2: Revenue and customer mix by branch")
ps2_rev <- sales_clean %>%
  dplyr::group_by(Branch, City) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Revenue = sum(Total, na.rm = TRUE),
    Mean_Total = mean(Total, na.rm = TRUE),
    Median_Total = median(Total, na.rm = TRUE),
    .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(Revenue))
View(ps2_rev)
print(as.data.frame(ps2_rev), row.names = FALSE)
write.csv(ps2_rev, file.path(report_dir, "ps2_branch_revenue.csv"), row.names = FALSE)

ps2_counts <- as.data.frame(table(Branch = sales_clean$Branch,
                                  Customer_Type = sales_clean$`Customer type`))
names(ps2_counts)[3] <- "Transactions"
View(ps2_counts)
print(ps2_counts, row.names = FALSE)
write.csv(ps2_counts, file.path(report_dir, "ps2_branch_customer_counts.csv"), row.names = FALSE)

ps2_aov <- summary(stats::aov(Total ~ Branch, data = sales_clean))
print(ps2_aov)
capture.output(ps2_aov, file = file.path(report_dir, "ps2_branch_anova.txt"))
b2 <- anova_stats(ps2_aov, "Branch")
add_test("ps2_anova", "PS2: branch revenue",
  "Does mean invoice total differ across the three branches?",
  "One-way ANOVA (Total ~ Branch)",
  "All three branch mean invoice totals are equal",
  "At least one branch mean invoice total differs",
  "F", b2$statistic, b2$df, b2$p_value)

ps2_chi <- stats::chisq.test(table(sales_clean$Branch, sales_clean$`Customer type`))
print(ps2_chi)
capture.output(ps2_chi, file = file.path(report_dir, "ps2_branch_customer_chisquare.txt"))
cat("Smallest expected cell count:", round(min(ps2_chi$expected), 1), "\n")
add_test("ps2_chi", "PS2: branch customer mix",
  "Is customer-type distribution independent of branch?",
  "Chi-square test of independence (Branch x Customer type)",
  "Customer type distribution is the same across branches",
  "Customer type distribution differs by branch",
  "X-squared", unname(ps2_chi$statistic), unname(ps2_chi$parameter), ps2_chi$p.value)

#problem statement 3
#Which Payment methods are preferred across different Gender and Customer type segments?

#statistical analysis
section("PS3: Payment preference by gender and customer type")
ps3_gender <- as.data.frame(table(Payment = sales_clean$Payment, Gender = sales_clean$Gender))
names(ps3_gender)[3] <- "Transactions"
ps3_gender$Share_within_gender <- ave(ps3_gender$Transactions, ps3_gender$Gender,
  FUN = function(x) round(x / sum(x) * 100, 1))
View(ps3_gender)
print(ps3_gender, row.names = FALSE)
write.csv(ps3_gender, file.path(report_dir, "ps3_payment_by_gender.csv"), row.names = FALSE)

ps3_cust <- as.data.frame(table(Payment = sales_clean$Payment,
                                Customer_Type = sales_clean$`Customer type`))
names(ps3_cust)[3] <- "Transactions"
ps3_cust$Share_within_segment <- ave(ps3_cust$Transactions, ps3_cust$Customer_Type,
  FUN = function(x) round(x / sum(x) * 100, 1))
View(ps3_cust)
print(ps3_cust, row.names = FALSE)
write.csv(ps3_cust, file.path(report_dir, "ps3_payment_by_customertype.csv"), row.names = FALSE)

ps3_chi_g <- stats::chisq.test(table(sales_clean$Payment, sales_clean$Gender))
print(ps3_chi_g)
capture.output(ps3_chi_g, file = file.path(report_dir, "ps3_payment_gender_chisquare.txt"))
cat("Smallest expected cell count:", round(min(ps3_chi_g$expected), 1), "\n")
add_test("ps3_gender", "PS3: payment by gender",
  "Is payment-method choice independent of gender?",
  "Chi-square test of independence (Payment x Gender)",
  "Payment preference is the same for Female and Male customers",
  "Payment preference differs by gender",
  "X-squared", unname(ps3_chi_g$statistic), unname(ps3_chi_g$parameter), ps3_chi_g$p.value)

ps3_chi_c <- stats::chisq.test(table(sales_clean$Payment, sales_clean$`Customer type`))
print(ps3_chi_c)
capture.output(ps3_chi_c, file = file.path(report_dir, "ps3_payment_customertype_chisquare.txt"))
cat("Smallest expected cell count:", round(min(ps3_chi_c$expected), 1), "\n")
add_test("ps3_cust", "PS3: payment by customer type",
  "Is payment-method choice independent of customer type?",
  "Chi-square test of independence (Payment x Customer type)",
  "Payment preference is the same for Member and Normal customers",
  "Payment preference differs by customer type",
  "X-squared", unname(ps3_chi_c$statistic), unname(ps3_chi_c$parameter), ps3_chi_c$p.value)

#problem statement 4
#What time of day (Time) and day of the week (Date) experience the highest customer volume and order totals?

#statistical analysis
section("PS4: Peak hours and weekdays")
if (any(!grepl("^[0-9]{2}:[0-9]{2}$", sales_clean$Time))) {
  stop("Unexpected Time format: values are not all HH:MM.")
}
sales_clean$Hour <- as.integer(substr(sales_clean$Time, 1, 2))
sales_clean$Part_of_day <- cut(sales_clean$Hour,
  breaks = c(9, 12, 16, 21), labels = c("Morning (10-12)", "Afternoon (13-16)", "Evening (17-20)"),
  include.lowest = TRUE, right = TRUE)
sales_clean$Weekday <- weekdays(sales_clean$Date)

ps4_hour <- sales_clean %>%
  dplyr::group_by(Hour) %>%
  dplyr::summarise(Transactions = dplyr::n(), Revenue = sum(Total, na.rm = TRUE),
                   Mean_Total = mean(Total, na.rm = TRUE), .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(Transactions))
View(ps4_hour)
print(as.data.frame(ps4_hour), row.names = FALSE)
write.csv(ps4_hour, file.path(report_dir, "ps4_hourly.csv"), row.names = FALSE)

ps4_part <- sales_clean %>%
  dplyr::group_by(Part_of_day) %>%
  dplyr::summarise(Transactions = dplyr::n(), Revenue = sum(Total, na.rm = TRUE),
                   Mean_Total = mean(Total, na.rm = TRUE), .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(Transactions))
View(ps4_part)
print(as.data.frame(ps4_part), row.names = FALSE)
write.csv(ps4_part, file.path(report_dir, "ps4_part_of_day.csv"), row.names = FALSE)

ps4_day <- sales_clean %>%
  dplyr::group_by(Weekday) %>%
  dplyr::summarise(Transactions = dplyr::n(), Revenue = sum(Total, na.rm = TRUE),
                   Mean_Total = mean(Total, na.rm = TRUE), .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(Transactions))
View(ps4_day)
print(as.data.frame(ps4_day), row.names = FALSE)
write.csv(ps4_day, file.path(report_dir, "ps4_weekday.csv"), row.names = FALSE)

ps4_chi_h <- stats::chisq.test(table(sales_clean$Hour))
print(ps4_chi_h)
capture.output(ps4_chi_h, file = file.path(report_dir, "ps4_hour_uniformity_chisquare.txt"))
add_test("ps4_hour", "PS4: hourly volume",
  "Are transactions evenly spread across opening hours?",
  "Chi-square goodness-of-fit (hourly counts vs uniform)",
  "Every opening hour has the same transaction volume",
  "At least one hour differs in volume",
  "X-squared", unname(ps4_chi_h$statistic), unname(ps4_chi_h$parameter), ps4_chi_h$p.value)

ps4_chi_d <- stats::chisq.test(table(sales_clean$Weekday))
print(ps4_chi_d)
capture.output(ps4_chi_d, file = file.path(report_dir, "ps4_weekday_uniformity_chisquare.txt"))
add_test("ps4_day", "PS4: weekday volume",
  "Are transactions evenly spread across weekdays?",
  "Chi-square goodness-of-fit (weekday counts vs uniform)",
  "Every weekday has the same transaction volume",
  "At least one weekday differs in volume",
  "X-squared", unname(ps4_chi_d$statistic), unname(ps4_chi_d$parameter), ps4_chi_d$p.value)

#problem statement 5
#How does product Unit price impact purchase Quantity and total gross income generated?

#statistical analysis
section("PS5: Unit price, quantity and gross income")
ps5_qty <- stats::cor.test(sales_clean$`Unit price`, sales_clean$Quantity, method = "pearson")
print(ps5_qty)
capture.output(ps5_qty, file = file.path(report_dir, "ps5_price_quantity_correlation.txt"))
cat("Pearson r (Unit price, Quantity) =", round(unname(ps5_qty$estimate), 4),
    ", n =", ps5_qty$parameter + 2,
    ", p =", format.pval(ps5_qty$p.value, digits = 4), "\n")
add_test("ps5_qty", "PS5: price vs quantity",
  "Is quantity purchased linearly associated with unit price?",
  "Pearson correlation test",
  "True correlation between Unit price and Quantity is zero",
  "The correlation differs from zero",
  "r", unname(ps5_qty$estimate), ps5_qty$parameter, ps5_qty$p.value)

ps5_gross <- stats::cor.test(sales_clean$`Unit price`, sales_clean$`gross income`, method = "pearson")
print(ps5_gross)
capture.output(ps5_gross, file = file.path(report_dir, "ps5_price_grossincome_correlation.txt"))
add_test("ps5_gross", "PS5: price vs gross income",
  "Is invoice gross income linearly associated with unit price?",
  "Pearson correlation test",
  "True correlation between Unit price and gross income is zero",
  "The correlation differs from zero",
  "r", unname(ps5_gross$estimate), ps5_gross$parameter, ps5_gross$p.value)

ps5_profit <- sales_clean %>%
  dplyr::group_by(`Product line`) %>%
  dplyr::summarise(
    Transactions = dplyr::n(),
    Mean_Unit_Price = mean(`Unit price`, na.rm = TRUE),
    Mean_Quantity = mean(Quantity, na.rm = TRUE),
    Total_Gross_Income = sum(`gross income`, na.rm = TRUE),
    Total_Revenue = sum(Total, na.rm = TRUE),
    .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(Total_Gross_Income))
View(ps5_profit)
print(as.data.frame(ps5_profit), row.names = FALSE)
write.csv(ps5_profit, file.path(report_dir, "ps5_profitability_by_product.csv"), row.names = FALSE)

ps5_model <- lm(`gross income` ~ `Unit price`, data = sales_clean)
print(summary(ps5_model))
capture.output(summary(ps5_model), file = file.path(report_dir, "ps5_gross_income_model.txt"))
cat("NOTE: gross income = 0.05 * Quantity * Unit price in every row, so this line\n")
cat("reproduces invoice arithmetic; it does not prove price drives profit.\n")

# Consolidated inferential table.
inferential_tests <- dplyr::bind_rows(inferential_rows)
inferential_tests$Significant_at_5pct <- inferential_tests$P_value < 0.05
inferential_tests$Conclusion <- ifelse(
  inferential_tests$Significant_at_5pct,
  "Reject H0 at alpha = 0.05: evidence of a difference/association in this sample.",
  "Fail to reject H0 at alpha = 0.05: no statistically significant evidence in this sample (not proof of equality).")
write.csv(inferential_tests, file.path(report_dir, "ps_inferential_tests.csv"), row.names = FALSE)
cat("\nConsolidated inferential tests:\n")
print(as.data.frame(inferential_tests[, c("Problem_statement", "Test", "Statistic",
                                          "DF", "P_value", "Significant_at_5pct")]),
      row.names = FALSE)

cat("\n[PROBLEM STATEMENTS] Completed. Tables in outputs/reports/ps*.csv,\n")
cat("test outputs in outputs/reports/*.txt, plots in outputs/plots/.\n")
