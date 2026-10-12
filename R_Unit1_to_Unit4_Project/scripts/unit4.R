# UNIT 4: multiple linear regression, correlation, model diagnostics
# Sources: Multiple Regression (1).R and course regression notes.

cat("\n[UNIT 4] Multiple linear regression\n")

# Correlation matrix for numeric variables only; categorical columns are excluded
# because cor() requires numeric inputs.
numeric_columns <- names(sales_clean)[vapply(sales_clean, is.numeric, logical(1))]
correlation_data <- sales_clean[, numeric_columns, drop = FALSE]
correlation_data <- correlation_data[, vapply(correlation_data,
  function(x) stats::sd(x, na.rm = TRUE) > 0, logical(1)), drop = FALSE]
correlation_data <- correlation_data[, colSums(is.na(correlation_data)) == 0,
                                     drop = FALSE]
if (ncol(correlation_data) >= 2) {
  correlation_matrix <- cor(correlation_data)
  print(round(correlation_matrix, 3))
  write.csv(correlation_matrix,
    file.path(project_root, "outputs/reports/unit4_numeric_correlation_matrix.csv"),
    row.names = TRUE)
}

# Fit a multiple regression model using actual available variables. Total is
# modeled from Unit price, Quantity, Branch, and Payment. This is a course-level
# demonstration of multiple predictors and categorical factor encoding.
required_for_model <- c("Total", "Unit price", "Quantity", "Branch", "Payment")
model_data <- sales_clean[complete.cases(sales_clean[, required_for_model]),
                          required_for_model]
model_data$Branch <- droplevels(as.factor(model_data$Branch))
model_data$Payment <- droplevels(as.factor(model_data$Payment))

if (nrow(model_data) < 10 || length(unique(model_data$`Unit price`)) < 2 ||
    length(unique(model_data$Quantity)) < 2) {
  stop("Unit 4 has insufficient complete observations or predictor variation.")
}
multiple_model <- lm(Total ~ `Unit price` + Quantity + Branch + Payment,
                     data = model_data)
multiple_summary <- summary(multiple_model)
print(multiple_summary)
capture.output(multiple_summary,
  file = file.path(project_root, "outputs/reports/unit4_multiple_regression_summary.txt"))

coefficient_table <- as.data.frame(multiple_summary$coefficients)
coefficient_table$Term <- rownames(coefficient_table)
rownames(coefficient_table) <- NULL
coefficient_table <- coefficient_table[, c("Term", "Estimate", "Std. Error",
                                           "t value", "Pr(>|t|)")]
print(coefficient_table)
write.csv(coefficient_table,
  file.path(project_root, "outputs/reports/unit4_regression_coefficients.csv"),
  row.names = FALSE)

fstat <- multiple_summary$fstatistic
model_metrics <- data.frame(
  Observations = nobs(multiple_model),
  R_Squared = multiple_summary$r.squared,
  Adjusted_R_Squared = multiple_summary$adj.r.squared,
  Residual_Standard_Error = multiple_summary$sigma,
  F_Statistic = unname(fstat[1]),
  F_DF1 = unname(fstat[2]),
  F_DF2 = unname(fstat[3]),
  Overall_Model_P_Value = pf(fstat[1], fstat[2], fstat[3], lower.tail = FALSE)
)
print(model_metrics)
write.csv(model_metrics,
  file.path(project_root, "outputs/reports/unit4_model_metrics.csv"),
  row.names = FALSE)
write.csv(as.data.frame(confint(multiple_model)),
  file.path(project_root, "outputs/reports/unit4_coefficient_confidence_intervals.csv"))

# Scatterplot of observed Total and fitted values, as a compact diagnostic.
fitted_data <- data.frame(Observed_Total = model_data$Total,
                          Predicted_Total = fitted(multiple_model))
p_observed_fitted <- ggplot2::ggplot(fitted_data,
  ggplot2::aes(x = Observed_Total, y = Predicted_Total)) +
  ggplot2::geom_point(color = "steelblue", alpha = 0.65) +
  ggplot2::geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  ggplot2::labs(title = "Observed vs Predicted Invoice Total",
                x = "Observed Total", y = "Predicted Total") +
  ggplot2::theme_minimal()
save_project_plot(p_observed_fitted, "unit4_observed_vs_predicted.png")
# Inferences:
# Points near the dashed equality line indicate predictions close to observed
# totals. Systematic departures show where the model under- or over-predicts.
# This visual check should be read alongside adjusted R² and coefficient tests.

# Save the classic four-panel regression diagnostics using Base R graphics.
grDevices::png(file.path(project_root, "outputs/plots/unit4_diagnostic_panels.png"),
               width = 1200, height = 1000, res = 130)
par(mfrow = c(2, 2))
plot(multiple_model)
par(mfrow = c(1, 1))
grDevices::dev.off()
# Inferences:
# 1. Residuals vs Fitted checks linearity and constant variance; systematic curves
#    or funnels suggest model assumptions may be violated.
# 2. The Normal Q-Q plot checks whether residuals follow a roughly normal shape.
# 3. Scale-Location checks whether residual spread is stable across fitted values.
# 4. Residuals vs Leverage helps flag influential observations. Review them rather
#    than deleting observations automatically.

# Predict at median numerical inputs and most common factor levels.
most_common <- function(x) {
  counts <- table(x)
  names(counts)[which.max(counts)]
}
new_case <- data.frame(
  `Unit price` = median(model_data$`Unit price`),
  Quantity = median(model_data$Quantity),
  Branch = factor(most_common(model_data$Branch), levels = levels(model_data$Branch)),
  Payment = factor(most_common(model_data$Payment), levels = levels(model_data$Payment)),
  check.names = FALSE
)
prediction <- predict(multiple_model, newdata = new_case,
                      interval = "prediction", level = 0.95)
prediction_table <- cbind(new_case, as.data.frame(prediction))
print(prediction_table)
write.csv(prediction_table,
  file.path(project_root, "outputs/reports/unit4_example_prediction.csv"),
  row.names = FALSE)

# ---------------------------------------------------------------------------
# Why the additive model is not a perfect fit.
# Total = 1.05 * Quantity * Unit price in every row of this dataset, i.e. the
# true relationship is multiplicative. An additive model therefore cannot reach
# R^2 = 1; adding the interaction term reproduces Total exactly. This check is
# reported so the model is not mistaken for an independent discovery.
# ---------------------------------------------------------------------------
interaction_model <- lm(Total ~ `Unit price` * Quantity, data = model_data)
interaction_summary <- summary(interaction_model)
cat("\nCheck - additive model vs model with interaction:\n")
cat(sprintf("Additive model (Total ~ Unit price + Quantity + Branch + Payment): R-squared = %.6f\n",
            multiple_summary$r.squared))
cat(sprintf("Model with interaction (Total ~ Unit price * Quantity):            R-squared = %.6f\n",
            interaction_summary$r.squared))
write.csv(data.frame(
  Model = c("Additive: Total ~ Unit price + Quantity + Branch + Payment",
            "With interaction: Total ~ Unit price * Quantity"),
  R_Squared = c(multiple_summary$r.squared, interaction_summary$r.squared),
  Note = c("Additive form cannot represent Total = 1.05 * Quantity * Unit price",
           "Interaction term reproduces the invoice formula, R-squared = 1")
), file.path(project_root, "outputs/reports/unit4_model_form_comparison.csv"),
row.names = FALSE)
capture.output(interaction_summary,
  file = file.path(project_root, "outputs/reports/unit4_interaction_model_summary.txt"))
cat("Residual standard error of the additive model:",
    round(multiple_summary$sigma, 4), " on", nobs(multiple_model), "observations.\n")

cat("[UNIT 4] Completed.\n")
