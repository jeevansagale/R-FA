# Oral examination preparation

All answers below match the executed run (`Rscript main.R`, R 4.6.1); numbers are
taken from `outputs/reports/verification_results.csv` and `ps_inferential_tests.csv`.

1. **What is the project about?** Analysis of 1,000 supermarket invoices (17 columns):
   PS1 ratings and gross income by product line; PS2 branch revenue and customer mix;
   PS3 payment preference by gender and customer type; PS4 peak hours and weekdays;
   PS5 unit price vs quantity and gross income.
2. **Dataset size?** 1,000 observations, 17 variables — above the 500-row / 10-variable
   minimum. No missing values, no duplicate rows, 1,000 unique invoice IDs.
3. **Which variables?** Categorical: Branch, City, Customer type, Gender, Product
   line, Payment. Numeric: Unit price, Quantity, Tax 5%, Total, cogs, gross margin
   percentage, gross income, Rating. Date/Time as text (parsed; Hour, Weekday and
   part of day derived in PS4).
4. **`str()` vs `summary()`?** `str()` shows types and structure; `summary()` gives
   per-column descriptive summaries (used on the dataset in `unit1.R`).
5. **How is data imported?** `read.csv("data/supermarket_sales.csv", stringsAsFactors
   = FALSE)` in `main.R`; a working copy `sales_clean` is analysed so the source object is unchanged.
6. **What cleaning was needed?** Whitespace trim, `Date` parsing (`%m/%d/%Y`), factor
   conversion of six grouping columns, Hour extraction with format validation;
   nothing was deleted (no NAs or duplicates found).
7. **`select/filter/mutate/arrange/group_by/summarise`?** `select` picks columns;
   `filter` picks rows; `mutate` creates columns; `arrange` sorts; `group_by` +
   `summarise` aggregate per category (used in PS1–PS5). `table()` builds
   contingency tables for PS2/PS3.
8. **PS1 result?** Food and beverages has the highest mean rating (7.11) and total
   gross income (2,673.56); Home and lifestyle the lowest rating (6.84). Rating
   ANOVA: F = 0.540, p = 0.746 — not significant.
9. **PS2 result?** Branch C revenue 110,568.71 is highest; ANOVA F = 0.885, p = 0.413
   — not significant. Member/Normal mix is ~50/50 in all branches; chi-square
   X² = 0.419, p = 0.811 — independent.
10. **PS3 result?** Females prefer Cash (35.5%), males Ewallet (37.1%), Members split
    evenly (Credit card 34.3%), Normal prefer Ewallet (36.9%). Chi-squares:
    gender p = 0.229, customer type p = 0.074 — neither significant.
11. **PS4 result?** Busiest hour 19:00 (113 invoices); afternoons carry most traffic
    (365); Saturday strongest (164 invoices, 56,120.81), Monday weakest (125).
    Uniformity tests: hours p = 0.050, weekdays p = 0.244 — not rejected.
12. **PS5 result?** Unit price vs Quantity r = 0.011 (p = 0.734): no linear link, so
    no pricing elasticity is visible. Unit price vs gross income r = 0.634, but that
    is invoice arithmetic (gross income = 5% × Quantity × Unit price). Food and
    beverages generates the most total gross income (2,673.56).
13. **What is chi-square used for?** Independence tests (does payment choice depend on
    gender/customer type? does mix depend on branch?) and goodness-of-fit (is volume
    uniform across hours/weekdays?). Needs adequate expected counts — smallest here
    is ~75, so the approximation is safe.
14. **p-value meaning?** Under H0 (and the model assumptions), how unusual the observed
    statistic would be; not the probability H0 is true. α = 0.05 is used throughout.
15. **`lm()` and R²?** `lm()` fits a linear model. Unit III `gross income ~ cogs` gives
    R² = 1, slope 0.05 — because gross income is literally 5% of cogs in the data
    (confirmed by the "essentially perfect fit" warning).
16. **Multiple regression?** `Total ~ Unit price + Quantity + Branch + Payment` gives
    adjusted R² = 0.890; Branch/Payment coefficients are not significant. The additive
    form cannot equal the true multiplicative invoice formula, so adding the
    interaction `Unit price * Quantity` reproduces `Total` exactly (R² = 1).
17. **Limitations?** Three-month, three-branch, 10:00–20:00 observational sample; no
    inventory, cost, promotion or demographic data; dependent financial columns;
    constant gross margin column; Branch–City redundancy.
18. **How to run?** Open the `.Rproj`, run `main.R` (or `Rscript main.R` from the
    project root). Required packages `dplyr`/`ggplot2`, optional `tidyr`.
19. **How are numbers verified?** `scripts/verify_results.R` recomputes all 19 headline
    numbers from the raw CSV in base R and stops the run on any mismatch; every check
    passed.
20. **Who is on the team?** Aditya Kuwar (125B1B097), Jeevan Sagale (125B1B080),
    Vedant Hire (125B1B099) and Tanay Daware (125B1B098). Branch, date and
    signatures are completed at submission.

## Key functions
- `read.csv()`, `write.csv()`, `dim()`, `names()`, `str()`, `summary()`, `head()`, `tail()`
- `is.na()`, `colSums()`, `duplicated()`, `complete.cases()`, `as.Date()`, `as.factor()`, `trimws()`, `substr()`, `weekdays()`, `table()`, `chisq.test()`
- `mean()`, `median()`, `sd()`, `var()`, `quantile()`, `IQR()`, `cut()`
- `dplyr`: `select()`, `filter()`, `mutate()`, `arrange()`, `group_by()`, `summarise()`, `n()`, `%>%`
- `ggplot2`: `ggplot()`, `aes()`, `geom_col()` (precomputed), `geom_bar()` (counts, dodge/stack),
  `geom_histogram()`, `geom_boxplot()`, `geom_point()`, `geom_smooth(method="lm")`, `labs()`, `coord_flip()`, `facet_wrap()`
- stats: `cor()`, `cor.test()`, `t.test()`, `aov()`, `lm()`, `summary()`, `predict()`, `confint()`
- `grid::viewport()` + `grid.layout()` for the two-panel report figures.
