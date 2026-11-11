# Shared county data

The [corrected NREL City and County Energy Profiles workbook](https://data.openei.org/submissions/149), **County** worksheet, supplies the baseline: **3,142 counties or county equivalents, 19 columns**. Eighteen source variables were retained, plus one estimated price. No valid county was dropped.

| File | Contents and purpose |
| --- | --- |
| `cleaned_county_data.csv` | UTF-8 flat data, one header, full numeric precision; portable to R and other tools |
| `cleaned_data.rds` | Same rows, values and order; genuine R serialization preserving character identifiers, numeric doubles and an unordered climate-zone factor |

These committed files are ready for analysis without the original workbook or `readxlsb`. The [dictionary](../docs/data_dictionary.md) defines all variables and units. The [cleaning report](../docs/cleaning_report.md) records exact source mappings, diagnostics, hashes and limitations. Both are the original accepted documents, unchanged.

## Vintage, units and keys

The workbook was completed in December 2019 and is primarily 2016-oriented: ACS 2012–2016 five-year population/housing, 2016 County Business Patterns employment, 2016 Gazetteer coordinates and 2016 eGRID emissions. Energy estimates are modeled. It is not a current-year dataset.

`county_fips` is the **five-character state-plus-county Census key**. Preserve leading zeros and verify the external geography/vintage before joining; never join by county name alone.

Estimated residential electricity price is:

```text
res_elec_price_usd_mwh = 1000 * res_elec_spend_kusd / res_elec_mwh
```

The numerator is source P in thousands of USD; the denominator is source O in total MWh. This estimates expenditure per MWh, not a directly observed tariff. Only positive finite consumption and nonnegative finite expenditure permit a price; otherwise price is missing.

There are **zero missing values in all 19 fields**, nine genuine gas-per-capita zeros and four employment zeros. Housing-unit fractions, three reference-name discrepancies, unlabelled climate codes and repeated emissions rates are preserved and documented. Do not impute or delete these records.

## Load and validate

```r
county <- readRDS("data/cleaned_data.rds")
source("R/validate_cleaned_data.R")
```

For explicit FIPS-safe CSV import, see [TEAM_SETUP.md](../TEAM_SETUP.md). CSV cannot preserve factor classes.

## Optional reproduction

Keep the roughly 36 MB original corrected workbook separately, or at the ignored local path `data/raw/original_workbook.xlsb`. There is no need to commit it or install its reader for routine analysis. Create `data/raw/` locally if it is absent after cloning.

The byte-preserved validated `R/00_data_preparation.R` has project-relative paths and dependency instructions. It reconstructs `data/cleaned_county_data.csv` and `data/cleaned_data.rds` from XLSB. Archived `readxlsb` 0.1.61 was tested with R 4.5.2 on Windows; other-platform installation is not guaranteed. Coordinate before running it and review the resulting data diff.

## Future external files

See [external/README.md](external/README.md) for canonical schemas and provenance requirements. The three real source CSVs are not yet present. The explicit future merge will save separate `county_with_external.csv` and `.rds` files, preserving this baseline unchanged. Do not create dummy external files or placeholder predictors.
