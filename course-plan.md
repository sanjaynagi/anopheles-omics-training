# Course plan: from expression to assay in malaria vectors

Title: **Anopheles Omics: from gene expression to field assays**

A 5-day course (and self-paced online book) that follows on from the
[MalariaGEN–PAMCA course](https://anopheles-genomic-surveillance.github.io/home.html).
It covers RNA-seq, the selection atlas, primer/probe and panel design, and amplicon
sequencing. Every notebook works on one public study, so participants follow a
candidate gene from discovery to a field assay.

---

## 1. The storyline: one study, end to end

**Setting: pyrethroid resistance in *An. gambiae* around Lake Victoria (Busia, Uganda and Siaya, Kenya).**

All the data is public, and each dataset leads into the next:

| Step | Question | Tool | Public data |
|---|---|---|---|
| 1. Discover | Which genes are differentially expressed in resistant mosquitoes? | **RNA-Seq-Pop** | Busia deltamethrin-selected colony vs parental vs Kisumu. ENA **PRJNA748581** (16 runs: Kisumu ×4, BusSus ×6, BusRes ×6; NovaSeq) |
| 2. Replicate | Is the gene overexpressed in other studies, countries and species? | **AnoExpress** | Bundled meta-analysis (Ag + Af) |
| 3. Explain | Is overexpression linked to CNVs or nearby SNPs in wild populations? | **malariagen_data** | Ag3: Ugandan and Kenyan cohorts, incl. Busia 2016 |
| 4. Selection | Is the locus under recent selection in the field? | **selection-atlas** | `UG-E_Busia_gamb_2016_Q2` has 4 signals: **2R Cyp6aa/p cluster** (28.48 Mb), **2L ~34 Mb**, **3R Gste cluster** (28.59 Mb), **X Cyp9k1** (15.29 Mb) |
| 5. Assay | How do we test for it cheaply in the lab? | **AnoPrimer** | Ag3 variation used to avoid SNPs in primers and probes |
| 6. Scale up | How do we multiplex the markers into a panel? | **multiply** (+ Ag-vampIR, AnoSpp as case studies) | AgamP4 reference |
| 7. Monitor | Do the markers predict survival in the field? | **AmpSeeker** | Ag-vampIR, SRA **PRJNA1207724**: **Siaya deltamethrin dead/alive, 264 samples, ~0.7 GB** (+ VK7 alive/dead, Ghana, Gambia) |

The loop closes at the Cyp6 locus. In Ag3 around Busia, the swept 2R haplotype carries
Cyp6p4-I236M and the Cyp6aa1 duplication (`Cyp6aap_Dup1a`), and Ag-vampIR's `Cyp6p4_I236M` and
`Cyp6_tag8` track it. In Siaya those markers predict deltamethrin survival (OR ≈ 3.4), as do the
`34mb_tag1-4` markers at the 2L sweep. The panel does **not** tag the Busia Cyp9k1 sweep (`Cyp9k1_Dup8`),
and its Gste tags and remaining Cyp6 tags don't vary around Busia/Siaya; they mostly come from West
African sweeps. The course says this openly and uses it to motivate designing new tags (4.2).

**Worked example: CYP6AA1.** Every module demonstrates its method on CYP6AA1 (AGAP002862)
first. It is upregulated and duplicated on the Uganda/Kenya "triple mutant" haplotype
(Cyp6aa1 dup + Cyp6p4-I236M + ZZB TE; Njoroge *et al.* 2022, *Mol Ecol*, doi:10.1111/mec.16591),
which lies in the Busia 2R sweep; its Ag-vampIR markers predict deltamethrin survival in Siaya.

**Candidate-gene thread.** At the end of Day 2, each participant gets 2–3 genes from
the Busia differential expression results. Each set mixes a known IR gene
(e.g. CYP6AA1/CYP6P3, CYP9K1, GSTE2, SAP2, a COE cluster gene) with a less-studied
DE gene. They take these genes through every later module and present a
**gene dossier** on Day 5.

### Alternative: Bouaké (Côte d'Ivoire, pirimiphos-methyl)
The draft training plan names the Bouaké dataset (also the RNA-Seq-Pop `exampleconfig`).
It has no public accession yet, so it can only be used if it is deposited first. Its
story works too (Ace1, the Coeae1f/2f sweep, Ag-vampIR `Ace1_G280S`), but Ag-vampIR
has no phenotyped Ivorian samples, so the Day 4 genotype:phenotype step would not
connect as well. **Recommendation: Busia/Siaya.** Bouaké could be an optional
extension exercise once it is published.

---

## 2. Avoiding overlap with the PAMCA course

| PAMCA module | Already covered there | What this course does instead |
|---|---|---|
| W1-M1 Colab, W1-M2/3 metadata and genome, W1-M4 Vgsc SNPs | Colab, `Ag3()`, SNP frequencies | Assumed. Link back; no re-teaching |
| W2-M3/M4 CNV calling and frequencies | CNV mechanics | Uses CNVs to explain the **overexpression of your gene** |
| W6-M3 GWSS (H12) | Computing and calibrating H12 | **Uses the atlas catalogue**: querying signals, comparing cohorts, placing signals on genes. No H12 re-computation |
| W6-M4 AnoPrimer | PCR theory, gDNA primers for ace1, qPCR for COEAE2F | 10-min recap, then **probes, SNP-genotyping/LNA assays, RT-qPCR for your gene, in-silico QC, multiplexing** |
| W7-M3/M4 haplotype clustering and networks | Methods | Optional follow-up at a Busia sweep locus only |

Anything new to this course: workflow managers, RNA-seq theory, DE and GSEA,
"the sequence in RNA-seq" (variants, Fst/PBS, karyotype, AIMs from RNA), meta-analysis,
probe design, panel design, amplicon sequencing, git and reproducibility.

---

## 3. Course structure (5 days → book parts)

Each notebook follows the PAMCA format: **learning objectives → theory → worked
practical → exercises (answers hidden in dropdowns) → short quiz → summary**.
Every notebook opens with a `CANDIDATE_GENES = [...]` cell that has a default, so it
also works on its own for self-paced learners.

Runs where: **C** = Colab, **S** = server/Codespaces (Snakemake)

### Day 1: The study, reproducible practice and workflows
| # | Module | Runs | Mine from |
|---|---|---|---|
| 0 | About the course + **study brief** (Lake Victoria, the datasets, what we will find) | – | RNA-Seq-Pop paper; Ag-vampIR ms |
| 1.1 | Omics approaches to finding IR genes and mutations (lecture notebook) | – | Existing Google Slides deck |
| 1.2 | Reproducible bioinformatics: project layout, environments (conda/pixi), **git and GitHub** (fork the course template repo; commit your work every day) | C/S | Buffalo, *Bioinformatics Data Skills* ch. 1–2, 5 (summarised, not copied) |
| 1.3 | Workflow managers: why, Snakemake concepts (rules, wildcards, DAG, conda envs, dry-run), a 3-rule toy workflow; Nextflow compared in theory | C (pip snakemake) | Snakemake tutorial (adapted) |
| 1.4 | **RNA-Seq-Pop:** directory layout, `samples.tsv`, `config.yaml`, contrasts, launch on the Busia mini dataset (let it run) | S | rna-seq-pop docs, `.test/`, `exampleconfig.yaml` |

*Note: the draft put git on Day 5. I suggest teaching the basics on Day 1 so
participants use git all week, then covering wider reproducibility on Day 5.*

### Day 2: Transcriptomics
| # | Module | Runs | Mine from |
|---|---|---|---|
| 2.1 | RNA-seq theory (library prep, pseudoalignment/kallisto, normalisation, DESeq2 model, FDR, GSEA) + **explore the Busia results**: MultiQC, PCA, volcano, GSEA. **Candidate genes assigned** | C | rna-seq-pop results book (`docs/rna-seq-pop-results`), RNA-Seq-Pop paper |
| 2.2 | **The sequence in RNA-seq:** variants of interest (Vgsc 995S), Fst/PBS per gene, diversity, karyotype, AIMs from RNA | C | RNA-Seq-Pop notebooks + outputs |
| 2.3 | **AnoExpress:** your genes across ~35 experiments; genome-wide expression scans, gene families, enrichment, co-expression | C | AnoExpress Colab notebooks (plot-gene-expression, GWES, families, candidates, enrichment, GRN) |

### Day 3: From expression to the genome
| # | Module | Runs | Mine from |
|---|---|---|---|
| 3.1 | **Why is my gene overexpressed?** CNV frequencies and missense SNPs in your genes in Ugandan and Kenyan Ag3 cohorts; combining `malariagen_data` + AnoExpress | C | PAMCA W2-M4, W7-M1 (pattern only); AnoExpress utility notebook |
| 3.2 | **The selection atlas:** H12/G123/iHS in brief (links to W6-M3); signal intervals (focus/span1/span2); query the signal table for East African cohorts; do any signals overlap your genes; how signals persist across time and space; using the website | C | selection-atlas `skills/index.md`, `signals.md`, `queries.md`, `followup.md`; atlas website |
| 3.3 | *(optional)* Follow-up at a Busia sweep: haplotype clustering at Cyp9k1 or Cyp6 | C | atlas `followup.md`, PAMCA W7-M3 |

### Day 4: From discovery to assays and surveillance
| # | Module | Runs | Mine from |
|---|---|---|---|
| 4.1 | **AnoPrimer, advanced:** quick recap; RT-qPCR primers for your gene (spanning exon junctions); **probe and LNA SNP-genotyping assays** for a variant found on Day 3; checking primers against Busia-cohort variation; off-target checks | C | AnoPrimer notebooks + teaching graphics; PAMCA W6-M4 (recap only) |
| 4.2 | **Amplicon sequencing and panel design:** principles, multiplex PCR constraints (dimers, Tm, off-targets); case studies Ag-vampIR and AnoSpp; **multiply:** design a multiplex for the class's candidate SNPs | C? / S | multiply README + `designs/ag-default.ini`; Ag-vampIR ms; AnoSpp docs; `amplicon-sequencing-slides.pptx` |
| 4.3 | **AmpSeeker:** run on the Siaya + VK7 subset from SRA; explore the results book (QC, coverage, species/AIMs, kdr origins, allele frequencies); **genotype:phenotype association** in Siaya: do the Busia sweep loci predict survival? | S (Colab stretch) | `AmpSeeker/docs/AmpSeeker_workshop.ipynb`, AmpSeeker docs, `code/agvampir002/notebooks/` |

### Day 5: Synthesis
| # | Module | Runs |
|---|---|---|
| 5.1 | **Gene dossier presentations** (template: expression → replication → CNV/SNP → selection → assay → amplicon evidence → verdict) | – |
| 5.2 | Good practice wrap-up: folder structure, environments, version control, workflow outputs as provenance, sharing data | C |
| 5.3 | Flexi / own projects / bring your own data | – |

Keep the **1-hour daily flexi block** from the draft (e.g. the last hour of each day).

---

## 4. Data preparation (all public)

| Asset | How it is made | Hosted |
|---|---|---|
| **Busia mini dataset** | Download PRJNA748581 via ENA FTP (or `ffq`, as RNA-Seq-Pop does); subsample to ~0.5–1 M read pairs per sample with `seqtk`; keep all 16 runs (Kisumu ×4, BusSus ×6, BusRes ×6). Aim for < 2 GB in total | Zenodo (DOI) |
| **Busia full results** | Run RNA-Seq-Pop once on the full dataset on HPC; package the counts, DE, GSEA, Fst/PBS, VOI frequencies, karyotype, AIMs and the results book | Zenodo + GitHub Pages |
| **Siaya/VK7 amplicon subset** | SRA PRJNA1207724 FASTQs (Siaya ~0.7 GB; VK7 ~0.1 GB); AmpSeeker config with `from-bcl: False`, metadata with phenotype | Zenodo (or fetched in the notebook) |
| **AmpSeeker full results** | Run once; host the results book (or link the existing `agvampir002-results`) | GitHub Pages |
| **Candidate gene pool** | Curated from the Busia DE table and cross-checked in the atlas/AnoExpress so every gene has something to find | Course repo `data/` |

Every Colab notebook reads its precomputed inputs from Zenodo. **No notebook needs a
workflow run to have finished**, so a failed run on Day 1 does not block Day 2.

---

## 5. Compute strategy

| Component | Colab? | Plan |
|---|---|---|
| AnoExpress, malariagen_data, selection atlas, AnoPrimer | Yes | Colab, with pinned `%pip install` lines |
| Toy Snakemake | Yes | `pip install snakemake` in Colab |
| multiply | Unclear (primer3, BLAST, conda) | **Spike:** try `condacolab`; fallback to Codespaces |
| RNA-Seq-Pop | No (many conda envs, freebayes, ~100 GB full) | Mini dataset on **GitHub Codespaces** (devcontainer with prebuilt envs; ties in with the git teaching) or an institutional server (h3bionet was used before); full run on HPC by instructors |
| AmpSeeker | Maybe (small data) | Same as RNA-Seq-Pop; Colab as a stretch goal after the spike |

Risk: the Codespaces free tier (2-core/8 GB, 60 h/month) may be tight for a kallisto
index plus freebayes. This needs testing in Phase 0, with the mini dataset shrunk if
necessary.

---

## 6. Book and repository

- **Jupyter Book 2 / MyST** (`myst.yml`). The PAMCA course is on JB1/Sphinx; JB2 is
  the current version and supports MyST cross-references, dropdowns and exercise
  directives. (If staying consistent with the parent site matters more, JB1 also works.)
- Layout:
  ```
  myst.yml
  index.md                    # home + study brief
  day-1/ ... day-5/           # one .ipynb per module (+ about.md per day)
  data/candidate-genes.tsv
  assessment/                 # dossier template, rubric, question bank
  facilitators/               # timings, answers, troubleshooting
  workflows/                  # rna-seq-pop + ampseeker configs for the mini datasets
  .devcontainer/              # Codespaces image for Snakemake sessions
  skills/                     # markdown conversions of notebooks (as in PAMCA repo)
  ```
- Commit notebooks with outputs (as PAMCA does); a **scheduled GitHub Action**
  re-runs the Colab notebooks against pinned versions and flags breakage.
- Colab launch buttons on every page; licence CC BY-SA 4.0 to match the parent.
- **Quizzes:** `jupyterquiz` (renders in Colab and in the built book) for formative
  checks; MyST `{exercise}`/`{solution}` dropdowns for exercises. This covers the
  T3 note about quizzes without moving to Next.js.

---

## 7. Assessment and evaluation
- **Formative:** a quiz at the end of each module; exercises with hidden answers.
- **Summative:** gene dossier presentation (group for informal runs; 1:2 assessed
  version for TROP970), with a rubric mapped to the learning outcomes.
- **Evaluation:** short end-of-day feedback form + end-of-course survey (Google Forms).

---

## 8. Implementation phases

**Phase 0: Spikes (de-risk first)**
1. Can current `malariagen_data`, `anoexpress` and `anoprimer` be installed together in Colab? Pin working versions.
2. Run RNA-Seq-Pop on full Busia on HPC → reference results; confirm the DE genes match the paper.
3. Build the Busia mini dataset; time RNA-Seq-Pop on Codespaces and on a server.
4. Run AmpSeeker on Siaya + VK7 from SRA FASTQs; check the association results.
5. Install multiply in Colab (condacolab) and on Codespaces; confirm the AnophelesGambiae download still works.

**Phase 1: Scaffold.** Repo, `myst.yml`, notebook template, study brief, Zenodo
record, candidate gene pool, devcontainer.

**Phase 2: Content, in data-flow order.** 2.1 → 2.2 → 2.3 → 3.1 → 3.2 → 4.1 →
4.3 → 4.2 → Day 1 modules (theory-heavy, least dependent on data) → 5.2.
Mine existing tutorials first; write new text only where needed.

**Phase 3: Assessment and facilitation.** Quizzes, dossier template and rubric,
facilitator notes with timings and answers, feedback forms.

**Phase 4: Pilot.** Notebook check (following the PAMCA checking process), a
dry run with 2–3 testers, then CI.

---

## 9. Decisions (agreed 2026-09-26)

1. **Dataset:** Busia (RNA-seq) + Siaya/VK7 (amplicon). Bouaké is an optional extension once it is deposited.
2. **Snakemake compute:** GitHub Codespaces (see below).
3. **Book:** Jupyter Book 2 / MyST.
4. **Hosting:** new repo `sanjaynagi/anopheles-omics-training`.
5. **Nextflow:** lecture only.
6. **AnoSpp:** lecture/case study only.
7. **Environments: pixi first** (course env, participants' projects, the Codespace Snakemake env); conda only where Snakemake's per-rule `--use-conda` envs need it.
8. Phase 0 spikes are expected to pass; go straight to building, and fix problems as they come up.

### Codespaces cost
- Participants **fork the course repo and create codespaces on their own accounts**, so it
  uses their free allowance, not ours.
- Free personal accounts get 120 core-hours and 15 GB-month storage per month (Pro/Student
  pack: 180 core-hours, 20 GB). That is 60 h on a 2-core/8 GB machine or 30 h on a
  4-core/16 GB one. Two Snakemake days fit easily.
- The default spending limit on personal accounts is $0, so participants cannot be
  charged; a codespace just stops when the allowance runs out.
- Beyond the allowance, prices are $0.18/h (2-core), $0.36/h (4-core) and $0.07/GB-month.
- Prebuilds would use the repo owner's Actions minutes and storage. Start without them
  (an env-setup script run on first open), and add them only if setup is too slow.
- Tell participants to **delete their codespace after the course** to free the storage.
