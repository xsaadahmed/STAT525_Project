# Aidan: run from STAT525_Project.Rproj (project root).
county <- readRDS("data/cleaned_data.rds")

# Response: res_elec_mwh_pc. Available categorical predictor: climate_zone.
# Future predictors: median_household_income, unemployment_rate_pct.
# TODO: Begin exploratory climate work with baseline data.
# TODO: Add reviewed 2016 ACS income and 2016 annual-average BLS files using
# data/external/README.md. Coordinate before changing shared merge code.
# After all three real external files are merged, explicitly switch to:
# county <- readRDS("data/county_with_external.rds")
# TODO: Check required variables/missingness, form model-specific complete cases,
# and perform exploratory analysis/regression later. Do not fabricate predictors.
