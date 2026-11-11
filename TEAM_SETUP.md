# Team setup and daily workflow

## First setup

1. Install [R](https://cran.r-project.org/).
2. Install [RStudio Desktop](https://posit.co/download/rstudio-desktop/).
3. Install [Git](https://git-scm.com/downloads) if it is not already available. Restart RStudio after installing it. If the Git pane is absent, check **Tools → Global Options → Git/SVN** and its Git executable setting.
4. In RStudio choose **File → New Project → Version Control → Git**.
5. Enter `https://github.com/xsaadahmed/STAT525_Project.git`, choose a local directory, and select **Create Project**. Authenticate with GitHub if prompted. Writing requires repository permission; this guide does not assert anyone's invitation status.
6. Open `STAT525_Project.Rproj` whenever returning to the project. Paths below assume the project root. Do not use `setwd()` with a personal absolute path in shared scripts.

## Load and check the existing data

Run in the R console:

```r
county <- readRDS("data/cleaned_data.rds")
dim(county) # 3142 observations, 19 variables
names(county)
summary(county)
source("R/validate_cleaned_data.R")
```

These commands need base R only. You do not need to install `readxlsb`, download XLSB, or run the preparation script. The validator reports success or stops with a meaningful error. The RDS preserves FIPS as character and climate zone as an unordered factor.

CSV alternative (FIPS explicitly character):

```r
county <- read.csv("data/cleaned_county_data.csv",
                   colClasses=c(county_fips="character", climate_zone="character"),
                   check.names=FALSE, na.strings="", fileEncoding="UTF-8")
county$climate_zone <- factor(county$climate_zone, levels=as.character(1:8),
                              ordered=FALSE)
stopifnot(nrow(county)==3142L, ncol(county)==19L,
          all(grepl("^[0-9]{5}$",county$county_fips)))
```

CSV cannot store factor classes. Spreadsheet programs may hide leading zeros when opening CSV, even though the file contains five-character FIPS. Use explicit R import types and avoid resaving the canonical data through a spreadsheet.

## Your analysis file

| Teammate | File | Ready now | Later input |
| --- | --- | --- | --- |
| Saad | `R/01_energy_consumption.R` | Electricity, gas, gasoline | None required |
| Aidan | `R/02_economic_factors.R` | Electricity and climate | 2016 ACS income / BLS unemployment |
| Ray | `R/03_electricity_prices.R` | Price and electricity emissions | USDA 2013 RUCC |

The three starter scripts load baseline data and list TODOs. They perform no analysis yet. See [external data instructions](data/external/README.md) before preparing any canonical external CSV. Coordinate before editing shared preparation/merge code or baseline files. Existing housing fractions and other limitations are documented in [the QA report](docs/cleaning_report.md).

## Everyday Git workflow in RStudio

1. Open the project. In the **Git** pane select **Pull** before starting. If you have uncommitted work, save and review it first; do not discard it to make a pull work.
2. Edit primarily your assigned script. Coordinate before simultaneous edits to shared files.
3. Save the file. In the Git pane select it and open **Diff** to review changes.
4. Check **Staged** only for intended files. Do not stage raw workbooks, session files, secrets or scratch data.
5. Select **Commit**, enter a clear message, review the staged diff, and commit.
6. Select **Push** if using the agreed shared branch and permission allows. For larger changes, push a topic branch and open a GitHub pull request instead.
7. If push is rejected because the remote changed, fetch/pull and inspect together. If conflicts occur, coordinate with the teammate who edited the file; resolve intentionally and validate again. Never force-push.

Terminal equivalent for a small agreed direct change (replace the script with your assignment):

```sh
git status
git pull --ff-only
git diff -- R/01_energy_consumption.R
git add R/01_energy_consumption.R
git diff --cached
git commit -m "Describe the energy script change"
git push origin main
```

Topic branch / pull request alternative, starting from a clean, updated main:

```sh
git switch main
git pull --ff-only
git switch -c saad-energy-work
# Edit, save, review, then stage only your intended files.
git add R/01_energy_consumption.R
git diff --cached
git commit -m "Describe the energy script change"
git push -u origin saad-energy-work
```

On GitHub, open a pull request from that branch to `main`. Use a unique branch name for each change. Do not switch branches or pull over unreviewed local edits. If Git identity is missing, configure your own name/email rather than copying a teammate's identity.

## Optional original-workbook reproduction

This is separate from ordinary analysis. Put the untouched corrected workbook at the ignored local path `data/raw/original_workbook.xlsb`. Read the dependency/install comments in `R/00_data_preparation.R` first. It was tested on Windows with R 4.5.2 and archived `readxlsb` 0.1.61; other operating systems were not tested.

```r
# Optional: regenerates the two baseline files; coordinate with the team first.
# source("R/00_data_preparation.R")
```

Do not commit the roughly 36 MB workbook. Do not overwrite shared baseline data casually. Run `source("R/validate_cleaned_data.R")` and review all diffs after any intentional regeneration.

Reference: [Posit's RStudio version-control guide](https://docs.posit.co/ide/user/ide/guide/tools/version-control.html).
