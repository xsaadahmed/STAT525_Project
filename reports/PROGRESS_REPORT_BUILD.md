# Building the shared progress report

Main document: `reports/progress_report_shared_draft.tex`.
Included tables/figures are committed under `reports/progress_assets/saad/` and
`reports/progress_assets/ray/`.
No personal paths, network downloads, R installation, original workbook or .bib
file are needed to compile this report. Keep relative paths and filenames intact.

## Local build

From repository root with pdfLaTeX installed:

```
pdflatex -interaction=nonstopmode -halt-on-error reports/progress_report_shared_draft.tex
pdflatex -interaction=nonstopmode -halt-on-error reports/progress_report_shared_draft.tex
```

Alternatively `cd reports` and run the same commands with
`progress_report_shared_draft.tex`. Two passes resolve table/figure references.
Use a scratch output directory if you do not want auxiliary files in the root.
Do not commit generated PDF, .aux, .log or .out files.

## Overleaf

Upload `progress_report_shared_draft.tex` and the entire `progress_assets/` folder,
keeping that folder next to the main .tex file. Set the main document explicitly
and choose pdfLaTeX. Uploading the TeX file alone will not include its assets.
The supplied Overleaf ZIP contains exactly this layout plus these instructions.
GitHub users can also download the repository ZIP and upload the same subset.

## Regenerating report assets (optional; not needed to compile)

From repository root with base R:

```
Rscript R/build_saad_progress_assets.R
Rscript R/validate_energy_analysis.R
Rscript R/build_ray_progress_assets.R
Rscript R/validate_ray_prices.R
```

The asset builder evaluates the existing analysis function and runs it into a
fresh temporary directory, then formats selected fitted results and redraws the
two report figures. It does not overwrite the accepted data, existing full
analysis outputs or individual report. The three .tex tables contain selected
summary statistics, simple-regression OLS inference, and five-model comparison.
The included distributions use original gas/electricity and log10 gasoline;
the relationship plots use full-data OLS/LOWESS, with a precisely bounded gasoline
99th-percentile viewport. Full numerical and diagnostic outputs remain in the
original Saad contribution.

## Current review and submission status

This is a partial group draft: Saad's and Ray's selected Part A/B content is
inserted; Aidan's placeholders and the integrated conclusion still need completion.
Current local compile: six pages, Part A three and Part B three (references included).
The compact title has no date or names; body/captions use impersonal academic prose.
Heading/float spacing is reduced while retaining 11-point type and one-inch margins.
Remove remaining placeholders and recheck each four-page part limit as economic
and climate results are integrated.
This is not a promise about the final count after new content is added. Each part
must remain at most four pages and the total at most eight. Remove every visible
blue Pending note before submission. Keep actual data, sample and uncertainty
statements and the AI-use disclosure accurate.

Validation performed: independent existing energy and price audits passed; assets regenerated
from fitted objects; root and isolated Overleaf-layout builds tested with pdfLaTeX;
final PDF pages visually checked; no overfull boxes or undefined references. All
four numbered tables/three figures are present. Pre-existing R locale startup
warnings occurred; there were no numerical errors. No individual or teammate
analysis files or accepted data were changed.

See `docs/progress_report_editing_plan.md` for the selection and further-cut plan.

Ray's builder refits the six raw/log formulas directly from baseline and canonical
RUCC and checks coefficients against the independently audited full outputs. It
then writes a compact six-model TeX table and a five-panel exploratory figure.
It changes neither the full analysis outputs nor canonical data. Ray's selected
conditional inference and sensitivity numbers come from the audited full tables;
region-cluster results are explicitly distinguished from classical OLS. RUCC is
categorical, not an equally spaced ruralness score. The two historical unmatched
FIPS and model samples are stated in the shared opening.
