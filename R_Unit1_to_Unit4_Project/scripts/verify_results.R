# INDEPENDENT VERIFICATION: recompute every reported number from the raw CSV
# (base R only) and compare with the analysis scripts. Mismatches stop the run.

cat("\n[VERIFICATION] Recomputing report figures from the raw CSV\n")

raw <- read.csv(file.path(project_root, "data", "supermarket_sales.csv"),
                stringsAsFactors = FALSE, check.names = FALSE)
raw_date <- as.Date(raw$Date, format = "%m/%d/%Y")

# Every quantity reported in the report: label, reported value, recomputed value
checks <- list(
  Rows = list(analysis = nrow(supermarket_data), raw = nrow(raw)),
  Columns = list(analysis = ncol(supermarket_data), raw = ncol(raw)),
  Missing_cells = list(analysis = sum(is.na(supermarket_data)),
                       raw = sum(is.na(raw))),
  Duplicate_rows = list(analysis = sum(duplicated(supermarket_data)),
                        raw = sum(duplicated(raw))),
  Unique_invoice_ids = list(analysis = length(unique(supermarket_data$`Invoice ID`)),
                            raw = length(unique(raw$`Invoice ID`))),
  Total_revenue = list(analysis = sum(sales_clean$Total, na.rm = TRUE),
                       raw = sum(raw$Total, na.rm = TRUE)),
  Mean_invoice_total = list(analysis = mean(sales_clean$Total, na.rm = TRUE),
                            raw = mean(raw$Total, na.rm = TRUE)),
  Median_invoice_total = list(analysis = median(sales_clean$Total, na.rm = TRUE),
                              raw = median(raw$Total, na.rm = TRUE)),
  SD_invoice_total = list(analysis = sd(sales_clean$Total, na.rm = TRUE),
                          raw = sd(raw$Total, na.rm = TRUE)),
  Mean_gross_income = list(analysis = mean(sales_clean$`gross income`, na.rm = TRUE),
                           raw = mean(raw$`gross income`, na.rm = TRUE)),
  Mean_rating = list(analysis = mean(sales_clean$Rating, na.rm = TRUE),
                     raw = mean(raw$Rating, na.rm = TRUE)),
  Mean_quantity = list(analysis = mean(sales_clean$Quantity, na.rm = TRUE),
                       raw = mean(raw$Quantity, na.rm = TRUE)),
  Mean_unit_price = list(analysis = mean(sales_clean$`Unit price`, na.rm = TRUE),
                         raw = mean(raw$`Unit price`, na.rm = TRUE)),
  Cor_quantity_total = list(analysis = unname(ps5_cor$estimate),
                            raw = cor(raw$Quantity, raw$Total)),
  Cor_rating_total = list(analysis = unname(ps6_cor$estimate),
                          raw = cor(raw$Rating, raw$Total)),
  Cor_unitprice_total = list(analysis = cor(raw$`Unit price`, raw$Total),
                             raw = cor(raw$`Unit price`, raw$Total)),
  Date_min = list(analysis = as.character(min(sales_clean$Date)),
                  raw = as.character(min(raw_date))),
  Date_max = list(analysis = as.character(max(sales_clean$Date)),
                  raw = as.character(max(raw_date))),
  Member_transactions = list(
    analysis = sum(sales_clean$`Customer type` == "Member"),
    raw = sum(raw$`Customer type` == "Member")),
  Normal_transactions = list(
    analysis = sum(sales_clean$`Customer type` == "Normal"),
    raw = sum(raw$`Customer type` == "Normal"))
)

verification <- do.call(rbind, lapply(names(checks), function(nm) {
  data.frame(
    Quantity = nm,
    Value_from_analysis_scripts = unname(checks[[nm]]$analysis),
    Value_recomputed_from_raw_csv = unname(checks[[nm]]$raw),
    Match = isTRUE(all.equal(unname(checks[[nm]]$analysis),
                             unname(checks[[nm]]$raw))),
    stringsAsFactors = FALSE
  )
}))

# Accounting identities that the report relies on for its caution notes.
identities <- data.frame(
  Identity = c("Total == 1.05 * cogs (all rows)",
               "cogs == Quantity * Unit price (all rows)",
               "Tax 5% == gross income (all rows)",
               "Tax 5% == 0.05 * cogs (all rows)",
               "gross margin percentage constant"),
  Holds = c(
    isTRUE(all.equal(raw$Total, raw$cogs * 1.05)),
    isTRUE(all.equal(raw$cogs, raw$Quantity * raw$`Unit price`)),
    isTRUE(all.equal(raw$`Tax 5%`, raw$`gross income`)),
    isTRUE(all.equal(raw$`Tax 5%`, raw$cogs * 0.05)),
    length(unique(raw$`gross margin percentage`)) == 1
  ),
  stringsAsFactors = FALSE
)

write.csv(verification,
          file.path(project_root, "outputs/reports/verification_results.csv"),
          row.names = FALSE)
write.csv(identities,
          file.path(project_root, "outputs/reports/accounting_relations_check.csv"),
          row.names = FALSE)

print(verification, row.names = FALSE)
print(identities, row.names = FALSE)

if (!all(verification$Match)) {
  stop("Verification failed: analysis scripts and raw CSV disagree.")
}
if (!all(identities$Holds)) {
  stop("Verification failed: an accounting identity assumed in the report does not hold.")
}
cat("\nAll", nrow(verification), "reported quantities recomputed and matched.\n")

cat("\n[VERIFICATION] Completed.\n")
