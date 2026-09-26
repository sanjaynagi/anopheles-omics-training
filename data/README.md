# Data manifest

All data used in the course is public. Items marked **TODO** still need preparing and hosting (Zenodo).

| Item | Source | Status | Used in |
|---|---|---|---|
| Busia RNA-seq reads | ENA PRJNA748581 | public | 1.4 |
| Busia mini dataset `busia-mini.tar.gz` (1 M read pairs × 16 runs + reference) | `prepare_busia_mini.sh` | TODO | 1.4 |
| Busia RNA-Seq-Pop full results `busia-rna-seq-pop-results.tar.gz` | RNA-Seq-Pop v2.3.0 on HPC; file list in `workflows/rna-seq-pop/README.md` | TODO | 2.1, 2.2 |
| AnoExpress data | bundled with `anoexpress` | public | 2.3, 3.1 |
| Ag3 WGS data | MalariaGEN via `malariagen_data` | public | 3.1–4.1 |
| Selection atlas signal table | selection-atlas repo | **TODO: not yet at a public URL** | 3.2, 3.3 |
| Ag-vampIR amplicon reads (Siaya, VK7) | SRA PRJNA1207724 | public | 4.3 |
| Ag-vampIR reads download | `prepare_siaya.sh` | script ready | 4.3 |
| AmpSeeker results bundle `ampseeker-siaya-vk7-results.tar.gz` (Siaya + VK7) | AmpSeeker v0.7.0 run; file list in `workflows/ampseeker/README.md` | TODO | 4.3 |
| Candidate gene pool (26 genes; CYP6AA1 = focal) | `make_candidate_genes.py` | draft | all analysis modules |
