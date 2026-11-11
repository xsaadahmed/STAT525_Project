# NREL county dataset cleaning and validation report

Prepared 2026-11-11. Data preparation only. No regressions, modeling transformations, graphs, external-data merges, or GitHub changes were performed.

## A. Source workbook information

- Uploaded file: `2016cityandcountyenergyprofiles_units correction (1).xlsb`.
- Format: genuine Excel Binary Workbook (.xlsb), readable with three independent readers: Python Calamine, Python pyxlsb, and R readxlsb.
- Worksheets, in actual order: Information, Search, City, County, Lookup, eGRID, Gazetteer.
- Observations: County worksheet only. Other sheets supplied reference evidence only.
- Declared worksheet extent: **A1:FM3156**, verified from binary worksheet dimensions and R record extent. Nonempty content extent: **A1:FM3147**, verified with Calamine and pyxlsb. Last valid county row: **3147**.
- Original columns: **169**. Header rows: **1–5**. County records: rows **6–3147**, or **3,142**. Rows **3148–3156** are nine entirely blank formatted rows.
- Hierarchy: row 1 calibration/NAICS context, row 2 sector, row 3 fuel, row 4 NAICS detail, row 5 actual heading. No indiscriminate header forward fill was used.
- Information sheet reports completion **12/3/2019**. Its source descriptions identify population and housing as **2012–2016 ACS five-year estimates**, employment as **2016 County Business Patterns**, coordinates as **2016 Gazetteer**, and electricity emissions as **2016 eGRID**. Modeled estimates are primarily associated with 2016, rather than uniformly observed in 2019.
- Information defines county_id as Census state code plus three-digit county code. It defines employment as total employment, occupied housing units as households, and electricity emissions rate as average electricity emissions intensity.
- Information explicitly describes consumption/expenditures as modeled, and warns more precise regional or local data may exist. It cites NREL/TP-7A40-72748 (2019) for methodology and transportation methodology at the historical SLED site.
- Original SHA-256 before and after processing: `f2b4b332f8eb4012bf00f924ce4eb9da5502f895a62f0054d65187ee763a234c`. Hash equality passed. R independently verified its input MD5 before/after. The original was never written.

## B. Selected column verification

All 18 supplied positions and meanings match the actual workbook. The source spelling `occuped housing units` was preserved in the audit and corrected only in the output name. Blank fuel headings for Y and AU are genuine blanks and were not filled with a neighboring fuel.

| Excel | One-based | Zero-based | Row 1 | Row 2 sector | Row 3 fuel | Row 4 | Row 5 original heading | Output | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| B | 2 | 1 | (blank) | (blank) | (blank) | (blank) | state_abbr | state_abbr | PASS |
| C | 3 | 2 | (blank) | (blank) | (blank) | (blank) | county_state_name | county_state_name | PASS |
| D | 4 | 3 | (blank) | (blank) | (blank) | (blank) | county_id | county_fips | PASS |
| E | 5 | 4 | (blank) | (blank) | (blank) | (blank) | county_name | county_name | PASS |
| F | 6 | 5 | (blank) | (blank) | (blank) | (blank) | latitude | latitude | PASS |
| G | 7 | 6 | (blank) | (blank) | (blank) | (blank) | longitude | longitude | PASS |
| I | 9 | 8 | (blank) | (blank) | (blank) | (blank) | population | population | PASS |
| K | 11 | 10 | (blank) | (blank) | (blank) | (blank) | employment | employment_count | PASS |
| M | 13 | 12 | (blank) | (blank) | (blank) | (blank) | doe_climate_zone | climate_zone | PASS |
| O | 15 | 14 | (blank) | Residential | Electricity | (blank) | consumption (MWh) | res_elec_mwh | PASS |
| P | 16 | 15 | (blank) | Residential | Electricity | (blank) | expenditures ('000 $) | res_elec_spend_kusd | PASS |
| Q | 17 | 16 | (blank) | Residential | Electricity | (blank) | consumption (MWh/capita) | res_elec_mwh_pc | PASS |
| V | 22 | 21 | (blank) | Residential | Natural Gas | (blank) | consumption (Mcf/capita) | res_gas_mcf_pc | PASS |
| Y | 25 | 24 | (blank) | Residential | (blank) | (blank) | occuped housing units | occupied_housing_units | PASS |
| AQ | 43 | 42 | (blank) | On Road Transportation | Gasoline | (blank) | consumption (gallons/capita) | gasoline_gal_pc | PASS |
| AU | 47 | 46 | (blank) | On Road Transportation | (blank) | (blank) | vehicle miles traveled (miles/capita) | vmt_miles_pc | PASS |
| FI | 165 | 164 | (blank) | Emissions factors | Electricity | (blank) | egrid_primary_subregion | egrid_subregion | PASS |
| FJ | 166 | 165 | (blank) | Emissions factors | Electricity | (blank) | CO2 equivalent total output emission rate (mton/MWh) | elec_co2e_tons_per_mwh | PASS |

## C. Cleaning operations

- Positive selection retained exactly B, C, D, E, F, G, I, K, M, O, P, Q, V, Y, AQ, AU, FI, FJ, with no duplicate positions.
- Excluded **151 = 169 − 18** original columns: A, H, J, L, N, R:U, W:X, Z:AP, AR:AT, AV:FH, FK:FM. No source cells or worksheets were modified.
- Read the five-row header separately from numeric observations. No header row was treated as a county.
- Removed only nine entirely blank trailing rows. Preserved original county order.
- Renamed the 18 source fields, standardized FIPS to five-character strings, and preserved native numeric doubles. Numeric text parsing supports whitespace and thousands separators, but no unexpected numeric strings occurred in these fields.
- Normalized genuine missing markers (blank, whitespace, -, NA, N/A, NULL, NaN, #N/A) with no imputations. Explicit Excel error records were checked before accepting missingness. No selected data cells contain such errors or genuine missing markers.
- Climate codes 1–8 are preserved as an **unordered factor** in RDS. No descriptive labels or equally spaced interpretations were invented. eGRID subregion remains character.
- Added only `res_elec_price_usd_mwh`. No external-predictor placeholders were added. No rounding, clipping, winsorization, or log transformation was applied.
- CSV was written in UTF-8 with 17 significant digits for numeric values and full five-character FIPS. RDS was created by base R `saveRDS`, then reopened with `readRDS`.

## D. Row preservation and identifiers

| Check | Actual result |
| --- | --- |
| Original valid counties | 3142 |
| Final counties | 3142 |
| Blank trailing rows excluded | 9 |
| Valid observations removed | 0 |
| Duplicate normalized FIPS | 0 |
| Invalid/missing normalized FIPS | 0 |
| Final distinct columns | 19 |
| Original county ordering | Preserved exactly |
| Leading-zero FIPS | 316 |

Every county FIPS matches the county block **Gazetteer A:J**, and its state abbreviation agrees. Gazetteer contains 3,220 county-equivalent rows, including **78 Puerto Rico municipalities** absent from County. These reference-only rows were not introduced. Lookup F:H likewise covers all 3,142 County identifiers and has the same 78 Puerto Rico extras.

Three Gazetteer names differ from County. IDs and state abbreviations match, so County names remain authoritative for the output:

| FIPS | County name | Gazetteer name | Interpretation |
| --- | --- | --- | --- |
| 02195 | Petersburg Census Area | Petersburg Borough | Geographic label/vintage inconsistency; no boundary equivalence inferred |
| 22059 | La Salle Parish | LaSalle Parish | Spacing difference |
| 35013 | Dona Ana County | Do±a Ana County | Apparent source encoding/diacritic inconsistency |

No name-based merge was used. These are disclosed source differences, not unexplained FIPS mismatches.

## E. Missing-value diagnostics

Before means genuine missing markers among the retained source observations, before normalization. Derived price has no source before-count. After counts also reflect explicit numeric conversion and derived-price eligibility.

| Variable | Missing before | Missing after | Missing % | Numeric zeros | Unexpected conversion NAs |
| --- | --- | --- | --- | --- | --- |
| state_abbr | 0 | 0 | 0 | N/A | 0 |
| county_state_name | 0 | 0 | 0 | N/A | 0 |
| county_fips | 0 | 0 | 0 | N/A | 0 |
| county_name | 0 | 0 | 0 | N/A | 0 |
| latitude | 0 | 0 | 0 | 0 | 0 |
| longitude | 0 | 0 | 0 | 0 | 0 |
| population | 0 | 0 | 0 | 0 | 0 |
| employment_count | 0 | 0 | 0 | 4 | 0 |
| climate_zone | 0 | 0 | 0 | N/A | 0 |
| res_elec_mwh | 0 | 0 | 0 | 0 | 0 |
| res_elec_spend_kusd | 0 | 0 | 0 | 0 | 0 |
| res_elec_mwh_pc | 0 | 0 | 0 | 0 | 0 |
| res_gas_mcf_pc | 0 | 0 | 0 | 9 | 0 |
| occupied_housing_units | 0 | 0 | 0 | 0 | 0 |
| gasoline_gal_pc | 0 | 0 | 0 | 0 | 0 |
| vmt_miles_pc | 0 | 0 | 0 | 0 | 0 |
| egrid_subregion | 0 | 0 | 0 | N/A | 0 |
| elec_co2e_tons_per_mwh | 0 | 0 | 0 | 0 | 0 |
| res_elec_price_usd_mwh | N/A (derived) | 0 | 0 | 0 | 0 |

All 18 selected source fields and the derived price have zero missing values. Zero source values were not treated as missing. Binary-cell inspection found the nine V-column gas zeros stored numerically with style 24 / custom number format 164. Its zero section is `_(* "-"??_)`, which displays a dash. These are formatting artifacts, not literal missing-marker strings. The four K-column employment zeros are stored numerically with the General format.

| Variable | FIPS | County | Source Excel row |
| --- | --- | --- | --- |
| res_gas_mcf_pc | 02068 | Denali Borough, AK | 78 |
| res_gas_mcf_pc | 02158 | Kusilvak Census Area, AK | 87 |
| res_gas_mcf_pc | 12067 | Lafayette County, FL | 358 |
| res_gas_mcf_pc | 13307 | Webster County, GA | 544 |
| res_gas_mcf_pc | 25007 | Dukes County, MA | 1226 |
| res_gas_mcf_pc | 30037 | Golden Valley County, MT | 1622 |
| res_gas_mcf_pc | 30069 | Petroleum County, MT | 1638 |
| res_gas_mcf_pc | 32011 | Eureka County, NV | 1758 |
| res_gas_mcf_pc | 46075 | Jones County, SD | 2404 |
| employment_count | 02158 | Kusilvak Census Area, AK | 87 |
| employment_count | 15005 | Kalawao County, HI | 554 |
| employment_count | 46102 | Oglala Lakota County, SD | 2418 |
| employment_count | 48269 | King County, TX | 2663 |

## F. Numeric validation

All listed variables are numeric doubles in RDS, finite, and source values are unchanged. Negative values are appropriate for west longitudes; every consumption, expenditure, count, and rate field is nonnegative. Latitude/longitude bounds were checked against ±90/±180. Positive longitude in the Aleutians is geographically plausible and was retained.

| Variable | Minimum | Median | Mean | Maximum | Nonfinite | Negative |
| --- | --- | --- | --- | --- | --- | --- |
| latitude | 19.597764 | 38.3799175 | 38.4552402066 | 69.449343 | 0 | 0 |
| longitude | -164.188912 | -90.3797635 | -92.1775204984 | 178.338813 | 0 | 3141 |
| population | 76 | 25737.5 | 101387.0662 | 10057155 | 0 | 0 |
| employment_count | 0 | 12710.5 | 77126.6301719 | 7743432 | 0 | 0 |
| res_elec_mwh | 256.576761119 | 122113.353324 | 396164.195118 | 21034157.2139 | 0 | 0 |
| res_elec_spend_kusd | 51.024995432 | 14146.7317443 | 50188.8574886 | 3270371.97795 | 0 | 0 |
| res_elec_mwh_pc | 0.971984750984 | 4.86866966149 | 4.70635095819 | 10.514809497 | 0 | 0 |
| res_gas_mcf_pc | 0 | 8.80337798768 | 11.1874775892 | 75.7175352956 | 0 | 0 |
| occupied_housing_units | 37 | 9745 | 37061.5652601 | 3281845 | 0 | 0 |
| gasoline_gal_pc | 46.6587643276 | 500.354805116 | 628.451374822 | 31576.7368421 | 0 | 0 |
| vmt_miles_pc | 951.317152508 | 11965.8150396 | 15532.088684 | 637722.736842 | 0 | 0 |
| elec_co2e_tons_per_mwh | 0.134236923664 | 0.540971055696 | 0.496297509232 | 0.761713870456 | 0 | 0 |
| res_elec_price_usd_mwh | 36.7624627628 | 115.471314179 | 121.166668068 | 480.402425917 | 0 | 0 |

Population and employment counts are exactly integer-valued. Occupied housing units are **not uniformly integer-valued in the source**. Absolute distance to the nearest integer exceeds 0.000001 unit for **1,017** counties and 0.0001 unit for **111** counties; maximum distance is **0.5**. The looser 0.0001-unit tolerance distinguishes substantial fractions from small floating-point residues. Even the substantial fractions are source values, not parsing errors: Calamine, pyxlsb and R readxlsb agree exactly. They are retained as numeric without rounding.

Counts of substantial housing fractions by state:

| State | Count |
| --- | --- |
| NY | 18 |
| PA | 53 |
| RI | 3 |
| SC | 23 |
| SD | 14 |

An all-county list of substantial housing fractions is included in the appendix. Their originating calculation is not explained by the workbook; no unsupported correction is applied.

Climate category frequencies (not numerical averages):

| Code | Count |
| --- | --- |
| 1 | 8 |
| 2 | 242 |
| 3 | 700 |
| 4 | 832 |
| 5 | 767 |
| 6 | 462 |
| 7 | 122 |
| 8 | 9 |

The workbook identifies DOE Building America climate zones but supplies no code-to-descriptive-name table. Category membership and unordered typing are verified; a full semantic label mapping is not established.

Identifiers/categories: 3142 distinct FIPS, 3142 county/state labels, 1877 county names, 51 state/DC abbreviations, 8 climate categories, and 26 eGRID subregions.

State/DC abbreviations and counts:

| State/DC | Count |
| --- | --- |
| AK | 29 |
| AL | 67 |
| AR | 75 |
| AZ | 15 |
| CA | 58 |
| CO | 64 |
| CT | 8 |
| DC | 1 |
| DE | 3 |
| FL | 67 |
| GA | 159 |
| HI | 5 |
| IA | 99 |
| ID | 44 |
| IL | 102 |
| IN | 92 |
| KS | 105 |
| KY | 120 |
| LA | 64 |
| MA | 14 |
| MD | 24 |
| ME | 16 |
| MI | 83 |
| MN | 87 |
| MO | 115 |
| MS | 82 |
| MT | 56 |
| NC | 100 |
| ND | 53 |
| NE | 93 |
| NH | 10 |
| NJ | 21 |
| NM | 33 |
| NV | 17 |
| NY | 62 |
| OH | 88 |
| OK | 77 |
| OR | 36 |
| PA | 67 |
| RI | 5 |
| SC | 46 |
| SD | 66 |
| TN | 95 |
| TX | 254 |
| UT | 29 |
| VA | 133 |
| VT | 14 |
| WA | 39 |
| WI | 72 |
| WV | 55 |
| WY | 23 |

eGRID comparison: County has **26 distinct rates** and **26 subregions**. Each subregion has exactly one rate. The reference eGRID sheet is in **lb/MWh**; County FJ is in **metric tons/MWh**. All reference rates reproduce County FJ using the workbook conversion coefficient **0.000453592 metric tons/lb**, to floating-point tolerance 1e-12. County values were preserved, not recomputed. The coefficient is slightly rounded relative to the exact physical conversion 0.00045359237.

| Subregion | Count | County metric tons/MWh | Reference lb/MWh |
| --- | --- | --- | --- |
| AKGD | 7 | 0.48864105384 | 1077.27 |
| AKMS | 22 | 0.228997735568 | 504.854 |
| AZNM | 46 | 0.475839780416 | 1049.048 |
| CAMX | 54 | 0.240353411288 | 529.889 |
| ERCT | 188 | 0.459976760992 | 1014.076 |
| FRCC | 57 | 0.461009589976 | 1016.353 |
| HIMS | 4 | 0.525580679136 | 1158.708 |
| HIOA | 1 | 0.759868204608 | 1675.224 |
| MROE | 40 | 0.761713870456 | 1679.293 |
| MROW | 410 | 0.565822454192 | 1247.426 |
| NEWE | 67 | 0.255697521464 | 563.717 |
| NWPP | 223 | 0.297287371944 | 655.407 |
| NYCW | 4 | 0.288973484176 | 637.078 |
| NYLI | 2 | 0.537956483264 | 1185.992 |
| NYUP | 57 | 0.134236923664 | 295.942 |
| RFCE | 96 | 0.345688359896 | 762.113 |
| RFCM | 67 | 0.580096994432 | 1278.896 |
| RFCW | 347 | 0.567657687424 | 1251.472 |
| RMPA | 97 | 0.6244941258 | 1376.775 |
| SPNO | 115 | 0.64508493464 | 1422.17 |
| SPSO | 160 | 0.569192642752 | 1254.856 |
| SRMV | 136 | 0.381993863576 | 842.153 |
| SRMW | 192 | 0.735936690688 | 1622.464 |
| SRSO | 245 | 0.496737217448 | 1095.119 |
| SRTV | 284 | 0.540971055696 | 1192.638 |
| SRVC | 221 | 0.367468940552 | 810.131 |

## G. Derived electricity-price verification

- Formula: **P × 1000 / O**, with P in thousands of USD and O in total residential MWh.
- O > 0 and P ≥ 0, both finite and nonmissing, are required. Invalid cases remain missing rather than producing infinite or normal-looking prices.
- Valid prices: **3,142**. Undefined prices: **0**. Missing O: **0**. Nonpositive O: **0**. Negative O: **0**. Missing P: **0**. Negative P: **0**.
- Minimum: **36.76246276283220 USD/MWh**; median: **115.47131417894821**; maximum: **480.40242591748495**.
- Programmatically checked all 3,142 prices against raw O/P with independent arithmetic order (`P / O * 1000`), tolerance absolute 1e-10 plus relative 1e-12. O and P were also checked unchanged. Python and R outputs match exactly at the binary-double level after round-trip CSV import.

First ten records plus ten additional records sampled with NumPy default_rng(525), without replacement from indices 10–3141. Excel row numbers make the sample independently locatable:

| Excel row | FIPS | County | O: MWh | P: thousand USD | Price USD/MWh |
| --- | --- | --- | --- | --- | --- |
| 6 | 01001 | Autauga County, AL | 315398.029124 | 39864.2388751 | 126.393430504 |
| 7 | 01003 | Baldwin County, AL | 1064842.63115 | 126826.099128 | 119.103138265 |
| 8 | 01005 | Barbour County, AL | 136097.793498 | 17085.4924398 | 125.53835004 |
| 9 | 01007 | Bibb County, AL | 117401.407035 | 14857.9316073 | 126.556674086 |
| 10 | 01009 | Blount County, AL | 328465.618283 | 41577.246807 | 126.580209595 |
| 11 | 01011 | Bullock County, AL | 53059.2594165 | 6709.06490157 | 126.444752063 |
| 12 | 01013 | Butler County, AL | 117811.999786 | 14943.807276 | 126.844526051 |
| 13 | 01015 | Calhoun County, AL | 648756.737954 | 82123.2085428 | 126.585519253 |
| 14 | 01017 | Chambers County, AL | 207887.629942 | 26282.6620701 | 126.427253403 |
| 15 | 01019 | Cherokee County, AL | 162896.881101 | 20819.0514389 | 127.805095458 |
| 50 | 01089 | Madison County, AL | 2189561.43166 | 211792.057779 | 96.7280728989 |
| 121 | 05009 | Boone County, AR | 171011.76847 | 17532.2797746 | 102.52089626 |
| 295 | 08089 | Otero County, CO | 63592.5458702 | 9988.675782 | 157.073060141 |
| 1072 | 21147 | McCreary County, KY | 91254.3569014 | 9134.18794036 | 100.095910492 |
| 1211 | 24027 | Howard County, MD | 1361816.33296 | 201621.910253 | 148.053673152 |
| 1330 | 27021 | Cass County, MN | 139163.954767 | 16314.6427268 | 117.233250191 |
| 1771 | 33003 | Carroll County, NH | 150004.703098 | 28380.9942982 | 189.200696459 |
| 2214 | 41001 | Baker County, OR | 75662.1556198 | 7497.18231744 | 99.0876119775 |
| 2297 | 42095 | Northampton County, PA | 1295654.99769 | 176805.103827 | 136.46001763 |
| 2336 | 45029 | Colleton County, SC | 227224.6758 | 32931.8938079 | 144.930975001 |

Minimum, two central records, and maximum (the sample median is the mean of the two central prices):

| Position | Excel row | FIPS | County | Price USD/MWh |
| --- | --- | --- | --- | --- |
| Minimum | 2967 | 53017 | Douglas County, WA | 36.7624627628 |
| Central 1571 | 2808 | 49051 | Wasatch County, UT | 115.4688766 |
| Central 1572 | 809 | 19029 | Cass County, IA | 115.473751758 |
| Maximum | 92 | 02188 | Northwest Arctic Borough, AK | 480.402425917 |

Extreme-value checks:

| Variable | Extreme | FIPS | County | Value | Population |
| --- | --- | --- | --- | --- | --- |
| res_elec_mwh_pc | Minimum | 36041 | Hamilton County, NY | 0.971984750984 | 4697 |
| res_elec_mwh_pc | Maximum | 31169 | Thayer County, NE | 10.514809497 | 5163 |
| res_gas_mcf_pc | Minimum | 02068 | Denali Borough, AK | 0 | 2125 |
| res_gas_mcf_pc | Maximum | 17143 | Peoria County, IL | 75.7175352956 | 186818 |
| gasoline_gal_pc | Minimum | 02050 | Bethel Census Area, AK | 46.6587643276 | 17885 |
| gasoline_gal_pc | Maximum | 48301 | Loving County, TX | 31576.7368421 | 76 |
| vmt_miles_pc | Minimum | 02158 | Kusilvak Census Area, AK | 951.317152508 | 7993 |
| vmt_miles_pc | Maximum | 48301 | Loving County, TX | 637722.736842 | 76 |

The maximum gasoline and VMT per-capita values occur in a very small population jurisdiction, making jurisdictional travel divided by resident population unusually large. This is consistent with a small-denominator mechanism, but does not independently establish measurement accuracy. The minimum and maximum prices were traced to source O/P and verified in all three readers. Regional tariff differences and modeling limitations may contribute, but their causal explanation cannot be established from this workbook. No extreme observation was removed or altered.

## H. Known limitations and reproducibility

- Energy estimates are modeled, rather than purely metered county totals. Geographic assignments and model calibration can influence values.
- Source years differ: primarily 2016 with ACS 2012–2016 five-year estimates and a 2019 dataset completion date. Later merges must align geography and years explicitly.
- Emissions factors repeat within subregions. The 3,142 county rows do not represent 3,142 independently measured electricity-emissions rates.
- Three reference-sheet naming differences and the fractional housing counts are genuine source issues. The workbook does not explain their full provenance. They do not justify changing identifiers or dropping observations.
- Median household income, unemployment rate and RUCC are absent. Employment is not unemployment. None was inferred, retrieved or merged.
- Climate descriptive category labels beyond the original codes are not provided in the workbook. Codes are preserved without an ordered interpretation.
- CSV cannot encode character or factor classes. Spreadsheet programs may hide FIPS leading zeros on import even though the file contains all five digits. Use explicit R types.
- The R script was actually executed using **R 4.5.2** and **readxlsb 0.1.61** on Windows. That package is archived on CRAN. Installation comments give a tested dated Windows binary and the archived source option for other platforms. Rcpp, xml2 and cellranger are its dependencies. Other OS/R versions were not tested.
- R startup emitted locale warnings for C.UTF-8 on this Windows environment. Full data comparisons, UTF-8 CSV imports, and RDS round trips succeeded. The expected housing warning was emitted.

### Reproduce from an RStudio project root

Place the untouched workbook at `data/raw/original_workbook.xlsb` and this script at `R/00_data_preparation.R`. Change the documented `raw_path` configuration if needed. Run:

```r
source("R/00_data_preparation.R")
```

Alternatively, command-line arguments can supply an input path and output directory. The delivered script has project-relative defaults and no machine-specific paths. During validation it read the original uploaded workbook directly using a command-line path override. It does not start from the cleaned CSV.

The script validates headers, positions, physical rows, error records, FIPS, Gazetteer membership, categories, emissions units, numeric bounds, price arithmetic and round-trip outputs. It prints diagnostics and explicitly warns about fractional housing counts rather than forcing a pass.

### Import for each project analysis script

```r
county <- readRDS("data/cleaned_data.rds")
stopifnot(is.character(county$county_fips), is.factor(county$climate_zone),
          !is.ordered(county$climate_zone))
```

Base R CSV alternative with all identifier/category types explicit:

```r
classes <- c(state_abbr="character", county_state_name="character",
             county_fips="character", county_name="character",
             latitude="numeric", longitude="numeric", population="numeric",
             employment_count="numeric", climate_zone="character",
             res_elec_mwh="numeric", res_elec_spend_kusd="numeric",
             res_elec_mwh_pc="numeric", res_gas_mcf_pc="numeric",
             occupied_housing_units="numeric", gasoline_gal_pc="numeric",
             vmt_miles_pc="numeric", egrid_subregion="character",
             elec_co2e_tons_per_mwh="numeric", res_elec_price_usd_mwh="numeric")
county <- read.csv("data/cleaned_county_data.csv", colClasses=classes,
                   na.strings="", check.names=FALSE, fileEncoding="UTF-8")
county$climate_zone <- factor(county$climate_zone, levels=as.character(1:8),
                              ordered=FALSE)
```

Put the CSV/RDS under `data/`, the R script under `R/`, and dictionary/report under `docs/` after your review. No GitHub or repository files were edited.

### Executed verification and file integrity

Python extraction used python-calamine and pyxlsb. Native cell values from both readers agreed exactly across all 18 selected fields. An independent Python result was compared with the R-produced CSV across every observation and column. Numeric double equality, identifier equality, names, order and shape all passed. The R-created RDS was read back and was identical to the in-memory R data frame. CSV and RDS values/classes were checked explicitly, allowing factor codes in CSV.

| File | SHA-256 |
| --- | --- |
| cleaned_county_data.csv | fabd36e7d9f94bc79e97036345f2b69f6bfd21abbe342b279475deeb5aa23908 |
| cleaned_data.rds | 5cdd9f497fbe1e99515f89253276ad6b4585200b1ad8b823a29e50fd234bf8bc |
| 00_data_preparation.R | ff6b80ac5d56f1ed1c314286ad4308068d6a6b6a51d60bf2532ad8dc17a31238 |
| data_dictionary.md | eceba59b6a915b51371fcec9f0a3e8587a8df2991a99c93cb982beccf63608ab |

## I. Final QA results

| Validation | Actual result | Status |
| --- | --- | --- |
| Readable source / correct County sheet | County; seven verified worksheets | PASS |
| Five header rows / sector / fuel / units | All 18 exact header vectors verified | PASS |
| Original width | 169 columns | PASS |
| Selected positions | 18 prescribed distinct positions; 151 excluded | PASS |
| Final schema | 19 distinct columns in prescribed order | PASS |
| County count and row preservation | 3142; zero valid removals; nine blank rows excluded | PASS |
| FIPS format and uniqueness | 3142 unique five-digit character strings | PASS |
| Geographic cross-check | 3142 Gazetteer and Lookup matches; 78 PR reference-only records | PASS |
| Name equality with Gazetteer | Three explained source naming differences, preserved | FAIL (source difference) |
| Source missingness and conversion | Zero missing markers, Excel errors or unexpected NAs | PASS |
| Stored zeros | Nine gas zeros and four employment zeros preserved | PASS |
| Numeric bounds and finite values | No invalid bounds, nonfinite values or inappropriate negatives | PASS |
| Population and employment integers | Exact whole-number values | PASS |
| Occupied housing units integer-valued | 111 deviations >0.0001 unit; max 0.5; source preserved | FAIL (source issue) |
| Climate categorical representation | Unordered factor, levels 1–8; eight observed codes | PASS |
| Full climate descriptive-label mapping | Not provided by workbook; no labels fabricated | NOT TESTED |
| Emissions rates and units | 26 subregions/rates; county mton/MWh versus reference lb/MWh verified | PASS |
| Price calculation | All 3142 O/P comparisons pass; no undefined values | PASS |
| Price samples and extrema | First ten, additional ten, min, max and central records checked | PASS |
| Source unchanged | Before/after SHA-256 and R MD5 equal | PASS |
| CSV reimport | Names, shape, order, FIPS and numeric values verified | PASS |
| RDS genuine and equivalent | saveRDS/readRDS identity; numeric doubles and category classes checked | PASS |
| R reproducibility from original XLSB | Executed R script; all values exactly match independent Python result | PASS |
| Cross-platform R execution | Only R 4.5.2 Windows executed | NOT TESTED |
| External predictors / modeling / repository changes | None performed or added | PASS |

The two source-related FAIL entries are retained transparently rather than forced into expected values. They do not prevent using the delivered dataset for the requested later analyses. Housing remains numeric because the authoritative source is fractional, and County names remain unchanged because FIPS establishes identity. Not-tested descriptive labels and cross-platform execution are explicitly limited above.

## Remaining work outside scope

Later work consists of the ACS median household income merge, BLS unemployment-rate merge, USDA RUCC merge, followed by exploratory analysis and regression modeling. Each researcher should form model-specific complete-case subsets at that later stage.

## Appendix: substantial fractional housing counts

Threshold: absolute difference from nearest integer >0.0001 housing unit. These are the 111 original values retained unchanged:

| Excel row | FIPS | County | Original occupied housing units | Distance to nearest integer |
| --- | --- | --- | --- | --- |
| 1839 | 36011 | Cayuga County, NY | 15519.5 | 0.5 |
| 1841 | 36015 | Chemung County, NY | 17443.4999992 | 0.499999215001 |
| 1842 | 36017 | Chenango County, NY | 9918.5000015 | 0.499998503999 |
| 1844 | 36021 | Columbia County, NY | 12647.5 | 0.5 |
| 1845 | 36023 | Cortland County, NY | 8841.50000165 | 0.499998354049 |
| 1846 | 36025 | Delaware County, NY | 9408.5 | 0.499999999951 |
| 1847 | 36027 | Dutchess County, NY | 53474.5 | 0.5 |
| 1850 | 36033 | Franklin County, NY | 9649.49999951 | 0.499999508 |
| 1852 | 36037 | Genesee County, NY | 11912.5 | 0.5 |
| 1853 | 36039 | Greene County, NY | 8562.5 | 0.5 |
| 1854 | 36041 | Hamilton County, NY | 619.499999799 | 0.4999997995 |
| 1858 | 36049 | Lewis County, NY | 5153.49999942 | 0.49999941945 |
| 1859 | 36051 | Livingston County, NY | 12108.4999999 | 0.499999941499 |
| 1860 | 36053 | Madison County, NY | 13060.5000013 | 0.499998675999 |
| 1861 | 36055 | Monroe County, NY | 150144.5 | 0.5 |
| 1867 | 36067 | Onondaga County, NY | 92462.5 | 0.499999999505 |
| 1872 | 36077 | Otsego County, NY | 11769.5 | 0.5 |
| 1875 | 36083 | Rensselaer County, NY | 31776.5 | 0.499999999949 |
| 2250 | 42001 | Adams County, PA | 38263.0628217 | 0.0628217050034 |
| 2251 | 42003 | Allegheny County, PA | 531034.125019 | 0.125019412953 |
| 2252 | 42005 | Armstrong County, PA | 28249.9119682 | 0.0880317593983 |
| 2253 | 42007 | Beaver County, PA | 69918.7600293 | 0.239970663402 |
| 2255 | 42011 | Berks County, PA | 152442.909847 | 0.0901531470008 |
| 2256 | 42013 | Blair County, PA | 50952.1238277 | 0.123827697797 |
| 2258 | 42017 | Bucks County, PA | 233503.012652 | 0.0126523170038 |
| 2259 | 42019 | Butler County, PA | 74761.0083889 | 0.00838893730543 |
| 2263 | 42027 | Centre County, PA | 57030.5406642 | 0.459335753301 |
| 2264 | 42029 | Chester County, PA | 186655.555215 | 0.444785153988 |
| 2265 | 42031 | Clarion County, PA | 15834.0167619 | 0.0167618703999 |
| 2266 | 42033 | Clearfield County, PA | 31302.5510481 | 0.448951916798 |
| 2267 | 42035 | Clinton County, PA | 14702.7714223 | 0.228577736299 |
| 2268 | 42037 | Columbia County, PA | 26347.3689682 | 0.3689682199 |
| 2269 | 42039 | Crawford County, PA | 34525.3738114 | 0.373811412901 |
| 2270 | 42041 | Cumberland County, PA | 96483.4810877 | 0.481087683002 |
| 2271 | 42043 | Dauphin County, PA | 110195.589465 | 0.410535496005 |
| 2272 | 42045 | Delaware County, PA | 203579.898346 | 0.101653582009 |
| 2273 | 42047 | Elk County, PA | 13361.3703412 | 0.370341153201 |
| 2274 | 42049 | Erie County, PA | 110035.013514 | 0.0135137799953 |
| 2275 | 42051 | Fayette County, PA | 53651.8814192 | 0.118580803799 |
| 2277 | 42055 | Franklin County, PA | 59382.7724505 | 0.227549515301 |
| 2278 | 42057 | Fulton County, PA | 5987.48174249 | 0.48174249449 |
| 2280 | 42061 | Huntingdon County, PA | 16970.594406 | 0.4055939873 |
| 2281 | 42063 | Indiana County, PA | 34057.054216 | 0.0542159988036 |
| 2282 | 42065 | Jefferson County, PA | 18358.345195 | 0.345195022299 |
| 2283 | 42067 | Juniata County, PA | 9325.87516088 | 0.12483911892 |
| 2284 | 42069 | Lackawanna County, PA | 85155.2039175 | 0.203917488499 |
| 2285 | 42071 | Lancaster County, PA | 196108.75317 | 0.24682997301 |
| 2286 | 42073 | Lawrence County, PA | 36297.8120951 | 0.187904887098 |
| 2287 | 42075 | Lebanon County, PA | 52238.1914918 | 0.191491814599 |
| 2288 | 42077 | Lehigh County, PA | 135335.925065 | 0.0749347569945 |
| 2289 | 42079 | Luzerne County, PA | 127502.388256 | 0.388256081002 |
| 2290 | 42081 | Lycoming County, PA | 45586.6611542 | 0.338845833598 |
| 2291 | 42083 | McKean County, PA | 17257.951942 | 0.0480580104995 |
| 2292 | 42085 | Mercer County, PA | 45349.3563848 | 0.356384753897 |
| 2293 | 42087 | Mifflin County, PA | 18688.2473401 | 0.247340088401 |
| 2294 | 42089 | Monroe County, PA | 57109.6837859 | 0.316214126098 |
| 2295 | 42091 | Montgomery County, PA | 309831.295962 | 0.295961524011 |
| 2297 | 42095 | Northampton County, PA | 112798.24254 | 0.242539614002 |
| 2298 | 42097 | Northumberland County, PA | 39189.8671976 | 0.132802395798 |
| 2300 | 42101 | Philadelphia County, PA | 582510.858233 | 0.141766721965 |
| 2301 | 42103 | Pike County, PA | 21134.725441 | 0.2745590056 |
| 2303 | 42107 | Schuylkill County, PA | 58335.0347125 | 0.0347124850014 |
| 2304 | 42109 | Snyder County, PA | 14527.2867878 | 0.2867877518 |
| 2305 | 42111 | Somerset County, PA | 29629.4051998 | 0.405199752098 |
| 2307 | 42115 | Susquehanna County, PA | 17364.4475364 | 0.447536366701 |
| 2310 | 42121 | Venango County, PA | 21961.7298721 | 0.270127928001 |
| 2311 | 42123 | Warren County, PA | 16903.1146943 | 0.1146943028 |
| 2312 | 42125 | Washington County, PA | 83726.8609061 | 0.139093915699 |
| 2313 | 42127 | Wayne County, PA | 19172.9675358 | 0.032464198699 |
| 2314 | 42129 | Westmoreland County, PA | 150687.739268 | 0.260732260009 |
| 2316 | 42133 | York County, PA | 167973.278465 | 0.278465454991 |
| 2318 | 44003 | Kent County, RI | 68659.356344 | 0.356344022206 |
| 2320 | 44007 | Providence County, RI | 237429.520698 | 0.479301637009 |
| 2321 | 44009 | Washington County, RI | 49552.6880605 | 0.3119394569 |
| 2325 | 45007 | Anderson County, SC | 74809.7498225 | 0.250177450696 |
| 2328 | 45013 | Beaufort County, SC | 67344.6873883 | 0.312611738496 |
| 2329 | 45015 | Berkeley County, SC | 70477.4024395 | 0.402439496902 |
| 2331 | 45019 | Charleston County, SC | 150884.250871 | 0.250871030992 |
| 2334 | 45025 | Chesterfield County, SC | 18167.2257724 | 0.225772428701 |
| 2339 | 45035 | Dorchester County, SC | 53001.523768 | 0.476231961497 |
| 2342 | 45041 | Florence County, SC | 51744.4541086 | 0.454108565304 |
| 2344 | 45045 | Greenville County, SC | 182450.86496 | 0.135039782996 |
| 2345 | 45047 | Greenwood County, SC | 26805.9959265 | 0.00407346749853 |
| 2346 | 45049 | Hampton County, SC | 7287.15510073 | 0.15510072525 |
| 2347 | 45051 | Horry County, SC | 122123.316065 | 0.316065141 |
| 2348 | 45053 | Jasper County, SC | 9297.51472172 | 0.485278283621 |
| 2349 | 45055 | Kershaw County, SC | 24098.383719 | 0.383718967601 |
| 2353 | 45063 | Lexington County, SC | 107519.380915 | 0.380915296002 |
| 2355 | 45067 | Marion County, SC | 12086.4984109 | 0.498410936099 |
| 2357 | 45071 | Newberry County, SC | 14503.5012502 | 0.498749831801 |
| 2359 | 45075 | Orangeburg County, SC | 33359.1880776 | 0.188077635103 |
| 2360 | 45077 | Pickens County, SC | 45620.7428392 | 0.2571608488 |
| 2361 | 45079 | Richland County, SC | 147327.020845 | 0.0208454910025 |
| 2363 | 45083 | Spartanburg County, SC | 111442.630446 | 0.369554133998 |
| 2364 | 45085 | Sumter County, SC | 40796.8818729 | 0.118127054702 |
| 2365 | 45087 | Union County, SC | 11592.8562619 | 0.143738077501 |
| 2367 | 45091 | York County, SC | 92297.6754687 | 0.324531256803 |
| 2369 | 46005 | Beadle County, SD | 7512.49566808 | 0.49566808494 |
| 2373 | 46013 | Brown County, SD | 16121.8637533 | 0.1362467281 |
| 2374 | 46015 | Brule County, SD | 2068.55484129 | 0.44515870685 |
| 2376 | 46019 | Butte County, SD | 4180.84882963 | 0.15117037074 |
| 2380 | 46027 | Clay County, SD | 5312.69027166 | 0.30972834421 |
| 2392 | 46051 | Grant County, SD | 3224.42792992 | 0.4279299163 |
| 2407 | 46081 | Lawrence County, SD | 10745.8610183 | 0.1389816705 |
| 2413 | 46093 | Meade County, SD | 10651.1676562 | 0.167656206901 |
| 2416 | 46099 | Minnehaha County, SD | 71566.8680827 | 0.131917263905 |
| 2420 | 46105 | Perkins County, SD | 1293.28357151 | 0.2835715052 |
| 2428 | 46123 | Tripp County, SD | 2556.36416333 | 0.36416333318 |
| 2429 | 46125 | Turner County, SD | 3470.13466902 | 0.13466901661 |
| 2430 | 46127 | Union County, SD | 6036.95929127 | 0.04070872595 |
| 2431 | 46129 | Walworth County, SD | 2329.58252601 | 0.41747399492 |

## Reference documentation consulted

Workbook facts above come directly from the uploaded Information, County, Gazetteer, Lookup and eGRID sheets. The R reader API was verified against the [readxlsb reference manual](https://search.r-project.org/CRAN/refmans/readxlsb/html/read_xlsb.html) and [package source](https://github.com/cran/readxlsb/blob/master/R/read_xlsb.R). Installation was tested using the dated Posit binary URL documented in the R script. These web references concern the reader implementation only; no external observations were added.
