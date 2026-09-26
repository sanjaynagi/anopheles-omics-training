# Beyond WGS: transcriptomics, selection and assay design in malaria vectors

This course follows on from the
[MalariaGEN–PAMCA training course](https://anopheles-genomic-surveillance.github.io/home.html),
which we assume you have completed (Workshop 1 at minimum). That course teaches population
genomics with whole-genome sequence data and `malariagen_data`. This course covers the other
data types and tools used in insecticide resistance research: RNA-seq, the selection atlas,
primer and probe design, and amplicon sequencing.

The whole course follows **one study**. You will be given a few candidate genes on Day 2 and
follow them through every later module, from expression data to a field assay. On Day 5 you
present what you found. See the [study brief](study-brief.md).

## Learning outcomes

By the end of the course you will be able to:

- Explain how genomic surveillance can support malaria vector control.
- Configure and run bioinformatic workflows (Snakemake), and explain why workflow managers matter.
- Analyse RNA-seq and amplicon sequencing data to identify markers associated with insecticide resistance.
- Interpret results from RNA-seq, selection scans and amplicon sequencing with confidence.
- Design primers, probes and multiplex panels to validate and monitor candidate resistance markers.

## Tools

| Tool | Used for |
|---|---|
| [RNA-Seq-Pop](https://github.com/sanjaynagi/rna-seq-pop) | RNA-seq workflow: expression and variation |
| [AnoExpress](https://github.com/sanjaynagi/AnoExpress) | Meta-analysis of resistance RNA-seq studies |
| [malariagen_data](https://github.com/malariagen/malariagen-data-python) | Ag1000G whole-genome data |
| [Selection atlas](https://anopheles-genomic-surveillance.github.io/selection-atlas/) | Catalogue of selective sweeps |
| [AnoPrimer](https://github.com/sanjaynagi/AnoPrimer) | Primer and probe design |
| [multiply](https://github.com/JasonAHendry/multiply) | Multiplex PCR design |
| [AmpSeeker](https://github.com/sanjaynagi/AmpSeeker) | Amplicon sequencing workflow |

## Running the notebooks

Most notebooks run in [Google Colab](https://colab.research.google.com); use the Colab button
at the top of each page. The two Snakemake workflows (RNA-Seq-Pop and AmpSeeker) run in
[GitHub Codespaces](https://github.com/features/codespaces). See
[Day 1, module 1.4](day-1/1-4-running-rna-seq-pop.ipynb) for setup.

## Licence

This work is licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
