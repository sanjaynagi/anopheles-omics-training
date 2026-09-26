# Timetable

Five days, 09:00–17:00. Every day has the same shape:

| Time | |
|---|---|
| 09:00–10:30 | Session 1 |
| 10:30–10:45 | Break |
| 10:45–12:30 | Session 2 |
| 12:30–13:30 | Lunch |
| 13:30–15:00 | Session 3 |
| 15:00–15:15 | Break |
| 15:15–16:00 | Session 4 |
| 16:00–17:00 | **Flexi hour**: catch-up, dossier work, own projects or tailored help |

The flexi hour is protected time. If a session overruns, take time from the flexi hour on
purpose, not by accident, and say so. Close each day at 16:55 with the short end-of-day
feedback form.

**Runs where:** C = Google Colab, S = GitHub Codespaces (Snakemake workflows), – = no computer needed.

## Day 1: The study, reproducible practice and workflows

| Time | Session | Runs | Notes |
|---|---|---|---|
| 09:00–09:30 | Welcome, introductions, how the week works | – | Talk about your own struggles with bioinformatics; it is normal to find this hard. Check everyone has a Google and a GitHub account |
| 09:30–10:30 | [Study brief](../study-brief.md) and [1.1 Omics approaches](../day-1/1-1-omics-approaches.ipynb): lecture | – | |
| 10:45–11:15 | 1.1 exercises (discussion in pairs) and quiz | C | |
| 11:15–12:30 | [1.2 Reproducible practice](../day-1/1-2-reproducible-practice.ipynb): layout, environments, git; **fork the course repo and make a first commit** | C/S | Ask everyone to create their codespace at the end of this session so it is ready after lunch |
| 13:30–15:00 | [1.3 Workflow managers](../day-1/1-3-workflow-managers.ipynb): Snakemake concepts and toy workflow; Nextflow compared | C | |
| 15:15–16:00 | [1.4 Running RNA-Seq-Pop](../day-1/1-4-running-rna-seq-pop.ipynb): layout, `samples.tsv`, `config.yaml`, launch on the Busia mini dataset | S | The run continues overnight or into the flexi hour. Nothing on Day 2 depends on it finishing (precomputed results are on Zenodo) |
| 16:00–17:00 | Flexi: check runs, git help, catch-up | S | |

## Day 2: Transcriptomics

| Time | Session | Runs | Notes |
|---|---|---|---|
| 09:00–09:15 | Recap; check RNA-Seq-Pop runs | S | Look at failed runs together: reading a Snakemake log is part of the learning |
| 09:15–10:30 | [2.1 RNA-seq results](../day-2/2-1-rna-seq-results.ipynb): theory (library prep, kallisto, normalisation, DESeq2, FDR, GSEA) | – | |
| 10:45–12:30 | 2.1 practical: MultiQC, PCA, volcano plots, GSEA on the Busia results. **Candidate genes assigned** (about 12:15) | C | Use `data/candidate-genes.tsv`; every participant gets 2–3 genes |
| 13:30–14:30 | [2.2 The sequence in RNA-seq](../day-2/2-2-sequence-in-rna-seq.ipynb): variants, Fst/PBS, diversity, karyotype, AIMs | C | |
| 14:30–15:00 | [2.3 AnoExpress](../day-2/2-3-anoexpress.ipynb): introduction; your genes across studies | C | |
| 15:15–16:00 | 2.3 continued: genome-wide expression scans, gene families, enrichment, co-expression | C | |
| 16:00–17:00 | Flexi: dossier sections 1–2; commit | C | |

## Day 3: From expression to the genome

| Time | Session | Runs | Notes |
|---|---|---|---|
| 09:00–09:15 | Recap | – | |
| 09:15–10:30 | [3.1 CNVs and SNPs](../day-3/3-1-cnvs-and-snps.ipynb): why is my gene overexpressed? | C | Links back to PAMCA W2-M4; do not re-teach CNV calling |
| 10:45–11:30 | 3.1 continued: your genes in Ugandan and Kenyan Ag3 cohorts | C | |
| 11:30–12:30 | [3.2 The selection atlas](../day-3/3-2-selection-atlas.ipynb): signals and intervals; querying the signal table | C | |
| 13:30–15:00 | 3.2 continued: `UG-E_Busia_gamb_2016_Q2` signals, overlap with your genes, signals across time and space, the website | C | |
| 15:15–16:00 | [3.3 Sweep follow-up](../day-3/3-3-sweep-follow-up.ipynb) (optional): haplotype clustering at *Cyp9k1* or *Cyp6* | C | Participants may use this slot for dossier work instead |
| 16:00–17:00 | Flexi: dossier sections 3–4; commit | C | |

## Day 4: From discovery to assays

| Time | Session | Runs | Notes |
|---|---|---|---|
| 09:00–09:15 | Recap; **launch AmpSeeker** on the Siaya + VK7 subset | S | Starting it now lets it run during the morning. Precomputed results are available as a fallback |
| 09:15–10:30 | [4.1 AnoPrimer assays](../day-4/4-1-anoprimer-assays.ipynb): recap; RT-qPCR primers for your gene | C | 10-minute recap only; link to PAMCA W6-M4 |
| 10:45–12:30 | 4.1 continued: probes and LNA SNP-genotyping assays; checking against Busia-cohort variation; off-target checks | C | |
| 13:30–14:30 | [4.2 Amplicon panel design](../day-4/4-2-amplicon-panel-design.ipynb): principles; Ag-vampIR and AnoSpp case studies; multiply | C/S | AnoSpp is a case study only |
| 14:30–15:00 | [4.3 AmpSeeker](../day-4/4-3-ampseeker.ipynb): the workflow and its results book | S | |
| 15:15–16:00 | 4.3 continued: genotype–phenotype association in Siaya. Do the Busia sweep loci predict survival? | S/C | |
| 16:00–17:00 | Flexi: finish the dossier; prepare slides; commit | – | |

## Day 5: Synthesis

| Time | Session | Runs | Notes |
|---|---|---|---|
| 09:00–09:30 | Final preparation; freeze repositories (note the commit hash) | – | |
| 09:30–10:30 | [5.1 Gene dossier presentations](../day-5/5-1-gene-dossier.md), part 1 | – | 10 min + 5 min questions each; about 4 per hour. Use the [rubric](../assessment/rubric.md) |
| 10:45–12:30 | 5.1 presentations, part 2; discussion of the whole class's findings | – | With more than ~11 presenters, run two rooms or present in groups |
| 13:30–14:45 | [5.2 Good practice](../day-5/5-2-good-practice.ipynb): looking back; provenance; sharing data; licences; READMEs; checklist | C | |
| 14:45–15:00 | End-of-course survey | – | |
| 15:15–16:45 | 5.3 Flexi: own projects, bring your own data, one-to-one help | – | |
| 16:45–17:00 | Close; remind everyone to delete their codespace | – | |

## Plan B

- **A workflow fails or Codespaces is too slow:** all Day 2 and Day 4 notebooks read
  precomputed results from Zenodo, so teaching continues. Debug the failed run together in
  the flexi hour.
- **Colab install breaks:** notebooks pin package versions; the scheduled GitHub Action should
  catch breakage before the course. Keep a copy of executed notebooks to show outputs.
- **Poor internet:** have the Busia mini dataset and precomputed results on a USB drive or
  local server, and slides as PDFs.
