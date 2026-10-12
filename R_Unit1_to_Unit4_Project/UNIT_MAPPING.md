# Unit I–IV mapping to the supermarket project

Based on the course files inside `SDAUR.zip` and the instructor's sample FA-II
script (`reference_materials/sample project_FA2.R`). Some supplied PDFs are image-only, so only
visible topics are mapped; no unseen content is claimed.

| Unit | Course topic (supplied material) | Project implementation |
|---|---|---|
| I | Arithmetic, vectors, scalar/vector ops, functions (`final Unit I command script.pdf`) | `scripts/unit1.R` (same expression patterns) |
| I | Types/mode/attributes, matrices and indexing, `det/solve/t/transpose`, data frames, binding | `scripts/unit1.R`, matrix demo in `scripts/course_concept_demos.R` |
| I | CSV import/export, `str()`, `summary()` | `scripts/unit1.R` (student demo + dataset profile) |
| II | Missing-value and duplicate checks (`Missing_value.pdf`) | `scripts/unit2.R` (dataset audit); toy demo in `course_concept_demos.R` |
| II | Data wrangling: `select/filter/mutate/arrange/group_by/summarise` (`dplyr.pdf`) | `scripts/unit2.R`, `scripts/problem_statements.R` (same patterns as the sample script) |
| II | Joins, tidyr reshaping, type conversion (`data_join.pdf`, `wrangling using tidyr.pdf`, `datatype_change.pdf`) | `scripts/course_concept_demos.R` (toy tables; single-table project needs no join) + `as.Date/as.factor` in `unit2.R` |
| II | Descriptive stats: mean, median, SD, variance, quartiles, IQR, CV, skewness, kurtosis (`Script_Desciptive ststistics.pdf`) | `scripts/unit2.R`, descriptive tables per PS |
| II | Bar/histogram/box/density/violin/pie/scatter plots (course plotting practicals) | `scripts/unit2.R`, PS figures (`geom_col` for precomputed values, `geom_bar` for counts) |
| III | Scatterplot, correlation, `lm()`, `summary()`, `predict()`, regression line (`Script Linear regression.pdf`, `Script_Scatter plot.pdf`) | `scripts/unit3.R`; PS5 correlation + model |
| IV | Numeric correlation matrix, multiple regression `lm(y ~ x1 + x2)`, coefficient tests, `confint()`, prediction (`Multiple Regression (1).R`) | `scripts/unit4.R`; PS5 model; interaction-form check |
| II/IV | Group comparisons: filtered boxplots with `grid::viewport` panels (sample script), `aov()`, `t.test()` | `scripts/problem_statements.R` (PS3 panel figure, PS1/PS2/PS4 ANOVA, PS3 t-test, PS5/PS6 `cor.test`) |

Instructor sample-script patterns reproduced on supermarket data: grouped
summaries (`PS1–PS7`), filtered boxplots in a `grid.layout` panel (PS3 Member vs
Normal), scatterplots (`PS5`), bar charts counted/filled by category (`PS4`),
per-statement code sections in the report, and grouped summary tables.
