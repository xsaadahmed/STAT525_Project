# Building the shared progress report

Main document: `reports/progress_report_shared_draft.tex`.
The included Saad tables and figures are committed under `reports/progress_assets/saad/`.
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

## Regenerating Saad's assets (optional; not needed to compile)

From repository root with base R:

```
Rscript R/build_saad_progress_assets.R
Rscript R/validate_energy_analysis.R
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

This is a partial group draft: Saad's selected Part A/B content is inserted;
Aidan/Ray placeholders and the integrated conclusion still need completion.
Current local compile: five pages, Part A three and Part B two (references included).
This is not a promise about the final count after new content is added. Each part
must remain at most four pages and the total at most eight. Remove every visible
blue Pending note before submission. Keep actual data, sample and uncertainty
statements and the AI-use disclosure accurate.

Validation performed: independent existing energy audit passed; assets regenerated
from fitted objects; root and isolated Overleaf-layout builds tested with pdfLaTeX;
final PDF pages visually checked; no overfull boxes or undefined references. All
three numbered tables/two figures are present. Pre-existing R locale startup
warnings occurred; there were no numerical errors. No individual or teammate
analysis files or accepted data were changed.

See `docs/progress_report_editing_plan.md` for the selection and further-cut plan.
