# STAT525_Project

Shared STAT 525 analysis project. Topic assignments are placeholders until the team agrees on ownership.

## Project structure

```text
STAT525_Project.Rproj
data/
  README.md
  cleaned_data.rds          # Generated after data preparation; not included yet
R/
  00_data_preparation.R     # Shared
  01_energy_consumption.R   # Saad
  02_economic_factors.R     # Aiden
  03_electricity_prices.R   # Ray
progress_report.Rmd
TEAM_SETUP.md
.gitignore
```

## Get started

Follow [TEAM_SETUP.md](TEAM_SETUP.md), then open `STAT525_Project.Rproj`.
Use paths relative to the project root, such as `readRDS("data/cleaned_data.rds")`.
Add the data import and cleaning code to `R/00_data_preparation.R` before running analyses.
Record data sources and required packages as the project develops.

To knit the report, install `rmarkdown` once with `install.packages("rmarkdown")`, then open `progress_report.Rmd` and select **Knit**.

## Working together

Pull before starting, coordinate edits to shared files, and commit and push small changes with clear messages.
Agree on who edits `00_data_preparation.R` and `progress_report.Rmd` to reduce conflicts.
If Git reports a conflict, coordinate with the teammate who edited the file before resolving it.

Collaborator invitations have not been sent. The owner can add teammates under **Settings → Collaborators** after receiving their GitHub usernames.
