# INDEPENDENT VERIFICATION: recompute every reported number from the raw CSV
# (base R only) and compare with the analysis scripts. Mismatches stop the run.

cat("\n[VERIFICATION] Recomputing report figures from the raw CSV\n")

raw <- read.csv(file.path(project_root, "data", "supermarket_sales.csv"),
                stringsAsFactors = FALSE, check.names = FALSE)
# Time/weekday derivations go on a copy so the pristine dimensions of `raw`
# stay comparable with the untouched supermarket_data object.
raw_times <- raw
raw_times$Hour <- as.integer(substr(raw_times$Time, 1, 2))
raw_times$Weekday <- weekdays(as.Date(raw_times$Date, format = "%m/%d/%Y"))

checks <- list(
  Rows = list(analysis = nrow(supermarket_data), raw = nrow(raw)),
  Columns = list(analysis = ncol(supermarket_data), raw = ncol(raw)),
  Derived_columns_present = list(
    analysis = all(c("Hour", "Part_of_day", "Weekday") %in% names(sales_clean)),
    raw = TRUE),
  Missing_cells = list(analysis = sum(is.na(supermarket_data)), raw = sum(is.na(raw))),
  Duplicate_rows = list(analysis = sum(duplicated(supermarket_data)),
                        raw = sum(duplicated(raw))),
  Total_revenue = list(analysis = sum(ps2_rev$Revenue), raw = sum(raw$Total)),
  Mean_rating = list(analysis = mean(sales_clean$Rating), raw = mean(raw$Rating)),
  Mean_gross_income = list(analysis = mean(sales_clean$`gross income`),
                           raw = mean(raw$`gross income`)),
  Food_beverages_revenue = list(
    analysis = ps1$Total_Revenue[ps1$`Product line` == "Food and beverages"],
    raw = sum(raw$Total[raw$`Product line` == "Food and beverages"])),
  Branch_C_revenue = list(
    analysis = ps2_rev$Revenue[ps2_rev$Branch == "C"],
    raw = sum(raw$Total[raw$Branch == "C"])),
  Hour19_transactions = list(
    analysis = ps4_hour$Transactions[ps4_hour$Hour == 19],
    raw = sum(raw_times$Hour == 19)),
  Saturday_revenue = list(
    analysis = ps4_day$Revenue[ps4_day$Weekday == "Saturday"],
    raw = sum(raw_times$Total[raw_times$Weekday == "Saturday"])),
  Cor_price_qty = list(analysis = unname(ps5_qty$estimate),
                       raw = cor(raw$`Unit price`, raw$Quantity)),
  Cor_price_gross = list(analysis = unname(ps5_gross$estimate),
                         raw = cor(raw$`Unit price`, raw$`gross income`)),
  Chisq_branch_cust = list(
    analysis = unname(ps2_chi$statistic),
    raw = unname(suppressWarnings(chisq.test(table(raw$Branch, raw$`Customer type`))$statistic))),
  Chisq_payment_gender = list(
    analysis = unname(ps3_chi_g$statistic),
    raw = unname(suppressWarnings(chisq.test(table(raw$Payment, raw$Gender))$statistic))),
  Chisq_payment_cust = list(
    analysis = unname(ps3_chi_c$statistic),
    raw = unname(suppressWarnings(chisq.test(table(raw$Payment, raw$`Customer type`))$statistic))),
  Anova_rating_F = list(
    analysis = r1$statistic,
    raw = unname(summary(aov(Rating ~ `Product line`, data = raw))[[1]][1, "F value"])),
  Anova_branch_F = list(
    analysis = b2$statistic,
    raw = unname(summary(aov(Total ~ Branch, data = raw))[[1]][1, "F value"]))
)

verification <- do.call(rbind, lapply(names(checks), function(nm) {
  data.frame(
    Quantity = nm,
    Value_from_analysis_scripts = unname(checks[[nm]]$analysis),
    Value_recomputed_from_raw_csv = unname(checks[[nm]]$raw),
    Match = isTRUE(all.equal(unname(checks[[nm]]$analysis),
                             unname(checks[[nm]]$raw))),
    stringsAsFactors = FALSE)
}))

identities <- data.frame(
  Identity = c("Total == 1.05 * cogs (all rows)",
               "cogs == Quantity * Unit price (all rows)",
               "Tax 5% == gross income (all rows)",
               "gross margin percentage constant",
               "Time values all HH:MM"),
  Holds = c(
    isTRUE(all.equal(raw$Total, raw$cogs * 1.05)),
    isTRUE(all.equal(raw$cogs, raw$Quantity * raw$`Unit price`)),
    isTRUE(all.equal(raw$`Tax 5%`, raw$`gross income`)),
    length(unique(raw$`gross margin percentage`)) == 1,
    all(grepl("^[0-9]{2}:[0-9]{2}$", raw$Time))),
  stringsAsFactors = FALSE)

write.csv(verification, file.path(project_root, "outputs/reports/verification_results.csv"),
          row.names = FALSE)
write.csv(identities, file.path(project_root, "outputs/reports/accounting_relations_check.csv"),
          row.names = FALSE)
print(verification, row.names = FALSE)
print(identities, row.names = FALSE)

if (!all(verification$Match)) stop("Verification failed: scripts and raw CSV disagree.")
if (!all(identities$Holds)) stop("Verification failed: an assumed identity does not hold.")
cat("\nAll", nrow(verification), "reported quantities recomputed and matched.\n")
cat("\n[VERIFICATION] Completed.\n")
