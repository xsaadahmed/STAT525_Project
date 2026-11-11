# STAT 525 Project Proposal

**Ray, Saad, Aidan**

## Project Goals

The goal of our project is to examine how electricity consumption and electricity prices are related to other energy, economic, and community characteristics across U.S. cities and counties. We are particularly interested in whether electricity consumption is associated with natural gas and gasoline consumption, as well as economic indicators such as income and unemployment rate. We also plan to explore whether electricity prices differ based on rural or urban status and whether there is a relationship between electricity-related emissions and electricity prices. From these areas, we will select a smaller set of research questions to investigate in greater depth using linear regression.

## Research Questions

- Is there a relationship between natural gas consumption and electricity consumption?
- Is there a relationship between gasoline consumption and electricity consumption?
- Are measures of economic success (income, unemployment rate, etc.) correlated with electricity consumption?
- Is rural/urban status correlated with electricity price?
- Is there a relationship between electricity emissions and electricity price?
- Is there a relationship between climate and energy consumption?

## Description of Dataset

The dataset we are using for this project is the City and County Energy Profiles dataset created by Megan Day at the National Renewable Energy Laboratory (NREL) and published through the Open Energy Data Initiative (OEDI). We will specifically use the `City and County Energy Profiles Corrected.xlsb` file, which corrects natural gas unit-labeling errors in the original version. The dataset provides modeled estimates of electricity and natural gas consumption and expenditures, on-road vehicle fuel consumption, vehicle miles traveled, and associated emissions for U.S. cities and counties.

Source: [City and County Energy Profiles](https://data.openei.org/submissions/149)

## Response and Predictor Variables

- **Response variables:** residential electricity consumption per capita (MWh/capita), residential electricity price ($/MWh)
- **Predictor variables:** residential natural gas consumption per capita (Mcf/capita), on-road gasoline consumption per capita (gal/capita), median income ($), unemployment rate (%), rural-urban continuum code (an ordered qualitative variable with codes 1–9), CO₂ equivalent total output emission rate from electricity (mton/MWh)

## Why This Question Is Important

Understanding the relationships between energy consumption and economic status is important for making impactful energy policy decisions. The relationships can provide insights into energy demand and affordability in communities across the country. Furthermore, exploring how energy use relates to emissions could help with increasing efficiency and reducing environmental impact.
