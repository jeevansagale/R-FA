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
