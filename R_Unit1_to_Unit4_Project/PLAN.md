# PLAN.md — FA-II R Programming Project: Supermarket Sales (Units I–IV)

Project root: `R_Unit1_to_Unit4_Project/` (open `R_Unit1_to_Unit4_Project.Rproj` in RStudio)
Plan status: executed. Generated results live in `outputs/`, the final report is
`report/Supermarket_Sales_FA2_Report.docx` / `.pdf` (built from the instructor sample
`Sample Report for FA2 Activity.docx`, preserved unchanged in the workspace).

---

## 1. Current project state and identified defects

### 1.1 Files found and their purpose

| File | Purpose | State |
|---|---|---|
| `main.R` | Entry point; validates paths, sources `requirements.R`, loads data, runs all scripts in order | Runs, but dataset path resolution is minimal |
| `requirements.R` | Checks/installs `dplyr`, `ggplot2`, `tidyr` | Hard-fails if install is impossible (no offline path) |
| `functions/helper_functions.R` | `save_project_plot()`, `safe_numeric_summary()` | Working; uses global `project_root` |
| `scripts/unit1.R` | Unit I: arithmetic, vectors, matrices, data frames, CSV import/export, `str`/`summary`, dataset profile | Working |
| `scripts/course_concept_demos.R` | Toy (non-sales) demos: matrices, missing values, joins, `pivot_longer/wider`, factors | Working; depends on `tidyr` |
| `scripts/unit2.R` | Unit II: cleaning, dplyr pipeline, descriptive statistics, skewness/kurtosis, 7 plots, cleaned CSV | Working |
| `scripts/unit3.R` | Unit III: correlation, simple linear regression, prediction, residuals | Working |
| `scripts/unit4.R` | Unit IV: correlation matrix, multiple regression, diagnostics, prediction | Working (minor `row.names` issue) |
| ~~`scripts/data_analysis.R`~~ | Integrated summaries (old brief) | **Removed** — old-PS script deleted, useful guards folded into `problem_statements.R` (PS0) |
| `scripts/problem_statements.R` | Five problem statements (PS1–PS5, revised brief) | Rewritten; old seven-PS version removed |
| `data/supermarket_sales.csv` | Supplied dataset (1 000 × 17) | Untouched; verified below |
| `outputs/reports/*.csv`, `outputs/plots/*.png` | Mixed set of tables/plots | **Stale — not reproducible from current code** |
| `report/final_project_report.docx/.pdf` | Earlier provisional report (generic structure) | Kept for reference; superseded by the sample-format report |
| `README.md`, `UNIT_MAPPING.md`, `ASSESSMENT_CHECKLIST.md`, `oral_exam/viva_questions_and_functions.md` | Documentation | Content correct but claims "R runtime unavailable" — now false |
| `reference_materials/original_SDAUR/*` | Instructor course material (from `SDAUR.zip`) | Authoritative for Unit I–IV content |
| **Newly supplied (instructor)** | `Sample Report for FA2 Activity.docx` (report format), `reference_materials/sample project_FA2.R` (instructor sample FA-II script; original kept outside the project) | Now available — the report must follow this format |

### 1.2 Dataset verification (computed, not copied)

`data/supermarket_sales.csv`: **1 000 rows × 17 columns**, 0 missing cells, 0 exact
duplicate rows, 1 000 unique `Invoice ID`s, dates 2019-01-01 to 2019-03-30 (3 months).
Categorical: `Branch` (A 340 / B 332 / C 328), `City`, `Customer type` (Member 501 / Normal 499),
`Gender` (Female 501 / Male 499), `Product line` (6 levels), `Payment` (Cash 344 / Credit card 311 / Ewallet 345).
Numeric: `Unit price`, `Quantity`, `Tax 5%`, `Total`, `cogs`, `gross margin percentage`, `gross income`, `Rating`.

Accounting relations detected in the real data (critical for honest reporting):

* `Total == cogs * 1.05` for **all** rows (max abs deviation < 1e-13), `cogs == Quantity * Unit price` for all rows, and `Tax 5% == gross income == 0.05 * cogs` for all rows (all verified `TRUE`).
* Consequently `cogs`, `Tax 5%`, `gross income`, `Unit price`, `Quantity` and `Total` are algebraically dependent (`Total = 1.05 × Quantity × Unit price`); `gross margin percentage` is constant (4.761905, single distinct value).
* `Branch` and `City` are one-to-one (A–Yangon, B–Mandalay, C–Naypyitaw).

Therefore Unit III/IV regressions involving these columns are **mechanical demonstrations of model fitting**, not discoveries.

### 1.3 Defects (prioritised)

**P0 — critical**

1. `library(tidyr)` in `main.R` fails where `tidyr` is absent; `requirements.R` aborts if the CRAN install cannot run (no documented offline alternative).
2. Dataset path is a single hard-coded project-relative string; no documented fallback to the known Windows location `D:/PCCOE/sem3/R/units/project/supermarket_sales.csv`, no report of which file was loaded, no clear error listing the searched locations.
3. `outputs/` is stale: the CSVs present (e.g. `dataset_profile.csv`, `unit_mapping.csv`, `inferential_tests.csv`, `descriptive_statistics.csv`, `product_line_summary.csv`) are **not** produced by the current scripts, and the PS/unit outputs the scripts do produce are missing. `outputs/plots/ps8_total_by_product_boxplot.png` refers to a "PS8" that does not exist in the code.

**P1 — required**

4. `scripts/problem_statements.R:5` uses `cat("\\n[PROBLEM STATEMENTS]…")`, printing a literal `\n` instead of a line break.
5. No single consolidated inferential-results table (test, statistic, df, p-value, hypotheses, conclusion) — required for the report and viva.
6. Problem statements print raw `capture.output()` to file only; nothing prints results/inferences to the console, so a viva run of `main.R` shows no analysis text.
7. The instructor's sample FA-II script patterns are only partly reproduced: a filtered-boxplot pair drawn with `grid::viewport` (its central demonstration) is missing from the supermarket analysis.
8. No `PLAN.md`, no `PROGRESS.md`; README/checklist/viva notes still state that R was not executed and repeat unverified numbers.

**P2 — quality**

9. `scripts/unit4.R` writes the correlation matrix without `row.names = FALSE`.
10. Mixed output naming (`unit2_descriptive_statistics.csv` vs stale `descriptive_statistics.csv`).
11. No verification script that re-checks numbers independently of the analysis scripts.

### 1.4 Missing instructor materials

* Report format: **now supplied** → `Sample Report for FA2 Activity.docx` (used as the authoritative template).
* Evaluation rubric / marks distribution: **not supplied** (searched `.pdf`, `.docx`, `.doc`, `.odt`, `.pptx` in the workspace and inside `SDAUR.zip`).
* Unit I–IV syllabus PDFs: supplied inside `SDAUR.zip`; several are image-only (`data_join`, `Missing_value`, `datatype_change`, `wrangling using tidyr`, `SDAUR Unit II`) so only filenames/visible topics are mapped, never invented content.

---

## 2. Required final project structure

```
R_Unit1_to_Unit4_Project/
├── main.R                       # entry point (fixed)
├── requirements.R               # package check (fixed, offline-tolerant)
├── PLAN.md
├── PROGRESS.md
├── README.md                    # updated with verified run evidence
├── UNIT_MAPPING.md              # updated: sample-script pattern mapping
├── ASSESSMENT_CHECKLIST.md     # updated: PASS/FAIL/NOT TESTED
├── R_Unit1_to_Unit4_Project.Rproj
├── data/supermarket_sales.csv   # untouched source
├── functions/helper_functions.R
├── scripts/unit1.R, course_concept_demos.R, unit2.R, unit3.R, unit4.R,
│          problem_statements.R (PS1–PS5, revised brief), verify_results.R
├── outputs/reports/…            # regenerated from the current code only
├── outputs/plots/…              # regenerated; each figure used in the report
├── report/Supermarket_Sales_FA2_Report.docx / .pdf   # final report (sample format)
│   └── final_project_report.docx/.pdf               # earlier provisional report (kept)
├── oral_exam/viva_questions_and_functions.md
└── reference_materials/original_SDAUR/ + extracted_text/
```

The original `report/final_project_report.docx/.pdf` are **retained** (they document the earlier
provisional format); the final submission report is the new sample-format file.

---

## 3. Changes grouped by priority

* **P0-1** `requirements.R`: check `dplyr`, `ggplot2`, `tidyr`; attempt install once; if installation is impossible, continue when the package is not required (`tidyr` is only used by the toy demo) and print a clear warning. `main.R` no longer aborts the whole project when a non-essential package is missing.
* **P0-2** `main.R`: `resolve_dataset_path()` — searches, in order, (a) `data/supermarket_sales.csv`, (b) the documented Windows location `D:/PCCOE/sem3/R/units/project/supermarket_sales.csv` if it exists, (c) the script's own directory as a fallback root; prints the file actually loaded; `stop()` with the full list of searched paths when nothing is found. Project root is derived from the script location, not `getwd()`, so the entry point works from any working directory.
* **P0-3** Delete only the stale, unreproducible outputs (they are derived artefacts) and regenerate the complete set from the current scripts.
* **P1-4** Fix `cat()` newline; add printed result tables and one-line inferences for each PS.
* **P1-5** Add `scripts/verify_results.R`: recomputes the report's key numbers (totals, means, correlations, test statistics, p-values, R², accounting identities) from the raw CSV in a fresh session and writes `outputs/reports/verification_results.csv`, so the report numbers are traceable and independently re-computed.
* **P1-6** Extend `scripts/problem_statements.R` PS3 with the instructor's filtered-boxplot + `grid::viewport` pattern (Member vs Normal invoice totals in a 2-row figure).
* **P1-7** ~~seven report figures (`fig1…fig7.png`)~~ — superseded by the revised brief: `report_figures.R` now produces `fig1…fig5.png` for PS1–PS5.
* **P1-8** Update README, `UNIT_MAPPING.md`, `ASSESSMENT_CHECKLIST.md`, viva notes with the executed run evidence (log in `outputs/reports/run_log.txt`).

---

## 4. Problem statement → data, R operations, statistics, graphs, inference

| # | Question | Variables | R operations | Statistics | Graph | Inference (computed in the run) |
|---|---|---|---|---|---|---|
| PS1 | Product Line Performance & Satisfaction: how do mean Rating and gross income vary by Product line? | `Product line`, `Rating`, `gross income` | `group_by()`, `summarise()`, `aov()` | group means/SDs, two one-way ANOVAs | `fig1_product_line_performance.png` (grid: rating + gross income) | Food & beverages top rating (7.11) and gross income (2,673.56); both ANOVAs ns (p = 0.746 / 0.890) |
| PS2 | Geographical & Branch Comparison: revenue and customer-type mix across Branch/City? | `Branch`, `City`, `Total`, `Customer type` | `group_by()`, `table()`, `aov()`, `chisq.test()` | revenue/means, ANOVA, chi-square independence | `fig2_branch_comparison.png` (grid: revenue + dodge mix) | C leads revenue (110,568.71); ANOVA ns (p = 0.413); mix independent (p = 0.811) |
| PS3 | Payment Method Demographics: preferences across Gender × Customer type? | `Payment`, `Gender`, `Customer type` | `table()`, shares, `chisq.test()` ×2 | cross-tabs, segment %, independence tests | `fig3_payment_demographics.png` (faceted dodge) | Cash leads females (35.5%), Ewallet males (37.1%); both ns (p = 0.229 / 0.074) |
| PS4 | Peak Shopping Hours & Days: volume and totals by Time and weekday? | `Time`→Hour, `Date`→Weekday, `Total` | `substr()`, `weekdays()`, `group_by()`, `chisq.test()` GOF ×2 | hourly/part/day summaries, uniformity tests | `fig4_peak_hours_days.png` (grid: hours + weekdays) | 19:00 (113) and Saturday (164) peak; uniformity ns (p = 0.050 / 0.244) |
| PS5 | Profitability & Pricing Elasticity: Unit price vs Quantity and gross income? | `Unit price`, `Quantity`, `gross income`, `Product line` | `cor.test()` ×2, `lm()`, `group_by()` | Pearson r, regression exercise | `fig5_price_vs_quantity.png` (scatter by line) | price–qty r = 0.011 ns (no elasticity); price–gross r = 0.634 (arithmetic) |

Course-unit coverage (mapped to code): Unit I → `scripts/unit1.R`; Unit II → `scripts/unit2.R`,
`scripts/problem_statements.R`; Unit III → `scripts/unit3.R`; Unit IV → `scripts/unit4.R`
+ the instructor-sample analytical patterns reproduced in `scripts/problem_statements.R`.

---

## 5. Testing and validation checklist

1. `Rscript main.R` (and `Rscript main.R` from a different working directory) completes with no error.
2. Console log reports the resolved dataset path, 1 000 × 17, 0 missing, 0 duplicates.
3. Every file in `outputs/reports/` and `outputs/plots/` was written by the current run (checked with `ls -l` timestamps and the generated manifest `project_file_manifest.csv`).
4. `outputs/reports/verification_results.csv` matches the analysis outputs for every reported number.
5. Each report figure exists, is non-empty, and is referenced by the report.
6. Report numbers cross-checked against `verification_results.csv` (spot-check of every statistic quoted in the report).
7. Report structure compared section-by-section with `Sample Report for FA2 Activity.docx`.
8. DOCX re-opened and re-parsed (paragraph/table/image inventory) after generation; PDF re-parsed (page count, page size, text/image extraction).
9. Project contains ≥ 5 implemented problem statements (7) and Unit I–IV coverage in real code.
10. ZIP contains the final tree with no caches, thumbnails, or machine-specific clutter.

## 6. Report and deliverable generation steps

1. Run `Rscript scripts/report_figures.R` → `report/figures/fig1…fig5.png`.
2. Build `report/Supermarket_Sales_FA2_Report.docx` from the sample template's structure
   (cover page → project title/data/variable details → red "Flow" list → per-PS sections with
   table, R code, figure, conclusion → correlation/regression analysis → conclusion),
   Times New Roman, A4, sample margins (top 1", right 0.29", bottom 1", left 0.89").
3. Export `report/Supermarket_Sales_FA2_Report.pdf` from the same content model at A4/print quality.
4. Write `REPORT_PLAN.md`, `REPORT_VALIDATION.md`, `PROGRESS.md`.
5. Re-run the whole pipeline once, then archive `Supermarket_Sales_R_Project_Complete.zip`
   (project only, excluding caches/temp files).

## 7. Constraints, assumptions, unresolved questions

* Rubric/marks scheme not supplied → checklist derived from the task instructions; compliance with an unseen rubric is explicitly **not** claimed.
* PDF export tooling: no LibreOffice/pandoc/LaTeX in this environment; the PDF is produced by a dedicated renderer (ReportLab in an isolated virtual environment) from the same content model as the DOCX, matching the sample's page size, margins and typography. Stated in the report's validation notes.
* Team names and PRNs supplied (Aditya Kuwar 125B1B097, Jeevan Sagale 125B1B080, Vedant Hire
  125B1B099, Tanay Daware 125B1B098) and filled into the report; branch, date and signatures
  remain as marked placeholders.
* Dataset is observational, 3 months, 3 branches: all inferences are associative, never causal.
