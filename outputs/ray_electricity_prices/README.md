# Ray price analysis outputs and validation

Run from project root:

1. `Rscript R/03_electricity_prices.R`
2. `Rscript R/validate_ray_prices.R`

Base R only. The canonical RUCC file is committed; original raw input is needed
only to rerun its separate preparation script. No final shared merge is executed.

- `coefficients.csv`: six models, classical OLS estimates/SEs/95% intervals/p-values;
  CR1 eGRID-cluster SEs/95% intervals/p-values with t(G-1) reference.
- `model_comparison.csv`: sample size, response scale, fit, BP-style variance check,
  Cook screening and studentized residual counts. Do not rank raw and log models
  by their R-squared or residual SE across different response scales.
- `joint_log_omnibus.csv`: classical nested F tests; RUCC is an eight-df factor
  block. These are not cluster-robust omnibus tests.
- `rucc_summary.csv`: category counts and price summaries in USD/MWh.
- `missing_rucc.csv`: explicitly omitted from RUCC/joint fits only; no recoding.
- `associations.csv`: Pearson/Spearman price-emissions association; association
  of emissions with RUCC is an R-squared, not a correlation on numeric RUCC codes.
- `joint_log_flagged_counties.csv`: identified leverage/residual/Cook screen cases.
- `joint_log_sensitivity.csv`: full complete cases; omit largest Cook case;
  omit Cook > 4/n. Diagnostic alternatives, not replacement primary samples.
- Eight PNGs: distributions, relationships and four-panel diagnostics for six fits.
  Diagnostic labels use FIPS. Q-Q panels assess residuals, not predictors.
- `execution.txt`: sample decisions and R session information.

Executed validation: both R analysis and independent audit passed using R 4.5.2.
The audit independently refits six formulas and checks factor design dimensions,
OLS coefficients/SEs/intervals/p-values, R-squared, n, cluster inference via an
independent sum of cluster score outer products, and all three sensitivity fits.
The unchanged baseline validator passes. The preparation script was executed on
the supplied file; its full canonical projection was independently compared to
the upload. Eight figures pass nonblank/dimension checks; visual review covers
relationships, distributions and diagnostic panels. Existing C.UTF-8 startup
warnings occurred; no numerical warnings or analysis errors occurred.

Raw-upload SHA-256:
`87ce0c8ae960e79e4c147d1a1edeb942b626094c67e4e127738012aa38d9fe50`.
Baseline retained unchanged: 3,142 counties; RUCC/joint sample 3,140, with codes
02158 and 46102 unmatched. No shared cleaning or other teammate analysis changed.
Source values have not been independently redownloaded/authenticated.

Interpretation: `docs/ray_electricity_prices_summary.md`. Main caveats: weak fit,
residual departures, influential counties, regional dependence, only 26 cluster
groups, historical modeled expenditure estimates and potential confounding.
