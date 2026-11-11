# Saad: run from STAT525_Project.Rproj (project root).
county <- readRDS("data/cleaned_data.rds")

# Response: res_elec_mwh_pc (MWh/person).
# Available predictors: res_gas_mcf_pc (Mcf/person), gasoline_gal_pc (gallons/person).
# No external data are required to begin.
# TODO: Explore distributions and relationships; retain genuine zero gas values.
# TODO: Define model-specific complete cases, fit regressions, and assess assumptions later.
