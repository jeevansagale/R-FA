# REPORT_PLAN.md — Final FA-II report from the instructor sample

## 1. Sample report identified
**Path:** `/home/Primo/Documents/programing/R/FA-2/Sample Report for FA2 Activity.docx`
(preserved unchanged; the final report is a new file, not an overwrite).

**Actual structure of the sample (inspected paragraph-by-paragraph):**
1. Cover page — trust name, college name, logo image, `Department of AS&H`,
   `Report of FA-2 activity`, Subject `Statistical Data Analysis using R`,
   Academic Year `2026-27`, Semester I, `Submitted by` table (Name/PRN/Branch/Sign),
   `Submitted to: Dr. Sujata Bhamre`, Date, Sign.
2. `Project Title: ...` (centered, 16 pt bold); `Data used: ...`; `Details of the
   data: Data contains N observations and V variables as follows`; numbered variable list.
3. `Flow:` + red 14 pt bold list: Problem Statement, Statistical Analysis,
   Data Visualization, Coding (Also add R code for every Problem Statement),
   Correlation, Regression Analysis., Conclusion:
4. Per problem statement: black 14 pt bold heading → description → result
   table → `Code:` + code lines → `Data Visualization:` + figure → `Conclusion:`.
   (The sample uses blue headings; the final report uses black at the team's request.)
5. Correlation and regression appear as Flow items (worked compactly).
6. No TOC, no headers/footers/page numbers, no bibliography in the sample.

**Formatting conventions (measured):** A4; margins top 1", right 0.29", bottom 1",
left 0.89"; Times New Roman; cover centered with 18/24/20 pt bold lines and the
PCCOE logo; body 14 pt justified; code in Consolas 11 on light shading (readability
deviation, documented); table centered with single borders, header bold, 12 pt;
figures centered inline at 6.3" width. Real Word styles are used for editability
with appearance matching the sample.

## 2. Reuse vs rewrite
- Reuse structurally: cover page layout, project-title page, `Flow:` list, the
  per-PS pattern (heading → description → table → Code → Data Visualization →
  Conclusion).
- Rewrite fully: every HR-specific word becomes the verified Supermarket Sales
  content for the five revised problem statements.
- The report covers PS1–PS5 (revised brief), a compact correlation/regression
  section with real output, a conclusion, limitations, and an execution appendix.
  No certificate/declaration pages are added because the sample has none.

## 3. Evidence map (section → verified source)
| Report section | Source |
|---|---|
| Cover page | Sample layout + PCCOE logo from the sample; team names/PRNs as supplied; branch/date/sign placeholders |
| Project title / data used / variable list | `outputs/reports/verification_results.csv` + dataset schema read in the run |
| Flow | Sample list, kept |
| PS1 table + figures + code + conclusion | `ps1_product_line_performance.csv`, `ps1_rating_anova.txt`, `ps1_gross_income_anova.txt`, `fig1_product_line_performance.png`, code from `scripts/problem_statements.R` |
| PS2 tables + figure + tests | `ps2_branch_revenue.csv`, `ps2_branch_customer_counts.csv`, `ps2_branch_anova.txt`, `ps2_branch_customer_chisquare.txt`, `fig2_branch_comparison.png` |
| PS3 tables + figure + tests | `ps3_payment_by_gender.csv`, `ps3_payment_by_customertype.csv`, both chi-square txts, `fig3_payment_demographics.png` |
| PS4 tables + figure + tests | `ps4_hourly.csv`, `ps4_part_of_day.csv`, `ps4_weekday.csv`, both uniformity txts, `fig4_peak_hours_days.png` |
| PS5 table + figure + tests | `ps5_profitability_by_product.csv`, both correlation txts, `ps5_gross_income_model.txt`, `fig5_price_vs_quantity.png` |
| Correlation & regression | `unit3_simple_regression_metrics.csv`, `unit4_model_metrics.csv`, `unit4_model_form_comparison.csv` |
| Conclusion & limitations | Verified numbers + accounting-identity checks |
| Appendix: how to run | `README.md` (run order, packages, paths) |

## 4. Genuinely unavailable information
Branch, submission date, signatures, separate evaluation rubric. All appear as marked
placeholders or documented gaps; no values invented. PDF conversion tooling
(LibreOffice/pandoc) is absent, so the PDF is rendered from the same content model
with ReportLab (isolated venv) at A4 with sample margins — recorded in
`REPORT_VALIDATION.md`, not presented as a Word export.
