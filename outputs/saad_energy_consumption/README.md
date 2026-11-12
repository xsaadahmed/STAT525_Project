# Saad energy analysis outputs

Regenerate from the project root with `Rscript R/01_energy_consumption.R`.
Base R only. All primary outputs use 3,142 counties. The baseline is not modified.

## Figures

- `01_distributions.png`: full-range histograms/boxplots for all three variables.
- `01b_gasoline_log_distribution.png`: full gasoline distribution on log scale.
- `02_relationships.png`: raw scatterplots with OLS/LOWESS; explicitly labeled
  99th-percentile zoom panels preserve full-data fits.
- `03_transformed_relationships.png`: exploratory log1p-gas/log-gasoline plots.
  These are marginal exploratory fits, not the selected multiple model.
- `04_influence.png`: full-sample Cook's distance; FIPS label key cases.
- `05_preliminary_model.png`: partial-residual/conditional mean curves.
- `diagnostics_*.png`: four-panel diagnostics for each of five fitted models;
  labels are county FIPS. The quadratic model is preliminary, not assumption-free.

## Tables and audit

- `descriptive_statistics.csv`: n, missingness, zeros, mean, median, SD,
  range, quartiles, IQR and moment skewness, with variable names/units.
- `correlations.csv`: Pearson and Spearman correlations.
- `model_coefficients.csv`: full-precision OLS estimates, SE, t, p, 95% CI;
  HC3 SE/CI/p sensitivity. Underflowed numerical p=0 means extremely small,
  not literally zero; narrative/tables format these as p < 0.001.
- `model_comparison.csv`: n, R-squared, adjusted R-squared, residual SE,
  seeded 10-fold original-response RMSE, maximum leverage and Cook's distance.
- `vif.csv`: model-specific variance inflation factors.
- `partial_r_squared.csv`: individual coefficient/term contribution given other
  terms. Gas and its square are related; removing a linear term while retaining
  its square is a descriptive comparison, not a recommended hierarchical model.
- `diagnostic_summary.csv`: fitted-value BP-style n*R-squared check (1 df),
  residual summary and numbers flagged at leverage > 2p/n, Cook's D > 4/n,
  or absolute externally studentized residual > 3. p counts the intercept.
- `exploratory_extremes.csv`: all marginal 1.5-IQR flags, identified counties.
- `natural_gas_zeros.csv`: nine genuine zeros with county identifiers.
- `flagged_counties.csv`: model-specific leverage/influence/residual flags;
  includes actual values and population. Unflagged counties are omitted only
  from this audit table, never from primary modeling.
- `sensitivity_coefficients.csv`: all counties; without Loving; without the
  model's single highest-Cook case; without Cook-screen cases. Exclusions are
  labeled diagnostic scenarios, not a replacement cleaned dataset.
- `execution_validation.txt`: in-script checks and R session information.

`R/validate_energy_analysis.R` independently refits all five model formulas,
checks exported inference/HC3 SEs and summaries, and validates all sensitivity
fits. `reports/saad_energy_consumption.Rmd` provides interpretation;
`docs/saad_energy_summary.md` provides the compact handoff.
