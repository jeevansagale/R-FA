# ==============================================================
# Subject: Statistical Data Analysis using R
# Topic: Descriptive Analysis of Supermarket Sales Data
# Dataset: Supermarket Sales Dataset
# ==============================================================


cat("\n============================================================\n")
cat("R PROGRAMMING PROJECT: UNIT 1 TO UNIT 4\n")
cat("Dataset: Supermarket Sales\n")
cat("Execution order: Unit 1 -> Unit 2 -> Unit 3 -> Unit 4 -> Problem Statements (PS1-PS5)\n")
cat("============================================================\n")

main_arguments <- commandArgs(trailingOnly = FALSE)
main_file <- sub("^--file=", "", main_arguments[grepl("^--file=", main_arguments)])
if (length(main_file) == 0) {
  project_root <- getwd()
} else {
  project_root <- dirname(normalizePath(main_file, mustWork = FALSE))
}
if (!file.exists(file.path(project_root, "data", "supermarket_sales.csv")) &&
    file.exists(file.path(getwd(), "data", "supermarket_sales.csv"))) {
  project_root <- normalizePath(getwd())
}
cat("\nProject root:", project_root, "\n")

required_paths <- c(
  "data/supermarket_sales.csv",
  "functions/helper_functions.R",
  "requirements.R"
)
missing_paths <- required_paths[!file.exists(file.path(project_root, required_paths))]
if (length(missing_paths) > 0) {
  stop(paste0("Required project file(s) not found relative to: ", project_root, "\n", paste(missing_paths, collapse="\n")))
}

source(file.path(project_root, "requirements.R"), local = .GlobalEnv)
library(dplyr)
library(ggplot2)
if (requireNamespace("tidyr", quietly = TRUE)) library(tidyr)
if (requireNamespace("pastecs", quietly = TRUE)) library(pastecs)
if (requireNamespace("moments", quietly = TRUE)) library(moments)
if (requireNamespace("corrplot", quietly = TRUE)) library(corrplot)

output_dirs <- c("outputs/plots", "outputs/reports", "report/figures")
for (dir in output_dirs) {
  dir.create(file.path(project_root, dir), recursive = TRUE, showWarnings = FALSE)
}

source(file.path(project_root, "functions", "helper_functions.R"), local = .GlobalEnv)

candidate_dataset_paths <- c(
  file.path(project_root, "data", "supermarket_sales.csv"),
  "D:/PCCOE/sem3/R/units/project/supermarket_sales.csv",
  file.path(project_root, "supermarket_sales.csv"),
  file.path(dirname(project_root), "supermarket_sales.csv")
)
dataset_path <- candidate_dataset_paths[file.exists(candidate_dataset_paths)][1]
if (is.na(dataset_path)) {
  stop("No dataset found. Searched:\n  " , paste(candidate_dataset_paths, collapse="\n  "))
}
cat("\nLoading dataset:", dataset_path, "\n")
supermarket_data <- read.csv(dataset_path, stringsAsFactors = FALSE, check.names = FALSE)
if (nrow(supermarket_data) == 0 || ncol(supermarket_data) == 0) {
  stop("The CSV was loaded but contains no rows or columns.")
}
cat("Dataset loaded successfully:", nrow(supermarket_data), "rows and", ncol(supermarket_data), "columns.\n")


# -----------------------------------------------------------------------------
# Inlined from scripts/unit1.R
# -----------------------------------------------------------------------------
# ==============================================================
# Subject: Statistical Data Analysis using R
# Topic: Descriptive Analysis of Supermarket Sales Data
# Dataset: Supermarket Sales Dataset
# ==============================================================


# installation of packages

try(install.packages("tidyr"), silent = TRUE)
try(install.packages("dplyr"), silent = TRUE)
try(install.packages("ggplot2"), silent = TRUE)
try(install.packages("pastecs"), silent = TRUE)
try(install.packages("moments"), silent = TRUE)
try(install.packages("corrplot"), silent = TRUE)
try(install.packages("modeest"), silent = TRUE)


library(tidyr)
library(dplyr)
library(ggplot2)
if (requireNamespace("pastecs", quietly = TRUE)) library(pastecs)
if (requireNamespace("moments", quietly = TRUE)) library(moments)
if (requireNamespace("corrplot", quietly = TRUE)) library(corrplot)
if (requireNamespace("modeest", quietly = TRUE)) library(modeest)

cat("\n[UNIT 1] R basics and data inspection\n")

# 1. Arithmetic operators and elementary functions.
arithmetic_examples <- data.frame(
  Expression = c("2 + 3", "2 * 4", "2^3", "30 %% 7", "30 %/% 7",
                 "sin(pi / 6)", "log(10)", "log(10, base = 10)"),
  Result = c(2 + 3, 2 * 4, 2^3, 30 %% 7, 30 %/% 7,
             sin(pi / 6), log(10), log(10, base = 10))
)
print(arithmetic_examples)
write.csv(arithmetic_examples,
          file.path(project_root, "outputs/reports/unit1_arithmetic_examples.csv"),
          row.names = FALSE)

# 2. Vectors and vectorized calculations.
numeric_vector <- c(2, 3, 5, 7)
vector_examples <- list(
  original_vector = numeric_vector,
  squared = numeric_vector^2,
  scalar_multiplication = numeric_vector * 3,
  scalar_addition = numeric_vector + 6,
  integer_division = numeric_vector %/% 2,
  remainder = numeric_vector %% 2,
  sum = sum(numeric_vector),
  product = prod(numeric_vector),
  minimum = min(numeric_vector),
  maximum = max(numeric_vector),
  absolute_values = abs(c(-2, -3, -4)),
  square_roots = sqrt(c(2, 4, 9))
)
print(vector_examples)

# 3. Data types, classes, dimensions and structure using built-in data.
cat("\nBuilt-in mtcars structure:\n")
print(head(mtcars, 2))
print(tail(mtcars))
str(mtcars)
summary(mtcars)
cat("\nBuilt-in iris structure:\n")
str(iris)
print(summary(iris))
print(colnames(iris))
cat("typeof(iris$Sepal.Length):", typeof(iris$Sepal.Length), "\n")
cat("class(iris$Species):", class(iris$Species), "\n")
cat("typeof(iris$Species):", typeof(iris$Species), "\n")
print(attributes(iris$Species))

# 4. Data frame creation and CSV import/export, as demonstrated in course notes.
student_data <- data.frame(
  Roll_No = c(101, 102, 103),
  Name = c("Amit", "Priya", "Rahul"),
  Marks = c(85, 90, 78)
)
write.csv(student_data,
          file.path(project_root, "outputs/reports/student_data_example.csv"),
          row.names = FALSE)
student_imported <- read.csv(
  file.path(project_root, "outputs/reports/student_data_example.csv")
)
print(student_imported)

# ==============================================================
# Supermarket dataset - sample-style inspection (as in stock sample)
# ==============================================================

# write supermarket data for sample-style import (mirrors write.csv(all_companies_combined,"all_companies.csv"))
write.csv(supermarket_data, file.path(project_root, "outputs/reports/supermarket_sales_exported.csv"), row.names = FALSE)

#import dataset
Data = read.csv(file.path(project_root, "data/supermarket_sales.csv"), stringsAsFactors = FALSE, check.names = FALSE)

View(Data)

#Basic dataset information

dim(Data)
colnames(Data)
head(Data)
head(Data,10)
tail(Data,2)
nrow(Data)
ncol(Data)
str(Data)
summary(Data)

mean(Data$Total)
median(Data$Total,na.rm = TRUE)
sd(Data$Total, na.rm=TRUE)
var(Data$Total, na.rm=TRUE)

mean(Data$Rating) # not gives the result because na value present if any
mean(Data$Rating,na.rm=TRUE)


typeof(Data) #list
typeof(Data$Branch) #character
typeof(Data$Total) #double
typeof(Data$Rating) #double

#check missing values

anyNA(Data)
is.na(Data)
sum(is.na(Data))
colSums(is.na(Data))
rowSums(is.na(Data))

#missing value table

Missing = data.frame(
  Column = colnames(Data),
  Missing_Count = colSums(is.na(Data))
)

View(Missing)


#Remove rows having missing values

CleanData = na.omit(Data) #create clean dataset containing zero na values
View(CleanData)
dim(CleanData)


# 5. Inspect the provided supermarket dataset.
cat("\nProvided dataset: supermarket_sales.csv\n")
cat("Dimensions:\n")
print(dim(supermarket_data))
cat("\nFirst six rows:\n")
print(head(supermarket_data))
cat("\nLast six rows:\n")
print(tail(supermarket_data))
cat("\nStructure:\n")
str(supermarket_data)
cat("\nSummary:\n")
print(summary(supermarket_data))
cat("\nColumn names:\n")
print(names(supermarket_data))
cat("\nMissing values by column:\n")
print(colSums(is.na(supermarket_data)))

# 6. Basic numeric summaries with missing values handled explicitly.
numeric_names <- names(supermarket_data)[vapply(supermarket_data, is.numeric, logical(1))]
if (length(numeric_names) > 0) {
  unit1_numeric_summary <- data.frame(
    Variable = numeric_names,
    Mean = vapply(supermarket_data[numeric_names], mean, numeric(1), na.rm = TRUE),
    Median = vapply(supermarket_data[numeric_names], median, numeric(1), na.rm = TRUE),
    SD = vapply(supermarket_data[numeric_names], sd, numeric(1), na.rm = TRUE),
    Variance = vapply(supermarket_data[numeric_names], var, numeric(1), na.rm = TRUE),
    Minimum = vapply(supermarket_data[numeric_names], min, numeric(1), na.rm = TRUE),
    Maximum = vapply(supermarket_data[numeric_names], max, numeric(1), na.rm = TRUE)
  )
  print(unit1_numeric_summary)
  write.csv(unit1_numeric_summary,
            file.path(project_root, "outputs/reports/unit1_dataset_numeric_summary.csv"),
            row.names = FALSE)
}

cat("[UNIT 1] Completed.\n")


# -----------------------------------------------------------------------------
# Inlined from scripts/course_concept_demos.R
# -----------------------------------------------------------------------------
# COURSE CONCEPT DEMOS: tiny toy examples, separate from supermarket_data.
# Syllabus concepts (matrices, joins, tidyr, factors, missing values)
# that do not apply to the single-table sales CSV.
cat("\n[COURSE CONCEPT DEMOS] Separate teaching examples only\n")

# 1. Matrix creation, indexing, transpose and matrix multiplication (Unit I).
A <- matrix(1:6, nrow = 2, ncol = 3, byrow = TRUE)
B <- matrix(1:6, nrow = 3, ncol = 2, byrow = TRUE)
cat("Matrix A:\n"); print(A)
cat("A[1, 2] = "); print(A[1, 2])
cat("Transpose of A:\n"); print(t(A))
cat("Matrix product A %*% B:\n"); print(A %*% B)

# 2. Missing values and empty strings (Missing_value.pdf).
# A tiny artificial example is used because the supplied sales CSV has no NAs.
missing_demo <- data.frame(value = c(10, NA, 30), label = c("A", "", "C"))
cat("Missing values in the separate demo:\n")
print(colSums(is.na(missing_demo)))
missing_demo$label[trimws(missing_demo$label) == ""] <- NA_character_
print(missing_demo)
missing_demo_complete <- stats::na.omit(missing_demo)
cat("Complete rows in the separate demo:\n"); print(missing_demo_complete)

# 3. Join examples (data_join.pdf). These toy tables are not project records.
left_demo <- data.frame(id = c(1, 2, 3), left_value = c("L1", "L2", "L3"))
right_demo <- data.frame(id = c(2, 3, 4), right_value = c("R2", "R3", "R4"))
cat("left_join demo:\n"); print(dplyr::left_join(left_demo, right_demo, by = "id"))
cat("inner_join demo:\n"); print(dplyr::inner_join(left_demo, right_demo, by = "id"))
cat("full_join demo:\n"); print(dplyr::full_join(left_demo, right_demo, by = "id"))
cat("anti_join demo (left rows without a match):\n"); print(dplyr::anti_join(left_demo, right_demo, by = "id"))

# 4. tidyr long/wide transformation (wrangling using tidyr.pdf).
if (requireNamespace("tidyr", quietly = TRUE)) {
  wide_demo <- data.frame(Product = c("A", "B"), Q1 = c(10, 12), Q2 = c(15, 18))
  long_demo <- tidyr::pivot_longer(wide_demo, cols = c(Q1, Q2),
                                   names_to = "Quarter", values_to = "Sales")
  cat("Long-format demo:\n"); print(long_demo)
  wide_again <- tidyr::pivot_wider(long_demo, names_from = Quarter,
                                   values_from = Sales)
  cat("Wide-format demo:\n"); print(wide_again)
} else {
  cat("tidyr is not installed, so the wide/long reshaping demo is skipped.\n")
  cat("Install it with install.packages(\"tidyr\") to run this section.\n")
}

# 5. Factor conversion and type inspection (datatype_change.pdf).
type_demo <- data.frame(branch = c("A", "B", "A"), sales = c(20, 25, 22))
type_demo$branch <- as.factor(type_demo$branch)
str(type_demo)
cat("[COURSE CONCEPT DEMOS] Completed; demo data are separate from the supplied CSV.\n")


# -----------------------------------------------------------------------------
# Inlined from scripts/unit2.R
# -----------------------------------------------------------------------------
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

# ==============================================================
# Sample-style extra operations (as in stock sample) - supermarket version
# ==============================================================

Data = supermarket_data
View(Data)

#select options

S1 = select(Data, Branch, `Product line`, Total, Rating, Quantity)
View(S1)

S2 = select(Data, Branch, Total, cogs, `gross income`)
View(S2)


#Filters operations

F1 = filter(Data, Quantity >= 7) # getting rows which has Quantity greather than or equal to 7
View(F1)

F2 = filter(Data, Rating > 7)
View(F2)

F3 = filter(Data, Quantity >= 7, Rating > 7)
View(F3)


#Mutate operation

M1 = mutate(Data, Price_Range = `Unit price` * Quantity)
View(M1)


#Arrange operation

A1 = arrange(Data, Total) #ascending order
View(A1)

A2 = arrange(Data, desc(Total)) #descending order
View(A2)


#summaries operation

info_close = summarise(Data,avg=mean(Total),count=n())
View(info_close)

info = summarise(
  Data,
  Average_Unit_price = mean(`Unit price`, na.rm=TRUE),
  Average_Quantity = mean(Quantity, na.rm=TRUE),
  Average_Total = mean(Total, na.rm=TRUE),
  Average_Rating = mean(Rating, na.rm=TRUE),
  Average_GrossIncome = mean(`gross income`, na.rm=TRUE)
)
View(info)

#group_by operation

new = group_by(Data, `Product line`)
View(new)


#pipe operations

Data$Total%>%mean(na.rm=TRUE)
Data%>%summarise(mean(Total, na.rm=TRUE),n())
Data%>%group_by(Branch)%>%summarise(count=n(),avg=mean(Total,na.rm=TRUE))


#gather operation (using tidyr gather for sample look; pivot_longer if not available)

if (exists("gather")) {
  gat = gather(Data,"Sales_stage","value",7:10)
} else {
  gat = tidyr::pivot_longer(Data, cols=7:10, names_to="Sales_stage", values_to="value")
}
View(gat)


#spread operation

if (exists("spread")) {
  spre = spread(gat,Sales_stage,value)
} else {
  spre = tidyr::pivot_wider(gat, names_from=Sales_stage, values_from=value)
}
View(spre)


#unite

club = unite(Data,"value",`Unit price`,Total,sep="<-->")
View(club)


#separate

sep = separate(club,value,c("Unit price","Total"),sep="<-->")
View(sep)



#CENTRAL TENDENCIES

Mean <- mean(Data$Total, na.rm = TRUE)
Median <- median(Data$Total, na.rm = TRUE)
# Mode via modeest if available, else manual
if (requireNamespace("modeest", quietly = TRUE)) {
  Mode <- modeest::mfv(Data$Total, na_rm = TRUE)
} else {
  Mode <- as.numeric(names(sort(table(Data$Total), decreasing=TRUE)[1]))
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

Numeric_Data <- Data %>%
  select(where(is.numeric))


#COEFFICIENT OF VARIATION

CV <- SD / Mean * 100
print(CV)

# CV for every numerical column
CV_All <- sapply(Numeric_Data, function(x) {
  mean_x <- mean(x, na.rm = TRUE)
  sd_x <- sd(x, na.rm = TRUE)
  
  if (is.na(mean_x) || mean_x == 0 || is.na(sd_x)) {
    return(NA_real_)
  }
  
  sd_x / abs(mean_x) * 100
})

print(CV_All)


#DESCRIPTIVE STATISTICS

if (requireNamespace("pastecs", quietly = TRUE)) {
  print(pastecs::stat.desc(Numeric_Data))
}

# CORRELATION

# Correlation matrix using numerical columns
Correlation_Data <- cor(
  Numeric_Data,
  use = "pairwise.complete.obs"
)

print(Correlation_Data)


# 13. CORRELATION PLOTS

# Correlation colour plot
if (requireNamespace("corrplot", quietly = TRUE)) corrplot::corrplot(Correlation_Data)

# Correlation with numerical values
if (requireNamespace("corrplot", quietly = TRUE)) corrplot::corrplot(Correlation_Data, method = "number")

# Correlation with pie charts
if (requireNamespace("corrplot", quietly = TRUE)) corrplot::corrplot(Correlation_Data, method = "pie")

# Export the cleaned working dataset.
write.csv(sales_clean,
          file.path(project_root, "outputs/reports/supermarket_sales_cleaned.csv"),
          row.names = FALSE)
cat("[UNIT 2] Completed.\n")


# -----------------------------------------------------------------------------
# Inlined from scripts/unit3.R
# -----------------------------------------------------------------------------
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


# -----------------------------------------------------------------------------
# Inlined from scripts/unit4.R
# -----------------------------------------------------------------------------
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


# -----------------------------------------------------------------------------
# Inlined from scripts/problem_statements.R
# -----------------------------------------------------------------------------
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


# -----------------------------------------------------------------------------
# Inlined from scripts/report_figures.R
# -----------------------------------------------------------------------------
# REPORT FIGURES: fig1-fig5 embedded in the FA-II report.
# Built from the same tables as scripts/problem_statements.R, after that script runs.

cat("\n[REPORT FIGURES] Building report figures\n")

figures_dir <- file.path(project_root, "report", "figures")
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

save_report_figure <- function(plot_object, file_name, width = 8.0, height = 5.0) {
  output_file <- file.path(figures_dir, file_name)
  ggplot2::ggsave(filename = output_file, plot = plot_object,
                  width = width, height = height, dpi = 200)
  message("Saved figure: ", output_file)
  invisible(plot_object)
}

save_grid_figure <- function(top_plot, bottom_plot, file_name,
                             width_in = 8.0, height_in = 6.4) {
  output_file <- file.path(figures_dir, file_name)
  grDevices::png(output_file, width = width_in * 200, height = height_in * 200, res = 200)
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(2, 1)))
  print(top_plot, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1))
  print(bottom_plot, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1))
  grDevices::dev.off()
  message("Saved figure: ", output_file)
  invisible(output_file)
}

# Figure 1: mean rating and total gross income by product line.
fig1_top <- ggplot2::ggplot(ps1, ggplot2::aes(x = stats::reorder(`Product line`, Mean_Rating),
                                              y = Mean_Rating, fill = `Product line`)) +
  ggplot2::geom_col(color = "white", show.legend = FALSE) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Figure 1a. Mean customer rating by product line",
                x = "Product line", y = "Mean rating (0-10)") +
  ggplot2::theme_minimal()
fig1_bottom <- ggplot2::ggplot(ps1, ggplot2::aes(x = stats::reorder(`Product line`, Total_Gross_Income),
                                                 y = Total_Gross_Income, fill = `Product line`)) +
  ggplot2::geom_col(color = "white", show.legend = FALSE) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Figure 1b. Total gross income by product line",
                x = "Product line", y = "Total gross income") +
  ggplot2::theme_minimal()
save_grid_figure(fig1_top, fig1_bottom, "fig1_product_line_performance.png")

# Figure 2: branch revenue and customer-type mix by branch.
fig2_top <- ggplot2::ggplot(ps2_rev, ggplot2::aes(x = Branch, y = Revenue, fill = City)) +
  ggplot2::geom_col(color = "white") +
  ggplot2::geom_text(ggplot2::aes(label = round(Revenue, 0)), vjust = -0.4, size = 3) +
  ggplot2::labs(title = "Figure 2a. Total revenue by branch",
                subtitle = "C = Naypyitaw, A = Yangon, B = Mandalay",
                x = "Branch", y = "Total revenue", fill = "City") +
  ggplot2::theme_minimal() +
  ggplot2::expand_limits(y = max(ps2_rev$Revenue) * 1.12)
fig2_counts <- sales_clean %>%
  dplyr::group_by(Branch, `Customer type`) %>%
  dplyr::summarise(Transactions = dplyr::n(), .groups = "drop")
fig2_bottom <- ggplot2::ggplot(fig2_counts,
  ggplot2::aes(x = Branch, y = Transactions, fill = `Customer type`)) +
  ggplot2::geom_bar(stat = "identity", position = "dodge", color = "white") +
  ggplot2::labs(title = "Figure 2b. Member vs Normal transactions by branch",
                x = "Branch", y = "Transactions", fill = "Customer type") +
  ggplot2::theme_minimal()
save_grid_figure(fig2_top, fig2_bottom, "fig2_branch_comparison.png")

# Figure 3: payment preference by gender, faceted by customer type.
fig3_data <- sales_clean %>%
  dplyr::group_by(Payment, Gender, `Customer type`) %>%
  dplyr::summarise(Transactions = dplyr::n(), .groups = "drop")
fig3 <- ggplot2::ggplot(fig3_data,
  ggplot2::aes(x = Payment, y = Transactions, fill = Gender)) +
  ggplot2::geom_col(position = "dodge", color = "white") +
  ggplot2::facet_wrap(~`Customer type`) +
  ggplot2::labs(title = "Figure 3. Payment method by gender and customer type",
                x = "Payment method", y = "Transactions", fill = "Gender") +
  ggplot2::theme_minimal()
save_report_figure(fig3, "fig3_payment_demographics.png")

# Figure 4: hourly volume and weekday revenue.
fig4_top <- ggplot2::ggplot(ps4_hour, ggplot2::aes(x = factor(Hour), y = Transactions)) +
  ggplot2::geom_col(fill = "steelblue", color = "white") +
  ggplot2::geom_text(ggplot2::aes(label = Transactions), vjust = -0.4, size = 3) +
  ggplot2::labs(title = "Figure 4a. Transactions by hour of day",
                x = "Hour", y = "Transactions") +
  ggplot2::theme_minimal() +
  ggplot2::expand_limits(y = max(ps4_hour$Transactions) * 1.12)
fig4_bottom <- ggplot2::ggplot(ps4_day,
  ggplot2::aes(x = stats::reorder(Weekday, Revenue), y = Revenue)) +
  ggplot2::geom_col(fill = "darkorange", color = "white") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Figure 4b. Revenue by weekday",
                x = "Weekday", y = "Total revenue") +
  ggplot2::theme_minimal()
save_grid_figure(fig4_top, fig4_bottom, "fig4_peak_hours_days.png")

# Figure 5: unit price vs quantity, coloured by product line.
fig5 <- ggplot2::ggplot(sales_clean,
  ggplot2::aes(x = `Unit price`, y = Quantity, color = `Product line`)) +
  ggplot2::geom_point(alpha = 0.6, size = 1.4) +
  ggplot2::geom_smooth(method = "lm", formula = y ~ x, color = "black",
                       linetype = "dashed", se = FALSE) +
  ggplot2::labs(title = "Figure 5. Unit price versus quantity purchased",
                subtitle = paste0("Pearson r = ", round(unname(ps5_qty$estimate), 3),
                                  " (n = 1000): no linear link in this sample"),
                x = "Unit price", y = "Quantity", color = "Product line") +
  ggplot2::theme_minimal()
save_report_figure(fig5, "fig5_price_vs_quantity.png")

cat("\n[REPORT FIGURES] Completed.\n")


# -----------------------------------------------------------------------------
# Inlined from scripts/verify_results.R
# -----------------------------------------------------------------------------
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

cat("\n============================================================\n")
cat("PROJECT RUN FINISHED\n")
cat("Review tables in outputs/reports/ and plots in outputs/plots/.\n")
cat("Report figures in report/figures/; verification table in outputs/reports/verification_results.csv.\n")
cat("============================================================\n")