# Prepare county median household income from the 2012–2016 ACS 5-year estimates.
# Source: U.S. Census Bureau, 2012–2016 American Community Survey five-year estimates, detailed table B19013.
# https://data.census.gov/table/ACSDT5Y2016.B19013
# Downloaded: 11/12/2026

input <- "data/external/downloads/acs_b19013_2016.csv"
output <- "data/external/acs_income_2016.csv"

acs <- read.csv(
  input,
  colClasses = "character",
  check.names = FALSE,
  fileEncoding = "UTF-8-BOM",
  na.strings = c("", "NA", "null")
)
acs <- acs[grepl("^0500000US[0-9]{5}$", acs$GEO_ID), ]

county_fips <- sub("^0500000US", "", acs$GEO_ID)
stopifnot(!anyDuplicated(county_fips))

raw_income <- acs$B19013_001E
median_household_income <- as.numeric(raw_income)

# Check that every nonmissing entry converted to a valid dollar amount.
stopifnot(all(is.na(raw_income) |
                (is.finite(median_household_income) & median_household_income >= 0)))

income <- data.frame(county_fips, median_household_income)
write.csv(income, output, row.names = FALSE, na = "", fileEncoding = "UTF-8")

# Validation
source("R/00_merge_external_data.R")
income <- read_canonical_external(output, "median_household_income")

# Check coverage against the energy baseline.
baseline <- readRDS("data/cleaned_data.rds")
idx <- match(baseline$county_fips, income$county_fips)
matched <- !is.na(idx)
usable <- !is.na(income$median_household_income[idx])

cat("ACS counties:", nrow(income), "\n")
cat("ACS counties with missing income:", sum(is.na(income$median_household_income)), "\n")
cat("NREL counties matched by FIPS:", sum(matched), "of", nrow(baseline), "\n")
cat("NREL counties with usable income:", sum(usable), "\n")
cat("NREL-only FIPS:", setdiff(baseline$county_fips, income$county_fips), "\n")
cat("ACS-only FIPS:", setdiff(income$county_fips, baseline$county_fips), "\n")




