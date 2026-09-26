# Gene dossier presentation rubric

This rubric is for the Day 5 gene dossier presentations
([Module 5.1](../day-5/5-1-gene-dossier.md)), which use the
[dossier template](gene-dossier-template.md). There are two ways to use it:

- **Informal runs** (workshops, group presentations): give feedback only, using the three
  levels in [Part A](#part-a-informal-feedback). No marks.
- **Formal assessed version (TROP970)**: an individual mark out of 100, using the weights
  and bands in [Part B](#part-b-formal-assessment-trop970).

Both parts use the same criteria. Each criterion maps to the course learning outcomes
(see the [course home page](../index.md)):

| Code | Learning outcome |
|---|---|
| **LO1** | Explain how genomic surveillance can support malaria vector control |
| **LO2** | Configure and run bioinformatic workflows (Snakemake), and explain why workflow managers matter |
| **LO3** | Analyse RNA-seq and amplicon sequencing data to identify markers associated with insecticide resistance |
| **LO4** | Interpret results from RNA-seq, selection scans and amplicon sequencing with confidence |
| **LO5** | Design primers, probes and multiplex panels to validate and monitor candidate resistance markers |

## Format

- About 10 minutes of presentation plus 5 minutes of questions per gene dossier (one or more
  genes; a participant with three genes may focus on the one with the most interesting story
  and summarise the others).
- The presenter shares their fork of the course repository. The `my-dossier/` folder is part
  of what is assessed (criterion F).
- Group runs: groups of 2–3 present one dossier together; every member should present a part
  and answer questions.

## Criteria

| | Criterion | Dossier sections | LOs | What we look for |
|---|---|---|---|---|
| **A** | Expression evidence | 1, 2 | LO3, LO4 | Correct fold changes and adjusted p-values for the right contrasts (selected vs parental, parental vs Kisumu). Replication in AnoExpress: how many experiments, which species and countries. Awareness of confounders (Kisumu background, induction, hitchhiking) |
| **B** | Genomic variation and selection | 3, 4 | LO4 | CNV and missense SNP frequencies in relevant Ugandan/Kenyan Ag3 cohorts, and whether they could explain the expression. Correct use of selection-atlas signals (which cohort, which interval: focus/span1/span2), and whether the gene is plausibly the target or a passenger |
| **C** | Assay design | 5 | LO5 | A sensible RT-qPCR primer pair and/or SNP-genotyping probe for the gene or a linked variant. Justified choices: exon-junction spanning, Tm and product size, avoidance of known Ag3 SNPs, off-target checks. How it could fit into a multiplex panel |
| **D** | Field evidence | 6 | LO3, LO4 | Correct reading of the Siaya Ag-vampIR results for the gene or a linked tagging SNP: allele frequencies in dead and alive mosquitoes, the association test and its limits (sample size, linkage, the gap between Busia and Siaya). Saying clearly when the panel has no marker for the gene |
| **E** | Synthesis and verdict | 7 | LO1, LO4 | A clear, balanced verdict on how strong the case is, weighing the lines of evidence, including those that disagree. Concrete next steps (e.g. functional validation, adding a marker to a panel) and why they matter for surveillance and control decisions |
| **F** | Reproducibility | all | LO2 | The dossier lives in a git repository with regular, meaningful commits; figures can be traced to notebooks; package versions are pinned or recorded; the RNA-Seq-Pop and AmpSeeker configs used are identified. The presenter can explain what the workflows did |
| **G** | Communication and questions | all | all | Clear figures with labelled axes and units; a logical story within time; accurate answers to questions, including saying "I don't know" when appropriate |

## Part A: informal feedback

For each criterion, the facilitator (and, if useful, peers) ticks one level and writes one
comment on what worked and one suggestion.

| Criterion | Not yet | There | Strong |
|---|---|---|---|
| A. Expression evidence | Numbers missing or from the wrong contrast | Correct numbers, some interpretation | Correct numbers, replication and confounders discussed |
| B. Genomic variation and selection | Signals or frequencies reported without interpretation | Correct cohorts and signals, some interpretation | Links CNVs/SNPs and selection to the expression result; target vs passenger discussed |
| C. Assay design | No assay, or choices not justified | A workable assay with some justification | Well-justified assay, checked against variation and off-targets |
| D. Field evidence | Results misread or missing | Correct reading of frequencies and association | Correct reading, with limitations and the Busia–Siaya link discussed |
| E. Synthesis and verdict | No clear verdict | A verdict with some support | A balanced verdict and concrete, well-argued next steps |
| F. Reproducibility | Work not in the repository | Work committed; some gaps in versions or provenance | Clean, regularly committed repository; versions and configs recorded |
| G. Communication | Hard to follow or over time | Clear, mostly within time | Clear, well paced, strong answers to questions |

## Part B: formal assessment (TROP970)

### Weights

| Criterion | Weight |
|---|---|
| A. Expression evidence | 20% |
| B. Genomic variation and selection | 20% |
| C. Assay design | 15% |
| D. Field evidence | 15% |
| E. Synthesis and verdict | 15% |
| F. Reproducibility | 10% |
| G. Communication and questions | 5% |

Each criterion is given a mark from 0–100 using the bands below; the final mark is the
weighted sum, rounded to the nearest whole number.

### Mark bands

| Band | Mark | Description (apply to each criterion) |
|---|---|---|
| **Excellent** | 70–100 | Complete and accurate. Goes beyond reporting to critical interpretation: weighs strengths and weaknesses of the evidence, uses the right comparisons and cohorts, and links the result to the rest of the dossier. At 80+, shows independent thinking (e.g. an extra analysis, or a well-argued challenge to the expected result) |
| **Good** | 60–69 | Complete and accurate, with sound interpretation. Minor gaps in critical discussion or links between sections |
| **Satisfactory** | 50–59 | Mostly complete and correct, but mainly descriptive. Some errors or omissions that do not undermine the main conclusion |
| **Insufficient** | 40–49 | Incomplete, or with errors that affect the conclusion. Little interpretation |
| **Poor** | 0–39 | Missing, largely incorrect, or shows a basic misunderstanding of the method or result |

The pass mark and band names should be checked against the current TROP970 module handbook
and the institution's marking scheme before use; adjust the band labels if needed, but keep the
criteria and weights so marks are comparable between cohorts.

### Marking procedure

1. Two markers attend (or watch a recording of) each presentation and mark independently, using
   the marking sheet below.
2. Markers agree a final mark. If their marks differ by more than 10, a third marker reviews
   the recording and the repository.
3. The repository is frozen at the start of the presentation session (markers note the commit
   hash) and reviewed for criterion F.
4. Written feedback: one strength and one improvement per criterion, plus an overall comment.

**Group work in the formal version.** If participants have worked in groups during the course,
each still presents and is marked individually. Shared analyses are allowed, but the
interpretation, verdict and answers to questions must be the presenter's own.

**Adjustments.** Remote participants can submit a recorded presentation (same length) and
answer questions live or in writing within 48 hours. Reasonable adjustments follow
institutional policy.

### Marking sheet

| Criterion | Weight | Mark (0–100) | Weighted | Comment |
|---|---|---|---|---|
| A. Expression evidence | 0.20 | | | |
| B. Genomic variation and selection | 0.20 | | | |
| C. Assay design | 0.15 | | | |
| D. Field evidence | 0.15 | | | |
| E. Synthesis and verdict | 0.15 | | | |
| F. Reproducibility | 0.10 | | | |
| G. Communication and questions | 0.05 | | | |
| **Total** | 1.00 | | | |

Presenter: ____________ Gene(s): ____________ Repository commit: ________ Marker: ____________

## Example questions for the Q&A

- Your gene is overexpressed in BusRes vs Kisumu. Is it also overexpressed in BusRes vs BusSus? Why does that matter?
- Could the overexpression be explained by a neighbouring gene in the same CNV or sweep?
- Which Ag3 cohort did you use, and how close is it in time and space to the Busia colony?
- Why did you choose this primer pair or probe over the alternatives?
- The Siaya association is not significant. Does that mean the gene is not involved?
- If a control programme could add one marker to its panel, would you recommend yours? Why?
- Could someone else regenerate your volcano plot from your repository? Show us how.
