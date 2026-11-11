# STAT 525: County energy consumption and electricity prices

UMass Amherst Applied Regression project studying relationships among county energy use, economic characteristics, climate, electricity expenditures and emissions. See the [proposal](docs/project_proposal.md) for research questions.

The validated **3,142-county, 19-column NREL baseline is ready to use**. It contains 18 source variables and one derived residential electricity-price variable. ACS income, BLS unemployment and USDA RUCC are **planned and not integrated**. Exploratory analysis, regressions and conclusions remain to be done.

## Team responsibilities

| Teammate | Research responsibility | Primary file |
| --- | --- | --- |
| Saad | Electricity consumption versus natural gas and gasoline use | [R/01_energy_consumption.R](R/01_energy_consumption.R) |
| Aidan | Economic factors and climate | [R/02_economic_factors.R](R/02_economic_factors.R) |
| Ray | Electricity prices, emissions and rural–urban classification | [R/03_electricity_prices.R](R/03_electricity_prices.R) |

## Data and documentation

Source: [NREL City and County Energy Profiles, corrected workbook](https://data.openei.org/submissions/149), County worksheet only. Sources are mainly 2016-oriented: population/housing use 2012–2016 ACS five-year estimates, employment uses 2016 County Business Patterns, and emissions use 2016 eGRID. The workbook was completed in December 2019.

- [Data dictionary](docs/data_dictionary.md): all 19 names, source columns, units and types.
- [Cleaning and QA report](docs/cleaning_report.md): actual checks, source exceptions and original file hashes.
- [Data README](data/README.md): formats, price formula and optional reproduction.
- [External-data guide](data/external/README.md): agreed schemas and safe future joins.
- [Team setup](TEAM_SETUP.md): beginner RStudio/Git instructions.

## Quick start

Clone this repository through RStudio **File → New Project → Version Control → Git**, using `https://github.com/xsaadahmed/STAT525_Project.git`, then open `STAT525_Project.Rproj`. Run from the project root:

```r
county <- readRDS("data/cleaned_data.rds")
dim(county) # 3142 19
source("R/validate_cleaned_data.R")
```

Loading and validating the committed data needs **base R only**, not the original XLSB or archived `readxlsb` package. The RDS preserves character FIPS and an unordered climate factor. For an explicit FIPS-safe CSV alternative, see [TEAM_SETUP.md](TEAM_SETUP.md).

## Project files

```text
STAT525_Project.Rproj
README.md
TEAM_SETUP.md
.gitignore
progress_report.Rmd                  # Existing unfilled report template
R/
  00_data_preparation.R               # Accepted original-XLSB preparation, optional
  00_merge_external_data.R            # Future merge helpers; no automatic merge
  validate_cleaned_data.R             # Independent base-R checks
  01_energy_consumption.R             # Saad
  02_economic_factors.R               # Aidan
  03_electricity_prices.R             # Ray
data/
  README.md
  cleaned_county_data.csv
  cleaned_data.rds
  external/
    README.md
docs/
  project_proposal.md
  data_dictionary.md
  cleaning_report.md
```

`data/raw/` is a local ignored location for optional reproduction. The three canonical external CSVs and enriched outputs are not present yet. Their future paths and requirements are documented in [data/external/README.md](data/external/README.md).

## Adding external predictors

Aidan needs `acs_income_2016.csv` and `bls_unemployment_2016.csv`; Ray needs `usda_rucc_2013.csv`. Each goes under `data/external/` after authoritative-source, units, FIPS, geography and vintage checks. Commit the real canonical CSV plus provenance and preparation code in a coordinated change. Saad can start with baseline data; Aidan can begin climate work; Ray can begin price/emissions work now.

Defining the merge helpers is safe even while files are missing:

```r
source("R/00_merge_external_data.R")
# Only after ALL three real source files are reviewed and available:
# result <- merge_external_data()
```

An explicit final merge requires all three files, checks keys/types, reports unmatched FIPS, and preserves all baseline rows/order and missing external values. It writes separate 22-column `data/county_with_external.csv` and `.rds` files. It never overwrites the 19-column baseline. Independent one-source work is explained in the external-data guide.

## Collaboration

Pull before working. Edit your assigned analysis script primarily; coordinate before changing shared preparation, merge, validation, README or report files. Review diffs, stage only intended files, commit with a clear message, and push a branch/open a pull request or use the team's agreed direct-push workflow. Never force-push or silently resolve another teammate's changes. See [TEAM_SETUP.md](TEAM_SETUP.md) for commands and Git-pane steps.

## Current limitations

Energy values are modeled estimates. The preserved source includes **111 substantial fractional housing-unit values**, **three Gazetteer name differences**, eight climate codes without a fully verified descriptive label mapping, and 26 eGRID subregions sharing emissions-rate values. Source vintages and county-equivalent boundaries require care in future joins. There are no missing baseline values; nine natural-gas zeros and four employment zeros are genuine. Electricity price is estimated expenditure per MWh, not a utility tariff. The detailed original findings remain unchanged in the QA report.

Original-data preparation was tested with **R 4.5.2 / readxlsb 0.1.61 on Windows**. That archived dependency is only needed to rebuild from XLSB; installation on other platforms is not guaranteed. Do not run preparation just to begin analysis.

The proposal and `progress_report.Rmd` remain unchanged. When ready to fill and knit the report, install `rmarkdown` with `install.packages("rmarkdown")`, open the Rmd and select **Knit**. No research results are claimed by the template.
