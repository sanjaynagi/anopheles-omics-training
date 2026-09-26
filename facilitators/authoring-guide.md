# Authoring guide for module notebooks

Every module notebook follows the same structure as the MalariaGEN–PAMCA course
(`anopheles-genomic-surveillance.github.io`): theory and practical together in one notebook.

## Structure

1. **Colab badge** (first markdown cell):
   `[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/sanjaynagi/malaria-software-training/blob/main/<path/to/notebook.ipynb>)`
2. `# X.Y Title`, then `**Theme:** Theory | Analysis | Tools & technology`, then a short intro that links the module to the study (see `study-brief.md`) and to the previous module.
3. `## Learning objectives`: 3–5 bullets, starting "At the end of this module you will be able to:".
4. `## Setup`: pinned installs (`%pip install -q --no-warn-conflicts pkg==x.y.z`) and imports.
5. **Candidate genes cell** (analysis modules only), always with a working default so the notebook runs on its own:
   ```python
   # Replace with the genes you were assigned on Day 2 (see data/candidate-genes.tsv)
   CANDIDATE_GENES = ["AGAP009193", "AGAP002894"]  # GSTE4, CYP6Z4 (both in the pool and inside Busia sweeps)
   ```
6. Sections of **theory then practical** (`##` headings). Keep theory short and concrete; use
   figures from the tools' own repos (raw GitHub URLs) rather than copying images into this repo.
7. `### Exercise N` markdown cells followed by an empty code cell. Put answers in a collapsed block
   that renders in both Colab and the book:
   ```html
   <details><summary>Show answer</summary>

   ...answer text or code block...

   </details>
   ```
8. **Quiz**: 3–5 multiple-choice questions in `quizzes/<notebook-stem>.json` (jupyterquiz format), shown with
   ```python
   %pip install -q jupyterquiz
   from jupyterquiz import display_quiz
   display_quiz("https://raw.githubusercontent.com/sanjaynagi/malaria-software-training/main/quizzes/<notebook-stem>.json")
   ```
9. `## Summary`, then `## Well done!`, then `## References` (numbered, with DOIs).

## Rules

- **Do not repeat the PAMCA course.** Assume participants know Colab, pandas, plotly, `malariagen_data.Ag3()`,
  SNP/CNV frequency functions, H12 GWSS and basic AnoPrimer usage. Link back to the relevant PAMCA module
  instead of re-teaching it (e.g. https://anopheles-genomic-surveillance.github.io/workshop-6/module-3-gwss.html).
- **Tie everything to the study**: Busia (Uganda) RNA-seq, Busia/Ugandan/Kenyan Ag3 cohorts, the
  `UG-E_Busia_gamb_2016_Q2` atlas cohort, Siaya (Kenya) Ag-vampIR data.
- **Data** comes from public URLs only. Data we still need to prepare and host (Zenodo) goes behind a
  constant at the top of the notebook, marked `# TODO(data): ...`, and listed in `data/README.md`.
- Mine the tools' existing tutorials (AnoPrimer, AnoExpress, AmpSeeker, RNA-Seq-Pop, selection-atlas docs
  are the course author's own and can be adapted freely; cite third-party tools such as multiply).
  Never copy text from books or papers; summarise.
- Pin package versions and check that the code runs against those versions (read the package source if
  you cannot execute it).
- Plain, direct British English. Short paragraphs. Explain *why* before *how*.
- Save notebooks with outputs if you could execute them; otherwise with outputs cleared.
