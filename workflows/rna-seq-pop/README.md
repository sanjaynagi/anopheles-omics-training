# RNA-Seq-Pop on the Busia RNA-seq data

This folder holds the RNA-Seq-Pop configuration for the course study: RNA-seq of
*Anopheles gambiae* from Busia, Uganda (Nagi *et al.* 2023, ENA
[PRJNA748581](https://www.ebi.ac.uk/ena/browser/view/PRJNA748581)).

| File | What it is |
|---|---|
| `config.yaml` | RNA-Seq-Pop configuration (copy to `config/config.yaml` in the rna-seq-pop clone) |
| `samples.tsv` | Sample sheet (copy to `config/samples.tsv`) |

Module [1.4](../../day-1/1-4-running-rna-seq-pop.ipynb) walks through these steps in detail.

## The samples

16 paired-end NovaSeq libraries. Each library is RNA from a **pool of five females**,
so variants are called with `ploidy: 10`.

| Treatment (`samples.tsv`) | Samples (ENA `sample_alias`) | What they are |
|---|---|---|
| `Kisumu` | Kis1–Kis4 | Lab-susceptible reference strain, unexposed |
| `BusiaParental` | BusSus1–BusSus6 | Busia colony, generation 24, **not** selected or exposed |
| `BusiaSelected` | BusRes1–BusRes6 | Busia G28 after four generations of deltamethrin selection; survivors of a 1 h 0.05% deltamethrin exposure |

"BusSus" in the ENA names does not mean the parental line is fully susceptible; it
is the unselected parent line. Treatment names must not contain underscores,
because RNA-Seq-Pop splits contrasts on `_`.

The `strain` column is set to the treatment so that freebayes treats each group as
a separate population (RNA-Seq-Pop v2.3.0 passes `strain` to `freebayes --populations`).

Contrasts (`control_case`, log2 fold change > 0 = higher in the case group):

- `Kisumu_BusiaParental`
- `BusiaParental_BusiaSelected`
- PBS: `BusiaSelected_BusiaParental_Kisumu` (branch length of the selected line, Kisumu as outgroup)

## Pinned version

**RNA-Seq-Pop v2.3.0** (git tag `v2.3.0`, commit `38869ef`, December 2024), the latest
release. The `master` branch has since renamed rules and changed the
variants-of-interest outputs, so always check out the tag.

Snakemake: **7.32.4** (the version RNA-Seq-Pop's CI uses), with `pulp<2.8`
(newer pulp breaks Snakemake 7).

Two package managers are involved:

- **pixi** runs Snakemake itself. The environment is `workflows/pixi.toml` (with its lock file); in
  the Codespace it is activated in every terminal by a shell hook in `~/.bashrc`. Outside the
  Codespace: `pixi shell --manifest-path workflows/pixi.toml`.
- **conda** builds RNA-Seq-Pop's per-rule environments (`workflow/envs/*.yaml`) when Snakemake runs
  with `--use-conda`, so it must be installed too, with `channel_priority flexible`. The Codespace's
  Snakemake profile (`$SNAKEMAKE_PROFILE`) sets `conda-frontend: conda` (Snakemake 7 cannot drive
  mamba 2) and `rerun-incomplete: true`. Elsewhere, pass `--conda-frontend conda --rerun-incomplete`
  yourself.

We recommend pixi for participants' own projects.

## Reference files

RNA-Seq-Pop does not download references; you provide them. The paper used the
VectorBase AgamP4.12 files, but VectorBase downloads are no longer openly available,
so we use **AgamP4 from Ensembl Metazoa release 63**:

- genome: chromosome arms 2L, 2R, 3L, 3R, X (`Anopheles_gambiae.AgamP4.dna.chromosomes.fa.gz`)
- transcriptome: `Anopheles_gambiae.AgamP4.cdna.all.fa.gz`
- GFF3 with the Ensembl `gene:`/`transcript:` ID prefixes removed (`...63.chr.clean.gff3`)
- gene-to-transcript map built from the cDNA headers, with gene names from RNA-Seq-Pop's curated map (`Gene2TranscriptMap.AgamP4.63.tsv`)
- GO annotations from the eggNOG-mapper file shipped with RNA-Seq-Pop (`AgamP4_eggnog_GO.gaf`)

`data/prepare_busia_mini.sh --reference` builds all five. The mini-dataset tarball on
Zenodo already contains them. The variants-of-interest table
(`resources/exampleMutations.tsv`) and the AIM and karyotype files come with RNA-Seq-Pop.

## Run in GitHub Codespaces (course mini dataset)

Use a **4-core / 16 GB** codespace. In **GitHub → Settings → Codespaces**, set the
default idle timeout to 240 minutes: a codespace stops after the idle timeout even if
Snakemake is still running. (If it stops, restart it and rerun the same command;
Snakemake picks up where it left off.)

```bash
# 1. The Codespace setup already cloned RNA-Seq-Pop v2.3.0 here; check the tag
cd /workspaces/rna-seq-pop
git describe --tags     # v2.3.0

# 2. Add the Busia configuration
cp /workspaces/anopheles-omics-training/workflows/rna-seq-pop/config.yaml config/config.yaml
cp /workspaces/anopheles-omics-training/workflows/rna-seq-pop/samples.tsv config/samples.tsv

# 3. Get the mini dataset (reads/ and reference/) into resources/
BUSIA_MINI_URL="..."   # TODO(data): Zenodo record of the Busia mini dataset (busia-mini.tar.gz)
curl -L -o busia-mini.tar.gz "$BUSIA_MINI_URL"
tar -xzf busia-mini.tar.gz -C resources
ls resources/reads resources/reference

# 4. Dry run: check the configuration and list the jobs (535 jobs for 16 samples)
snakemake --cores 4 --use-conda -n

# 5. Draw the rule graph (RNA-Seq-Pop prints a banner first, so strip it before dot)
snakemake --rulegraph | sed -n '/^digraph/,$p' | dot -Tsvg > rulegraph.svg

# 6. (optional) build all the conda environments first, which takes the longest
snakemake --cores 4 --use-conda --conda-create-envs-only

# 7. Run in the background and follow the log
nohup snakemake --cores 4 --use-conda --keep-going > snakemake-run.log 2>&1 &   # profile adds --rerun-incomplete
tail -f snakemake-run.log
```

Outside the Codespace (no profile), add `--conda-frontend conda --rerun-incomplete` to these commands.

When it finishes, open `results/rna-seq-pop-results/_build/html/index.html` (the results
book) and `results/qc/multiQC.html`.

## Run on HPC (full dataset, instructors)

The Day 2 notebooks read results from the full run (all reads), hosted on Zenodo.

```bash
bash data/prepare_busia_mini.sh -n 0 -o busia-full     # ~113 GB download, MD5-checked
git clone --branch v2.3.0 --depth 1 https://github.com/sanjaynagi/rna-seq-pop.git
cd rna-seq-pop
cp <course>/workflows/rna-seq-pop/{config.yaml,samples.tsv} config/
mv ../busia-full/reads/* resources/reads/
mv ../busia-full/reference/* resources/reference/
snakemake --cores 32 --use-conda --conda-frontend conda --rerun-incomplete --keep-going
# or with a cluster profile, e.g. snakemake --profile slurm --use-conda --jobs 50
```

Then package these files (paths relative to the rna-seq-pop root) as
`busia-rna-seq-pop-results.tar.gz` for Zenodo. Modules 2.1 and 2.2 read them:

```
config/config.yaml
config/samples.tsv
results/qc/multiQC.html
results/qc/coverage/{sample}.mosdepth.summary.txt          (16 files)
results/counts/countStatistics.tsv
results/counts/KallistoQuantSummary.tsv
results/counts/normCounts.tsv
results/counts/rawcounts.tsv
results/genediff/Kisumu_BusiaParental.csv
results/genediff/BusiaParental_BusiaSelected.csv
results/genediff/nsig_genes.tsv
results/genediff/Ag_Busia_diffexp.xlsx
results/isoformdiff/Kisumu_BusiaParental.csv
results/isoformdiff/BusiaParental_BusiaSelected.csv
results/gsea/genediff/Kisumu_BusiaParental.de.tsv
results/gsea/genediff/BusiaParental_BusiaSelected.de.tsv
results/gsea/fst/Kisumu_BusiaParental.fst.tsv
results/gsea/fst/BusiaParental_BusiaSelected.fst.tsv
results/variantAnalysis/SNPstats/snpsPerGenomicFeature.tsv
results/variantAnalysis/SNPstats/totalSNPs.tsv
results/variantAnalysis/variantsOfInterest/csvs/{mut}_alleleBalance.csv        (22 files)
results/variantAnalysis/variantsOfInterest/csvs/mean_{mut}_alleleBalance.csv   (22 files)
results/variantAnalysis/selection/FstPerGene.tsv
results/variantAnalysis/selection/PbsPerGene.tsv
results/variantAnalysis/selection/TajimasDPerGene.tsv
results/variantAnalysis/selection/fst/{1000,2000,5000}snp_window/{contrast}.Fst.{contig}.tsv
results/variantAnalysis/selection/pbs/{1000,2000,5000}snp_window/BusiaSelected_BusiaParental_Kisumu.PBS.{contig}.tsv
results/variantAnalysis/diversity/SequenceDiversity.tsv
results/variantAnalysis/diversity/WattersonsTheta.tsv
results/variantAnalysis/diversity/SequenceDivPerGene.tsv
results/variantAnalysis/diversity/DxyPerGene.tsv
results/variantAnalysis/diversity/inbreedingCoef.mean.tsv
results/variantAnalysis/ancestry/AIMs_summary.tsv
results/variantAnalysis/ancestry/n_AIMS_per_chrom.tsv
results/variantAnalysis/ancestry/AIM_fraction_{contig}.tsv
results/karyotype/karyotypes.tsv
results/rna-seq-pop-results/_build/html/                   (results book, also for GitHub Pages)
```

Before packaging, check that the headline results match the paper: ~5,400 and ~5,700
DE genes (padj < 0.05) in the two contrasts, SAP2 ~10-fold up in `BusiaSelected`,
Vgsc 995S rising from ~25% to ~100%, and 2La from ~33% to ~86%.
