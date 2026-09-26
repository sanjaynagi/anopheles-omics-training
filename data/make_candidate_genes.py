"""Build data/candidate-genes.tsv, the pool of candidate genes handed out on Day 2.

Run from anywhere:

    uv run --no-project --with pandas python data/make_candidate_genes.py

What it does
------------
1. Loads the AnoExpress (v0.3.3) fold changes and adjusted p-values for the
   `gamb_colu` analysis (18 RNA-seq contrasts in An. gambiae / An. coluzzii).
2. Takes the curated gene list below and checks that every gene is significantly
   overexpressed (padj < 0.05, log2FC > 0) in `BusiaSurvivors_v_Kisumu`.
3. Adds gene coordinates (AgamP4, Ensembl Metazoa release 63 GFF3), the number of
   gamb_colu contrasts in which each gene is overexpressed, whether it lies inside
   a selection-atlas signal (span2) for cohort `UG-E_Busia_gamb_2016_Q2`, and
   whether an Ag-vampIR amplicon target lies within 50 kb.

Notes
-----
* The AnoExpress Busia contrast is G28 deltamethrin-selected *survivors* vs the
  susceptible Kisumu strain. The course's own RNA-Seq-Pop run also gives
  selected vs parental (G24) and parental vs Kisumu. Genes that respond mainly to
  selection within the colony (for example the Sap genes, which the RNA-Seq-Pop
  paper reports as overexpressed in selected vs parental) are therefore missing
  here and should be added once the full RNA-Seq-Pop results are available.
* Several classic East African IR genes are NOT overexpressed in this contrast and
  so are not in the pool: CYP6P3 (log2FC -3.4), CYP6P4, CYP6M2, GSTE2 (-2.2),
  CYP9K1 (-0.4), CYP6AA1 (n.s.), SAP2 (padj missing). The Kisumu samples in this
  batch express CYP6P3 and GSTE2 highly. Module 2.3 uses this as a teaching point.
* `n_experiments_overexpressed` counts all 18 gamb_colu contrasts, including
  the Busia contrast itself.
* Compound contigs in the selection atlas: 2RL = 2R then 2L, 3RL = 3R then 3L.
  Arm lengths (AgamP4) are taken from selection-atlas
  `sweepclust/resources/ag3-arm-lengths.tsv`: 2R = 61,545,105 bp,
  3R = 53,200,684 bp. The same offsets are used in anoexpress.utils.load_gff.
"""

import argparse
from pathlib import Path

import pandas as pd

HERE = Path(__file__).resolve().parent

ANOEXPRESS = "https://raw.githubusercontent.com/sanjaynagi/AnoExpress/v0.3.3"
GFF_URL = (
    "https://ftp.ensemblgenomes.ebi.ac.uk/pub/metazoa/release-63/gff3/"
    "anopheles_gambiae/Anopheles_gambiae.AgamP4.63.chr.gff3.gz"
)
AGVAMPIR_BED = (
    "https://raw.githubusercontent.com/sanjaynagi/AmpSeeker/864ba69/config/ag-vampir.bed"
)
# TODO(data): the selection-atlas signal table is not yet at a public URL. Point this at
# a local copy of h12-signal-detection-all.csv (selection-atlas repo root) until it is.
SIGNALS = HERE.parent.parent / "selection-atlas" / "h12-signal-detection-all.csv"

CONTRAST = "BusiaSurvivors_v_Kisumu"
COHORT = "UG-E_Busia_gamb_2016_Q2"
LEN_2R = 61_545_105
LEN_3R = 53_200_684
PANEL_WINDOW = 50_000

# Curated pool. known_ir = previously implicated in insecticide resistance in Anopheles
# (or, for COEBE3C, highlighted by the Busia RNA-Seq-Pop paper itself).
# novel = strongly DE and/or widely replicated and/or inside a Busia sweep, but little studied.
CANDIDATES = {
    # The course's worked example, used by every module. Not significant in the
    # AnoExpress survivors-vs-Kisumu contrast, but upregulated and duplicated in the
    # Uganda/Kenya "triple mutant" haplotype (Cyp6aa1 dup + Cyp6p4-I236M + ZZB TE;
    # Njoroge et al. 2022, Mol Ecol, doi:10.1111/mec.16591), which Ag-vampIR tags.
    "AGAP002862": "focal",  # CYP6AA1, Cyp6aa/p cluster (2R sweep)
    # known IR genes
    "AGAP009193": "known_ir",  # GSTE4, Gste cluster (3R sweep)
    "AGAP009197": "known_ir",  # GSTE3, Gste cluster (3R sweep)
    "AGAP008219": "known_ir",  # CYP6Z1
    "AGAP008217": "known_ir",  # CYP6Z3
    "AGAP000877": "known_ir",  # CYP4G17, cuticular hydrocarbons
    "AGAP009946": "known_ir",  # GSTMS3
    "AGAP005756": "known_ir",  # COEAE1D (Ag-vampIR Coeae1d_tag)
    "AGAP006227": "known_ir",  # COEAE1F
    "AGAP005372": "known_ir",  # COEBE3C (Busia RNA-Seq-Pop paper)
    # less-studied genes
    "AGAP028019": "novel",  # CYP4H18, up in 16/18 contrasts
    "AGAP009246": "novel",  # CYP4C27, up in 15/18 contrasts
    "AGAP005499": "novel",  # SDR family member 11, up in 16/18 contrasts
    "AGAP002894": "novel",  # CYP6Z4, inside the 2R Cyp6 sweep
    "AGAP002852": "novel",  # unannotated, inside the 2R Cyp6 sweep
    "AGAP002850": "novel",  # Niemann-Pick type C-2, inside the 2R Cyp6 sweep
    "AGAP009184": "novel",  # unannotated, inside the 3R Gste sweep
    "AGAP000833": "novel",  # MIP, inside the X Cyp9k1 sweep
    "AGAP000834": "novel",  # unannotated, inside the X Cyp9k1 sweep
    "AGAP006521": "novel",  # G-alpha-s, inside the 2L 34 Mb sweep
    "AGAP006548": "novel",  # glycine cleavage H, 2L 34 Mb sweep, next to 34mb tags
    "AGAP005373": "novel",  # COEBE1C, strongly DE carboxylesterase
    "AGAP011909": "novel",  # unannotated, log2FC 5, up in 12/18
    "AGAP003221": "novel",  # ABCC3
    "AGAP011564": "novel",  # UGT
    "AGAP008331": "novel",  # WD repeat-containing protein 59
}


def load_anoexpress():
    fc = pd.read_csv(f"{ANOEXPRESS}/results/fcs.gamb_colu.tsv", sep="\t", index_col="GeneID")
    padj = pd.read_csv(f"{ANOEXPRESS}/results/pvals.gamb_colu.tsv", sep="\t", index_col="GeneID")
    annots = pd.read_csv(f"{ANOEXPRESS}/resources/AgamP4.annots.tsv", sep="\t", index_col="GeneID")
    return fc, padj, annots


def load_genes():
    gff = pd.read_csv(
        GFF_URL, sep="\t", comment="#", header=None, usecols=[0, 2, 3, 4, 8],
        names=["contig", "type", "start", "end", "attributes"],
    )
    gff = gff.query("type == 'gene'").copy()
    gff["GeneID"] = gff["attributes"].str.extract(r"gene_id=([^;]+)")[0]
    return gff.set_index("GeneID")[["contig", "start", "end"]]


def to_compound(contig, pos):
    """AgamP4 arm coordinate -> selection-atlas compound contig coordinate."""
    if contig == "2R":
        return "2RL", pos
    if contig == "2L":
        return "2RL", pos + LEN_2R
    if contig == "3R":
        return "3RL", pos
    if contig == "3L":
        return "3RL", pos + LEN_3R
    return contig, pos


def in_busia_sweep(row, signals):
    contig, start = to_compound(row.contig, row.start)
    _, end = to_compound(row.contig, row.end)
    hits = signals.query("contig == @contig and span2_pstart <= @end and span2_pstop >= @start")
    return not hits.empty


def on_agvampir(row, bed):
    near = bed.query(
        "contig == @row.contig and pos >= @row.start - @PANEL_WINDOW and pos <= @row.end + @PANEL_WINDOW"
    )
    return not near.empty


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--signals", default=str(SIGNALS), help="path to h12-signal-detection-all.csv")
    parser.add_argument("--out", default=str(HERE / "candidate-genes.tsv"))
    args = parser.parse_args()

    fc, padj, annots = load_anoexpress()
    genes = load_genes()
    signals = pd.read_csv(args.signals).query("cohort_id == @COHORT")
    bed = pd.read_csv(AGVAMPIR_BED, sep="\t", header=None, usecols=[0, 2, 4], names=["contig", "pos", "target"])

    ids = list(CANDIDATES)
    df = pd.DataFrame(index=pd.Index(ids, name="gene_id"))
    df["gene_name"] = annots["GeneName"].reindex(ids)
    df["description"] = (
        annots["GeneDescription"].reindex(ids).str.replace(r"\s*\[Source:.*\]", "", regex=True)
        .fillna("unannotated")
    )
    df = df.join(genes)
    df["busia_log2fc"] = fc.loc[ids, CONTRAST]
    df["busia_padj"] = padj.loc[ids, CONTRAST]
    df["category"] = [CANDIDATES[g] for g in ids]
    df["n_experiments_overexpressed"] = ((fc > 0) & (padj < 0.05)).sum(axis=1).loc[ids]
    df["in_busia_sweep"] = df.apply(in_busia_sweep, axis=1, signals=signals)
    df["on_agvampir"] = df.apply(on_agvampir, axis=1, bed=bed)

    bad = df.query("category != 'focal' and not (busia_padj < 0.05 and busia_log2fc > 0)")
    assert bad.empty, f"not significantly overexpressed in {CONTRAST}: {list(bad.index)}"
    assert df[["contig", "start", "end"]].notna().all().all(), "missing coordinates"

    df = df.astype({"start": int, "end": int}).sort_values(["category", "busia_log2fc"], ascending=[True, False])
    df.to_csv(args.out, sep="\t")
    print(df.drop(columns="description").to_string())
    print(f"\nWrote {len(df)} genes to {args.out}")


if __name__ == "__main__":
    main()
