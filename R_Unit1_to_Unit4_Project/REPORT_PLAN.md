# REPORT_PLAN.md — Final FA-II report from the instructor sample

## 1. Sample report identified
**Path:** `/home/Primo/Documents/programing/R/FA-2/Sample Report for FA2 Activity.docx`
(preserved unchanged; the final report is a new file, not an overwrite).

**Actual structure of the sample (inspected paragraph-by-paragraph):**
1. Cover page — trust name, college name, logo image, `Department of AS&H`,
   `Report of FA-2 activity`, Subject `Statistical Data Analysis using R`,
   Academic Year `2026-27`, Semester I, `Submitted by` table (Name/PRN/Branch/Sign,
   2 rows), `Submitted to: Dr. Sujata Bhamre`, Date, Sign.
2. `Project Title: ...` (centered, 16 pt bold); `Data used: ...`; `Details of the
   data: Data contains N observations and V variables as follows`; numbered variable list.
3. `Flow:` + red 14 pt bold list: Problem Statement, Statistical Analysis,
   Data Visualization, Coding (Also add R code for every Problem Statement),
   Correlation, Regression Analysis., Conclusion:
4. Per problem statement: blue 14 pt bold heading → 1-line description → result
   table → `Code:` + code lines → `Data Visualization:` + figure → `Conclusion:`.
5. Only PS1 is worked in the sample; PS2–PS5 are listed as headings; correlation and
   regression appear as Flow items (worked once, compactly).
6. No TOC, no headers/footers/page numbers, no bibliography in the sample.

**Formatting conventions (measured):** A4; margins top 1", right 0.29", bottom 1",
left 0.89"; Times New Roman; cover centered with 18/24/20 pt bold lines; body
14 pt justified; code 14 pt left; table centered, width 4880 dxa, header row bold;
figures centered inline at ~6.5" width. Heading styles are absent in the sample;
the final report uses real Word Heading styles for the section headings (still Times
New Roman, same sizes) so the document stays editable, with direct formatting kept
visually identical to the sample.

## 2. Reuse vs rewrite
- Reuse structurally: cover page layout, project-title page, `Flow:` list, the
  per-PS pattern (heading → description → table → Code → Data Visualization →
  Conclusion), uncovered-sign/date placeholders, red/blue heading colours.
- Rewrite fully: every HR-specific word (title, dataset, variables, tables, code,
  figure, conclusions) becomes the verified Supermarket Sales content.
- Add (report only gains what the project proves): all seven PS sections, a compact
  correlation + regression section with real output, a conclusion, limitations, and
  an appendix listing the project files and run instructions. No certificate/
  declaration pages are added because the sample does not contain them.

## 3. Evidence map (section → verified source)
| Report section | Source |
|---|---|
| Cover page | Sample layout; placeholders only (names/PRNs not supplied); subject/AY/semester/guide copied from the sample (same course) |
| Project title / data used / variable list | `outputs/reports/verification_results.csv` + dataset schema read in the run |
| Flow | Sample list, kept |
| PS1 table + figure + code + conclusion | `ps1_product_line_revenue.csv`, `fig1_revenue_by_product_line.png`, `ps1_product_line_anova.txt`, R code quote from `scripts/problem_statements.R` |
| PS2 … PS7 | Same pattern, per-PS CSVs/TXTs/figs (see `outputs/reports/ps*`, `report/figures/fig2…fig7.png`) |
| Correlation & regression | `ps5_quantity_total_correlation.txt`, `ps6_rating_total_correlation.txt`, `unit3_simple_regression_metrics.csv`, `unit4_model_metrics.csv`, `unit4_model_form_comparison.csv` |
| Conclusion & limitations | Verified numbers + accounting-identity checks |
| Appendix: how to run | `README.md` (run order, packages, paths) |

## 4. Genuinely unavailable information
Student names, PRN numbers, roll numbers, branch, signatures, submission date,
separate evaluation rubric. All appear as marked placeholders; no values invented.
PDF conversion tooling (LibreOffice/pandoc) is absent, so the PDF is rendered from
the same content model with ReportLab (isolated venv) at A4 with sample margins —
recorded in `REPORT_VALIDATION.md`, not presented as a Word export.
