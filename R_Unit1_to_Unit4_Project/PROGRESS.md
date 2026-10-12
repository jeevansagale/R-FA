# PROGRESS.md — FA-II Supermarket Sales R project

## 2026-10-12 — full completion pass (single session)

### Phase 1 — inspection (no modifications)
- Mapped the tree: project root `R_Unit1_to_Unit4_Project/`; duplicate older copy at
  `~/Documents/programing/R/R_Unit1_to_Unit4_Project` left untouched.
- Read `main.R`, `requirements.R`, all six scripts, helpers, README, UNIT_MAPPING,
  ASSESSMENT_CHECKLIST, viva notes, `SDAUR.zip` listing, instructor sample script
  (`reference_materials/sample project_FA2.R`) and the instructor sample report
  (`Sample Report for FA2 Activity.docx`, parsed paragraph-by-paragraph).
- Verified the dataset with R: 1 000 × 17, 0 NAs, 0 duplicates, dates 2019-01-01 to
  2019-03-30, plus the accounting identities (`Total = 1.05 × Quantity × Unit price`,
  `Tax 5% = gross income`, constant margin, Branch–City 1:1).

### Phase 2 — PLAN.md written (defects P0/P1/P2, structure, test checklist).

### Phase 3/4 — implementation
- `requirements.R`: tidyr made optional with offline-tolerant install; clear errors.
- `main.R`: root derived from script location; dataset search order
  (project `data/` → `D:/PCCOE/...` → siblings); prints the file actually loaded.
- `scripts/unit2.R`: fixed `City` dropped by `select()` (halted the run).
- `scripts/problem_statements.R`: fixed literal `\n` bug; added printed tables and
  per-PS console output; added instructor-pattern filtered boxplots with
  `grid::viewport` (PS3); added robust ANOVA term-row matching; consolidated
  `ps_inferential_tests.csv`.
- `scripts/unit4.R`: fixed correlation CSV row names; added interaction-form check
  (additive R² 0.891 vs interaction R² 1.000) with honest interpretation.
- Added `scripts/report_figures.R` (fig1–fig7) and `scripts/verify_results.R`
  (base-R re-computation, stops on mismatch).
- Trimmed banner/verbose comments across scripts; kept statistical explanations
  and graph inferences.
- Installed `tidyr` 1.3.2 (+deps) from Posit binaries into the user R library.

### Phase 5 — validation
- Five full runs; final run from a foreign working directory: exit 0, 20/20
  headline numbers re-verified, 5/5 accounting identities hold. Log kept at
  `outputs/reports/run_log.txt`. Only warning is the genuine Unit III
  "essentially perfect fit" note (documented, not hidden).
- DOCX built by `report/build_report.py` from the verified CSVs; re-parsed OK
  (355 paragraphs, 9 tables, 7 figures, no HR leakage).
- PDF rendered from the DOCX by `report/build_pdf.py`; 12 pages A4, 7 images,
  all pages visually inspected, cover overlap fixed.
- `REPORT_PLAN.md`, `REPORT_VALIDATION.md` written; README/UNIT_MAPPING/
  ASSESSMENT_CHECKLIST/viva notes updated with executed evidence.

### Outstanding issues
- Rubric not supplied → rubric compliance BLOCKED (documented, not claimed).
- Windows fallback dataset path NOT TESTED on this Linux host.
- Report placeholders left: branch, submission date, signatures. Names/PRNs filled 2026-10-12;
  superseded files moved to `FA-2/Junk/` (old provisional report, previous ZIP, failed extracts).
