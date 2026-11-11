# County energy data dictionary

Unit of observation: one U.S. county or Census county equivalent. All 3,142 observations come from County rows 6–3147. The data have 18 source variables and one derived variable, in the order below. Text is UTF-8. Missing values, if any, use empty CSV fields and R NA. There are none in the delivered data.

RDS numeric variables are double precision. County FIPS and text identifiers are character. Climate zone is an unordered factor; eGRID subregion is character. CSV stores category codes but cannot encode R classes.

## 1. `state_abbr`

- Origin: source variable, County column **B**, Excel position 2 (zero-based 1).
- Original row-5 heading: `state_abbr`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: State abbreviation. RDS type: character.
- Description: State or District of Columbia abbreviation.
- Research area: Shared identification / validation.
- Interpretation / limitation: Source labels or coordinates retained without geographic recoding.

## 2. `county_state_name`

- Origin: source variable, County column **C**, Excel position 3 (zero-based 2).
- Original row-5 heading: `county_state_name`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: Text. RDS type: character.
- Description: County and state label.
- Research area: Shared identification / validation.
- Interpretation / limitation: Source labels or coordinates retained without geographic recoding.

## 3. `county_fips`

- Origin: source variable, County column **D**, Excel position 4 (zero-based 3).
- Original row-5 heading: `county_id`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: Five-digit FIPS. RDS type: character.
- Description: Census state code plus three-digit county code.
- Research area: Shared identification / validation.
- Interpretation / limitation: Character merge key for this workbook vintage. External geographic vintages still require harmonization.

## 4. `county_name`

- Origin: source variable, County column **E**, Excel position 5 (zero-based 4).
- Original row-5 heading: `county_name`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: Text. RDS type: character.
- Description: County or county equivalent name.
- Research area: Shared identification / validation.
- Interpretation / limitation: Source labels or coordinates retained without geographic recoding.

## 5. `latitude`

- Origin: source variable, County column **F**, Excel position 6 (zero-based 5).
- Original row-5 heading: `latitude`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: Decimal degrees. RDS type: numeric (double).
- Description: County centroid latitude.
- Research area: Shared identification / validation.
- Interpretation / limitation: Source labels or coordinates retained without geographic recoding.

## 6. `longitude`

- Origin: source variable, County column **G**, Excel position 7 (zero-based 6).
- Original row-5 heading: `longitude`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: Decimal degrees. RDS type: numeric (double).
- Description: County centroid longitude.
- Research area: Shared identification / validation.
- Interpretation / limitation: Source labels or coordinates retained without geographic recoding.

## 7. `population`

- Origin: source variable, County column **I**, Excel position 9 (zero-based 8).
- Original row-5 heading: `population`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: Persons. RDS type: numeric (double).
- Description: Total population, 2012-2016 ACS five-year estimate.
- Research area: Shared identification / validation.
- Interpretation / limitation: ACS five-year estimate, not a single-date census count.

## 8. `employment_count`

- Origin: source variable, County column **K**, Excel position 11 (zero-based 10).
- Original row-5 heading: `employment`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: Employees. RDS type: numeric (double).
- Description: Total employment, 2016 County Business Patterns; not unemployment.
- Research area: Shared identification / validation.
- Interpretation / limitation: Employment count is not an unemployment rate and must not be converted into one.

## 9. `climate_zone`

- Origin: source variable, County column **M**, Excel position 13 (zero-based 12).
- Original row-5 heading: `doe_climate_zone`.
- Sector/fuel: Geographic / demographic. Rows 1 and 4 are blank in this selected column.
- Units: Category code. RDS type: factor (unordered; levels 1–8).
- Description: DOE Building America climate-zone code; unordered categorical.
- Research area: Person 2: climate.
- Interpretation / limitation: Unordered R factor with levels 1–8. Workbook does not supply a code-to-descriptive-label table. Do not impose equal spacing or ordered-factor contrasts.

## 10. `res_elec_mwh`

- Origin: source variable, County column **O**, Excel position 15 (zero-based 14).
- Original row-5 heading: `consumption (MWh)`.
- Sector/fuel: Residential > Electricity. Rows 1 and 4 are blank in this selected column.
- Units: MWh. RDS type: numeric (double).
- Description: Modeled total residential electricity consumption.
- Research area: Person 3: electricity prices.
- Interpretation / limitation: Modeled estimate, not purely metered county consumption.

## 11. `res_elec_spend_kusd`

- Origin: source variable, County column **P**, Excel position 16 (zero-based 15).
- Original row-5 heading: `expenditures ('000 $)`.
- Sector/fuel: Residential > Electricity. Rows 1 and 4 are blank in this selected column.
- Units: Thousands of USD. RDS type: numeric (double).
- Description: Modeled total residential electricity expenditure.
- Research area: Person 3: electricity prices.
- Interpretation / limitation: Thousands of USD. Multiply by 1000 only when calculating USD/MWh.

## 12. `res_elec_mwh_pc`

- Origin: source variable, County column **Q**, Excel position 17 (zero-based 16).
- Original row-5 heading: `consumption (MWh/capita)`.
- Sector/fuel: Residential > Electricity. Rows 1 and 4 are blank in this selected column.
- Units: MWh/person. RDS type: numeric (double).
- Description: Modeled residential electricity consumption per resident.
- Research area: Persons 1 and 2: response.
- Interpretation / limitation: Keep source per-capita estimate. Do not substitute for total MWh in the price denominator.

## 13. `res_gas_mcf_pc`

- Origin: source variable, County column **V**, Excel position 22 (zero-based 21).
- Original row-5 heading: `consumption (Mcf/capita)`.
- Sector/fuel: Residential > Natural Gas. Rows 1 and 4 are blank in this selected column.
- Units: Mcf/person. RDS type: numeric (double).
- Description: Modeled residential natural gas consumption per resident.
- Research area: Person 1: energy consumption.
- Interpretation / limitation: Mcf means thousand cubic feet. Nine stored numerical zeros are genuine values; their Excel format displays dashes.

## 14. `occupied_housing_units`

- Origin: source variable, County column **Y**, Excel position 25 (zero-based 24).
- Original row-5 heading: `occuped housing units`.
- Sector/fuel: Residential. Rows 1 and 4 are blank in this selected column.
- Units: Housing units. RDS type: numeric (double).
- Description: Occupied housing units or households; fractional source values retained.
- Research area: Shared identification / validation.
- Interpretation / limitation: Source heading misspells occupied as occuped. Source has substantial fractional counts in 111 counties at tolerance 0.0001 unit and smaller floating-point residues elsewhere. Retained unchanged as numeric.

## 15. `gasoline_gal_pc`

- Origin: source variable, County column **AQ**, Excel position 43 (zero-based 42).
- Original row-5 heading: `consumption (gallons/capita)`.
- Sector/fuel: On Road Transportation > Gasoline. Rows 1 and 4 are blank in this selected column.
- Units: Gallons/person. RDS type: numeric (double).
- Description: Modeled on-road gasoline consumed within jurisdiction per resident.
- Research area: Person 1: energy consumption.
- Interpretation / limitation: Jurisdictional on-road fuel usage per resident, not fuel purchases or household driving. Small populations can yield extreme ratios.

## 16. `vmt_miles_pc`

- Origin: source variable, County column **AU**, Excel position 47 (zero-based 46).
- Original row-5 heading: `vehicle miles traveled (miles/capita)`.
- Sector/fuel: On Road Transportation. Rows 1 and 4 are blank in this selected column.
- Units: Miles/person. RDS type: numeric (double).
- Description: Modeled on-road vehicle miles within jurisdiction per resident.
- Research area: Person 1: energy consumption.
- Interpretation / limitation: Jurisdictional on-road mileage per resident, not resident-only travel. Small populations can yield extreme ratios.

## 17. `egrid_subregion`

- Origin: source variable, County column **FI**, Excel position 165 (zero-based 164).
- Original row-5 heading: `egrid_primary_subregion`.
- Sector/fuel: Emissions factors > Electricity. Rows 1 and 4 are blank in this selected column.
- Units: eGRID code. RDS type: character.
- Description: Primary eGRID subregion assigned to county.
- Research area: Person 3: electricity prices.
- Interpretation / limitation: Stored as character. Assigned primary subregion does not describe all local generation or utilities.

## 18. `elec_co2e_tons_per_mwh`

- Origin: source variable, County column **FJ**, Excel position 166 (zero-based 165).
- Original row-5 heading: `CO2 equivalent total output emission rate (mton/MWh)`.
- Sector/fuel: Emissions factors > Electricity. Rows 1 and 4 are blank in this selected column.
- Units: Metric tons CO2e/MWh. RDS type: numeric (double).
- Description: Average electricity CO2-equivalent output emissions intensity.
- Research area: Person 3: electricity prices.
- Interpretation / limitation: County FJ already uses metric tons/MWh; eGRID reference uses lb/MWh. Preserve County rates. Counties within a subregion share this predictor.

## 19. `res_elec_price_usd_mwh`

- Origin: derived variable, using County O (Excel 15) and P (Excel 16).
- Formula: `1000 * res_elec_spend_kusd / res_elec_mwh` = P × 1000 / O.
- Units: USD/MWh. RDS type: numeric (double).
- Calculate only for finite nonmissing O > 0 and finite nonmissing P >= 0. Missing/nonpositive denominators or missing/negative expenditures yield NA and a diagnostic. No such cases occur here.
- Interpretation: estimated average residential electricity expenditure per MWh. This is not a directly observed utility tariff or household-specific price.
- Research area: Person 3 response. Source O and P remain unchanged. Full calculated precision is retained.

## Future predictors absent from this output

`median_household_income` (Census ACS), `unemployment_rate_pct` (BLS LAUS), and `rucc_2013` (USDA ERS) remain unavailable and have not been added, retrieved, inferred, or merged. Use `county_fips` after checking external geography and vintage. Candidate later sources are 2016 ACS five-year income, 2016 annual-average unemployment, and 2013 RUCC.
