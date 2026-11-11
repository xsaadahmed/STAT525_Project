# STAT 525: prepare county data from the untouched NREL XLSB workbook.
# Run from the RStudio project root: source("R/00_data_preparation.R")
# Dependencies: readxlsb 0.1.61, Rcpp, xml2, cellranger (base R otherwise).
# readxlsb is archived on CRAN. A Windows binary can be installed with:
# install.packages(c("Rcpp", "xml2", "cellranger"))
# install.packages("https://packagemanager.posit.co/cran/2024-09-01/bin/windows/contrib/4.4/readxlsb_0.1.61.zip", repos=NULL, type="win.binary")
# This binary was tested with R 4.5.2 on Windows for these deliverables.
# Other platforms: install the archived source (requires build tools):
# install.packages("https://cran.r-project.org/src/contrib/Archive/readxlsb/readxlsb_0.1.61.tar.gz", repos=NULL, type="source")
# API: https://search.r-project.org/CRAN/refmans/readxlsb/html/read_xlsb.html
# No package installation is performed automatically by this script.

raw_path <- "data/raw/original_workbook.xlsb" # Place the original workbook here.
output_dir <- "data"
# Optional command-line overrides: Rscript R/00_data_preparation.R path/to/source.xlsb data
args <- commandArgs(trailingOnly=TRUE)
if (length(args) >= 1L) raw_path <- args[1L]
if (length(args) >= 2L) output_dir <- args[2L]
stopifnot(file.exists(raw_path), requireNamespace("readxlsb", quietly=TRUE))
source_md5 <- unname(tools::md5sum(raw_path))
letters <- c("B", "C", "D", "E", "F", "G", "I", "K", "M", "O", "P", "Q", "V", "Y", "AQ", "AU", "FI", "FJ")
positions <- c(2, 3, 4, 5, 6, 7, 9, 11, 13, 15, 16, 17, 22, 25, 43, 47, 165, 166)
output_names <- c("state_abbr", "county_state_name", "county_fips", "county_name", "latitude", "longitude", "population", "employment_count", "climate_zone", "res_elec_mwh", "res_elec_spend_kusd", "res_elec_mwh_pc", "res_gas_mcf_pc", "occupied_housing_units", "gasoline_gal_pc", "vmt_miles_pc", "egrid_subregion", "elec_co2e_tons_per_mwh")
numeric_names <- c("latitude", "longitude", "population", "employment_count", "res_elec_mwh", "res_elec_spend_kusd", "res_elec_mwh_pc", "res_gas_mcf_pc", "occupied_housing_units", "gasoline_gal_pc", "vmt_miles_pc", "elec_co2e_tons_per_mwh")
expected_headers <- rbind(
c("", "", "", "", "state_abbr"),
c("", "", "", "", "county_state_name"),
c("", "", "", "", "county_id"),
c("", "", "", "", "county_name"),
c("", "", "", "", "latitude"),
c("", "", "", "", "longitude"),
c("", "", "", "", "population"),
c("", "", "", "", "employment"),
c("", "", "", "", "doe_climate_zone"),
c("", "Residential", "Electricity", "", "consumption (MWh)"),
c("", "Residential", "Electricity", "", "expenditures ('000 $)"),
c("", "Residential", "Electricity", "", "consumption (MWh/capita)"),
c("", "Residential", "Natural Gas", "", "consumption (Mcf/capita)"),
c("", "Residential", "", "", "occuped housing units"),
c("", "On Road Transportation", "Gasoline", "", "consumption (gallons/capita)"),
c("", "On Road Transportation", "", "", "vehicle miles traveled (miles/capita)"),
c("", "Emissions factors", "Electricity", "", "egrid_primary_subregion"),
c("", "Emissions factors", "Electricity", "", "CO2 equivalent total output emission rate (mton/MWh)")
)
# Verify positional references independently of their numerical representation.
excel_position <- function(x) Reduce(function(a,b) a*26L+b, utf8ToInt(x)-64L, init=0L)
stopifnot(length(positions)==18L, !anyDuplicated(positions),
          identical(as.integer(vapply(letters, excel_position, numeric(1))), as.integer(positions)))

# Read all five header rows separately, so mixed text headers cannot affect data types.
headers <- readxlsb::read_xlsb(raw_path, sheet="County", range="A1:FM5",
                             col_names=FALSE, trim_ws=FALSE)
stopifnot(nrow(headers)==5L, ncol(headers)==169L)
observed_headers <- t(as.matrix(headers[, positions, drop=FALSE]))
observed_headers[is.na(observed_headers)] <- ""
stopifnot(identical(unname(observed_headers), unname(expected_headers)))
print(data.frame(excel=letters, one_based=positions, zero_based=positions-1L,
                 heading=observed_headers[,5L], sector=observed_headers[,2L],
                 fuel=observed_headers[,3L], output=output_names), row.names=FALSE)

# skip=5 retains native numeric source values. debug=TRUE also exposes cell error types,
# physical row positions, and sheet names. No fixed final data row is imposed.
source_read <- readxlsb::read_xlsb(raw_path, sheet="County", skip=5,
                                 col_names=FALSE, trim_ws=FALSE, debug=TRUE)
cat("Worksheets:", paste(source_read$env$sheets$Name, collapse=", "), "\n")
raw <- source_read$result
stopifnot(ncol(raw)==169L)
content <- source_read$env$content
cat("Declared/record extent: A1:FM", max(content$row), "\n", sep="")
# mapped.type == 1 is readxlsb's explicit Excel error type, not a missing marker.
error_cells <- content[content$row>=6L & content$column %in% positions &
                       content$mapped.type==1L, , drop=FALSE]
stopifnot(nrow(error_cells)==0L)

blank <- function(x) is.na(x) | trimws(as.character(x))==""
blank_rows <- Reduce(`&`, lapply(raw, blank))
excel_rows <- seq_len(nrow(raw))+5L
cat("Entirely blank data-region rows excluded:", sum(blank_rows), "\n")
raw <- raw[!blank_rows, , drop=FALSE]
excel_rows <- excel_rows[!blank_rows]
cat("Last nonempty county row:", max(excel_rows), "\n")
# Only entirely blank rows are removed. A partial or repeated-header row must fail QA.
stopifnot(nrow(raw)==3142L, identical(excel_rows, 6:3147))
selected_source <- raw[, positions, drop=FALSE]
names(selected_source) <- output_names
cleaned_data <- selected_source

is_missing <- function(x) is.na(x) | toupper(trimws(as.character(x))) %in%
  c("", "-", "NA", "N/A", "NULL", "NAN", "#N/A")
missing_before <- vapply(selected_source, function(x) sum(is_missing(x)), integer(1))
conversion_failures <- setNames(integer(length(output_names)), output_names)
for (nm in output_names) {
  x <- cleaned_data[[nm]]
  if (is.character(x)) x <- trimws(x)
  x[is_missing(x)] <- NA
  cleaned_data[[nm]] <- x
}
for (nm in numeric_names) {
  x <- cleaned_data[[nm]]
  # Keep native numerics untouched. Parse text only when source storage requires it.
  y <- if (is.numeric(x)) as.numeric(x) else
    suppressWarnings(as.numeric(gsub(",", "", x, fixed=TRUE)))
  conversion_failures[nm] <- sum(!is.na(x) & is.na(y))
  stopifnot(conversion_failures[nm]==0L, all(is.finite(y[!is.na(y)])))
  cleaned_data[[nm]] <- y
}
normalize_fips <- function(x) {
  if (any(is_missing(x))) stop("Missing county FIPS identifier")
  s <- trimws(as.character(x))
  if (!is.numeric(x) && any(!grepl("^[0-9]+(\\.0+)?$", s)))
    stop("Malformed county FIPS identifier")
  y <- suppressWarnings(as.numeric(s))
  if (any(!is.finite(y) | y!=floor(y) | y<=0 | y>99999)) stop("Invalid county FIPS identifier")
  # Reject overlong character identifiers, even if numerically representable.
  if (any(nchar(sub("\\.0+$", "", s))>5L)) stop("Overlong county FIPS identifier")
  sprintf("%05d", as.integer(y))
}
cleaned_data$county_fips <- normalize_fips(selected_source$county_fips)
stopifnot(!anyDuplicated(cleaned_data$county_fips),
          all(grepl("^[0-9]{5}$", cleaned_data$county_fips)))
for (nm in c("state_abbr", "county_state_name", "county_name", "egrid_subregion"))
  cleaned_data[[nm]] <- as.character(cleaned_data[[nm]])

# Information identifies DOE Building America climate zones. Preserve codes without
# inventing unavailable descriptive category labels or implying equal spacing.
zone <- as.character(cleaned_data$climate_zone)
stopifnot(setequal(unique(zone), as.character(1:8)))
cleaned_data$climate_zone <- factor(zone, levels=as.character(1:8), ordered=FALSE)
cat("Climate categories and counts:\n"); print(table(cleaned_data$climate_zone))
stopifnot(all(abs(cleaned_data$latitude)<=90, na.rm=TRUE),
          all(abs(cleaned_data$longitude)<=180, na.rm=TRUE))
nonnegative <- setdiff(numeric_names, c("latitude", "longitude"))
stopifnot(all(vapply(cleaned_data[nonnegative], function(x) all(x>=0, na.rm=TRUE), logical(1))))
for (nm in c("population", "employment_count"))
  stopifnot(all(abs(cleaned_data[[nm]]-round(cleaned_data[[nm]]))<=1e-8, na.rm=TRUE))
# The supplied workbook has genuinely fractional occupied-housing-unit values.
# Preserve them as numeric and disclose them, rather than rounding or removing counties.
housing_deviation <- abs(cleaned_data$occupied_housing_units-round(cleaned_data$occupied_housing_units))
cat("Housing count deviations > 1e-4 units:", sum(housing_deviation>1e-4, na.rm=TRUE), "\n")
if (any(housing_deviation>1e-4, na.rm=TRUE))
  warning("Source occupied housing units are not uniformly integer-valued; retained unchanged")

# Gazetteer A:J is the county block. Other blocks represent subdivisions/places.
gaz <- readxlsb::read_xlsb(raw_path, sheet="Gazetteer", range="A1:J4000",
                         skip=1, col_names=FALSE)
gaz <- gaz[!is_missing(gaz[[2L]]), , drop=FALSE]
gaz_fips <- normalize_fips(gaz[[2L]])
stopifnot(!anyDuplicated(gaz_fips), all(cleaned_data$county_fips %in% gaz_fips))
match_idx <- match(cleaned_data$county_fips, gaz_fips)
stopifnot(identical(cleaned_data$state_abbr, as.character(gaz[[1L]][match_idx])))
cat("Gazetteer matches:", length(match_idx), "; reference-only counties:",
    sum(!gaz_fips %in% cleaned_data$county_fips), "\n")
name_diff <- cleaned_data$county_name != gaz[[4L]][match_idx]
print(data.frame(fips=cleaned_data$county_fips[name_diff],
                 county_name=cleaned_data$county_name[name_diff],
                 gazetteer_name=gaz[[4L]][match_idx][name_diff]))

# eGRID reference uses pounds/MWh. County FJ already uses metric tons/MWh.
# Verify the reference relationship without replacing or rescaling County values.
egrid <- readxlsb::read_xlsb(raw_path, sheet="eGRID", range="A1:C100",
                           skip=2, col_names=FALSE)
egrid <- egrid[!is_missing(egrid[[1L]]), , drop=FALSE]
stopifnot(!anyDuplicated(egrid[[1L]]),
          setequal(unique(cleaned_data$egrid_subregion), as.character(egrid[[1L]])))
reference_lb <- as.numeric(egrid[[3L]][match(cleaned_data$egrid_subregion,egrid[[1L]])])
stopifnot(all(abs(cleaned_data$elec_co2e_tons_per_mwh-reference_lb*0.000453592)<1e-12))
cat("eGRID subregions:",length(unique(cleaned_data$egrid_subregion)),
    "; distinct County emission rates:",length(unique(cleaned_data$elec_co2e_tons_per_mwh)),"\n")

# Primary price uses total residential source O/P, never the per-capita Q column.
o <- cleaned_data$res_elec_mwh
p <- cleaned_data$res_elec_spend_kusd
eligible <- !is.na(o) & !is.na(p) & is.finite(o) & is.finite(p) & o>0 & p>=0
cleaned_data$res_elec_price_usd_mwh <- rep(NA_real_, nrow(cleaned_data))
cleaned_data$res_elec_price_usd_mwh[eligible] <- 1000*p[eligible]/o[eligible]
# Independently reference the original column positions and alter arithmetic order.
direct_price <- as.numeric(raw[[16L]])/as.numeric(raw[[15L]])*1000
stopifnot(all(abs(cleaned_data$res_elec_price_usd_mwh[eligible]-direct_price[eligible]) <=
              1e-10 + 1e-12*abs(direct_price[eligible])))
stopifnot(identical(o, as.numeric(raw[[15L]])), identical(p, as.numeric(raw[[16L]])))
final_names <- c(output_names, "res_elec_price_usd_mwh")
stopifnot(ncol(cleaned_data)==19L, identical(names(cleaned_data), final_names),
          all(vapply(cleaned_data[c(numeric_names, final_names[19L])],
                     function(x) all(is.finite(x[!is.na(x)])), logical(1))))
# Diagnostics include selected-source missing markers before normalization.
missing_before <- c(missing_before, res_elec_price_usd_mwh=NA_integer_)
conversion_failures <- c(conversion_failures, res_elec_price_usd_mwh=0L)
diagnostics <- data.frame(variable=final_names, missing_before=unname(missing_before),
  missing_after=vapply(cleaned_data, function(x) sum(is.na(x)), integer(1)),
  percent_missing=100*vapply(cleaned_data, function(x) mean(is.na(x)), numeric(1)),
  zeros=vapply(cleaned_data, function(x) if(is.numeric(x)) sum(x==0,na.rm=TRUE) else NA_integer_, integer(1)),
  numeric_conversion_failures=unname(conversion_failures))
print(diagnostics, row.names=FALSE)
cat("Price eligibility reasons: missing O=",sum(is.na(o)), ", nonpositive O=",sum(o<=0,na.rm=TRUE),
    ", missing P=",sum(is.na(p)), ", negative P=",sum(p<0,na.rm=TRUE), "\n", sep="")
cat("Price min/median/max:", range(cleaned_data$res_elec_price_usd_mwh,na.rm=TRUE)[1L],
    median(cleaned_data$res_elec_price_usd_mwh,na.rm=TRUE),
    range(cleaned_data$res_elec_price_usd_mwh,na.rm=TRUE)[2L], "\n")
# Explicit 17-significant-digit serialization preserves binary-double precision.
# Text columns are quoted; FIPS are serialized as full five-character strings.
dir.create(output_dir, recursive=TRUE, showWarnings=FALSE)
serialized <- cleaned_data
for (nm in names(serialized)) {
  x <- serialized[[nm]]
  serialized[[nm]] <- if (is.numeric(x)) ifelse(is.na(x), NA_character_, sprintf("%.17g", x)) else as.character(x)
}
text_indices <- which(!vapply(cleaned_data, is.numeric, logical(1)))
csv_path <- file.path(output_dir, "cleaned_county_data.csv")
rds_path <- file.path(output_dir, "cleaned_data.rds")
write.table(serialized, csv_path, sep=",", row.names=FALSE, col.names=TRUE,
            quote=text_indices, na="", fileEncoding="UTF-8", qmethod="double")
saveRDS(cleaned_data, rds_path, version=3)
classes <- ifelse(vapply(cleaned_data, is.numeric, logical(1)), "numeric", "character")
roundtrip <- read.csv(csv_path, colClasses=classes, check.names=FALSE, na.strings="", fileEncoding="UTF-8")
stopifnot(nrow(roundtrip)==nrow(cleaned_data), identical(names(roundtrip),final_names))
for (nm in final_names) {
  expected <- cleaned_data[[nm]]
  if (is.factor(expected)) expected <- as.character(expected)
  stopifnot(isTRUE(all.equal(roundtrip[[nm]], expected, tolerance=1e-14, check.attributes=FALSE)))
}
stopifnot(identical(readRDS(rds_path),cleaned_data), identical(unname(tools::md5sum(raw_path)), source_md5))
cat("PASS: 3142 counties, 19 columns, FIPS/headers/types/price/CSV/RDS/source integrity checked.\n")
cat("Source exception: fractional housing counts retained. See cleaning_report.md.\n")
cat("R:", R.version.string, "; readxlsb:", as.character(utils::packageVersion("readxlsb")), "\n")
