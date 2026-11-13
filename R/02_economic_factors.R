# Run from STAT525_Project.Rproj. The companion Rmd sources this script.
source("R/00_merge_external_data.R", local = TRUE)
county <- readRDS("data/cleaned_data.rds")

income <- read_canonical_external("data/external/acs_income_2016.csv",
                                  "median_household_income")
unemp <- read_canonical_external("data/external/bls_unemployment_2016.csv",
                                 "unemployment_rate_pct")

climate_path <- "data/external/nanda_degree_days_2016.csv"
if (!file.exists(climate_path)) {
  stop("Generate the local climate CSV first: source('R/prepare_nanda_climate.R')")
}

climate <- read.csv(
  climate_path,
  na.strings = c("", "NA"),
  colClasses = c(county_fips = "character", hdd65 = "numeric", cdd65 = "numeric")
)

stopifnot(
  all(c("county_fips", "hdd65", "cdd65") %in% names(climate)),
  !anyNA(climate$county_fips),
  all(grepl("^[0-9]{5}$", climate$county_fips)),
  !anyDuplicated(climate$county_fips),
  !anyDuplicated(county$county_fips)
)

# One lookup per baseline county preserves the original county order.
weather_row <- match(county$county_fips, climate$county_fips)
income_row <- match(county$county_fips, income$county_fips)
unemp_row <- match(county$county_fips, unemp$county_fips)

# Scale the predictors into units we can interpret in the report.
county$hdd100 <- climate$hdd65[weather_row] / 100
county$cdd100 <- climate$cdd65[weather_row] / 100
county$income10k <- income$median_household_income[income_row] / 10000
county$unemployment <- unemp$unemployment_rate_pct[unemp_row]

labels <- c(
  hdd100 = "HDD (100 degree-days)",
  cdd100 = "CDD (100 degree-days)",
  income10k = "Median income ($10,000s)",
  unemployment = "Unemployment (%)"
)
xvars <- names(labels)
yvar <- "res_elec_mwh_pc"

# Part A: fit one simple regression per predictor.
# Each fit uses all counties with that predictor and the response.
simple <- lapply(xvars, function(x) {
  lm(reformulate(x, response = yvar), data = county, na.action = na.omit)
})
names(simple) <- xvars

simple_table <- do.call(rbind, lapply(xvars, function(x) {
  fit <- simple[[x]]
  ci <- confint(fit, x)

  data.frame(
    Predictor = unname(labels[x]),
    N = nobs(fit),
    Slope = unname(coef(fit)[x]),
    Lower = ci[1],
    Upper = ci[2],
    R2_pct = 100 * summary(fit)$r.squared,
    Residual_SE = sigma(fit)
  )
}))

# Two checks on the straight-line specification.
log_income <- lm(res_elec_mwh_pc ~ log(income10k), data = county)
cdd_curve <- lm(res_elec_mwh_pc ~ cdd100 + I(cdd100^2), data = county)

# Part B: fit both candidate models on exactly the same counties.
joint <- county[complete.cases(county[c(yvar, xvars)]), ]

econ <- lm(res_elec_mwh_pc ~ income10k + unemployment, data = joint)
full <- lm(res_elec_mwh_pc ~ income10k + unemployment + hdd100 + cdd100,
           data = joint)

correlations <- cor(joint[xvars])
adjusted_ci <- confint(full)[xvars, , drop = FALSE]

adjusted_table <- data.frame(
  Predictor = unname(labels),
  Slope = unname(coef(full)[xvars]),
  Lower = adjusted_ci[, 1],
  Upper = adjusted_ci[, 2],
  row.names = NULL
)

# Keep every eligible county in the main fit. Refit once to check how much
# the CDD slope depends on the county with the largest Cook's distance.
influential <- which.max(cooks.distance(full))
without_one <- update(full, data = joint[-influential, ])

# Figures 1 and 2: distributions and response-versus-predictor relationships.
plot_panel <- function(kind = c("hist", "scatter")) {
  kind <- match.arg(kind)
  old <- par(mfrow = c(2, 2), mar = c(3.6, 3.9, 1.9, 0.8),
             mgp = c(2.3, 0.7, 0))
  on.exit(par(old))

  y <- county[[yvar]]

  for (x in xvars) {
    keep <- complete.cases(county[[x]], y)
    v <- county[[x]][keep]
    title <- paste("n =", format(sum(keep), big.mark = ","))

    if (kind == "hist") {
      hist(v, breaks = 25, xlab = labels[x], ylab = "Counties", main = title,
           col = "lightblue", border = "white")
    } else {
      plot(v, y[keep],
           xlab = labels[x], ylab = "Electricity (MWh/person)", main = title,
           ylim = range(y, na.rm = TRUE), pch = 16, cex = 0.55,
           col = adjustcolor("steelblue4", alpha.f = 0.35))
      abline(simple[[x]], col = "firebrick", lwd = 2)
      lines(lowess(v, y[keep]), col = "black", lty = 2, lwd = 2)
    }
  }
}

# Supporting diagnostics: each column is a model. The top row checks shape
# and spread; the bottom row checks the tails of the residual distribution.
plot_checks <- function() {
  fits <- c(simple, list(joint = full))
  names(fits) <- c("HDD", "CDD", "Income", "Unemployment", "Joint model")

  old <- par(mfcol = c(2, length(fits)), mar = c(3.3, 3.2, 1.8, 0.5),
             mgp = c(2.1, 0.6, 0))
  on.exit(par(old))

  for (nm in names(fits)) {
    plot(fits[[nm]], which = 1, main = nm, caption = "", sub.caption = "",
         id.n = 0, pch = 16, cex = 0.35, col = "#38597266")
    plot(fits[[nm]], which = 2, caption = "", sub.caption = "",
         id.n = 0, pch = 16, cex = 0.35, col = "#38597266")
  }
}

# Save the two figures the group can use in its shared report.
out <- "outputs/aidan_economic_factors"
dir.create(out, recursive = TRUE, showWarnings = FALSE)

for (kind in c("hist", "scatter")) {
  png(file.path(out, paste0(kind, ".png")),
      width = 8, height = 5.3, units = "in", res = 160)
  tryCatch(plot_panel(kind), finally = dev.off())
}
