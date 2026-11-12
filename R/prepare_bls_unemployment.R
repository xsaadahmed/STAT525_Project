# Prepare 2016 county unemployment rates from the BLS LAUS workbook.
# Source: U.S. Bureau of Labor Statistics, Local Area Unemployment Statistics (LAUS), Labor Force Data by County, 2016 Annual Averages.
# https://www.bls.gov/lau/laucnty16.xlsx
# Downloaded: 11/12/2026

bls <- readxl::read_excel("data/external/downloads/laucnty16.xlsx",
                          skip = 1,
                          col_types = "text")
bls <- bls[which(bls$Year == "2016"), ]

state <- bls[["State FIPS Code"]]
county <- bls[["County FIPS Code"]]

# check for missing or improperly formatted FIPS codes
stopifnot(
  !anyNA(state), !anyNA(county),
  all(grepl("^[0-9]{2}$", state)),
  all(grepl("^[0-9]{3}$", county))
)

rate <- as.numeric(bls$`Unemployment Rate (%)`)
# check for proper rates
stopifnot(all(rate >= 0 & rate <= 100, na.rm = TRUE))

unemployment <- data.frame(
  county_fips = paste0(state, county),
  unemployment_rate_pct = rate
)
stopifnot(!anyDuplicated(unemployment$county_fips))

write.csv(unemployment, "data/external/bls_unemployment_2016.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")


# validation
source("R/00_merge_external_data.R")
unemployment <- read_canonical_external("data/external/bls_unemployment_2016.csv", "unemployment_rate_pct")

# checking which counties match the counties in our data
baseline <- readRDS("data/cleaned_data.rds")
idx <- match(baseline$county_fips, unemployment$county_fips)

cat("BLS counties:", nrow(unemployment), "\n")
cat("Matched NREL counties:", sum(!is.na(idx)), "of", nrow(baseline), "\n")
cat("NREL counties with missing rates:",
    sum(is.na(unemployment$unemployment_rate_pct[idx])), "\n")
cat("NREL-only FIPS:", setdiff(baseline$county_fips, unemployment$county_fips), "\n")
cat("BLS-only FIPS:", setdiff(unemployment$county_fips, baseline$county_fips), "\n")




