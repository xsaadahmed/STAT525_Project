# Saad: energy consumption contribution

## Scope and data

RQ1: residential natural gas versus residential electricity per capita.
RQ2: jurisdictional on-road gasoline versus residential electricity per capita.

All 3,142 accepted counties are retained. Response: `res_elec_mwh_pc`
(MWh/person). Predictors: `res_gas_mcf_pc` (Mcf/person; thousand cubic feet)
and `gasoline_gal_pc` (gallons/person). Nine genuine gas zeros remain; no
missing analysis values. No source data or teammate/shared report files changed.
Gasoline is jurisdictional travel per resident, not household gasoline usage.

## Models and findings

| Model | R-squared | Adjusted R-squared | Residual SE | 10-fold RMSE |
| --- | ---: | ---: | ---: | ---: |
| Electricity ~ gas | 0.11635 | 0.11607 | 1.12152 | 1.12303 |
| Electricity ~ gasoline | 0.00301 | 0.00269 | 1.19127 | 1.19179 |
| Electricity ~ gas + gasoline | 0.11769 | 0.11713 | 1.12084 | 1.12230 |
| Electricity ~ gas + ln(gasoline) | 0.13639 | 0.13584 | 1.10890 | 1.11028 |
| Electricity ~ gas + gas squared + ln(gasoline) | 0.18627 | 0.18549 | 1.07658 | 1.07721 |

SE/RMSE units are MWh/person; n = 3,142 throughout. Random-fold CV is an
interpolation check, not geographically independent validation.

- Gas/electricity Pearson r = -0.3411; Spearman r = -0.4556. Simple slope
  -0.04390 MWh/person per Mcf/person (OLS 95% CI -0.04813 to -0.03967).
- Gasoline/electricity Pearson r = 0.0549; Spearman r = 0.1808. Simple slope
  0.00008606 per gallon/person, or 0.00861 MWh/person per 100 gallons/person.
  Classical p = 0.0021, but HC3 p = 0.104: avoid calling this strong evidence.
- Raw multiple slopes: gas -0.04365; gasoline 0.00005752. Gasoline adds only
  0.00152 partial R-squared beyond gas. Its HC3 p = 0.116, despite OLS p = 0.029.
- Raw predictor correlation -0.0537 and VIF 1.003: fuel-to-fuel collinearity is negligible.

## Preferred preliminary model

`electricity = 3.55018 - 0.099986*gas + 0.00142322*gas^2 + 0.314104*ln(gasoline)`.

The quadratic follows visible gas curvature; logging gasoline reduces extreme
ratio leverage. It has lower cross-validation error, while leaving the response
in useful original units. About 18.6% of electricity variation is explained.
A doubling of gasoline corresponds to about 0.218 MWh/person more electricity
at fixed gas (HC3 95% CI about 0.145 to 0.290). Gas's slope varies: at 10 Mcf/person
it is about -0.0715 MWh/person per additional Mcf/person; the fitted minimum is
near 35.1 Mcf/person. Do not summarize the full curve as uniformly negative or
interpret the upturn causally. `log1p(gas)` was inspected graphically and preserves
zeros, but did not clearly resolve the high-tail curvature; ordinary log gas was
not used. No broad transformation search was performed.

## Diagnostics and caveats

- Residual curvature is reduced, but heteroscedasticity and Q-Q tail departures
  remain. Preferred-model BP-style p < 0.001. HC3 intervals supplement OLS;
  neither addresses spatial dependence or omitted-variable bias.
- Loving County, TX (76 residents; 31,576.74 gallons/person) dominates raw gasoline
  leverage (about 0.528). Removing it changes the preferred log-gasoline slope
  only from 0.3141 to 0.3169.
- Peoria County, IL (75.72 Mcf/person; 186,818 residents) is most influential in
  the quadratic model (Cook's D 0.1316). Removing Peoria preserves curvature
  and gives log-gasoline slope 0.3117.
- Removing all 185 preferred-model Cook-screen cases gives gas slopes -0.1282
  and 0.001775, and log-gasoline slope 0.2845. Signs persist; gas magnitudes change
  materially. This selected-sample comparison does not justify deletion.
- Quadratic gas and its square have VIF near 4.95 because they represent the
  same underlying predictor. Log-gasoline VIF remains 1.008.
- Modeled historical estimates, unequal energy sectors, shared population
  denominators, small-population extremes, unmeasured climate/economic/community
  characteristics and geographic dependence limit interpretation. Equal county
  weighting does not estimate an average resident's relationship. No causation.

## What to integrate

The group report is due November 12: at most four pages Part A and four pages
Part B. Select a compact subset; do not paste the whole individual Rmd.

- Part A: shortened descriptive table, correlations, `02_relationships.png`,
  and distribution panels from `01_distributions.png`. Mention genuine zeros,
  Loving's leverage and gas curvature.
- Part B: compact model-comparison table, preferred coefficients/HC3 intervals,
  and `05_preliminary_model.png`; summarize remaining diagnostic problems.
- Backup: `diagnostics_quadratic_gas_log_gasoline.png`, `04_influence.png`;
  full model-specific diagnostics and coefficient/sensitivity CSVs are available.

Primary script: `R/01_energy_consumption.R`. Standalone write-up:
`reports/saad_energy_consumption.Rmd`. All figures/tables:
`outputs/saad_energy_consumption/`. Output guide there lists the files.

## Reproduce and remaining work

From project root: `Rscript R/01_energy_consumption.R`, then
`Rscript R/validate_energy_analysis.R`. Analysis uses base R only.
Render with `rmarkdown::render('reports/saad_energy_consumption.Rmd')`;
requires knitr, rmarkdown and Pandoc. Knitting reruns the analysis.

Saad should review the write-up and be ready to explain conditional slopes,
quadratic curvature, influence versus outliers, and why tiny p-values can coexist
with low R-squared. Coordinate confounder discussion with Aidan; discuss sparse
high-gas counties and spatial dependence with the instructor. The presentation
and independent final report still need integration, selection and student review.
Generative AI assisted with code, execution validation and drafting; preserve an
accurate disclosure and check any subsequently updated course requirements.
