# UNIT 1: R basics, data types, vectors, data frames, CSV import/export
# Sources: "final Unit I command script.pdf" and introductory examples.

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
