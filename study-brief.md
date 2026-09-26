# Study brief: pyrethroid resistance around Lake Victoria

Pyrethroid-treated bed nets are the main malaria vector control tool in East Africa, and
*Anopheles gambiae* around Lake Victoria is highly resistant to pyrethroids. In this course
you work as an analyst on a study with three questions:

1. **Which genes are involved in pyrethroid resistance in this population?**
2. **Are those genes under selection in wild mosquitoes?**
3. **Can we build cheap assays to monitor them, and do they predict whether mosquitoes survive?**

All of the data is public.

## The data

| Data | Source | Used on |
|---|---|---|
| **RNA-seq** of a colony from **Busia, Uganda** (collected 2018): a deltamethrin-selected line, its unselected parent line, and the susceptible Kisumu strain | Nagi *et al.* (2023) *Mol Ecol Resour*, ENA [PRJNA748581](https://www.ebi.ac.uk/ena/browser/view/PRJNA748581) | Days 1–2 |
| **Expression meta-analysis** across many resistance studies in *An. gambiae* s.l. and *An. funestus* | AnoExpress | Day 2 |
| **Whole genomes** of wild mosquitoes from Uganda and Kenya, including Busia in 2016 | MalariaGEN Ag3 | Day 3 |
| **Selection signals** for the Busia 2016 cohort (`UG-E_Busia_gamb_2016_Q2`) and its neighbours | Malaria vector selection atlas | Day 3 |
| **Amplicon sequencing** (Ag-vampIR panel) of mosquitoes from **Siaya, Kenya** that were exposed to deltamethrin nets and scored dead or alive | Nagi *et al.* (2025) *bioRxiv*, SRA [PRJNA1207724](https://www.ebi.ac.uk/ena/browser/view/PRJNA1207724) | Day 4 |

Busia and Siaya lie about 50 km apart, on either side of the Uganda–Kenya border.

## Your task

On Day 2 you are given two or three **candidate genes** from the Busia RNA-seq results.
For each gene, build a **gene dossier** as you go:

- **Expression:** how strongly is it differentially expressed in Busia?
- **Replication:** is it overexpressed in other studies?
- **Genomic variation:** do CNVs or amino acid changes in wild populations explain the expression?
- **Selection:** is it inside a selective sweep?
- **Assay:** primers and probes to measure its expression or genotype it.
- **Field evidence:** is it (or a linked marker) associated with surviving deltamethrin in Siaya?

On Day 5, present your dossier and give a verdict: how strong is the case that this gene
contributes to resistance, and what should be done next? Use the
[dossier template](assessment/gene-dossier-template.md).
