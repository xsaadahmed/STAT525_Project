# Define helpers safely before external files exist:
# source("R/00_merge_external_data.R")
# Explicit final merge (requires all three real, reviewed canonical files):
# result <- merge_external_data()
# Base R only. No downloads, imputation, automatic execution, or baseline writes.

external_specs <- list(
  acs=list(file="acs_income_2016.csv",variable="median_household_income"),
  bls=list(file="bls_unemployment_2016.csv",variable="unemployment_rate_pct"),
  usda=list(file="usda_rucc_2013.csv",variable="rucc_2013")
)

read_canonical_external <- function(path, variable) {
  if (!file.exists(path)) stop("Missing external file: ",path,call.=FALSE)
  # Character import protects FIPS zeros and allows explicit numeric-error checks.
  x <- read.csv(path,colClasses="character",check.names=FALSE,
                na.strings=c("","NA"),fileEncoding="UTF-8",strip.white=TRUE)
  if (nrow(x)==0L || !setequal(names(x),c("county_fips",variable)) || ncol(x)!=2L)
    stop("Expected nonempty canonical CSV with exactly county_fips and ",variable,": ",path,call.=FALSE)
  x <- x[,c("county_fips",variable),drop=FALSE]
  fips <- x$county_fips
  if (anyNA(fips) || any(!grepl("^[0-9]{5}$",fips)) || any(fips=="00000"))
    stop("Missing or malformed five-character FIPS in ",path,"; standardize and verify geography first",call.=FALSE)
  if (anyDuplicated(fips)) stop("Duplicate external FIPS in ",path,"; no arbitrary deduplication allowed",call.=FALSE)
  raw_value <- x[[variable]]
  value <- suppressWarnings(as.numeric(raw_value))
  if (any(!is.na(raw_value) & is.na(value)) || any(!is.finite(value[!is.na(value)])))
    stop("Invalid numeric values in ",path,call.=FALSE)
  if (variable=="median_household_income" && any(value<0,na.rm=TRUE))
    stop("Income must be nonnegative USD; resolve documented source suppression codes before merging",call.=FALSE)
  if (variable=="unemployment_rate_pct" && any(value<0 | value>100,na.rm=TRUE))
    stop("Unemployment must be percent on the 0-100 scale",call.=FALSE)
  if (variable=="rucc_2013") {
    if (any(!value[!is.na(value)] %in% 1:9)) stop("RUCC must be integer codes 1-9 or NA",call.=FALSE)
    value <- factor(value,levels=1:9,ordered=FALSE)
  }
  x[[variable]] <- value
  x
}

merge_external_data <- function(data_dir="data") {
  # This explicit operation requires every input; merely sourcing this file does not.
  paths <- vapply(external_specs,function(s) file.path(data_dir,"external",s$file),character(1))
  missing <- paths[!file.exists(paths)]
  if (length(missing)) stop("Final merge not run. Missing required files: ",
    paste(missing,collapse=", "),". No outputs were written; any older enriched files are unchanged and may be stale.",call.=FALSE)
  baseline <- readRDS(file.path(data_dir,"cleaned_data.rds"))
  expected_names <- c("state_abbr", "county_state_name", "county_fips", "county_name", "latitude", "longitude", "population", "employment_count", "climate_zone", "res_elec_mwh", "res_elec_spend_kusd", "res_elec_mwh_pc", "res_gas_mcf_pc", "occupied_housing_units", "gasoline_gal_pc", "vmt_miles_pc", "egrid_subregion", "elec_co2e_tons_per_mwh", "res_elec_price_usd_mwh")
  if (!is.data.frame(baseline) || nrow(baseline)!=3142L ||
      !identical(names(baseline),expected_names) || anyNA(baseline) ||
      !is.character(baseline$county_fips) ||
      any(!grepl("^[0-9]{5}$",baseline$county_fips)) || anyDuplicated(baseline$county_fips))
    stop("Invalid 3142-row, 19-column baseline or FIPS; run R/validate_cleaned_data.R",call.=FALSE)
  baseline_paths <- file.path(data_dir,c("cleaned_data.rds","cleaned_county_data.csv"))
  before <- unname(tools::md5sum(baseline_paths))
  enriched <- baseline
  audits <- list()
  for (source in names(external_specs)) {
    spec <- external_specs[[source]]
    external <- read_canonical_external(paths[[source]],spec$variable)
    # Unique right keys + match preserve left rows/order and prevent row multiplication.
    idx <- match(baseline$county_fips,external$county_fips)
    unmatched <- baseline$county_fips[is.na(idx)]
    extra <- setdiff(external$county_fips,baseline$county_fips)
    enriched[[spec$variable]] <- external[[spec$variable]][idx]
    audit <- list(matched=sum(!is.na(idx)),unmatched_baseline=unmatched,
                  reference_only=extra,missing_values=sum(is.na(enriched[[spec$variable]])))
    audits[[source]] <- audit
    cat(source,": matched=",audit$matched,"; unmatched baseline=",length(unmatched),
        "; external-only=",length(extra),"; missing predictor=",audit$missing_values,"\n",sep="")
    cat("Unmatched baseline FIPS:",if(length(unmatched)) paste(unmatched,collapse=", ") else "none","\n")
    cat("External-only FIPS:",if(length(extra)) paste(extra,collapse=", ") else "none","\n")
  }
  stopifnot(nrow(enriched)==3142L,ncol(enriched)==22L,
            identical(enriched$county_fips,baseline$county_fips),
            identical(enriched[,names(baseline),drop=FALSE],baseline))
  # Full precision, UTF-8 CSV. Genuine missing external values stay blank/NA.
  serialized <- enriched
  for (nm in names(serialized)) {
    x <- serialized[[nm]]
    serialized[[nm]] <- if (is.numeric(x)) ifelse(is.na(x),NA_character_,sprintf("%.17g",x)) else as.character(x)
  }
  temp_csv <- tempfile("external-",tmpdir=data_dir,fileext=".csv")
  temp_rds <- tempfile("external-",tmpdir=data_dir,fileext=".rds")
  on.exit(unlink(c(temp_csv,temp_rds)),add=TRUE)
  write.table(serialized,temp_csv,sep=",",row.names=FALSE,col.names=TRUE,
              quote=which(!vapply(enriched,is.numeric,logical(1))),na="",fileEncoding="UTF-8",qmethod="double")
  saveRDS(enriched,temp_rds,version=3)
  stopifnot(identical(readRDS(temp_rds),enriched))
  classes <- ifelse(vapply(enriched,is.numeric,logical(1)),"numeric","character")
  csv <- read.csv(temp_csv,colClasses=classes,check.names=FALSE,na.strings="",fileEncoding="UTF-8")
  for (nm in names(enriched)) {
    expected <- enriched[[nm]]
    if (is.factor(expected)) expected <- as.character(expected)
    stopifnot(isTRUE(all.equal(csv[[nm]],expected,tolerance=1e-14,check.attributes=FALSE)))
  }
  stopifnot(identical(unname(tools::md5sum(baseline_paths)),before))
  destinations <- file.path(data_dir,c("county_with_external.csv","county_with_external.rds"))
  if (!all(file.copy(c(temp_csv,temp_rds),destinations,overwrite=TRUE)))
    stop("Could not publish both enriched files locally. Check permissions and rerun; outputs may be incomplete.",call.=FALSE)
  cat("Saved enriched CSV/RDS: 3142 rows, 22 columns. Baseline unchanged. Review unmatched FIPS before modeling.\n")
  invisible(list(data=enriched,audits=audits))
}
message("External helpers loaded. No merge performed. Run merge_external_data() only after all three real canonical sources have been reviewed.")
