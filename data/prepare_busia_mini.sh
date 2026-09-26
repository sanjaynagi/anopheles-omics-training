#!/usr/bin/env bash
# prepare_busia_mini.sh
# ----------------------------------------------------------------------------
# Build the Busia RNA-seq inputs for RNA-Seq-Pop (v2.3.0):
#
#   1. reads      Download the 16 paired-end FASTQ pairs of ENA PRJNA748581
#                 (Nagi et al. 2023), check their MD5s and subsample each pair
#                 to N read pairs with seqtk (same seed for R1 and R2, so the
#                 pairs stay in sync). Output: <outdir>/reads/<sampleID>_1.fastq.gz
#                 and _2.fastq.gz, the names RNA-Seq-Pop expects when
#                 `fastq: auto: True`.
#   2. reference  Download AgamP4 from Ensembl Metazoa (release 63) and make the
#                 files named in workflows/rna-seq-pop/config.yaml: genome,
#                 transcriptome, cleaned GFF3, gene-to-transcript map and a
#                 GO annotation (GAF-like) file.
#
# The mini dataset (default 1,000,000 pairs per sample, ~1.5 GB) is what course
# participants run in GitHub Codespaces. Instructors run this ONCE and upload
# the tarball to Zenodo; participants do not need to run it.
#
# Usage
#   bash data/prepare_busia_mini.sh [options]
#
#   -n N          read pairs per sample (default 1000000; 0 = keep all reads)
#   -o DIR        output directory (default busia-mini)
#   -s SEED       seqtk seed (default 11)
#   -r DIR        rna-seq-pop clone, used for the gene-name and GO source files
#                 (default: clones tag v2.3.0 into DIR/.rna-seq-pop)
#   --reads       only do step 1
#   --reference   only do step 2
#   --tar         also write <outdir>.tar.gz for upload to Zenodo
#
# Requirements: bash, curl, awk, gzip, md5sum (or md5 on macOS), seqtk, git.
#   e.g.  mamba create -n busia-prep -c conda-forge -c bioconda seqtk curl git
#
# Disk: raw files are processed one sample at a time and deleted afterwards,
# so you need ~8 GB free scratch space plus the output (~1.5 GB at 1 M pairs).
# The whole project is ~113 GB to download, so run this on a server or HPC
# with a good connection, not in a Codespace.
#
# FULL dataset (reference results for Day 2)
#   The course's precomputed results come from RNA-Seq-Pop run on ALL reads:
#       bash data/prepare_busia_mini.sh -n 0 -o busia-full
#   (-n 0 skips subsampling and keeps the verified raw FASTQs under the
#   RNA-Seq-Pop names.) Then on HPC, from a clone of rna-seq-pop at v2.3.0:
#       cp -r busia-full/reads/*        resources/reads/
#       cp -r busia-full/reference/*    resources/reference/
#       cp <course>/workflows/rna-seq-pop/config.yaml  config/config.yaml
#       cp <course>/workflows/rna-seq-pop/samples.tsv  config/samples.tsv
#       snakemake --cores 32 --use-conda --rerun-incomplete --keep-going
#   or submit through your scheduler (e.g. `--slurm` / a snakemake profile).
#   Expect ~1-2 days on 32 cores and ~400 GB of working space (BAMs, VCFs).
#   See workflows/rna-seq-pop/README.md for the files to package for Zenodo.
# ----------------------------------------------------------------------------
set -euo pipefail

PROJECT="PRJNA748581"
RNASEQPOP_TAG="v2.3.0"
ENSEMBL_RELEASE="63"
ENSEMBL="https://ftp.ensemblgenomes.ebi.ac.uk/pub/metazoa/release-${ENSEMBL_RELEASE}"
CONTIGS=(2L 2R 3L 3R X)

N=1000000
OUTDIR="busia-mini"
SEED=11
RSP_DIR=""
DO_READS=1
DO_REF=1
DO_TAR=0

usage() { sed -n '2,52p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n) N="$2"; shift 2 ;;
    -o) OUTDIR="$2"; shift 2 ;;
    -s) SEED="$2"; shift 2 ;;
    -r) RSP_DIR="$2"; shift 2 ;;
    --reads) DO_REF=0; shift ;;
    --reference) DO_READS=0; shift ;;
    --tar) DO_TAR=1; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
done

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >&2; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: '$1' not found on PATH" >&2; exit 1; }; }

md5_of() {
  if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1
  else md5 -q "$1"; fi
}

fetch() {  # fetch URL DEST, with retries and resume
  curl -fsSL --retry 10 --retry-delay 30 --retry-all-errors -C - -o "$2" "$1"
}

mkdir -p "$OUTDIR"

# ---------------------------------------------------------------------------
# 1. Reads
# ---------------------------------------------------------------------------
prepare_reads() {
  need curl; need awk; need gzip
  [[ "$N" -gt 0 ]] && need seqtk
  local readdir="$OUTDIR/reads" tmpdir="$OUTDIR/.raw"
  mkdir -p "$readdir" "$tmpdir"

  # The ENA filereport API gives one row per run. sample_alias is the sample
  # name used in the paper and in workflows/rna-seq-pop/samples.tsv
  # (Kis1-4, BusSus1-6 = parental G24, BusRes1-6 = selected G28).
  local report="$OUTDIR/${PROJECT}_filereport.tsv"
  log "Fetching ENA file report for $PROJECT"
  curl -fsSL --retry 5 \
    "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${PROJECT}&result=read_run&fields=run_accession,sample_alias,read_count,fastq_ftp,fastq_md5,fastq_bytes&format=tsv" \
    > "$report"
  log "$(($(wc -l < "$report") - 1)) runs listed (expected 16)"

  # columns: run_accession sample_alias read_count fastq_ftp fastq_md5 fastq_bytes
  tail -n +2 "$report" | sort -k2,2V | while IFS=$'\t' read -r run sample nreads ftp md5s _bytes; do
    local out1="$readdir/${sample}_1.fastq.gz" out2="$readdir/${sample}_2.fastq.gz"
    if [[ -s "$out1" && -s "$out2" ]]; then
      log "$sample ($run): output exists, skipping"; continue
    fi
    log "$sample ($run): $nreads read pairs on ENA"

    IFS=';' read -r url1 url2 <<< "$ftp"
    IFS=';' read -r md51 md52 <<< "$md5s"
    local raw1="$tmpdir/${run}_1.fastq.gz" raw2="$tmpdir/${run}_2.fastq.gz"

    for pair in "1|$url1|$md51|$raw1" "2|$url2|$md52|$raw2"; do
      IFS='|' read -r mate url md5 raw <<< "$pair"
      if [[ ! -s "$raw" || "$(md5_of "$raw")" != "$md5" ]]; then
        log "  downloading R$mate"
        fetch "https://${url}" "$raw"
      fi
      [[ "$(md5_of "$raw")" == "$md5" ]] || { echo "ERROR: MD5 mismatch for $raw" >&2; exit 1; }
    done

    if [[ "$N" -eq 0 ]]; then
      mv "$raw1" "$out1"; mv "$raw2" "$out2"
    else
      # seqtk sample with the same seed and N on both mates keeps pairs in sync,
      # because both files list the reads in the same order.
      log "  subsampling to $N pairs (seed $SEED)"
      seqtk sample -s "$SEED" "$raw1" "$N" | gzip -c > "$out1.tmp"
      seqtk sample -s "$SEED" "$raw2" "$N" | gzip -c > "$out2.tmp"
      # sanity check: same number of reads, and matching read names at the start
      local c1 c2
      c1=$(gzip -dc "$out1.tmp" | awk 'END{print NR/4}')
      c2=$(gzip -dc "$out2.tmp" | awk 'END{print NR/4}')
      [[ "$c1" == "$c2" ]] || { echo "ERROR: $sample R1/R2 read counts differ ($c1 vs $c2)" >&2; exit 1; }
      if ! cmp -s <(gzip -dc "$out1.tmp" | awk 'NR%4==1{print $1}' | head -1000 | sed 's#/1$##') \
                  <(gzip -dc "$out2.tmp" | awk 'NR%4==1{print $1}' | head -1000 | sed 's#/2$##'); then
        echo "ERROR: $sample R1/R2 read names are out of sync" >&2; exit 1
      fi
      mv "$out1.tmp" "$out1"; mv "$out2.tmp" "$out2"
      rm -f "$raw1" "$raw2"
    fi
    log "  wrote $out1 and $out2"
  done
  rmdir "$tmpdir" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# 2. Reference (Ensembl Metazoa AgamP4)
# ---------------------------------------------------------------------------
prepare_reference() {
  need curl; need awk; need gzip; need git
  local refdir="$OUTDIR/reference"
  mkdir -p "$refdir"

  if [[ -z "$RSP_DIR" ]]; then
    RSP_DIR="$OUTDIR/.rna-seq-pop"
    [[ -d "$RSP_DIR" ]] || git clone -q --depth 1 --branch "$RNASEQPOP_TAG" \
      https://github.com/sanjaynagi/rna-seq-pop.git "$RSP_DIR"
  fi

  # Genome: chromosome arms only (no Mt, UNKN or Y_unplaced), gzip-compressed.
  local genome="$refdir/Anopheles_gambiae.AgamP4.dna.chromosomes.fa.gz"
  if [[ ! -s "$genome" ]]; then
    log "Downloading genome (Ensembl Metazoa release $ENSEMBL_RELEASE)"
    : > "$genome.tmp"
    for c in "${CONTIGS[@]}"; do
      curl -fsSL --retry 5 \
        "$ENSEMBL/fasta/anopheles_gambiae/dna/Anopheles_gambiae.AgamP4.dna.chromosome.${c}.fa.gz" \
        | gzip -dc | awk 'NR==1{print $1; next}{print}' | gzip -c >> "$genome.tmp"
    done
    mv "$genome.tmp" "$genome"
  fi

  # Transcriptome: all cDNAs. Headers start with the transcript ID (AGAP000002-RA),
  # which is all kallisto keeps.
  local cdna="$refdir/Anopheles_gambiae.AgamP4.cdna.all.fa.gz"
  if [[ ! -s "$cdna" ]]; then
    log "Downloading transcriptome"
    fetch "$ENSEMBL/fasta/anopheles_gambiae/cdna/Anopheles_gambiae.AgamP4.cdna.all.fa.gz" "$cdna"
  fi

  # GFF3: Ensembl prefixes IDs (ID=gene:AGAP004707, Parent=transcript:...). RNA-Seq-Pop
  # matches GFF gene IDs to plain AGAP IDs, so strip the prefixes.
  local gff="$refdir/Anopheles_gambiae.AgamP4.${ENSEMBL_RELEASE}.chr.clean.gff3"
  if [[ ! -s "$gff" ]]; then
    log "Downloading and cleaning GFF3"
    curl -fsSL --retry 5 "$ENSEMBL/gff3/anopheles_gambiae/Anopheles_gambiae.AgamP4.${ENSEMBL_RELEASE}.chr.gff3.gz" \
      | gzip -dc \
      | sed -E 's/(ID|Parent)=(gene|transcript|CDS):/\1=/g' > "$gff"
  fi

  # Gene-to-transcript map: GeneID, TranscriptID, GeneName, GeneDescription.
  # Transcripts come from the Ensembl cDNA headers (so every kallisto target has a
  # gene); names/descriptions come from the curated RNA-Seq-Pop map (VectorBase
  # community names used in the paper), falling back to the Ensembl GFF.
  local g2t="$refdir/Gene2TranscriptMap.AgamP4.${ENSEMBL_RELEASE}.tsv"
  log "Writing $g2t"
  awk -F'\t' -v OFS='\t' '
    FNR==1 { f++ }
    f==1 && FNR>1 { if (!($1 in nm)) { nm[$1]=$3; ds[$1]=$4 }; next }    # rna-seq-pop map
    f==2 && $3=="gene" {                                                   # Ensembl GFF genes
      id=""; name=""; desc=""
      n=split($9, a, ";")
      for (i=1;i<=n;i++) {
        if (a[i] ~ /^ID=/) id=substr(a[i],4)
        else if (a[i] ~ /^Name=/) name=substr(a[i],6)
        else if (a[i] ~ /^description=/) desc=substr(a[i],13)
      }
      gn[id]=name; gd[id]=desc; next
    }
    f==3 && /^>/ {                                                         # cDNA headers
      nf=split($0, h, " "); tx=substr(h[1],2); g=""
      for (i=2;i<=nf;i++) if (h[i] ~ /^gene:/) g=substr(h[i],6)
      name = (g in nm && nm[g]!="" && nm[g]!="\"\"") ? nm[g] : gn[g]
      desc = (g in ds && ds[g]!="") ? ds[g] : gd[g]
      gsub(/"/, "", name); gsub(/%3B/, ";", desc); gsub(/%2C/, ",", desc)
      print g, tx, name, desc
    }
    BEGIN { print "GeneID", "TranscriptID", "GeneName", "GeneDescription" }
  ' "$RSP_DIR/resources/exampleGene2TranscriptMap.tsv" "$gff" <(gzip -dc "$cdna") > "$g2t"

  # GO annotations. RNA-Seq-Pop reads columns 2 (gene) and 5 (GO term) of a GAF.
  # The paper used the VectorBase GAF; here we use the eggNOG-mapper GO terms that
  # ship with rna-seq-pop (one row per gene/GO pair).
  local gaf="$refdir/AgamP4_eggnog_GO.gaf"
  log "Writing $gaf"
  {
    printf 'DB\tDB_Object_ID\tDB_Object_Symbol\tQualifier\tGO_ID\n'
    gzip -dc "$RSP_DIR/resources/Anogam_long.pep_eggnog_diamond.emapper.annotations.tsv.gz" \
      | awk -F'\t' -v OFS='\t' '{
          split($1, a, "_"); g=a[2]; sub(/-R[A-Z]+$/, "", g)
          n=split($2, go, ","); for (i=1;i<=n;i++) print "eggNOG", g, g, "", go[i]
        }' | sort -u
  } > "$gaf"

  log "Reference files in $refdir:"
  ls -lh "$refdir" >&2
}

[[ $DO_READS -eq 1 ]] && prepare_reads
[[ $DO_REF -eq 1 ]] && prepare_reference

if [[ $DO_TAR -eq 1 ]]; then
  log "Writing $OUTDIR.tar.gz"
  tar -czf "$OUTDIR.tar.gz" -C "$OUTDIR" --exclude='.raw' --exclude='.rna-seq-pop' .
  log "Done. Upload $OUTDIR.tar.gz to Zenodo; it unpacks to reads/ and reference/."
fi
log "Finished."
