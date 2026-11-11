# Canonical external county data: not added yet

This directory currently contains instructions only. Do not create dummy CSVs or merge current-year substitutes. Keep the 19-column NREL baseline unchanged. All paths below are relative to the project root.

## Agreed files and schemas

Each real canonical UTF-8 CSV must have exactly two columns, one header and at most one record per county. Column order may vary. Store FIPS as five-digit strings, unformatted numeric values without currency symbols or thousands separators, and genuine unavailable values as blank or `NA`. Never leave numeric source suppression codes as ordinary values; interpret them using source documentation and record the decision.

| Future file | Exact columns | Source / vintage / units | Owner |
| --- | --- | --- | --- |
| `data/external/acs_income_2016.csv` | `county_fips`, `median_household_income` | Census **2016 ACS 5-year**, county estimates, candidate `B19013_001E`; dollars, not thousands | Aidan |
| `data/external/bls_unemployment_2016.csv` | `county_fips`, `unemployment_rate_pct` | BLS LAUS **2016 annual-average county** unemployment rate; percentages on **0–100** scale | Aidan |
| `data/external/usda_rucc_2013.csv` | `county_fips`, `rucc_2013` | USDA ERS **2013** Rural–Urban Continuum Codes; integer categories **1–9** | Ray |

Authoritative source entry points and variable documentation:

- [Census 2016 ACS five-year B19013_001E definition](https://api.census.gov/data/2016/acs/acs5/variables/B19013_001E.json): median household income in 2016 inflation-adjusted dollars. Select the county geography and 2016 five-year product, not a one-year or newer product.
- [BLS Local Area Unemployment Statistics](https://www.bls.gov/lau/): select the 2016 annual-average county rate and document release/revision date. Do not average arbitrary monthly percentages or infer unemployment from NREL employment counts. Verify a published 5.2 percent remains 5.2, not 0.052.
- [USDA ERS Rural–Urban Continuum Codes](https://www.ers.usda.gov/data-products/rural-urban-continuum-codes): explicitly choose the **2013 historical release**, not the site's newer default release. Codes 1–3 are metro and 4–9 nonmetro; this county classification is not identical to an urban/rural household classification. Use an unordered factor unless a specific later model justifies another encoding.

These links are metadata/instructions, not downloaded datasets. No external observations have been retrieved or merged by this integration.

## FIPS and geography checks

- Never merge by county name alone. `county_fips` must be a nonmissing five-character digit string with unique values. The merge helper rejects malformed, short, duplicate and `00000` identifiers.
- If separate state and county codes are supplied, first verify integer codes and widths, then combine the zero-padded two-digit state and three-digit county codes. Do not convert to numeric after concatenation.
- During source-specific preparation, pad only verified valid codes. Do not truncate overlong IDs, guess codes or force name-based matches.
- Verify county-equivalent boundaries and vintage against the NREL baseline. Alaska changes and historical county equivalents deserve particular care. A matching string alone does not prove compatible boundaries.
- Puerto Rico or other records absent from NREL may occur. Keep them distinguishable and document reference-only records and unmatched baseline counties. Do not discard or rename records merely to improve a match rate.
- Resolve duplicates and ambiguous geography using source evidence before publishing the canonical file. Never silently retain an arbitrary duplicate.

## One teammate can add one file independently

1. Obtain the authoritative historical source; keep original downloads and caches outside tracked canonical data (local `cache/` or `downloads/` directories are ignored).
2. Standardize the agreed two-column schema, units and FIPS. Preserve genuine missingness and do not impute.
3. Validate source-specific geography, unique keys, numeric bounds and vintage.
4. Add provenance here (or in a clearly linked companion note): source/download URL, access date, exact release/vintage, source variable names, units, geography, suppression handling, preprocessing code and decisions, row count, duplicate checks, unmatched IDs and license/distribution considerations. Do not invent a successful checklist before obtaining data.
5. Commit the real canonical CSV and reproducible preparation code if distribution is appropriate; open a PR or coordinate review. Do not modify NREL baseline files or another teammate's canonical CSV.
6. Wait for the common final merge until all three real files are available. Meanwhile, work in your assigned analysis script on the baseline or an in-memory one-source left join.

The helper can validate one real file independently; this does not create an enriched dataset:

```r
source("R/00_merge_external_data.R")
# After the real ACS file exists (not runnable before it is added):
# income <- read_canonical_external("data/external/acs_income_2016.csv",
#                                   "median_household_income")
```

A one-source example for later use, kept in memory in Aidan's script (requires `dplyr` with join relationships, e.g. 1.1.1+):

```r
# Run only after obtaining and validating the real ACS canonical file.
# install.packages("dplyr") # once, if needed for this optional example
# source("R/00_merge_external_data.R")
# county <- readRDS("data/cleaned_data.rds")
# income <- read_canonical_external("data/external/acs_income_2016.csv",
#                                   "median_household_income")
# stopifnot(!anyDuplicated(county$county_fips), !anyDuplicated(income$county_fips))
# unmatched <- setdiff(county$county_fips, income$county_fips)
# reference_only <- setdiff(income$county_fips, county$county_fips)
# print(unmatched); print(reference_only) # document both, even when empty
# working <- dplyr::left_join(county, income, by="county_fips",
#                            relationship="one-to-one")
# stopifnot(nrow(working)==3142L, identical(working$county_fips,county$county_fips))
# stopifnot(identical(working[,names(county),drop=FALSE],county))
# # Preserve missing external values; form model-specific subsets later.
```

Saad can start baseline energy work now. Aidan can begin climate work and independently add income/unemployment later. Ray can begin price/emissions work and independently add RUCC later. Do not save partial results using the common final-enriched filenames.

## Explicit common final merge

First review all three files and provenance with the team, then run:

```r
source("R/validate_cleaned_data.R")
source("R/00_merge_external_data.R") # defines functions only; safe without inputs
# After all three real canonical CSVs have been added and reviewed:
# result <- merge_external_data()
# result$audits
```

Uncomment the explicit call only when inputs are ready. Missing required files stop that operation with a list of absent paths and no writes. Any older enriched outputs are left unchanged and may be stale; a failed call never certifies them.

The base-R merge checks exact schemas, character FIPS, unique right-hand keys, numeric parsing, nonnegative income, unemployment in 0–100 and RUCC categories 1–9. Schema checks do not establish provenance or detect a rate supplied on the wrong scale when the number still falls within bounds: source review is essential.

It uses NREL as the left dataset and `match()` on unique FIPS, preserves all 3,142 counties and their order, reports matched counts, unmatched baseline FIPS, external-only FIPS and missing predictor counts, and keeps unmatched/genuine missing external values as NA. It does not impute or require complete-case rows. Unmatched records must be reviewed and documented, rather than forcing perfect matches.

After checks pass, it writes **22 columns** to separate `data/county_with_external.csv` and `data/county_with_external.rds`. RUCC is an unordered factor in RDS; CSV stores its original codes. The first 19 variables remain identical to the baseline, whose hashes are checked unchanged during execution. The helper returns audit details for documentation. Only the common final merge should create these shared enriched outputs.

## Provenance status

ACS income: **not supplied**. BLS unemployment: **not supplied**. USDA RUCC: **not supplied**. No match rates or external-data results are claimed yet.
