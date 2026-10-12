# Assessment and source-compliance checklist

## Instructor inputs
- Dataset `supermarket_sales.csv`: supplied.
- Course material `SDAUR.zip`: supplied.
- Instructor sample FA-II script: supplied (`reference_materials/sample project_FA2.R`; original kept at `../R/sample project_FA2.R`).
- Instructor sample report format: supplied (`Sample Report for FA2 Activity.docx`);
  the final report follows its structure and layout.
- Evaluation rubric / marks distribution: **not supplied** — nothing below claims
  rubric compliance.

## Checklist derived from the task instructions
- [x] Dataset has at least 500 observations (1 000 rows, verified by the run).
- [x] Dataset has at least 10 variables (17 columns; 6 categorical, 8 numeric,
      date/time, identifier), verified by the run.
- [x] Dataset preserved unchanged; no fabricated rows or columns.
- [x] At least five distinct problem statements (seven implemented, PS1–PS7).
- [x] R concepts from Units I–IV demonstrated in real code (see `UNIT_MAPPING.md`).
- [x] Relative paths, resolvable dataset location, single `main.R` entry point.
- [x] Graphs with titles, axes and written inferences; report embeds regenerated figures.
- [x] Summary tables and a consolidated inferential-results table exported.
- [x] `main.R` executed end-to-end (R 4.6.1): 20 headline numbers independently
      re-verified (`outputs/reports/verification_results.csv`); log kept with the run.
- [x] Final report in the sample format (`report/Supermarket_Sales_FA2_Report.docx/.pdf`).
- [x] Viva prep with actual findings and limitations (`oral_exam/`).
- [x] Team/institution details left as placeholders (not supplied).
- [ ] Rubric criterion-by-criterion match: **NOT TESTED** (rubric not supplied).

## Facts to state honestly in the viva
- `Total = 1.05 × Quantity × Unit price` for every row; `Tax 5%` equals `gross
  income`; `gross margin percentage` is constant (4.761905). These regressions are
  mechanical fits, not causal findings.
- Branch–City is one-to-one; including both in one model duplicates information.
- Dates span 1 January to 30 March 2019 only: month/weekday patterns are descriptive.
- No missing values or exact duplicate rows; `Total == cogs × 1.05` warns that
  Unit III's R² = 1 fit is the invoice formula, confirmed by the "essentially
  perfect fit" warning in the run log.
- All group-difference tests (branch, product line, payment, customer type) are
  not significant at α = 0.05 — this is not proof the groups are identical.
