# Supermarket Sales Analysis — R Project

A reproducible RStudio project covering descriptive statistics, data cleaning, visualization, correlation, regression, and five supermarket-sales problem statements.

## Project Contents

- `R_Unit1_to_Unit4_Project.Rproj` — open this file in RStudio.
- `main.R` — primary analysis script for Units I–IV and PS1–PS5.
- `functions/helper_functions.R` — helper functions used by the project.
- `data/supermarket_sales.csv` — source dataset.
- `outputs/plots/` — exploratory and diagnostic plots.
- `outputs/reports/` — generated summaries, statistical test results, and verification output.
- `report/` — report documents and figures, where included in the repository.
- `oral_exam/` — viva preparation notes.
- `reference_materials/` — course reference materials.

## Analysis

1. **Product Line Performance & Satisfaction** — grouped summaries and one-way ANOVA for rating and gross income.
2. **Branch Sales Comparison** — branch-level revenue summaries and customer-type comparisons.
3. **Payment Method Demographics** — cross-tabulation and chi-square tests.
4. **Peak Shopping Hours & Days** — hourly and weekday summaries.
5. **Pricing Relationships** — correlation and regression exercises involving unit price, quantity, and gross income.

## Run the Project

### Requirements

- R 4.x
- RStudio (recommended)
- Required R packages used by `main.R`

### Steps

1. Clone the repository.
2. Open `R_Unit1_to_Unit4_Project.Rproj` in RStudio.
3. Run `main.R` from the project root, or use:

```bash
Rscript main.R
```

The script expects the dataset at `data/supermarket_sales.csv`. Keep the provided relative folder structure when running the project from a different machine.

Inspect the generated files under `outputs/plots/` and `outputs/reports/`.

## Interpretation Notes

- The dataset contains 1,000 transaction rows and 17 columns.
- Branch and city are one-to-one in the supplied dataset.
- The data covers January–March 2019.
- Several monetary columns are mathematically related by the dataset's construction. Correlation and regression results involving these fields should not be interpreted as causal findings.
- This is an analysis of the supplied sample, not a live supermarket data pipeline.

## Reproducibility

The repository includes generated outputs and verification artifacts. Re-run the analysis locally before relying on results, especially after modifying the script or source data.

## Team

The project was completed as a course activity by the contributors listed in the root repository README.

## License

No license file is included in this project directory. Refer to the repository root for licensing information; do not assume third-party course materials or datasets are covered by a source-code license.
