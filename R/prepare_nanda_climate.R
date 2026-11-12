# Prepare 2016 county heating and cooling degree days.
# Source: National Neighborhood Data Archive (NaNDA): Weather by County, United States, 2003-2016, dataset 14 (Average Temperatures - 2016).
# https://doi.org/10.3886/ICPSR38858.v1
# Downloaded: 11/12/2026

weather <- read.delim(
  "data/external/downloads/nanda_climate_data.tsv",
  colClasses = "character",
  na.strings = c("", "NA"),
  strip.white = TRUE
)

names(weather) <- tolower(names(weather))
stopifnot(all(c("stcofips10", "date_string", "mean_temp_avg") %in% names(weather)))


fips <- weather[["stcofips10"]]
day <- as.Date(weather[["date_string"]], format = "%Y%m%d")
raw_temp <- weather[["mean_temp_avg"]]
temp_c <- suppressWarnings(as.numeric(raw_temp))
stopifnot(all(is.na(raw_temp) | (!is.na(temp_c) & is.finite(temp_c))))

# verify no missing or duplicate county and date values
stopifnot(
  !anyNA(fips),
  all(grepl("^[0-9]{5}$", fips)),
  !anyNA(day),
  all(format(day, "%Y") == "2016"),
  !anyDuplicated(data.frame(fips, day))
)

temp_f <- temp_c * 9 / 5 + 32

daily <- data.frame(
  county_fips = fips,
  valid_days = as.integer(!is.na(temp_f)),
  hdd65 = pmax(65 - temp_f, 0),
  cdd65 = pmax(temp_f - 65, 0)
)


annual <- aggregate(
  daily[c("valid_days", "hdd65", "cdd65")],
  by = list(county_fips = daily$county_fips),
  FUN = sum,
  na.rm = TRUE
)

incomplete <- annual$valid_days < 366
annual$hdd65[incomplete] <- NA_real_
annual$cdd65[incomplete] <- NA_real_

climate <- annual[c("county_fips", "hdd65", "cdd65")]
write.csv(
  climate,
  "data/external/nanda_degree_days_2016.csv",
  row.names = FALSE,
  na = ""
)

# Annual values are missing unless all 366 finite daily temperatures exist.


# checking which counties match the counties in our data
baseline <- readRDS("data/cleaned_data.rds")
idx <- match(baseline$county_fips, climate$county_fips)
matched <- !is.na(idx)
usable <- complete.cases(climate$hdd65[idx], climate$cdd65[idx])

cat("NaNDA counties:", nrow(climate), "\n")
cat("NaNDA counties with complete annual totals:",
    sum(complete.cases(climate$hdd65, climate$cdd65)), "\n\n")

cat("NREL counties:", nrow(baseline), "\n")
cat("NREL counties matched by FIPS:", sum(matched), "\n")
cat("  Matched with usable HDD and CDD:", sum(usable), "\n")
cat("  Matched with missing annual totals:", sum(matched & !usable), "\n")
cat("NREL counties with no NaNDA match:", sum(!matched), "\n")

cat("NREL-only FIPS:", setdiff(baseline$county_fips, climate$county_fips), "\n")
cat("NaNDA-only FIPS:", setdiff(climate$county_fips, baseline$county_fips), "\n")



