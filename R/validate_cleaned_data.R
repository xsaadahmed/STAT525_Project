# Run from the project root: source("R/validate_cleaned_data.R")
# Base R only; no original workbook or readxlsb needed. No files are written.
validate_cleaned_data <- function(data_dir="data", quiet=FALSE) {
  check <- function(ok, message) if (!isTRUE(ok)) stop(message, call.=FALSE)
  expected <- c("state_abbr",
  "county_state_name",
  "county_fips",
  "county_name",
  "latitude",
  "longitude",
  "population",
  "employment_count",
  "climate_zone",
  "res_elec_mwh",
  "res_elec_spend_kusd",
  "res_elec_mwh_pc",
  "res_gas_mcf_pc",
  "occupied_housing_units",
  "gasoline_gal_pc",
  "vmt_miles_pc",
  "egrid_subregion",
  "elec_co2e_tons_per_mwh",
  "res_elec_price_usd_mwh")
  rds_path <- file.path(data_dir,"cleaned_data.rds")
  csv_path <- file.path(data_dir,"cleaned_county_data.csv")
  check(file.exists(rds_path), paste("Missing RDS:",rds_path))
  check(file.exists(csv_path), paste("Missing CSV:",csv_path))
  county <- tryCatch(readRDS(rds_path),error=function(e) stop("Cannot read baseline RDS: ",conditionMessage(e),call.=FALSE))
  check(is.data.frame(county), "RDS must contain a data frame")
  check(nrow(county)==3142L, "Baseline must contain exactly 3142 counties")
  check(identical(names(county),expected), "Baseline must have the exact 19 column names in the accepted order")
  check(is.character(county$county_fips) && all(grepl("^[0-9]{5}$",county$county_fips)), "FIPS must be five-digit character strings")
  check(!anyDuplicated(county$county_fips), "Duplicate baseline FIPS")
  check(is.factor(county$climate_zone) && !is.ordered(county$climate_zone) &&
        identical(levels(county$climate_zone),as.character(1:8)) &&
        setequal(as.character(county$climate_zone),as.character(1:8)), "Climate zone must be an unordered factor with observed levels 1-8")
  check(!anyNA(county), "Unexpected missing baseline values")
  text <- c("state_abbr","county_state_name","county_fips","county_name","egrid_subregion")
  check(all(vapply(county[text],is.character,logical(1))), "Baseline text identifiers must remain character")
  numeric <- setdiff(expected,c(text,"climate_zone"))
  check(all(vapply(county[numeric],is.numeric,logical(1))), "Unexpected nonnumeric baseline predictor")
  check(all(vapply(county[numeric],function(x) all(is.finite(x)),logical(1))), "Nonfinite baseline numeric value")
  check(sum(county$res_gas_mcf_pc==0)==9L, "Expected nine genuine natural-gas zeros")
  check(sum(county$employment_count==0)==4L, "Expected four genuine employment zeros")
  check(all(county$res_elec_mwh>0), "Residential electricity MWh must be positive")
  check(all(county$res_elec_spend_kusd>=0), "Residential electricity spending must be nonnegative")
  expected_price <- 1000*county$res_elec_spend_kusd/county$res_elec_mwh
  check(all(abs(county$res_elec_price_usd_mwh-expected_price)<=1e-10+1e-12*abs(expected_price)), "Electricity price does not equal P*1000/O")
  check(length(unique(county$egrid_subregion))==26L, "Expected 26 eGRID subregions")
  check(all(vapply(split(county$elec_co2e_tons_per_mwh,county$egrid_subregion),function(x) length(unique(x))==1L,logical(1))), "Unexpected within-subregion emissions-rate variation")
  classes <- ifelse(vapply(county,is.numeric,logical(1)),"numeric","character")
  csv <- read.csv(csv_path,colClasses=classes,check.names=FALSE,na.strings="",fileEncoding="UTF-8")
  check(nrow(csv)==3142L && identical(names(csv),expected), "CSV dimensions or column order differ from RDS")
  for (nm in expected) {
    original <- county[[nm]]
    if (is.factor(original)) original <- as.character(original)
    equal <- if (is.numeric(original)) isTRUE(all.equal(csv[[nm]],original,tolerance=1e-14,check.attributes=FALSE)) else identical(csv[[nm]],original)
    check(equal,paste("CSV/RDS values or county order differ in",nm))
  }
  if (!quiet) {
    cat("PASS: 3142 rows, 19 columns; unique character FIPS; unordered climate factor; no NAs; 9 gas zeros; 4 employment zeros; 26 eGRID subregions; all prices correct; CSV/RDS equivalent.\n")
    cat("Price min / median / max (USD/MWh):",format(min(expected_price),digits=13),
        format(median(expected_price),digits=13),format(max(expected_price),digits=13),"\n")
    cat("Known source limitations, including fractional housing counts, remain in docs/cleaning_report.md.\n")
  }
  invisible(county)
}
invisible(validate_cleaned_data())
