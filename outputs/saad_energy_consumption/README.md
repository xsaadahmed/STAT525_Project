# Saad energy analysis outputs

Regenerate from the project root with `Rscript R/01_energy_consumption.R`.
Base R only. All primary outputs use 3,142 counties. The baseline is not modified.

## Figures

- `01_distributions.png`: full-range histograms/boxplots for all three variables.
- `01b_gasoline_log_distribution.png`: full gasoline distribution on log scale.
- `02_relationships.png`: raw scatterplots with OLS/LOWESS; explicitly labeled
  exact observed-minimum/99th-percentile zoom limits preserve full-data fits.
  Counts are strict predictor exceedances of the displayed upper boundary.
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
  seeded pooled 10-fold original-response RMSE, maximum leverage and Cook's distance.
  Common random county folds compare explored candidate formulas; the winner's
  RMSE does not independently validate selection or new-region performance.
- `vif.csv`: model-specific variance inflation factors.
- `partial_r_squared.csv`: individual coefficient/term contribution given other
  terms. `partial_r_squared` divides the reduction in SSE by reduced-model SSE
  (variation unexplained by the other terms); `delta_r_squared` divides it by total
  centered response sum of squares (increase in ordinary R-squared). Both are
  dimensionless proportions; multiplying by 100 gives percent remaining variation
  and percentage points of total variation, respectively. Gas and its square are related; removing a linear term while retaining
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
- `gas_upturn_tail_by_state.csv`: counts strictly above the full-data quadratic
  minimum by state, and that minimum in Mcf/person. NE and IL dominate this tail.
- `geographic_sensitivity.csv`: full sample and exploratory joint NE/IL exclusion;
  n, gas coefficients, observed gas range, implied minimum, in-range flag and
  derivatives at both endpoints. `observed_rising_limb` requires a positive square
  coefficient and negative/positive endpoint derivatives. Changing range/composition
  does not identify a state effect; primary models still use all counties.
- `relationship_zoom_bounds.csv`: intended limits, actual production `par('usr')`
  horizontal bounds and strict counts above the upper limit; all fits use all rows.
- `execution_validation.txt`: in-script checks and R session information.

`R/validate_energy_analysis.R` independently refits all five model formulas,
checks exported inference/HC3 t-based inference and summaries, and validates all
existing sensitivity fits, independent seeded out-of-fold predictions, both R2
contribution denominators, geographic refits/derivatives and exact zoom bounds. `reports/saad_energy_consumption.Rmd` provides interpretation;
`docs/saad_energy_summary.md` provides the compact handoff.
