# ==============================================================
# Subject: Statistical Data Analysis using R
# Topic: Descriptive Analysis of Supermarket Sales Data
# Dataset: Supermarket Sales Dataset
# ==============================================================


library(tidyr)
library(dplyr)
library(ggplot2)
if (requireNamespace("pastecs", quietly = TRUE)) library(pastecs)
if (requireNamespace("moments", quietly = TRUE)) library(moments)
if (requireNamespace("corrplot", quietly = TRUE)) library(corrplot)
if (requireNamespace("modeest", quietly = TRUE)) library(modeest)

args_list <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args_list[grepl("^--file=", args_list)])
project_root <- if (length(file_arg) == 0) getwd() else dirname(normalizePath(file_arg, mustWork = FALSE))

if (!file.exists(file.path(project_root, "data", "supermarket_sales.csv")) &&
    file.exists(file.path(getwd(), "data", "supermarket_sales.csv"))) {
  project_root <- normalizePath(getwd())
}

for (d in c("outputs/plots", "outputs/reports", "report/figures")) {
  dir.create(file.path(project_root, d), recursive = TRUE, showWarnings = FALSE)
}

report_dir <- file.path(project_root, "outputs/reports")
plots_dir  <- file.path(project_root, "outputs/plots")
fig_dir    <- file.path(project_root, "report/figures")

save_plot <- function(plot_obj, filename, width = 8, height = 5) {
  ggsave(file.path(plots_dir, filename), plot_obj, width = width, height = height, dpi = 200)
}

arithmetic_examples <- data.frame(
  Expression = c("2 + 3", "2 * 4", "2^3", "30 %% 7", "sin(pi / 6)"),
  Result = c(5, 8, 8, 2, 0.5)
)
write.csv(arithmetic_examples, file.path(report_dir, "unit1_arithmetic_examples.csv"), row.names = FALSE)

numeric_vector <- c(2, 3, 5, 7)
vector_examples <- list(
  squared = numeric_vector^2,
  sum = sum(numeric_vector),
  product = prod(numeric_vector)
)
print(vector_examples)

student_data <- data.frame(
  Roll_No = c(101, 102, 103),
  Name = c("Amit", "Priya", "Rahul"),
  Marks = c(85, 90, 78)
)
write.csv(student_data, file.path(report_dir, "student_data_example.csv"), row.names = FALSE)

csv_path <- file.path(project_root, "data", "supermarket_sales.csv")
if (!file.exists(csv_path)) csv_path <- "supermarket_sales.csv"

#import dataset
Data <- read.csv(csv_path, stringsAsFactors = FALSE, check.names = FALSE)
supermarket_data <- Data
write.csv(Data, file.path(report_dir, "supermarket_sales_exported.csv"), row.names = FALSE)

View(Data)

#Basic dataset information

dim(Data)
colnames(Data)
head(Data)
head(Data, 10)
tail(Data, 2)
nrow(Data)
ncol(Data)
str(Data)
summary(Data)

mean(Data$Total)
median(Data$Total, na.rm = TRUE)
sd(Data$Total, na.rm = TRUE)
var(Data$Total, na.rm = TRUE)

mean(Data$Rating)
mean(Data$Rating, na.rm = TRUE)

typeof(Data)
typeof(Data$Branch)
typeof(Data$Total)

num_vars <- names(Data)[vapply(Data, is.numeric, logical(1))]
unit1_summary <- data.frame(
  Variable = num_vars,
  Mean = vapply(Data[num_vars], mean, numeric(1), na.rm = TRUE),
  Median = vapply(Data[num_vars], median, numeric(1), na.rm = TRUE),
  SD = vapply(Data[num_vars], sd, numeric(1), na.rm = TRUE)
)
write.csv(unit1_summary, file.path(report_dir, "unit1_dataset_numeric_summary.csv"), row.names = FALSE)

#check missing values

anyNA(Data)
is.na(Data)
sum(is.na(Data))
colSums(is.na(Data))
rowSums(is.na(Data))

#missing value table

Missing <- data.frame(
  Column = colnames(Data),
  Missing_Count = colSums(is.na(Data))
)

View(Missing)
write.csv(Missing, file.path(report_dir, "unit2_missing_value_audit.csv"), row.names = FALSE)

#Remove rows having missing values

CleanData <- na.omit(Data)
View(CleanData)
dim(CleanData)

sales_clean <- Data
for (col in names(sales_clean)[vapply(sales_clean, is.character, logical(1))]) {
  sales_clean[[col]] <- trimws(sales_clean[[col]])
}
sales_clean$Date <- as.Date(sales_clean$Date, format = "%m/%d/%Y")
for (factor_col in intersect(c("Branch", "City", "Customer type", "Gender", "Product line", "Payment"), names(sales_clean))) {
  sales_clean[[factor_col]] <- as.factor(sales_clean[[factor_col]])
}

duplicate_audit <- data.frame(Total_Rows = nrow(sales_clean), Duplicate_Rows = sum(duplicated(sales_clean)))
write.csv(duplicate_audit, file.path(report_dir, "unit2_duplicate_audit.csv"), row.names = FALSE)
write.csv(sales_clean, file.path(report_dir, "supermarket_sales_cleaned.csv"), row.names = FALSE)

#select options

S1 <- select(Data, Branch, `Product line`, Total, Rating, Quantity)
View(S1)

S2 <- select(Data, Branch, Total, cogs, `gross income`)
View(S2)

#Filters operations

F1 <- filter(Data, Quantity >= 7)
View(F1)

F2 <- filter(Data, Rating > 7)
View(F2)

F3 <- filter(Data, Quantity >= 7, Rating > 7)
View(F3)

#Mutate operation

M1 <- mutate(Data, Price_Range = `Unit price` * Quantity)
View(M1)

#Arrange operation

A1 <- arrange(Data, Total)
View(A1)

A2 <- arrange(Data, desc(Total))
View(A2)

#summaries operation

info_close <- summarise(Data, avg = mean(Total), count = n())
View(info_close)

info <- summarise(
  Data,
  Average_Unit_price = mean(`Unit price`, na.rm = TRUE),
  Average_Quantity = mean(Quantity, na.rm = TRUE),
  Average_Total = mean(Total, na.rm = TRUE),
  Average_Rating = mean(Rating, na.rm = TRUE),
  Average_Gross_Income = mean(`gross income`, na.rm = TRUE)
)
View(info)

#group_by operation

new <- group_by(Data, `Product line`)
View(new)

#pipe operations

Data$Total %>% mean(na.rm = TRUE)
Data %>% summarise(mean(Total, na.rm = TRUE), n())
Data %>% group_by(Branch) %>% summarise(count = n(), avg = mean(Total, na.rm = TRUE))

#gather operation

gat <- gather(Data, "Sales_Stage", "value", 7:10)
View(gat)

#spread operation

spre <- spread(gat, Sales_Stage, value)
View(spre)

#unite

club <- unite(Data, "value", `Unit price`, Total, sep = "<-->")
View(club)

#separate

sep <- separate(club, value, c("Unit price", "Total"), sep = "<-->")
View(sep)

product_summary <- sales_clean %>%
  group_by(`Product line`) %>%
  summarise(
    Transaction_Count = n(),
    Mean_Total = mean(Total),
    SD_Total = sd(Total),
    Total_Revenue = sum(Total),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Revenue))
write.csv(product_summary, file.path(report_dir, "unit2_product_line_summary.csv"), row.names = FALSE)

branch_summary <- sales_clean %>%
  group_by(Branch, City) %>%
  summarise(Transactions = n(), Revenue = sum(Total), Average_Total = mean(Total), .groups = "drop")
write.csv(branch_summary, file.path(report_dir, "unit2_branch_summary.csv"), row.names = FALSE)

#CENTRAL TENDENCIES

Mean <- mean(Data$Total, na.rm = TRUE)
Median <- median(Data$Total, na.rm = TRUE)
Mode <- if (requireNamespace("modeest", quietly = TRUE)) {
  modeest::mfv(Data$Total, na_rm = TRUE)[1]
} else {
  as.numeric(names(which.max(table(Data$Total))))
}
print(Mean)
print(Median)
print(Mode)

#DISPERSION

SD <- sd(Data$Total, na.rm = TRUE)
Variance <- var(Data$Total, na.rm = TRUE)
Quartile <- quantile(Data$Total, na.rm = TRUE)
IQR_Value <- IQR(Data$Total, na.rm = TRUE)
Price_Range <- range(Data$Total, na.rm = TRUE)

print(SD)
print(Variance)
print(Quartile)
print(IQR_Value)
print(Price_Range)

#selecting Numerical data

Numeric_Data <- Data %>% select(where(is.numeric))

#COEFFICIENT OF VARIATION

CV <- SD / Mean * 100
print(CV)

# CV for every numerical column
CV_All <- sapply(Numeric_Data, function(x) {
  mean_x <- mean(x, na.rm = TRUE)
  sd_x <- sd(x, na.rm = TRUE)
  if (is.na(mean_x) || mean_x == 0 || is.na(sd_x)) return(NA_real_)
  sd_x / abs(mean_x) * 100
})
print(CV_All)

#DESCRIPTIVE STATISTICS

if (requireNamespace("pastecs", quietly = TRUE)) {
  print(stat.desc(Numeric_Data))
}

num_vars_desc <- intersect(c("Unit price", "Quantity", "Tax 5%", "Total", "cogs", "gross income", "Rating"), names(sales_clean))
descriptive_table <- data.frame(
  Variable = num_vars_desc,
  N = vapply(sales_clean[num_vars_desc], function(x) sum(!is.na(x)), integer(1)),
  Mean = vapply(sales_clean[num_vars_desc], mean, numeric(1), na.rm = TRUE),
  SD = vapply(sales_clean[num_vars_desc], sd, numeric(1), na.rm = TRUE),
  IQR = vapply(sales_clean[num_vars_desc], IQR, numeric(1), na.rm = TRUE)
)
write.csv(descriptive_table, file.path(report_dir, "unit2_descriptive_statistics.csv"), row.names = FALSE)

# CORRELATION

Correlation_Data <- cor(Numeric_Data, use = "pairwise.complete.obs")
print(Correlation_Data)

# 13. CORRELATION PLOTS

# Correlation colour plot
if (requireNamespace("corrplot", quietly = TRUE)) {
  corrplot(Correlation_Data)
  # Correlation with numerical values
  corrplot(Correlation_Data, method = "number")
  # Correlation with pie charts
  corrplot(Correlation_Data, method = "pie")
}

save_plot(ggplot(sales_clean, aes(x = Total)) + geom_histogram(bins = 30, fill = "steelblue", color = "white") + labs(title = "Histogram of Total Invoice Spending", x = "Total Invoice Spending", y = "Count") + theme_minimal(), "unit2_total_histogram.png")
save_plot(ggplot(sales_clean, aes(x = Total)) + geom_density(fill = "darkseagreen3", alpha = 0.65) + labs(title = "Density Plot of Invoice Totals", x = "Invoice Total") + theme_minimal(), "unit2_total_density.png")
save_plot(ggplot(sales_clean, aes(y = Total)) + geom_boxplot(fill = "lightblue") + labs(title = "Boxplot of Invoice Totals", y = "Invoice Total") + theme_minimal(), "unit2_total_boxplot.png")
save_plot(ggplot(sales_clean, aes(x = `Product line`, fill = `Product line`)) + geom_bar() + coord_flip() + labs(title = "Transactions by Product Line", x = "Product Line", y = "Count") + theme_minimal() + theme(legend.position = "none"), "unit2_product_line_bar.png")
save_plot(ggplot(sales_clean, aes(x = `Product line`, y = Total, fill = `Product line`)) + geom_boxplot() + labs(title = "Total by Product Line", x = "Product Line", y = "Total") + theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none"), "unit2_total_by_product_line.png")
save_plot(ggplot(branch_summary, aes(x = Branch, y = Revenue, fill = Branch)) + geom_col() + labs(title = "Total Revenue by Branch", x = "Branch", y = "Revenue") + theme_minimal(), "unit2_branch_revenue.png")
save_plot(ggplot(sales_clean, aes(x = `Unit price`, y = Total)) + geom_point(color = "blue", alpha = 0.65) + labs(title = "Unit Price vs Total Spend", x = "Unit Price", y = "Total") + theme_minimal(), "unit2_unit_price_vs_total_scatter.png")

#visualization

inferential_rows <- list()
add_test <- function(id, ps, q, test, h0, h1, type, stat, df, p) {
  inferential_rows[[id]] <<- data.frame(
    Problem_statement = ps, Question = q, Test = test,
    Null_hypothesis = h0, Alternative = h1, Alpha = 0.05,
    Statistic_type = type, Statistic = stat, DF = df, P_value = p,
    stringsAsFactors = FALSE
  )
}

data_quality <- data.frame(
  Rows = nrow(Data), Columns = ncol(Data),
  Missing_Cells = sum(is.na(Data)), Duplicate_Rows = sum(duplicated(Data))
)
write.csv(data_quality, file.path(report_dir, "ps0_data_quality.csv"), row.names = FALSE)

#problem statement 1
#How do average customer Rating scores and gross income vary across different Product line categories?

#statistical analysis
ps1 <- sales_clean %>%
  group_by(`Product line`) %>%
  summarise(
    Transactions = n(),
    Mean_Rating = mean(Rating),
    SD_Rating = sd(Rating),
    Mean_Gross_Income = mean(`gross income`),
    Total_Gross_Income = sum(`gross income`),
    Total_Revenue = sum(Total),
    .groups = "drop"
  ) %>%
  arrange(desc(Mean_Rating))

View(ps1)
write.csv(ps1, file.path(report_dir, "ps1_product_line_performance.csv"), row.names = FALSE)

ps1_rating_aov <- summary(aov(Rating ~ `Product line`, data = sales_clean))
r1_f <- ps1_rating_aov[[1]][1, "F value"]
r1_df <- ps1_rating_aov[[1]][1, "Df"]
r1_p <- ps1_rating_aov[[1]][1, "Pr(>F)"]
add_test("ps1_rating", "PS1: product line ratings", "Do mean ratings differ?", "ANOVA", "H0: equal", "H1: differs", "F", r1_f, r1_df, r1_p)
capture.output(ps1_rating_aov, file = file.path(report_dir, "ps1_rating_anova.txt"))

ps1_gross_aov <- summary(aov(`gross income` ~ `Product line`, data = sales_clean))
g1_f <- ps1_gross_aov[[1]][1, "F value"]
g1_df <- ps1_gross_aov[[1]][1, "Df"]
g1_p <- ps1_gross_aov[[1]][1, "Pr(>F)"]
add_test("ps1_gross", "PS1: product line gross income", "Do mean gross incomes differ?", "ANOVA", "H0: equal", "H1: differs", "F", g1_f, g1_df, g1_p)
capture.output(ps1_gross_aov, file = file.path(report_dir, "ps1_gross_income_anova.txt"))

#visualization
ggplot(ps1, aes(x = reorder(`Product line`, Mean_Rating), y = Mean_Rating, fill = `Product line`)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = round(Mean_Rating, 2)), hjust = -0.2) +
  coord_flip() +
  labs(title = "Average Customer Rating by Product Line", x = "Product Line", y = "Average Rating") +
  theme_minimal()

#conclusion:
#The bar chart and grouped summary compare average satisfaction ratings and gross income across product categories.
#Food and beverages recorded the highest average satisfaction rating (7.11) and total gross income (2,673.56).
#However, one-way ANOVA indicates that differences in customer ratings (F = 0.54, p = 0.746) and gross income (F = 0.33, p = 0.890)
#across product lines are statistically non-significant, demonstrating consistent performance across supermarket departments.

#problem statement 2
#Is there a statistically significant difference in revenue and Customer type distribution among the three branches?

#statistical analysis
ps2_rev <- sales_clean %>%
  group_by(Branch, City) %>%
  summarise(
    Transactions = n(),
    Revenue = sum(Total),
    Mean_Total = mean(Total),
    Median_Total = median(Total),
    .groups = "drop"
  ) %>%
  arrange(desc(Revenue))

View(ps2_rev)
write.csv(ps2_rev, file.path(report_dir, "ps2_branch_revenue.csv"), row.names = FALSE)

ps2_counts <- as.data.frame(table(Branch = sales_clean$Branch, Customer_Type = sales_clean$`Customer type`))
names(ps2_counts)[3] <- "Transactions"
View(ps2_counts)
write.csv(ps2_counts, file.path(report_dir, "ps2_branch_customer_counts.csv"), row.names = FALSE)

ps2_aov <- summary(aov(Total ~ Branch, data = sales_clean))
b2_f <- ps2_aov[[1]][1, "F value"]
b2_df <- ps2_aov[[1]][1, "Df"]
b2_p <- ps2_aov[[1]][1, "Pr(>F)"]
add_test("ps2_anova", "PS2: branch revenue", "Do means differ by branch?", "ANOVA", "H0: equal", "H1: differs", "F", b2_f, b2_df, b2_p)
capture.output(ps2_aov, file = file.path(report_dir, "ps2_branch_anova.txt"))

ps2_chi <- chisq.test(table(sales_clean$Branch, sales_clean$`Customer type`))
capture.output(ps2_chi, file = file.path(report_dir, "ps2_branch_customer_chisquare.txt"))
add_test("ps2_chi", "PS2: branch customer mix", "Is mix independent of branch?", "Chi-square", "H0: same", "H1: differs", "X-squared", unname(ps2_chi$statistic), unname(ps2_chi$parameter), ps2_chi$p.value)

#visualization
ggplot(ps2_rev, aes(x = Branch, y = Revenue, fill = City)) +
  geom_col() +
  geom_text(aes(label = round(Revenue, 1)), vjust = -0.5) +
  labs(title = "Total Revenue by Branch and City", x = "Branch", y = "Total Revenue") +
  theme_minimal()

#conclusion:
#Branch C (Naypyitaw) generated the highest overall sales revenue (110,568.71), followed by Branch A (106,200.37) and Branch B (106,197.67).
#An ANOVA test revealed no statistically significant difference in mean transaction totals among branches (F = 0.89, p = 0.413).
#Furthermore, the chi-square test of independence (X-squared = 0.42, p = 0.811) indicates that Member vs Normal customer proportions
#remain virtually identical across all three geographic retail locations.

#problem statement 3
#Which payment methods are preferred across different Gender and Customer type segments?

#statistical analysis
ps3_gender <- as.data.frame(table(Payment = sales_clean$Payment, Gender = sales_clean$Gender))
names(ps3_gender)[3] <- "Transactions"
ps3_gender$Share_within_gender <- ave(ps3_gender$Transactions, ps3_gender$Gender, FUN = function(x) round(x / sum(x) * 100, 1))
View(ps3_gender)
write.csv(ps3_gender, file.path(report_dir, "ps3_payment_by_gender.csv"), row.names = FALSE)

ps3_cust <- as.data.frame(table(Payment = sales_clean$Payment, Customer_Type = sales_clean$`Customer type`))
names(ps3_cust)[3] <- "Transactions"
ps3_cust$Share_within_segment <- ave(ps3_cust$Transactions, ps3_cust$Customer_Type, FUN = function(x) round(x / sum(x) * 100, 1))
View(ps3_cust)
write.csv(ps3_cust, file.path(report_dir, "ps3_payment_by_customertype.csv"), row.names = FALSE)

ps3_chi_g <- chisq.test(table(sales_clean$Payment, sales_clean$Gender))
capture.output(ps3_chi_g, file = file.path(report_dir, "ps3_payment_gender_chisquare.txt"))
add_test("ps3_gender", "PS3: payment by gender", "Independent of gender?", "Chi-square", "H0: same", "H1: differs", "X-squared", unname(ps3_chi_g$statistic), unname(ps3_chi_g$parameter), ps3_chi_g$p.value)

ps3_chi_c <- chisq.test(table(sales_clean$Payment, sales_clean$`Customer type`))
capture.output(ps3_chi_c, file = file.path(report_dir, "ps3_payment_customertype_chisquare.txt"))
add_test("ps3_cust", "PS3: payment by customer type", "Independent of type?", "Chi-square", "H0: same", "H1: differs", "X-squared", unname(ps3_chi_c$statistic), unname(ps3_chi_c$parameter), ps3_chi_c$p.value)

#visualization
ps3_plot_data <- sales_clean %>%
  group_by(Payment, Gender, `Customer type`) %>%
  summarise(Transactions = n(), .groups = "drop")

ggplot(ps3_plot_data, aes(x = Payment, y = Transactions, fill = Gender)) +
  geom_col(position = "dodge") +
  facet_wrap(~`Customer type`) +
  labs(title = "Payment Methods by Gender and Customer Type Segment", x = "Payment Method", y = "Number of Transactions") +
  theme_minimal()

#conclusion:
#Females preferred Cash (35.5%) followed by Ewallet (32.9%), whereas Males utilized Ewallet most frequently (37.1%).
#Normal shoppers showed higher adoption of Ewallet (36.9%) compared to Credit Cards (31.1%).
#Both chi-square tests (Gender: p = 0.229; Customer Type: p = 0.074) show that customer demographics and payment channels
#do not exhibit significant dependence at alpha = 0.05, recommending multi-channel payment availability across all segments.

#problem statement 4
#What time of day and day of the week experience the highest customer volume and order totals?

#statistical analysis
sales_clean$Hour <- as.integer(substr(sales_clean$Time, 1, 2))
sales_clean$Part_of_day <- cut(
  sales_clean$Hour,
  breaks = c(9, 12, 16, 21),
  labels = c("Morning (10-12)", "Afternoon (13-16)", "Evening (17-20)"),
  include.lowest = TRUE
)
sales_clean$Weekday <- weekdays(sales_clean$Date)

ps4_hour <- sales_clean %>%
  group_by(Hour) %>%
  summarise(Transactions = n(), Revenue = sum(Total), Mean_Total = mean(Total), .groups = "drop") %>%
  arrange(desc(Transactions))
View(ps4_hour)
write.csv(ps4_hour, file.path(report_dir, "ps4_hourly.csv"), row.names = FALSE)

ps4_part <- sales_clean %>%
  group_by(Part_of_day) %>%
  summarise(Transactions = n(), Revenue = sum(Total), Mean_Total = mean(Total), .groups = "drop") %>%
  arrange(desc(Transactions))
View(ps4_part)
write.csv(ps4_part, file.path(report_dir, "ps4_part_of_day.csv"), row.names = FALSE)

ps4_day <- sales_clean %>%
  group_by(Weekday) %>%
  summarise(Transactions = n(), Revenue = sum(Total), Mean_Total = mean(Total), .groups = "drop") %>%
  arrange(desc(Transactions))
View(ps4_day)
write.csv(ps4_day, file.path(report_dir, "ps4_weekday.csv"), row.names = FALSE)

ps4_chi_h <- chisq.test(table(sales_clean$Hour))
capture.output(ps4_chi_h, file = file.path(report_dir, "ps4_hour_uniformity_chisquare.txt"))
add_test("ps4_hour", "PS4: hourly volume", "Uniform hours?", "Chi-square GOF", "H0: uniform", "H1: differs", "X-squared", unname(ps4_chi_h$statistic), unname(ps4_chi_h$parameter), ps4_chi_h$p.value)

ps4_chi_d <- chisq.test(table(sales_clean$Weekday))
capture.output(ps4_chi_d, file = file.path(report_dir, "ps4_weekday_uniformity_chisquare.txt"))
add_test("ps4_day", "PS4: weekday volume", "Uniform weekdays?", "Chi-square GOF", "H0: uniform", "H1: differs", "X-squared", unname(ps4_chi_d$statistic), unname(ps4_chi_d$parameter), ps4_chi_d$p.value)

#visualization
ggplot(ps4_hour, aes(x = factor(Hour), y = Transactions)) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = Transactions), vjust = -0.5) +
  labs(title = "Customer Footfall and Volume by Hour of Day", x = "Hour (24-Hour Clock)", y = "Number of Invoices") +
  theme_minimal()

#conclusion:
#Hourly volume peaks during evening hours at 19:00 (113 invoices) and 13:00 (104 invoices), reflecting post-work and lunch shopping spikes.
#Across days of the week, Saturday generated maximum store traffic (164 invoices, 56,120.81 total revenue).
#Chi-square goodness-of-fit testing reveals that transaction timing is distributed smoothly throughout business operating hours
#without extreme clustering bottlenecks (Hourly GOF: p = 0.401; Weekday GOF: p = 0.509).

#problem statement 5
#How does product Unit price relate to purchasing Quantity and gross income?

#statistical analysis
ps5_qty <- cor.test(sales_clean$`Unit price`, sales_clean$Quantity)
capture.output(ps5_qty, file = file.path(report_dir, "ps5_price_quantity_correlation.txt"))
add_test("ps5_qty", "PS5: price vs quantity", "Correlation zero?", "Pearson", "H0: r=0", "H1: r!=0", "r", unname(ps5_qty$estimate), ps5_qty$parameter, ps5_qty$p.value)

ps5_gross <- cor.test(sales_clean$`Unit price`, sales_clean$`gross income`)
capture.output(ps5_gross, file = file.path(report_dir, "ps5_price_grossincome_correlation.txt"))
add_test("ps5_gross", "PS5: price vs gross income", "Correlation zero?", "Pearson", "H0: r=0", "H1: r!=0", "r", unname(ps5_gross$estimate), ps5_gross$parameter, ps5_gross$p.value)

ps5_profit <- sales_clean %>%
  group_by(`Product line`) %>%
  summarise(
    Transactions = n(),
    Mean_Unit_Price = mean(`Unit price`),
    Mean_Quantity = mean(Quantity),
    Total_Gross_Income = sum(`gross income`),
    Total_Revenue = sum(Total),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Gross_Income))
View(ps5_profit)
write.csv(ps5_profit, file.path(report_dir, "ps5_profitability_by_product.csv"), row.names = FALSE)

#calculate correlation
print(cor(sales_clean$`Unit price`, sales_clean$Quantity))
print(cor(sales_clean$`Unit price`, sales_clean$`gross income`))

#visualization
ggplot(sales_clean, aes(x = `Unit price`, y = Quantity)) +
  geom_point(alpha = 0.4, color = "blue") +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Scatter Plot: Unit Price vs Quantity Purchased", x = "Unit Price", y = "Quantity Purchased") +
  theme_minimal()

#conclusion:
#The correlation between Unit price and Quantity purchased is approximately zero (r = 0.0108, p = 0.734), indicating price-inelastic demand.
#In contrast, Unit price is strongly and positively correlated with gross income (r = 0.634, p < 0.001) due to accounting multiplication.
#Retailers can bundle higher unit price items with complimentary products without fear of immediate quantity drops.

#regression model equation

#select required variables and remove missing values
Regression_Data <- sales_clean %>%
  select(cogs, `gross income`) %>%
  na.omit()

#check correlation
cor(Regression_Data$cogs, Regression_Data$`gross income`)

#regression model
Stock_Model <- lm(`gross income` ~ cogs, data = Regression_Data)

#display model summary
summary(Stock_Model)
capture.output(summary(Stock_Model), file = file.path(report_dir, "unit3_simple_regression_summary.txt"))

#extract regression coefficients
Coefficients <- coef(Stock_Model)
Intercept <- Coefficients[1]
Slope <- Coefficients[2]
print(Intercept)
print(Slope)

#display regression equation
cat("Regression Equation: gross income =", round(Intercept, 4), "+", round(Slope, 4), "* cogs\n")

simple_metrics <- data.frame(
  Intercept = unname(Intercept),
  Slope = unname(Slope),
  R_Squared = summary(Stock_Model)$r.squared,
  Observations = nobs(Stock_Model)
)
write.csv(simple_metrics, file.path(report_dir, "unit3_simple_regression_metrics.csv"), row.names = FALSE)

#visualization with regression equation
Stock_Plot <- ggplot(Regression_Data, aes(x = cogs, y = `gross income`)) +
  geom_point(alpha = 0.5, color = "blue") +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Regression Model: COGS vs Gross Income", x = "Cost of Goods Sold (COGS)", y = "Gross Income") +
  theme_minimal()
save_plot(Stock_Plot, "unit3_simple_regression.png")

resid_df <- data.frame(Fitted = fitted(Stock_Model), Residuals = residuals(Stock_Model))
save_plot(ggplot(resid_df, aes(x = Fitted, y = Residuals)) + geom_point(color = "darkorange") + geom_hline(yintercept = 0, linetype = "dashed", color = "red") + theme_minimal(), "unit3_residuals_vs_fitted.png")

pred_cogs <- data.frame(cogs = as.numeric(quantile(Regression_Data$cogs, probs = c(0.25, 0.5, 0.75))))
write.csv(cbind(pred_cogs, as.data.frame(predict(Stock_Model, newdata = pred_cogs, interval = "prediction"))), file.path(report_dir, "unit3_predictions.csv"), row.names = FALSE)

#multiple regression

# Step 1: Select variables and remove missing values
Mult_Reg_Data <- sales_clean %>%
  select(Total, `Unit price`, Quantity, Branch, Payment) %>%
  na.omit()

# Step 2: Build the multiple regression model
Multiple_Model <- lm(Total ~ `Unit price` + Quantity + Branch + Payment, data = Mult_Reg_Data)

# Step 3: Display regression model summary
mult_summary <- summary(Multiple_Model)
print(mult_summary)
capture.output(mult_summary, file = file.path(report_dir, "unit4_multiple_regression_summary.txt"))

# Step 4: Display regression coefficients
b <- coef(Multiple_Model)
print(b)

coef_df <- as.data.frame(mult_summary$coefficients)
coef_df$Term <- rownames(coef_df)
write.csv(coef_df, file.path(report_dir, "unit4_regression_coefficients.csv"), row.names = FALSE)

# Step 5: Display the regression equation
cat("Multiple Regression Equation:\nTotal = ", round(b[1], 4), " + ", round(b[2], 4), "*(Unit price) + ", round(b[3], 4), "*(Quantity)\n")

model_metrics <- data.frame(
  Observations = nobs(Multiple_Model),
  R_Squared = mult_summary$r.squared,
  Adjusted_R_Squared = mult_summary$adj.r.squared,
  Residual_Standard_Error = mult_summary$sigma
)
write.csv(model_metrics, file.path(report_dir, "unit4_model_metrics.csv"), row.names = FALSE)
write.csv(as.data.frame(confint(Multiple_Model)), file.path(report_dir, "unit4_coefficient_confidence_intervals.csv"))

numeric_cols <- names(sales_clean)[vapply(sales_clean, is.numeric, logical(1))]
cor_table <- cor(sales_clean[, numeric_cols])
write.csv(cor_table, file.path(report_dir, "unit4_numeric_correlation_matrix.csv"), row.names = TRUE)

observed_predicted_df <- data.frame(Observed_Total = Mult_Reg_Data$Total, Predicted_Total = fitted(Multiple_Model))
save_plot(ggplot(observed_predicted_df, aes(x = Observed_Total, y = Predicted_Total)) + geom_point(color = "steelblue", alpha = 0.65) + geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") + theme_minimal(), "unit4_observed_vs_predicted.png")

png(file.path(plots_dir, "unit4_diagnostic_panels.png"), width = 1200, height = 1000, res = 130)
par(mfrow = c(2, 2))
plot(Multiple_Model)
dev.off()

example_case <- data.frame(
  `Unit price` = median(Mult_Reg_Data$`Unit price`),
  Quantity = median(Mult_Reg_Data$Quantity),
  Branch = factor(names(which.max(table(Mult_Reg_Data$Branch))), levels = levels(Mult_Reg_Data$Branch)),
  Payment = factor(names(which.max(table(Mult_Reg_Data$Payment))), levels = levels(Mult_Reg_Data$Payment)),
  check.names = FALSE
)
write.csv(cbind(example_case, as.data.frame(predict(Multiple_Model, newdata = example_case, interval = "prediction"))), file.path(report_dir, "unit4_example_prediction.csv"), row.names = FALSE)

interaction_model <- lm(Total ~ `Unit price` * Quantity, data = Mult_Reg_Data)
model_comparison <- data.frame(
  Model = c("Additive", "With interaction"),
  R_Squared = c(mult_summary$r.squared, summary(interaction_model)$r.squared)
)
write.csv(model_comparison, file.path(report_dir, "unit4_model_form_comparison.csv"), row.names = FALSE)

all_tests <- bind_rows(inferential_rows)
all_tests$Significant_at_5pct <- all_tests$P_value < 0.05
write.csv(all_tests, file.path(report_dir, "ps_inferential_tests.csv"), row.names = FALSE)

save_report_figure <- function(p, fn, w = 8, h = 5) {
  ggsave(file.path(fig_dir, fn), p, width = w, height = h, dpi = 200)
}

save_grid_figure <- function(top, bottom, fn, w = 8, h = 6.4) {
  png(file.path(fig_dir, fn), width = w * 200, height = h * 200, res = 200)
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(2, 1)))
  print(top, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1))
  print(bottom, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1))
  dev.off()
}

fig1_a <- ggplot(ps1, aes(x = reorder(`Product line`, Mean_Rating), y = Mean_Rating, fill = `Product line`)) +
  geom_col(show.legend = FALSE) + coord_flip() + labs(title = "Figure 1a. Mean rating by product line") + theme_minimal()
fig1_b <- ggplot(ps1, aes(x = reorder(`Product line`, Total_Gross_Income), y = Total_Gross_Income, fill = `Product line`)) +
  geom_col(show.legend = FALSE) + coord_flip() + labs(title = "Figure 1b. Total gross income by product line") + theme_minimal()
save_grid_figure(fig1_a, fig1_b, "fig1_product_line_performance.png")

fig2_a <- ggplot(ps2_rev, aes(x = Branch, y = Revenue, fill = City)) +
  geom_col() + labs(title = "Figure 2a. Revenue by branch") + theme_minimal()
fig2_counts_df <- sales_clean %>% group_by(Branch, `Customer type`) %>% summarise(Transactions = n(), .groups = "drop")
fig2_b <- ggplot(fig2_counts_df, aes(x = Branch, y = Transactions, fill = `Customer type`)) +
  geom_bar(stat = "identity", position = "dodge") + theme_minimal()
save_grid_figure(fig2_a, fig2_b, "fig2_branch_comparison.png")

save_report_figure(
  ggplot(ps3_plot_data, aes(x = Payment, y = Transactions, fill = Gender)) +
    geom_col(position = "dodge") + facet_wrap(~`Customer type`) +
    labs(title = "Figure 3. Payment by gender and customer type") + theme_minimal(),
  "fig3_payment_demographics.png"
)

fig4_a <- ggplot(ps4_hour, aes(x = factor(Hour), y = Transactions)) +
  geom_col(fill = "steelblue") + theme_minimal()
fig4_b <- ggplot(ps4_day, aes(x = reorder(Weekday, Revenue), y = Revenue)) +
  geom_col(fill = "darkorange") + coord_flip() + theme_minimal()
save_grid_figure(fig4_a, fig4_b, "fig4_peak_hours_days.png")

save_report_figure(
  ggplot(sales_clean, aes(x = `Unit price`, y = Quantity, color = `Product line`)) +
    geom_point(alpha = 0.6) + geom_smooth(method = "lm", linetype = "dashed", color = "black", se = FALSE) +
    labs(title = "Figure 5. Unit price vs quantity") + theme_minimal(),
  "fig5_price_vs_quantity.png"
)

raw_csv <- read.csv(file.path(project_root, "data", "supermarket_sales.csv"), stringsAsFactors = FALSE, check.names = FALSE)

verification_list <- list(
  Rows = list(analysis = nrow(Data), raw = nrow(raw_csv)),
  Columns = list(analysis = ncol(Data), raw = ncol(raw_csv)),
  Total_revenue = list(analysis = sum(ps2_rev$Revenue), raw = sum(raw_csv$Total)),
  Mean_rating = list(analysis = mean(sales_clean$Rating), raw = mean(raw_csv$Rating)),
  Cor_price_qty = list(analysis = unname(ps5_qty$estimate), raw = cor(raw_csv$`Unit price`, raw_csv$Quantity)),
  Chisq_branch_cust = list(analysis = unname(ps2_chi$statistic), raw = unname(suppressWarnings(chisq.test(table(raw_csv$Branch, raw_csv$`Customer type`))$statistic))),
  Anova_rating_F = list(analysis = r1_f, raw = unname(summary(aov(Rating ~ `Product line`, data = raw_csv))[[1]][1, "F value"]))
)

verification <- do.call(rbind, lapply(names(verification_list), function(name) {
  data.frame(
    Quantity = name,
    Value_from_analysis_scripts = unname(verification_list[[name]]$analysis),
    Value_recomputed_from_raw_csv = unname(verification_list[[name]]$raw),
    Match = isTRUE(all.equal(unname(verification_list[[name]]$analysis), unname(verification_list[[name]]$raw))),
    stringsAsFactors = FALSE
  )
}))

accounting_identities <- data.frame(
  Identity = c("Total == 1.05 * cogs", "cogs == Qty * Price", "Tax == gross"),
  Holds = c(
    isTRUE(all.equal(raw_csv$Total, raw_csv$cogs * 1.05)),
    isTRUE(all.equal(raw_csv$cogs, raw_csv$Quantity * raw_csv$`Unit price`)),
    isTRUE(all.equal(raw_csv$`Tax 5%`, raw_csv$`gross income`))
  )
)

write.csv(verification, file.path(report_dir, "verification_results.csv"), row.names = FALSE)
write.csv(accounting_identities, file.path(report_dir, "accounting_relations_check.csv"), row.names = FALSE)

if (!all(verification$Match)) {
  stop("Verification failed: calculated metrics do not match raw data.")
}
