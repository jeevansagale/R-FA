# UNIT 3: simple linear regression and correlation
# Sources: Script Linear regression.pdf, Script_Scatter plot.pdf.

cat("\n[UNIT 3] Simple linear regression\n")

# The course notes introduce scatterplots, correlation, lm(), summary(), and
# regression-line visualization. Here we use actual dataset variables.
regression_data <- sales_clean[complete.cases(sales_clean[, c("cogs", "gross income")]),
                               c("cogs", "gross income")]
if (nrow(regression_data) < 3 || length(unique(regression_data$cogs)) < 2) {
  stop("Unit 3 requires at least three complete rows and variation in cogs.")
}

cat("Correlation between cogs and gross income:\n")
print(cor(regression_data$cogs, regression_data$`gross income`))

simple_model <- lm(`gross income` ~ cogs, data = regression_data)
simple_model_summary <- summary(simple_model)
print(simple_model_summary)
capture.output(simple_model_summary,
  file = file.path(project_root, "outputs/reports/unit3_simple_regression_summary.txt"))

simple_metrics <- data.frame(
  Intercept = unname(coef(simple_model)[1]),
  Slope = unname(coef(simple_model)[2]),
  R_Squared = simple_model_summary$r.squared,
  Adjusted_R_Squared = simple_model_summary$adj.r.squared,
  Slope_P_Value = coef(simple_model_summary)["cogs", "Pr(>|t|)"],
  Residual_Standard_Error = simple_model_summary$sigma,
  Observations = nobs(simple_model)
)
print(simple_metrics)
write.csv(simple_metrics,
  file.path(project_root, "outputs/reports/unit3_simple_regression_metrics.csv"),
  row.names = FALSE)

# Scatterplot with linear trendline, based on the course's geom_point + lm line.
p_simple_regression <- ggplot2::ggplot(regression_data,
  ggplot2::aes(x = cogs, y = `gross income`)) +
  ggplot2::geom_point(color = "blue", alpha = 0.65) +
  ggplot2::geom_smooth(method = "lm", formula = y ~ x,
                       color = "red", linetype = "dashed", se = TRUE) +
  ggplot2::labs(title = "Simple Regression: Gross Income vs COGS",
                x = "Cost of Goods Sold (cogs)", y = "Gross Income") +
  ggplot2::theme_minimal()
save_project_plot(p_simple_regression, "unit3_simple_regression.png")
# Inferences:
# The slope and its p-value quantify the fitted linear association, while R²
# describes the share of variation explained by the line. In this supermarket
# dataset gross income is derived from 5% of cogs, so the strong relationship is
# largely built into the accounting formula and is not causal evidence.

# Prediction at the 25th, 50th and 75th percentiles of cogs.
prediction_data <- data.frame(cogs = as.numeric(
  quantile(regression_data$cogs, probs = c(0.25, 0.50, 0.75), na.rm = TRUE)))
prediction_interval <- predict(simple_model, newdata = prediction_data,
                               interval = "prediction", level = 0.95)
prediction_results <- cbind(prediction_data, as.data.frame(prediction_interval))
print(prediction_results)
write.csv(prediction_results,
  file.path(project_root, "outputs/reports/unit3_predictions.csv"),
  row.names = FALSE)

# Residuals vs fitted diagnostic plot.
residual_data <- data.frame(Fitted = fitted(simple_model),
                            Residuals = residuals(simple_model))
p_residuals <- ggplot2::ggplot(residual_data,
  ggplot2::aes(x = Fitted, y = Residuals)) +
  ggplot2::geom_point(color = "darkorange", alpha = 0.7) +
  ggplot2::geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  ggplot2::labs(title = "Simple Regression: Residuals vs Fitted",
                x = "Fitted Gross Income", y = "Residual") +
  ggplot2::theme_minimal()
save_project_plot(p_residuals, "unit3_residuals_vs_fitted.png")
# Inferences:
# Random scatter around zero is consistent with linearity and roughly constant
# variance. Curvature suggests missing structure; a funnel suggests unequal
# variance. Very small residuals are expected because gross income is derived
# directly from cogs in this dataset.

cat("[UNIT 3] Completed.\n")
