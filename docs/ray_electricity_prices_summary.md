# Ray: corrected electricity-price analysis

## Scope and reproduction

Questions: how is modeled residential electricity expenditure per MWh associated
with electricity CO2e intensity and USDA 2013 Rural-Urban Continuum Code (RUCC)?
Run `Rscript R/03_electricity_prices.R`, then `Rscript R/validate_ray_prices.R`
from the project root. Both use base R. No common enriched-data merge is needed.
The accepted NREL baseline and other teammates' work are unchanged.

The supplied RUCC file is now committed in the agreed two-column canonical format.
`R/prepare_usda_rucc.R` reproduces it from the original user upload in the ignored
`data/external/downloads/` directory. Six entirely blank rows are removed; 3,234
unique valid FIPS remain, including two missing territorial codes. No nonblank
record is arbitrarily deduplicated. Raw-upload SHA-256:
`87ce0c8ae960e79e4c147d1a1edeb942b626094c67e4e127738012aa38d9fe50`.
Provenance is the supplied USDA-2013-labelled file, not an independent source
redownload or an assertion that every source row was externally authenticated.

All 3,142 baseline counties enter emissions-only fits. Two lack a direct RUCC
match: Kusilvak Census Area, AK (02158), and Oglala Lakota County, SD (46102).
Their historical identifiers are not automatically remapped. RUCC-only/joint fits
use the 3,140 complete counties; no response outlier is deleted from primary fits.

## What changed

RUCC is an unordered nine-level factor, with code 1 the reference, giving eight
contrasts. Codes 1-3 describe metro areas and 4-9 nonmetro categories; they do not
form an equally spaced quantitative ruralness scale. Boxplots replace its numeric
scatterplot. Overall RUCC association is assessed with an eight-df classical
nested-model F test, not a one-df numeric trend t-test. Outputs preserve both raw
price and log-price candidates, along with full diagnostic plots.

Q-Q plots assess **residuals**, not predictor normality. Logging the positive
response compresses the long high-price tail; it does not establish that regression
assumptions are met. R-squared and residual SE on raw and log response scales are
not directly comparable measures for selecting a response transformation.

## Computed results and corrected interpretations

| Model | n | R-squared | Residual SE (response scale) |
| --- | ---: | ---: | ---: |
| Price ~ emissions | 3142 | 0.03406 | 26.6733 USD/MWh |
| Price ~ categorical RUCC | 3140 | 0.01086 | 26.9949 USD/MWh |
| Price ~ emissions + categorical RUCC | 3140 | 0.04169 | 26.5751 USD/MWh |
| ln(price) ~ emissions | 3142 | 0.02106 | 0.18472 log units |
| ln(price) ~ categorical RUCC | 3140 | 0.01229 | 0.18558 log units |
| ln(price) ~ emissions + categorical RUCC | 3140 | 0.02975 | 0.18397 log units |

In the joint log model, the emissions coefficient is -0.18605 per metric ton
CO2e/MWh (classical 95% CI -0.23465 to -0.13744; p < 0.001). A 0.1 metric-ton/MWh
higher emissions rate corresponds to about 1.84% lower fitted **geometric mean**
expenditure per MWh at fixed RUCC, not a causal decrease in utility tariffs.

However, emissions rates repeat across only 26 eGRID subregions. An exploratory
region-cluster variance sensitivity calculation (CR1, t reference with 25 df)
gives a much wider coefficient interval, -0.67534 to +0.30325, and p=0.441.
The classical county-level p-value therefore should not support a confident
significance claim. This sensitivity assumes independent clusters and does not
resolve geographic dependence between regions; 26 groups also limits precision.

The classical RUCC block F test in the joint log model is F(8,3130)=3.678,
p=0.000279. This is exploratory independent-error inference, not a cluster-robust
omnibus conclusion. Category effects must be described relative to code 1:
for example code 8 is -0.06344 log units, about 6.15% lower fitted geometric mean
expenditure, at fixed emissions. Effects are **not monotonic across codes**, so
"price decreases as a county becomes more rural" is not justified. Inspect the
full coefficient table and its cluster sensitivity intervals; eight separate
contrasts are not eight prespecified independent discoveries.

## Diagnostics and influence

The joint log diagnostic panels still show a curved residual smoother, changing
spread and substantial Q-Q tail departures. The fitted-value BP-style auxiliary
p-value is below 0.001; 40 counties have absolute externally studentized residuals
above 3 and 172 exceed the Cook's D > 4/n screening threshold. These flags do not
prove data errors. Kauai County, HI (15007), Hawaii County, HI (15001), and Northwest
Arctic Borough, AK (02188) have the largest Cook's distances. The largest is 0.0361.

Omitting Kauai alone leaves the emissions slope nearly unchanged (-0.18614).
Omitting all 172 Cook-screen cases leaves 2,968 counties and changes the emissions
slope to +0.04213. This selected-sample diagnostic demonstrates material sensitivity;
it is not evidence to delete valid counties or replace the full-sample conclusion.
There is no basis for claiming no influential observations or satisfied assumptions.

## Group-report use and limitations

Use `distributions.png`, `relationships.png`, the small model-comparison table,
and selected joint-model diagnostics. All figures and full-precision tables are
under `outputs/ray_electricity_prices/`. The log joint model remains a provisional
descriptive candidate, not a validated final model. Explain weak explanatory power,
RUCC contrasts, geographic clustering and the influence sensitivity rather than
claiming both predictors are definitively significant.

The response is estimated average residential expenditure per MWh, not a directly
observed tariff. Historical modeled estimates, geographic mismatches, confounding,
regional price structure and repeated emissions rates restrict interpretation.
No causal claim or monotonic RUCC trend is supported. Keep this contribution
compact within the group's four-page Part A and four-page Part B limits.

Generative AI assisted in correcting code, executing checks and drafting these
notes. Ray should review the analysis and interpretations; no independent student
review is claimed. Sources: NREL baseline documentation, the user-supplied USDA
2013 RUCC CSV, and the project's external-data guide. These notes do not replace
Ray's independently written final report.
