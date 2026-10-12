# Oral examination preparation

All answers below match the executed run (`Rscript main.R`, R 4.6.1); numbers are
taken from `outputs/reports/verification_results.csv` and `ps_inferential_tests.csv`.

1. **What is the project about?** Analysis of 1,000 supermarket invoices (17 columns)
   across 3 branches and 6 product lines: revenue by product line (PS1) and branch
   (PS2), Member vs Normal spending (PS3), payment methods (PS4), quantity vs total
   (PS5), ratings (PS6), and month/weekday revenue (PS7).
2. **Dataset size?** 1,000 observations, 17 variables — above the 500-row / 10-variable
   minimum. No missing values, no duplicate rows, 1,000 unique invoice IDs.
3. **Which variables?** Categorical: Branch, City, Customer type, Gender, Product
   line, Payment. Numeric: Unit price, Quantity, Tax 5%, Total, cogs, gross margin
   percentage, gross income, Rating. Plus Date/Time as text, parsed with `as.Date()`.
4. **`str()` vs `summary()`?** `str()` shows types and structure; `summary()` gives
   per-column descriptive summaries (used on the dataset in `unit1.R`).
5. **How is data imported?** `read.csv("data/supermarket_sales.csv", stringsAsFactors
   = FALSE)` in `main.R`; a working copy `sales_clean` is analysed so the source object is unchanged.
6. **What cleaning was needed?** Whitespace trim, `Date` parsing (`%m/%d/%Y`), factor
   conversion of six grouping columns; nothing was deleted (no NAs or duplicates found).
7. **`select/filter/mutate/arrange/group_by/summarise`?** `select` picks columns;
   `filter` picks rows; `mutate` creates columns (e.g. Average_Amount_Per_Item);
   `arrange` sorts; `group_by` + `summarise` aggregate per category (used in PS1–PS7).
8. **Mean vs median?** Mean 322.97 vs median 253.85 for `Total`: the mean is pulled up
   by large invoices, so the median better represents a "typical" invoice here.
9. **Spread measures?** SD of `Total` is 245.89; IQR is 346.93. SD is in the same units
   as the mean; IQR covers the middle 50%.
10. **Correlation?** Quantity–Total Pearson r = 0.706 (strong, p ≈ 2.1e-151, n = 1000);
    Unit price–Total r = 0.634; Rating–Total r = −0.036 (p = 0.250, not significant).
    Correlation is association, not causation.
11. **`lm()` and R²?** `lm()` fits a linear model. Unit III `gross income ~ cogs` gives
    R² = 1, slope 0.05 — because gross income is literally 5% of cogs in the data
    (accounting identity, confirmed by the "essentially perfect fit" warning).
12. **Multiple regression?** `Total ~ Unit price + Quantity + Branch + Payment` gives
    adjusted R² = 0.890; Branch/Payment coefficients are not significant. The additive
    form cannot equal the true multiplicative invoice formula, so adding the
    interaction `Unit price * Quantity` reproduces `Total` exactly (R² = 1).
13. **p-value meaning?** Under H0 (and the model assumptions), how unusual the observed
    statistic would be; not the probability H0 is true. α = 0.05 is used throughout.
14. **ANOVA results?** Branch: F = 0.885, p = 0.413. Product line: F = 0.338, p = 0.890.
    Payment: F = 0.081, p = 0.922. None significant — no evidence of mean differences,
    not proof of equality.
15. **t-test result?** Welch t for Member (327.79) vs Normal (318.12): t = 0.622,
    df = 997.8, p = 0.534 — not significant. The filtered boxplots (PS3 grid figure)
    show heavily overlapping distributions.
16. **Strongest practical pattern?** Quantity–Total association (r = 0.706), expected
    mechanically since total is computed from quantity and unit price.
17. **Time patterns?** January revenue 116,291.87 (352 invoices) > March 109,455.51 >
    February 97,219.37. Saturday has the highest weekday revenue (56,120.81). The
    window is only 3 months, so no seasonal claims are made.
18. **Limitations?** Three-month, three-branch observational sample; no inventory,
    cost, promotion or demographic data; dependent financial columns; constant gross
    margin column; Branch–City redundancy.
19. **How to run?** Open the `.Rproj`, run `main.R` (or `Rscript main.R` from the
    project root). Required packages `dplyr`/`ggplot2`, optional `tidyr`.
20. **How are numbers verified?** `scripts/verify_results.R` recomputes all 20 headline
    numbers from the raw CSV in base R and stops the run on any mismatch; every check
    passed.
21. **Who is on the team?** Aditya Kuwar (125B1B097), Jeevan Sagale (125B1B080),
    Vedant Hire (125B1B099) and Tanay Daware (125B1B098). Branch, date and
    signatures are completed at submission.

## Key functions
- `read.csv()`, `write.csv()`, `dim()`, `names()`, `str()`, `summary()`, `head()`, `tail()`
- `is.na()`, `colSums()`, `duplicated()`, `complete.cases()`, `as.Date()`, `as.factor()`, `trimws()`
- `mean()`, `median()`, `sd()`, `var()`, `quantile()`, `IQR()`
- `dplyr`: `select()`, `filter()`, `mutate()`, `arrange()`, `group_by()`, `summarise()`, `n()`, `%>%`
- `ggplot2`: `ggplot()`, `aes()`, `geom_col()` (precomputed), `geom_bar()` (counts),
  `geom_histogram()`, `geom_boxplot()`, `geom_point()`, `geom_smooth(method="lm")`, `labs()`, `coord_flip()`, `facet_wrap()`
- stats: `cor()`, `cor.test()`, `t.test()`, `aov()`, `lm()`, `summary()`, `predict()`, `confint()`
- `grid::viewport()` + `grid.layout()` for the two-panel PS3 boxplot figure.
