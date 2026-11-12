# Final validation record

Executed on Windows with R 4.5.2, using the accepted baseline.

- `Rscript R/01_energy_consumption.R`: PASS; five models, all 3,142 counties,
  nine gas zeros retained, descriptive/inference/diagnostic/sensitivity outputs.
- `Rscript R/validate_energy_analysis.R`: PASS; independent refits verify five
  coefficient tables and OLS inference, HC3 SEs, summaries and 20 sensitivity fits.
- `rmarkdown::render('reports/saad_energy_consumption.Rmd')`: PASS with installed
  knitr/rmarkdown and RStudio-bundled Pandoc. Final render had no missing-resource
  warnings; four figures are embedded and seven tables are present. HTML preview
  is supplied separately to avoid committing a duplicate generated document.
- Eleven PNGs pass size/nonblank checks; figure review covered distributions,
  raw/transformed relationships, model diagnostics, influence and conditional fits.
- `git diff --check`: PASS before commit.
- The unchanged baseline validator passes RDS/CSV equivalence and its other checks.
- R startup reports pre-existing C.UTF-8 locale warnings on Windows. Execution,
  model checks and knitting succeeded; no numerical warning was suppressed in
  the standalone R execution. Rmd suppresses routine messages in its display.

Unchanged accepted-data SHA-256 values:

- RDS: `5cdd9f497fbe1e99515f89253276ad6b4585200b1ad8b823a29e50fd234bf8bc`
- CSV: `fabd36e7d9f94bc79e97036345f2b69f6bfd21abbe342b279475deeb5aa23908`

Shared data, preparation/merge/validation scripts, `progress_report.Rmd`,
`R/02_economic_factors.R` and `R/03_electricity_prices.R` were not modified.
Scope is Saad's contribution; group-report integration and final student review
remain. This is a preliminary descriptive model with documented assumption issues.
