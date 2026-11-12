# Ray: run from STAT525_Project.Rproj (project root).
county <- readRDS("data/cleaned_data.rds")

# Response: res_elec_price_usd_mwh (estimated expenditure USD/MWh, not a tariff).
# Available predictor: elec_co2e_tons_per_mwh; context: egrid_subregion.
# Future categorical predictor: rucc_2013 (codes 1-9, unordered by default).
# Emissions rates are shared within eGRID subregions, not independently measured
# county-specific rates. Account for this limitation in later interpretation.

# TODO: Begin exploratory price/emissions work using baseline data.
# TODO: Add reviewed USDA 2013 RUCC following data/external/README.md.
# After the common final merge, explicitly switch to:
# county <- readRDS("data/county_with_external.rds")
# TODO: Inspect missingness, form model-specific complete cases, then model later.



# Part A: Data exploration and initial modeling The goal is to understand the data and prepare for multivariate
# linear regression. The draft should include:
#   • distributions of Y and each predictor (e.g., histograms/boxplots);
# • scatterplots of Y versus quantitative predictors and appropriate visual summaries for categorical predictors;
# • discussion of potential outliers or extreme values;
# • assessment of whether transformations of Y or predictors may be needed (including nonlinear terms such as X2
#                                                                           when appropriate);
# • correlation analysis among quantitative predictors and discussion of potential multicollinearity;
# • simple linear regressions of Y on meaningful predictors and a brief check of key assumptions; if issues are found,
# propose remedies (e.g., transformation, alternative specification, or careful treatment of unusual observations).
# Part B: Deeper analysis and preliminary conclusions This section should summarize what has been done
# beyond exploratory summaries. It should include:
#   • analyses beyond simple linear regression (e.g., candidate multiple regression models);
# • key statistical findings (tables/figures as needed) and subject-matter interpretations


#part A: exploratory analysis
library(dplyr)
library(stringr)
county <- readRDS("data/cleaned_data.rds")
rucc_2013 <- read.csv("data/external/usda_rucc_2013.csv")
rucc_2013 <- rename(rucc_2013, county_fips = FIPS) |>
  mutate(county_fips = str_pad(trimws(county_fips), width = 5, side = "left", pad = "0"))

county <- left_join(county, rucc_2013, by = "county_fips")

#distributions of Y and predictors
library(ggplot2)
library(patchwork)

bar_col <- "#2F6B9A"

theme_set(
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(color = "grey90"),
      plot.title         = element_text(size = 11, face = "bold"),
      axis.title         = element_text(color = "grey30")
    )
)

#Y: electricity price
p1 <- ggplot(county, aes(x = res_elec_price_usd_mwh)) +
  geom_histogram(bins = 30, fill = bar_col, color = "white", linewidth = 0.3,
                 na.rm = TRUE) +
  labs(title = "Residential electricity price",
       x = "USD per MWh", y = "Number of counties")

#x1: co2 intensity
p2 <- ggplot(county, aes(x = elec_co2e_tons_per_mwh)) +
  geom_histogram(bins = 30, fill = bar_col, color = "white", linewidth = 0.3,
                 na.rm = TRUE) +
  labs(title = "Electricity CO2e intensity",
       x = "Tons CO2e per MWh", y = NULL)

#x2: RUCC
p3 <- ggplot(county, aes(x = factor(RUCC_2013))) +
  geom_bar(fill = bar_col, color = "white", linewidth = 0.3, width = 0.9) +
  labs(title = "Rural-Urban Continuum Code (2013)",
       x = "RUCC (1 = most urban, 9 = most rural)", y = NULL)

p1 + p2 + p3 +
  plot_annotation(title = "Distributions for US Counties")


#scatter plots
pt_col = "#2F1B9A"
p3 <- ggplot(county, aes(x = elec_co2e_tons_per_mwh, y = res_elec_price_usd_mwh)) +
  geom_point(color = pt_col, alpha = 0.4, size = 1.5, na.rm = TRUE) +
  labs(title = "Price vs. CO2e intensity",
       x = "Tons CO2e per MWh", y = "Residential price (USD per MWh)")


p4 <- ggplot(county, aes(x = RUCC_2013, y = res_elec_price_usd_mwh)) +
  geom_point(width = 0.2, height = 0, color = pt_col, alpha = 0.35,
              size = 1.5, na.rm = TRUE) +
  scale_x_continuous(breaks = 1:9) +
  labs(title = "Price vs. Rural-Urban Continuum Code (2013)",
       x = "RUCC",
       y = "Residential price (USD per MWh)")

p3 + p4

#simple linear regression with each predictor
fit_co2 <- lm(res_elec_price_usd_mwh ~ elec_co2e_tons_per_mwh, data = county)
fit_rucc <- lm(res_elec_price_usd_mwh ~ RUCC_2013, data = county)

#diagnostic plots

plot(fit_co2)
plot(fit_rucc)

#note: there is only

#discussion
#the primary issue seen in the diagnostic plots is non-normality.
#both simple linear regression fits showed Q-Q plots where the points deviate on the right-hand side of the plot
#this shows the predictors are not normally distributed
#this suggests transformations would be useful
#the other 3 diagnostic plots illustrate:
  # good linearity (residuals vs fitted),
  # homoskedasticity (scale-location)
  # no influential points/outliers (residuals vs leverage)

#we will try a log transformation of Y and see if that improves the plots
fit_co2_log <- lm(log(res_elec_price_usd_mwh) ~ elec_co2e_tons_per_mwh, data = county)
fit_rucc_log <- lm(log(res_elec_price_usd_mwh) ~ RUCC_2013, data = county)
plot(fit_co2_log, which = 2)
plot(fit_rucc_log, which = 2)

#the q-q plot is showing some non-normality still, but there is some improvement
#this suggests that a transformation of Y was helpful to meet our normality assumption

#part B: deeper analysis and preliminary conclusions

#candidate multiple regression model:
fit_price <- lm(log(res_elec_price_usd_mwh) ~ elec_co2e_tons_per_mwh + RUCC_2013, data = county)
#the log transformation of Y that improved the q-q plot is used
#both predictors are combined in a multiple regression model

#comparison of coefficients and significance for simple regression models and multiple regression model
coef(summary(fit_co2_log))
coef(summary(fit_rucc_log))
coef(summary(fit_price))

#preliminary conclusions:
#negative correlations observed between price and CO2 and price and RUCC for all models
#CO2 and RUCC were significant in both types of models, using a t-test at the alpha=0.05 level
#in the context of the problem:
  #As CO2 intensity of electric generation increases, energy price decreases
  #As a county becomes more rural, energy price decreases

