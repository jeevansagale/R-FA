# R-FA — FA-II R Programming Project: Supermarket Sales Analysis

FA-II activity for **Statistical Data Analysis using R (SDAUR)** — a complete,
reproducible R project (Units I–IV) on 1,000 supermarket transactions, plus a
submission-ready report built from the instructor's sample-report format.

**Team**

| Name | PRN |
|---|---|
| Aditya Kuwar | 125B1B097 |
| Jeevan Sagale | 125B1B080 |
| Vedant Hire | 125B1B099 |
| Tanay Daware | 125B1B098 |

Submitted to: Dr. Sujata Bhamre · Dept. of AS&H, PCCOE · Academic Year 2026-27, Semester I

## What's in this repo

| Path | Contents |
|---|---|
| `R_Unit1_to_Unit4_Project/` | The project: R scripts, dataset, executed outputs, final report |
| `R_Unit1_to_Unit4_Project/report/Supermarket_Sales_FA2_Report.docx` / `.pdf` | Final submission report (editable + print-ready) |
| `R_Unit1_to_Unit4_Project/scripts/` | `unit1.R`–`unit4.R`, `problem_statements.R` (PS1–PS7), `data_analysis.R`, `report_figures.R`, `verify_results.R` |
| `R_Unit1_to_Unit4_Project/outputs/` | Regenerated tables (`reports/`) and plots (`plots/`) |
| `R_Unit1_to_Unit4_Project/data/supermarket_sales.csv` | Source dataset, preserved unchanged (1,000 rows × 17 columns) |
| `course_materials/` | Course PDFs, practice datasets and scripts |
| `SDAUR.zip` | Original course-material archive |
| `Sample Report for FA2 Activity.docx` | Instructor's sample report format (reference, unchanged) |
| `Supermarket_Sales_R_Project_Complete.zip` | Packaged snapshot of the finished project |
| `Junk/` | Superseded files (old report draft, previous ZIP, failed text extractions) |

## Dataset

`supermarket_sales.csv`: 1,000 invoices, 17 columns, 3 branches (A/Yangon, B/Mandalay,
C/Naypyitaw), 6 product lines, 1 Jan – 30 Mar 2019. No missing values, no duplicate
rows. Note: `Total = 1.05 × Quantity × Unit price`, `Tax 5%` = `gross income`, and
`gross margin percentage` is constant — regressions on these columns are honest
model-fitting exercises, not causal discoveries (documented in code and report).

## Key findings (all recomputed from the data by the scripts)

- Total revenue **322,966.75**; mean invoice **322.97**, median **253.85**
- Top product line: **Food and beverages (56,144.84)**; top branch: **C/Naypyitaw (110,568.71)**
- Member (327.79) vs Normal (318.12): Welch t-test **not significant** (p = 0.534)
- Quantity–Total correlation **r = 0.706** (p < 1e-150); Rating–Total **r = −0.036** (p = 0.250)
- Branch / product-line / payment-method ANOVAs: all **not significant** at α = 0.05

## How to run

1. Install R (4.x) and RStudio.
2. Open `R_Unit1_to_Unit4_Project/R_Unit1_to_Unit4_Project.Rproj`.
3. Run `main.R` (or `Rscript main.R` from the project root).
4. Packages `dplyr`/`ggplot2` are auto-installed; `tidyr` is optional. Tables land in
   `outputs/reports/`, plots in `outputs/plots/`, report figures in `report/figures/`.
5. `scripts/verify_results.R` independently recomputes every headline number from
   the raw CSV and stops on any mismatch — 20/20 matched in the submitted run.

Project docs: `PLAN.md` (audit + fix plan), `REPORT_PLAN.md`, `REPORT_VALIDATION.md`,
`PROGRESS.md`, `UNIT_MAPPING.md`, `ASSESSMENT_CHECKLIST.md`, viva prep in `oral_exam/`.

## Still to fill before submission

Branch, submission date, and signatures in the report.
