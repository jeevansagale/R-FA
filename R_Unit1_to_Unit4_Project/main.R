# ==============================================================
# Subject: Statistical Data Analysis using R
# Topic: Descriptive Analysis of Supermarket Sales Data
# Dataset: Supermarket Sales Dataset
# ==============================================================

cat("\n============================================================\n")
cat("R PROGRAMMING PROJECT: UNIT 1 TO UNIT 4\n")
cat("============================================================\n")

a <- commandArgs(trailingOnly=FALSE)
f <- sub("^--file=", "", a[grepl("^--file=", a)])
project_root <- if (length(f)==0) getwd() else dirname(normalizePath(f, mustWork=FALSE))
if (!file.exists(file.path(project_root,"data","supermarket_sales.csv")) && file.exists(file.path(getwd(),"data","supermarket_sales.csv")))
  project_root <- normalizePath(getwd())

source(file.path(project_root,"requirements.R"), local=.GlobalEnv)
library(dplyr); library(ggplot2)
if (requireNamespace("tidyr", quietly=TRUE)) library(tidyr)
if (requireNamespace("pastecs", quietly=TRUE)) library(pastecs)
if (requireNamespace("moments", quietly=TRUE)) library(moments)
if (requireNamespace("corrplot", quietly=TRUE)) library(corrplot)

for (d in c("outputs/plots","outputs/reports","report/figures"))
  dir.create(file.path(project_root,d), recursive=TRUE, showWarnings=FALSE)
source(file.path(project_root,"functions/helper_functions.R"), local=.GlobalEnv)

paths <- c(file.path(project_root,"data","supermarket_sales.csv"),
           "D:/PCCOE/sem3/R/units/project/supermarket_sales.csv")
dataset_path <- paths[file.exists(paths)][1]
supermarket_data <- read.csv(dataset_path, stringsAsFactors=FALSE, check.names=FALSE)
cat("Dataset:", nrow(supermarket_data), "rows,", ncol(supermarket_data), "cols\n")

# UNIT 1 - basics
arithmetic_examples <- data.frame(Expression=c("2+3","2*4","2^3","30%%7","sin(pi/6)"),
  Result=c(5,8,8,2,0.5))
write.csv(arithmetic_examples, file.path(project_root,"outputs/reports/unit1_arithmetic_examples.csv"), row.names=FALSE)

numeric_vector <- c(2,3,5,7)
vector_examples <- list(sq=numeric_vector^2, sum=sum(numeric_vector), prod=prod(numeric_vector))
print(vector_examples)

student_data <- data.frame(Roll_No=c(101,102,103), Name=c("Amit","Priya","Rahul"), Marks=c(85,90,78))
write.csv(student_data, file.path(project_root,"outputs/reports/student_data_example.csv"), row.names=FALSE)

Data <- read.csv(file.path(project_root,"data/supermarket_sales.csv"), stringsAsFactors=FALSE, check.names=FALSE)
dim(Data); colnames(Data); head(Data,2); str(Data); summary(Data)
mean(Data$Total); sd(Data$Total, na.rm=TRUE)
Missing <- data.frame(Column=colnames(Data), Missing_Count=colSums(is.na(Data)))
CleanData <- na.omit(Data)

numeric_names <- names(supermarket_data)[vapply(supermarket_data, is.numeric, logical(1))]
unit1_numeric_summary <- data.frame(Variable=numeric_names,
  Mean=vapply(supermarket_data[numeric_names], mean, numeric(1), na.rm=TRUE),
  Median=vapply(supermarket_data[numeric_names], median, numeric(1), na.rm=TRUE),
  SD=vapply(supermarket_data[numeric_names], sd, numeric(1), na.rm=TRUE))
write.csv(unit1_numeric_summary, file.path(project_root,"outputs/reports/unit1_dataset_numeric_summary.csv"), row.names=FALSE)
write.csv(supermarket_data, file.path(project_root,"outputs/reports/supermarket_sales_exported.csv"), row.names=FALSE)

# UNIT 2 - cleaning + descriptive
sales_clean <- supermarket_data
for (nm in names(sales_clean)[vapply(sales_clean, is.character, logical(1))]) sales_clean[[nm]] <- trimws(sales_clean[[nm]])
sales_clean$Date <- as.Date(sales_clean$Date, format="%m/%d/%Y")
for (nm in intersect(c("Branch","City","Customer type","Gender","Product line","Payment"), names(sales_clean)))
  sales_clean[[nm]] <- as.factor(sales_clean[[nm]])

duplicate_audit <- data.frame(Total_Rows=nrow(sales_clean), Duplicate_Rows=sum(duplicated(sales_clean)))
write.csv(duplicate_audit, file.path(project_root,"outputs/reports/unit2_duplicate_audit.csv"), row.names=FALSE)
missing_audit <- data.frame(Variable=names(sales_clean), Missing_Count=colSums(is.na(sales_clean)))
write.csv(missing_audit, file.path(project_root,"outputs/reports/unit2_missing_value_audit.csv"), row.names=FALSE)

selected_sales <- select(sales_clean, Branch, City, `Product line`, Total, Quantity, `gross income`, Rating)
filtered_sales <- filter(selected_sales, Total>0)
mutated_sales <- mutate(filtered_sales, Average_Amount_Per_Item=Total/Quantity)
ordered_sales <- arrange(mutated_sales, desc(Total))

product_summary <- mutated_sales %>% group_by(`Product line`) %>%
  summarise(Transaction_Count=n(), Mean_Total=mean(Total), SD_Total=sd(Total), Total_Revenue=sum(Total), .groups="drop") %>%
  arrange(desc(Total_Revenue))
write.csv(product_summary, file.path(project_root,"outputs/reports/unit2_product_line_summary.csv"), row.names=FALSE)

branch_summary <- mutated_sales %>% group_by(Branch, City) %>%
  summarise(Transactions=n(), Revenue=sum(Total), Average_Total=mean(Total), .groups="drop")
write.csv(branch_summary, file.path(project_root,"outputs/reports/unit2_branch_summary.csv"), row.names=FALSE)

numeric_vars <- intersect(c("Unit price","Quantity","Tax 5%","Total","cogs","gross income","Rating"), names(sales_clean))
descriptive_table <- data.frame(Variable=numeric_vars,
  N=vapply(sales_clean[numeric_vars], function(x) sum(!is.na(x)), integer(1)),
  Mean=vapply(sales_clean[numeric_vars], mean, numeric(1), na.rm=TRUE),
  SD=vapply(sales_clean[numeric_vars], sd, numeric(1), na.rm=TRUE),
  IQR=vapply(sales_clean[numeric_vars], IQR, numeric(1), na.rm=TRUE))
write.csv(descriptive_table, file.path(project_root,"outputs/reports/unit2_descriptive_statistics.csv"), row.names=FALSE)

# plots
save_project_plot(ggplot(sales_clean, aes(x=Total)) + geom_histogram(bins=30, fill="steelblue", color="white") + labs(title="Invoice Totals", x="Invoice Total") + theme_minimal(), "unit2_total_histogram.png")
save_project_plot(ggplot(sales_clean, aes(x=Total)) + geom_density(fill="darkseagreen3", alpha=0.65) + theme_minimal(), "unit2_total_density.png")
save_project_plot(ggplot(sales_clean, aes(y=Total)) + geom_boxplot(fill="lightblue") + theme_minimal(), "unit2_total_boxplot.png")
save_project_plot(ggplot(sales_clean, aes(x=`Product line`, fill=`Product line`)) + geom_bar() + coord_flip() + theme_minimal() + theme(legend.position="none"), "unit2_product_line_bar.png")
save_project_plot(ggplot(sales_clean, aes(x=`Product line`, y=Total, fill=`Product line`)) + geom_boxplot() + theme_minimal(), "unit2_total_by_product_line.png")
save_project_plot(ggplot(branch_summary, aes(x=Branch, y=Revenue, fill=Branch)) + geom_col() + theme_minimal(), "unit2_branch_revenue.png")
save_project_plot(ggplot(sales_clean, aes(x=`Unit price`, y=Total)) + geom_point(color="blue", alpha=0.65) + theme_minimal(), "unit2_unit_price_vs_total_scatter.png")

# sample-style extras
S1 <- select(Data, Branch, `Product line`, Total, Rating, Quantity)
F1 <- filter(Data, Quantity >= 7)
M1 <- mutate(Data, Price_Range=`Unit price`*Quantity)
A1 <- arrange(Data, Total); A2 <- arrange(Data, desc(Total))
info <- summarise(Data, Average_Total=mean(Total, na.rm=TRUE), Average_Rating=mean(Rating, na.rm=TRUE))
new <- group_by(Data, `Product line`)

Numeric_Data <- Data %>% select(where(is.numeric))
Mean <- mean(Data$Total, na.rm=TRUE); Median <- median(Data$Total, na.rm=TRUE)
SD <- sd(Data$Total, na.rm=TRUE); CV <- SD/Mean*100
CV_All <- sapply(Numeric_Data, function(x) sd(x,na.rm=TRUE)/abs(mean(x,na.rm=TRUE))*100)
if (requireNamespace("pastecs", quietly=TRUE)) pastecs::stat.desc(Numeric_Data)
Correlation_Data <- cor(Numeric_Data, use="pairwise.complete.obs")
if (requireNamespace("corrplot", quietly=TRUE)) { corrplot::corrplot(Correlation_Data); corrplot::corrplot(Correlation_Data, method="number") }

write.csv(sales_clean, file.path(project_root,"outputs/reports/supermarket_sales_cleaned.csv"), row.names=FALSE)

# UNIT 3 - simple regression
regression_data <- sales_clean[complete.cases(sales_clean[,c("cogs","gross income")]), c("cogs","gross income")]
simple_model <- lm(`gross income` ~ cogs, data=regression_data)
simple_model_summary <- summary(simple_model)
capture.output(simple_model_summary, file=file.path(project_root,"outputs/reports/unit3_simple_regression_summary.txt"))
simple_metrics <- data.frame(Intercept=unname(coef(simple_model)[1]), Slope=unname(coef(simple_model)[2]),
  R_Squared=simple_model_summary$r.squared, Observations=nobs(simple_model))
write.csv(simple_metrics, file.path(project_root,"outputs/reports/unit3_simple_regression_metrics.csv"), row.names=FALSE)
save_project_plot(ggplot(regression_data, aes(x=cogs, y=`gross income`)) + geom_point(color="blue", alpha=0.65) + geom_smooth(method="lm", color="red", linetype="dashed") + theme_minimal(), "unit3_simple_regression.png")
prediction_data <- data.frame(cogs=as.numeric(quantile(regression_data$cogs, probs=c(0.25,0.5,0.75))))
write.csv(cbind(prediction_data, as.data.frame(predict(simple_model, newdata=prediction_data, interval="prediction"))),
  file.path(project_root,"outputs/reports/unit3_predictions.csv"), row.names=FALSE)
save_project_plot(ggplot(data.frame(Fitted=fitted(simple_model), Residuals=residuals(simple_model)), aes(x=Fitted, y=Residuals)) + geom_point(color="darkorange") + geom_hline(yintercept=0, linetype="dashed", color="red") + theme_minimal(), "unit3_residuals_vs_fitted.png")

# UNIT 4 - multiple regression
numeric_columns <- names(sales_clean)[vapply(sales_clean, is.numeric, logical(1))]
correlation_data <- sales_clean[, numeric_columns, drop=FALSE]
correlation_data <- correlation_data[, vapply(correlation_data, function(x) sd(x,na.rm=TRUE)>0, logical(1)), drop=FALSE]
correlation_data <- correlation_data[, colSums(is.na(correlation_data))==0, drop=FALSE]
correlation_matrix <- cor(correlation_data)
write.csv(correlation_matrix, file.path(project_root,"outputs/reports/unit4_numeric_correlation_matrix.csv"), row.names=TRUE)

required_for_model <- c("Total","Unit price","Quantity","Branch","Payment")
model_data <- sales_clean[complete.cases(sales_clean[,required_for_model]), required_for_model]
multiple_model <- lm(Total ~ `Unit price` + Quantity + Branch + Payment, data=model_data)
multiple_summary <- summary(multiple_model)
capture.output(multiple_summary, file=file.path(project_root,"outputs/reports/unit4_multiple_regression_summary.txt"))
coefficient_table <- as.data.frame(multiple_summary$coefficients); coefficient_table$Term <- rownames(coefficient_table)
write.csv(coefficient_table, file.path(project_root,"outputs/reports/unit4_regression_coefficients.csv"), row.names=FALSE)
fstat <- multiple_summary$fstatistic
model_metrics <- data.frame(Observations=nobs(multiple_model), R_Squared=multiple_summary$r.squared, Adjusted_R_Squared=multiple_summary$adj.r.squared, Residual_Standard_Error=multiple_summary$sigma)
write.csv(model_metrics, file.path(project_root,"outputs/reports/unit4_model_metrics.csv"), row.names=FALSE)
write.csv(as.data.frame(confint(multiple_model)), file.path(project_root,"outputs/reports/unit4_coefficient_confidence_intervals.csv"))
save_project_plot(ggplot(data.frame(Observed_Total=model_data$Total, Predicted_Total=fitted(multiple_model)), aes(x=Observed_Total, y=Predicted_Total)) + geom_point(color="steelblue", alpha=0.65) + geom_abline(slope=1, intercept=0, color="red", linetype="dashed") + theme_minimal(), "unit4_observed_vs_predicted.png")
png(file.path(project_root,"outputs/plots/unit4_diagnostic_panels.png"), width=1200, height=1000, res=130); par(mfrow=c(2,2)); plot(multiple_model); dev.off()
new_case <- data.frame(`Unit price`=median(model_data$`Unit price`), Quantity=median(model_data$Quantity),
  Branch=factor(names(which.max(table(model_data$Branch))), levels=levels(model_data$Branch)),
  Payment=factor(names(which.max(table(model_data$Payment))), levels=levels(model_data$Payment)), check.names=FALSE)
write.csv(cbind(new_case, as.data.frame(predict(multiple_model, newdata=new_case, interval="prediction"))),
  file.path(project_root,"outputs/reports/unit4_example_prediction.csv"), row.names=FALSE)
interaction_model <- lm(Total ~ `Unit price` * Quantity, data=model_data)
write.csv(data.frame(Model=c("Additive","With interaction"), R_Squared=c(multiple_summary$r.squared, summary(interaction_model)$r.squared)),
  file.path(project_root,"outputs/reports/unit4_model_form_comparison.csv"), row.names=FALSE)

# PROBLEM STATEMENTS PS1-PS5
report_dir <- file.path(project_root,"outputs/reports")
anova_term_row <- function(s, term) { r <- trimws(gsub("`","",rownames(s[[1]]))); s[[1]][which(r==term),] }
anova_stats <- function(s, term) { r <- anova_term_row(s, term); list(statistic=unname(r[["F value"]]), df=unname(r[["Df"]]), p_value=unname(r[["Pr(>F)"]])) }
inferential_rows <- list()
add_test <- function(id, ps, q, test, h0, h1, type, stat, df, p) {
  inferential_rows[[id]] <<- data.frame(Problem_statement=ps, Question=q, Test=test, Null_hypothesis=h0, Alternative=h1, Alpha=0.05, Statistic_type=type, Statistic=stat, DF=df, P_value=p, stringsAsFactors=FALSE)
}

data_quality <- data.frame(Rows=nrow(supermarket_data), Columns=ncol(supermarket_data), Missing_Cells=sum(is.na(supermarket_data)), Duplicate_Rows=sum(duplicated(supermarket_data)))
write.csv(data_quality, file.path(report_dir,"ps0_data_quality.csv"), row.names=FALSE)

ps1 <- sales_clean %>% group_by(`Product line`) %>%
  summarise(Transactions=n(), Mean_Rating=mean(Rating), SD_Rating=sd(Rating), Mean_Gross_Income=mean(`gross income`), Total_Gross_Income=sum(`gross income`), Total_Revenue=sum(Total), .groups="drop") %>% arrange(desc(Mean_Rating))
write.csv(ps1, file.path(report_dir,"ps1_product_line_performance.csv"), row.names=FALSE)
ps1_rating_aov <- summary(aov(Rating ~ `Product line`, data=sales_clean)); r1 <- anova_stats(ps1_rating_aov, "Product line")
add_test("ps1_rating","PS1: product line ratings","Do mean ratings differ?","ANOVA","H0: equal","H1: differs","F",r1$statistic,r1$df,r1$p_value)
capture.output(ps1_rating_aov, file=file.path(report_dir,"ps1_rating_anova.txt"))
ps1_gross_aov <- summary(aov(`gross income` ~ `Product line`, data=sales_clean)); g1 <- anova_stats(ps1_gross_aov, "Product line")
add_test("ps1_gross","PS1: product line gross income","Do mean gross incomes differ?","ANOVA","H0: equal","H1: differs","F",g1$statistic,g1$df,g1$p_value)
capture.output(ps1_gross_aov, file=file.path(report_dir,"ps1_gross_income_anova.txt"))

ps2_rev <- sales_clean %>% group_by(Branch, City) %>%
  summarise(Transactions=n(), Revenue=sum(Total), Mean_Total=mean(Total), Median_Total=median(Total), .groups="drop") %>% arrange(desc(Revenue))
write.csv(ps2_rev, file.path(report_dir,"ps2_branch_revenue.csv"), row.names=FALSE)
ps2_counts <- as.data.frame(table(Branch=sales_clean$Branch, Customer_Type=sales_clean$`Customer type`)); names(ps2_counts)[3] <- "Transactions"
write.csv(ps2_counts, file.path(report_dir,"ps2_branch_customer_counts.csv"), row.names=FALSE)
ps2_aov <- summary(aov(Total ~ Branch, data=sales_clean)); b2 <- anova_stats(ps2_aov, "Branch")
add_test("ps2_anova","PS2: branch revenue","Do means differ by branch?","ANOVA","H0: equal","H1: differs","F",b2$statistic,b2$df,b2$p_value)
capture.output(ps2_aov, file=file.path(report_dir,"ps2_branch_anova.txt"))
ps2_chi <- chisq.test(table(sales_clean$Branch, sales_clean$`Customer type`))
capture.output(ps2_chi, file=file.path(report_dir,"ps2_branch_customer_chisquare.txt"))
add_test("ps2_chi","PS2: branch customer mix","Is mix independent of branch?","Chi-square","H0: same","H1: differs","X-squared",unname(ps2_chi$statistic),unname(ps2_chi$parameter),ps2_chi$p.value)

ps3_gender <- as.data.frame(table(Payment=sales_clean$Payment, Gender=sales_clean$Gender)); names(ps3_gender)[3] <- "Transactions"
ps3_gender$Share_within_gender <- ave(ps3_gender$Transactions, ps3_gender$Gender, FUN=function(x) round(x/sum(x)*100,1))
write.csv(ps3_gender, file.path(report_dir,"ps3_payment_by_gender.csv"), row.names=FALSE)
ps3_cust <- as.data.frame(table(Payment=sales_clean$Payment, Customer_Type=sales_clean$`Customer type`)); names(ps3_cust)[3] <- "Transactions"
ps3_cust$Share_within_segment <- ave(ps3_cust$Transactions, ps3_cust$Customer_Type, FUN=function(x) round(x/sum(x)*100,1))
write.csv(ps3_cust, file.path(report_dir,"ps3_payment_by_customertype.csv"), row.names=FALSE)
ps3_chi_g <- chisq.test(table(sales_clean$Payment, sales_clean$Gender))
capture.output(ps3_chi_g, file=file.path(report_dir,"ps3_payment_gender_chisquare.txt"))
add_test("ps3_gender","PS3: payment by gender","Independent of gender?","Chi-square","H0: same","H1: differs","X-squared",unname(ps3_chi_g$statistic),unname(ps3_chi_g$parameter),ps3_chi_g$p.value)
ps3_chi_c <- chisq.test(table(sales_clean$Payment, sales_clean$`Customer type`))
capture.output(ps3_chi_c, file=file.path(report_dir,"ps3_payment_customertype_chisquare.txt"))
add_test("ps3_cust","PS3: payment by customer type","Independent of type?","Chi-square","H0: same","H1: differs","X-squared",unname(ps3_chi_c$statistic),unname(ps3_chi_c$parameter),ps3_chi_c$p.value)

sales_clean$Hour <- as.integer(substr(sales_clean$Time,1,2))
sales_clean$Part_of_day <- cut(sales_clean$Hour, breaks=c(9,12,16,21), labels=c("Morning (10-12)","Afternoon (13-16)","Evening (17-20)"), include.lowest=TRUE)
sales_clean$Weekday <- weekdays(sales_clean$Date)
ps4_hour <- sales_clean %>% group_by(Hour) %>% summarise(Transactions=n(), Revenue=sum(Total), Mean_Total=mean(Total), .groups="drop") %>% arrange(desc(Transactions))
write.csv(ps4_hour, file.path(report_dir,"ps4_hourly.csv"), row.names=FALSE)
ps4_part <- sales_clean %>% group_by(Part_of_day) %>% summarise(Transactions=n(), Revenue=sum(Total), Mean_Total=mean(Total), .groups="drop") %>% arrange(desc(Transactions))
write.csv(ps4_part, file.path(report_dir,"ps4_part_of_day.csv"), row.names=FALSE)
ps4_day <- sales_clean %>% group_by(Weekday) %>% summarise(Transactions=n(), Revenue=sum(Total), Mean_Total=mean(Total), .groups="drop") %>% arrange(desc(Transactions))
write.csv(ps4_day, file.path(report_dir,"ps4_weekday.csv"), row.names=FALSE)
ps4_chi_h <- chisq.test(table(sales_clean$Hour)); capture.output(ps4_chi_h, file=file.path(report_dir,"ps4_hour_uniformity_chisquare.txt"))
add_test("ps4_hour","PS4: hourly volume","Uniform hours?","Chi-square GOF","H0: uniform","H1: differs","X-squared",unname(ps4_chi_h$statistic),unname(ps4_chi_h$parameter),ps4_chi_h$p.value)
ps4_chi_d <- chisq.test(table(sales_clean$Weekday)); capture.output(ps4_chi_d, file=file.path(report_dir,"ps4_weekday_uniformity_chisquare.txt"))
add_test("ps4_day","PS4: weekday volume","Uniform weekdays?","Chi-square GOF","H0: uniform","H1: differs","X-squared",unname(ps4_chi_d$statistic),unname(ps4_chi_d$parameter),ps4_chi_d$p.value)

ps5_qty <- cor.test(sales_clean$`Unit price`, sales_clean$Quantity)
capture.output(ps5_qty, file=file.path(report_dir,"ps5_price_quantity_correlation.txt"))
add_test("ps5_qty","PS5: price vs quantity","Correlation zero?","Pearson","H0: r=0","H1: r!=0","r",unname(ps5_qty$estimate),ps5_qty$parameter,ps5_qty$p.value)
ps5_gross <- cor.test(sales_clean$`Unit price`, sales_clean$`gross income`)
capture.output(ps5_gross, file=file.path(report_dir,"ps5_price_grossincome_correlation.txt"))
add_test("ps5_gross","PS5: price vs gross income","Correlation zero?","Pearson","H0: r=0","H1: r!=0","r",unname(ps5_gross$estimate),ps5_gross$parameter,ps5_gross$p.value)
ps5_profit <- sales_clean %>% group_by(`Product line`) %>% summarise(Transactions=n(), Mean_Unit_Price=mean(`Unit price`), Mean_Quantity=mean(Quantity), Total_Gross_Income=sum(`gross income`), Total_Revenue=sum(Total), .groups="drop") %>% arrange(desc(Total_Gross_Income))
write.csv(ps5_profit, file.path(report_dir,"ps5_profitability_by_product.csv"), row.names=FALSE)
ps5_model <- lm(`gross income` ~ `Unit price`, data=sales_clean)
capture.output(summary(ps5_model), file=file.path(report_dir,"ps5_gross_income_model.txt"))

inferential_tests <- bind_rows(inferential_rows)
inferential_tests$Significant_at_5pct <- inferential_tests$P_value < 0.05
write.csv(inferential_tests, file.path(report_dir,"ps_inferential_tests.csv"), row.names=FALSE)

# REPORT FIGURES
figures_dir <- file.path(project_root,"report/figures")
save_report_figure <- function(p, fn, w=8, h=5) ggsave(file.path(figures_dir,fn), p, width=w, height=h, dpi=200)
save_grid_figure <- function(top,bottom,fn,w=8,h=6.4) { png(file.path(figures_dir,fn), width=w*200, height=h*200, res=200); grid::pushViewport(grid::viewport(layout=grid::grid.layout(2,1))); print(top, vp=grid::viewport(layout.pos.row=1, layout.pos.col=1)); print(bottom, vp=grid::viewport(layout.pos.row=2, layout.pos.col=1)); dev.off() }
fig1_top <- ggplot(ps1, aes(x=reorder(`Product line`, Mean_Rating), y=Mean_Rating, fill=`Product line`)) + geom_col(show.legend=FALSE) + coord_flip() + labs(title="Figure 1a. Mean rating by product line") + theme_minimal()
fig1_bottom <- ggplot(ps1, aes(x=reorder(`Product line`, Total_Gross_Income), y=Total_Gross_Income, fill=`Product line`)) + geom_col(show.legend=FALSE) + coord_flip() + labs(title="Figure 1b. Total gross income by product line") + theme_minimal()
save_grid_figure(fig1_top, fig1_bottom, "fig1_product_line_performance.png")
fig2_top <- ggplot(ps2_rev, aes(x=Branch, y=Revenue, fill=City)) + geom_col() + labs(title="Figure 2a. Revenue by branch") + theme_minimal()
fig2_counts <- sales_clean %>% group_by(Branch, `Customer type`) %>% summarise(Transactions=n(), .groups="drop")
fig2_bottom <- ggplot(fig2_counts, aes(x=Branch, y=Transactions, fill=`Customer type`)) + geom_bar(stat="identity", position="dodge") + theme_minimal()
save_grid_figure(fig2_top, fig2_bottom, "fig2_branch_comparison.png")
fig3_data <- sales_clean %>% group_by(Payment, Gender, `Customer type`) %>% summarise(Transactions=n(), .groups="drop")
save_report_figure(ggplot(fig3_data, aes(x=Payment, y=Transactions, fill=Gender)) + geom_col(position="dodge") + facet_wrap(~`Customer type`) + labs(title="Figure 3. Payment by gender and customer type") + theme_minimal(), "fig3_payment_demographics.png")
fig4_top <- ggplot(ps4_hour, aes(x=factor(Hour), y=Transactions)) + geom_col(fill="steelblue") + theme_minimal()
fig4_bottom <- ggplot(ps4_day, aes(x=reorder(Weekday, Revenue), y=Revenue)) + geom_col(fill="darkorange") + coord_flip() + theme_minimal()
save_grid_figure(fig4_top, fig4_bottom, "fig4_peak_hours_days.png")
save_report_figure(ggplot(sales_clean, aes(x=`Unit price`, y=Quantity, color=`Product line`)) + geom_point(alpha=0.6) + geom_smooth(method="lm", linetype="dashed", color="black", se=FALSE) + labs(title="Figure 5. Unit price vs quantity") + theme_minimal(), "fig5_price_vs_quantity.png")

# VERIFICATION
raw <- read.csv(file.path(project_root,"data","supermarket_sales.csv"), stringsAsFactors=FALSE, check.names=FALSE)
raw_times <- raw; raw_times$Hour <- as.integer(substr(raw_times$Time,1,2)); raw_times$Weekday <- weekdays(as.Date(raw_times$Date, format="%m/%d/%Y"))
checks <- list(Rows=list(analysis=nrow(supermarket_data), raw=nrow(raw)), Columns=list(analysis=ncol(supermarket_data), raw=ncol(raw)),
  Total_revenue=list(analysis=sum(ps2_rev$Revenue), raw=sum(raw$Total)),
  Mean_rating=list(analysis=mean(sales_clean$Rating), raw=mean(raw$Rating)),
  Cor_price_qty=list(analysis=unname(ps5_qty$estimate), raw=cor(raw$`Unit price`, raw$Quantity)),
  Chisq_branch_cust=list(analysis=unname(ps2_chi$statistic), raw=unname(suppressWarnings(chisq.test(table(raw$Branch, raw$`Customer type`))$statistic))),
  Anova_rating_F=list(analysis=r1$statistic, raw=unname(summary(aov(Rating ~ `Product line`, data=raw))[[1]][1,"F value"])))
verification <- do.call(rbind, lapply(names(checks), function(nm) data.frame(Quantity=nm, Value_from_analysis_scripts=unname(checks[[nm]]$analysis), Value_recomputed_from_raw_csv=unname(checks[[nm]]$raw), Match=isTRUE(all.equal(unname(checks[[nm]]$analysis), unname(checks[[nm]]$raw))), stringsAsFactors=FALSE)))
identities <- data.frame(Identity=c("Total == 1.05*cogs","cogs == Qty*Price","Tax==gross"), Holds=c(isTRUE(all.equal(raw$Total, raw$cogs*1.05)), isTRUE(all.equal(raw$cogs, raw$Quantity*raw$`Unit price`)), isTRUE(all.equal(raw$`Tax 5%`, raw$`gross income`))))
write.csv(verification, file.path(project_root,"outputs/reports/verification_results.csv"), row.names=FALSE)
write.csv(identities, file.path(project_root,"outputs/reports/accounting_relations_check.csv"), row.names=FALSE)
if (!all(verification$Match)) stop("Verification failed")

cat("\n============================================================\n")
cat("PROJECT RUN FINISHED\n")
cat("============================================================\n")
