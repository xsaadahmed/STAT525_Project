# Ray: run from STAT525_Project.Rproj (project root).
county <- readRDS("data/cleaned_data.rds")

# Response: res_elec_price_usd_mwh (estimated expenditure USD/MWh, not a tariff).
# Available predictor: elec_co2e_tons_per_mwh; context: egrid_subregion.
# Future categorical predictor: rucc_2013 (codes 1-9, unordered by default).
# Emissions rates are shared within eGRID subregions, not independently measured
# county-specific rates. Account for this limitation in later interpretation.
# TODO: Begin exploratory price/emissions work using baseline data.
# TODO: Add reviewed USDA 2013 RUCC following data/external/README.md.
# After the common final merge, explicitly switch to:
# county <- readRDS("data/county_with_external.rds")
# TODO: Inspect missingness, form model-specific complete cases, then model later.
