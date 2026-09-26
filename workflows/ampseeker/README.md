# AmpSeeker: Siaya + VK7 Ag-vampIR data

Configuration for running [AmpSeeker](https://github.com/sanjaynagi/AmpSeeker) **v0.7.0** on the
Ag-vampIR amplicon data from Nagi *et al.* (2025), SRA/ENA
[PRJNA1207724](https://www.ebi.ac.uk/ena/browser/view/PRJNA1207724). Used in Module 4.3.

| File | What it is |
|---|---|
| `config.yaml` | AmpSeeker config (`dataset: siaya-vk7`, `from-bcl: False`, FASTQ auto-naming, custom snpEff database) |
| `metadata.tsv` | Sample sheet: 360 samples (Siaya 264, VK7 96) |

## The samples

| Cohort | n | Notes |
|---|---|---|
| `Siaya_dead`, `Siaya_alive` | 131 + 131 | Siaya colony (western Kenya, established 2023), exposed to PermaNet 2.0 (deltamethrin) in 40-minute WHO cone tests |
| `VK7_dead`, `VK7_alive` | 48 + 47 | VK7 colony (*An. coluzzii*, Vallée du Kou, Burkina Faso, established 2014). The paper does not report which insecticide (`insecticide: not_reported`). `VK7_dead` includes six `_dil` dilution replicates |
| `negative_control` | 3 | `Siaya_Delta_Dead_Negative`, `Siaya_Delta_Alive_Negative`, `VK7_Negative` |

Columns: `sample_id` (= ENA `sample_alias`), `run_accession`, `location`, `country`, `cohort`,
`phenotype` (dead / alive / negative_control), `insecticide`, `taxon` (`unassigned`; AmpSeeker's
species-ID step fills it in), `plate`, `well_letter`, `well_number` (from the paper's
`metadata_ms.tsv`), `latitude`, `longitude` (approximate place of origin of each colony, not
collection sites). AmpSeeker's sample QC removes the negatives and `_dil` samples by name.

## Running it (GitHub Codespace)

The codespace's setup script clones AmpSeeker v0.7.0 to `/workspaces/AmpSeeker` and installs
Snakemake 7.32.4 with pixi (`workflows/pixi.toml`), so `snakemake` is on the PATH in every terminal.
Elsewhere: `pixi shell --manifest-path workflows/pixi.toml`.

```bash
cd /workspaces/malaria-software-training
bash data/prepare_siaya.sh          # all 360 samples (~0.8 GB); add "-n 12" for a 51-sample class run
cd /workspaces/AmpSeeker
snakemake --cores 4 --use-conda --configfile config/siaya.yaml -n    # dry run (~4,000 jobs for all samples)
snakemake --cores 4 --use-conda --configfile config/siaya.yaml
```

`prepare_siaya.sh` downloads the FASTQs from ENA (checking MD5s) to
`resources/reads/{sample_id}_1.fastq.gz` / `_2.fastq.gz`, which is where AmpSeeker looks when
`from-bcl: False` and the metadata has no `fq1`/`fq2` columns. It copies this folder's files to
`config/siaya.yaml` and `config/siaya-metadata.tsv` (only the samples downloaded), and writes the
AgamP4 reference (chromosome arms, Ensembl Metazoa release 63) to `resources/reference/AgamP4.fa`
and `AgamP4.gff3`.

Two departures from AmpSeeker's defaults, and why:
- **Reference from Ensembl**: `resources/reference/download-vectorbase-reference.sh` in AmpSeeker
  points at VectorBase release 66, which now returns 404.
- **`custom-snpeffdb: True`**: the prebuilt snpEff 5.1 `Anopheles_gambiae` database could not be
  downloaded when this was written; building one from the Ensembl FASTA + GFF3 avoids it.

Snakemake: with the pixi environment (7.32.4 plus `conda`), `--use-conda` dry runs build the full
DAG for this config and for RNA-Seq-Pop v2.3.0 (8.30.0 also works; 9.x breaks RNA-Seq-Pop v2.3.0).
The codespace profile sets `conda-frontend: conda`, because mamba is not installed.

## Results bundle for the course (Zenodo, TODO)

Module 4.3 reads a bundle from a full run, `ampseeker-siaya-vk7-results.tar.gz`, containing these
paths relative to the AmpSeeker folder:

```
config/siaya.yaml
config/siaya-metadata.tsv
config/ag-vampir.bed
results/config/metadata.tsv
results/config/metadata.qcpass.tsv
results/vcfs/targets/siaya-vk7.annot.vcf
results/vcfs/amplicons/siaya-vk7.annot.vcf
results/coverage/amplicon_by_sample_depth.xlsx
results/ag-vampir/aims/taxon_aims.tsv
results/ag-vampir/kdr-origins/kdr_origins.tsv
results/snp_frequencies_summary.tsv
results/qc/multiqc/multiqc_report.html
```

Make it with:

```bash
cd /path/to/AmpSeeker
tar czf ampseeker-siaya-vk7-results.tar.gz \
  config/siaya.yaml config/siaya-metadata.tsv config/ag-vampir.bed \
  results/config/metadata.tsv results/config/metadata.qcpass.tsv \
  results/vcfs/targets/siaya-vk7.annot.vcf results/vcfs/amplicons/siaya-vk7.annot.vcf \
  results/coverage/amplicon_by_sample_depth.xlsx \
  results/ag-vampir/aims/taxon_aims.tsv results/ag-vampir/kdr-origins/kdr_origins.tsv \
  results/snp_frequencies_summary.tsv results/qc/multiqc/multiqc_report.html
```

The results book (`results/ampseeker-results/_build/html/`) can be published to GitHub Pages
separately; until then, the notebook links to the paper's book at
https://sanjaynagi.github.io/agvampir002-results/.
