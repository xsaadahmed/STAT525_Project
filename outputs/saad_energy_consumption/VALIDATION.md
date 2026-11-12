# Audit-correction validation record

Executed from the repository root on Windows with R 4.5.2. Fetched PR #1's head
and confirmed it was the audited `4d467d5a57b3259b13d8e52cb76d19700685fcec`;
there was no newer branch work to reconcile. Scope remains Saad's contribution.

## Executed checks

- `Rscript R/01_energy_consumption.R`: PASS. All five primary models retain
  3,142 counties and all nine recorded gas zeros. Existing influence/sensitivity
  fits and the simpler log-gasoline candidate remain available.
- `Rscript R/validate_energy_analysis.R`: PASS. Independently refits baseline
  formulas and verifies OLS inference, HC3 SEs/intervals/p-values using squared
  residuals divided by (1-h)^2 and residual-df t references, descriptive summaries,
  all 20 existing sensitivity fits, sample sizes and zero handling.
- Five primary R-squared values remain 0.1163492614, 0.0030101537, 0.1176899597,
  0.1363949014 and 0.1862684555. Raw adjusted gasoline OLS p=0.0290367815;
  HC3 p=0.1158529021. HC3 allows unequal variance under independent observations,
  not geographic dependence.
- Independently reconstructs seed-525 balanced folds and refits coefficients on
  training rows. Each county receives exactly one out-of-fold prediction per
  model. Pooled sqrt(sum(squared errors)/3142) is 1.1230250267, 1.1917891902,
  1.1223043325, 1.1102757225 and 1.0772109965 MWh/person in existing model order.
  Quadratic improvement over gas + log gasoline: 0.0330647259 MWh/person;
  over raw multiple: 0.0450933359. These are exploratory candidate comparisons,
  not independent validation of selection or new-region performance.
- Full-data quadratic minimum: 35.12670583 Mcf/person. Strictly above it: 60
  counties (NE 36, IL 13; remaining states/counts exported). Gas derivative at
  observed endpoints 0 and 75.71753530: -0.0999861479 and +0.1155394616.
- Joint NE/IL exclusion: n=2,947; gas coefficients -0.07519073954 and
  +0.0002136335675. Observed gas range 0-51.04531723 Mcf/person; minimum
  175.98062990 is outside it. Endpoint derivatives -0.07519073954 and
  -0.05338075310 are both negative: no observed rising limb. This exploratory
  change in range/composition does not identify a state effect or invalidate
  the full-sample fit.
- Independently verifies both term-contribution denominators from residual sums
  of squares. Raw gasoline delta R-squared=0.001340698273 (0.1340698273 percentage
  points of total response variation); partial R-squared=0.001517226450
  (0.1517226450% of variation unexplained by gas). Checks
  delta=(1-R-squared_reduced)*partial for all existing term comparisons.
- Production zoom `par('usr')` matches explicit minimum/99th-percentile limits
  using `xaxs='i'`. Independently reconstructs limits and draws test viewports:
  gas [0,47.3510482008], gasoline [46.6587643276,2448.9201558783]. Exactly 32
  strict exceedances for each upper bound; full-data OLS/LOWESS curves retained.

## Render and inspection

- Fresh R session: `rmarkdown::render('reports/saad_energy_consumption.Rmd')`
  succeeds using knitr/rmarkdown and RStudio-bundled Pandoc. No missing-resource
  or analysis warnings in the render. Seven numbered tables and four numbered,
  embedded figures checked in HTML; corrected narrative values, units, caption,
  CV qualification, geographic result and R2 denominators verified in rendered text.
- The Figure 2 PNG embedded in HTML is byte-identical to the regenerated output;
  that embedded image was extracted and visually inspected. Exact zoom limits,
  readable annotations and both full-data curves are present. Other PNGs and
  existing model/comparison outputs remain unchanged from the audited head.
- Browser policy blocked a file-protocol HTML preview. No browser-layout visual
  inspection is claimed; HTML structure/text and actual embedded Figure 2 were
  inspected directly. No duplicate HTML preview is committed.
- R startup emits the same four pre-existing C.UTF-8 locale warnings on Windows;
  numerical execution and knitting succeed. The Rmd hides routine warnings and
  messages in its display; standalone executions exposed startup warnings.
- Final diff/whitespace and scope checks cover only authorized Saad files.
  Protected data, baseline validator, preparation/merge scripts, teammate scripts
  and `progress_report.Rmd` remain unchanged against the PR base.

Accepted-data SHA-256 values (unchanged):

- RDS: `5cdd9f497fbe1e99515f89253276ad6b4585200b1ad8b823a29e50fd234bf8bc`
- CSV: `fabd36e7d9f94bc79e97036345f2b69f6bfd21abbe342b279475deeb5aa23908`

The quadratic remains a provisional full-sample description. Geographic
concentration, spatial dependence, selection optimism, confounding and remaining
residual departures limit inference. Group-report integration and Saad's review
remain; source attribution and AI-assistance disclosure are retained.
