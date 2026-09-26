#!/usr/bin/env bash
# Prepare the Siaya + VK7 Ag-vampIR amplicon data (SRA/ENA PRJNA1207724) for AmpSeeker.
#
# What it does
#   1. reads   Download paired FASTQs from ENA for the samples in
#              workflows/ampseeker/metadata.tsv, check their MD5 sums, and save them as
#                <ampseeker>/resources/reads/{sample_id}_1.fastq.gz
#                <ampseeker>/resources/reads/{sample_id}_2.fastq.gz
#              This is the naming AmpSeeker expects when from-bcl is False and the
#              metadata has no fq1/fq2 columns ("fastq auto" mode).
#   2. config  Copy the course config and a metadata file that lists only the
#              downloaded samples into <ampseeker>/config/ (siaya.yaml, siaya-metadata.tsv).
#   3. reference  Download AgamP4 (chromosome arms 2L, 2R, 3L, 3R, X) and its GFF3 from
#              Ensembl Metazoa and save them as resources/reference/AgamP4.fa and AgamP4.gff3.
#
# Usage
#   bash data/prepare_siaya.sh [options]
#
# Options
#   -a DIR             AmpSeeker folder (default: /workspaces/AmpSeeker if it exists,
#                      otherwise ./AmpSeeker)
#   -c LIST            locations to include, comma-separated: Siaya,VK7 (default: both)
#   -n N               keep at most N samples per cohort (Siaya_dead, Siaya_alive,
#                      VK7_dead, VK7_alive, negative_control). Default 0 = all 360 samples.
#                      e.g. -n 12 gives a small run for class (51 samples).
#   -j N               parallel downloads (default 8)
#   --no-reference     skip the reference download
#   -h                 show this help
#
# Sizes: Siaya ~0.72 GB (264 samples), VK7 ~0.1 GB (96 samples); reference ~0.3 GB.
# Requires: bash, curl, awk, gzip, md5sum (or md5 on macOS).
#
# Then, from the AmpSeeker folder:
#   snakemake --cores 4 --use-conda --configfile config/siaya.yaml -n   # dry run
#   snakemake --cores 4 --use-conda --configfile config/siaya.yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COURSE_DIR="$(dirname "$SCRIPT_DIR")"
COURSE_CONFIG="$COURSE_DIR/workflows/ampseeker/config.yaml"
COURSE_METADATA="$COURSE_DIR/workflows/ampseeker/metadata.tsv"

PROJECT="PRJNA1207724"
ENA_REPORT="https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${PROJECT}&result=read_run&fields=run_accession,sample_alias,fastq_ftp,fastq_md5,fastq_bytes&format=tsv"
ENSEMBL="https://ftp.ensemblgenomes.ebi.ac.uk/pub/metazoa/release-63"
CONTIGS=(2L 2R 3L 3R X)

if [[ -d /workspaces/AmpSeeker ]]; then AMP_DIR=/workspaces/AmpSeeker; else AMP_DIR=./AmpSeeker; fi
LOCATIONS="Siaya,VK7"
MAX_PER_COHORT=0
JOBS=8
DO_REFERENCE=1

usage() { sed -n '2,37p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a) AMP_DIR="$2"; shift 2 ;;
    -c) LOCATIONS="$2"; shift 2 ;;
    -n) MAX_PER_COHORT="$2"; shift 2 ;;
    -j) JOBS="$2"; shift 2 ;;
    --no-reference) DO_REFERENCE=0; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
done

log() { echo "[prepare_siaya] $*" >&2; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need curl; need awk; need gzip
if command -v md5sum >/dev/null 2>&1; then MD5="md5sum"; elif command -v md5 >/dev/null 2>&1; then MD5="md5 -r"; else
  echo "Missing md5sum (or md5 on macOS)" >&2; exit 1; fi

[[ -f "$AMP_DIR/workflow/Snakefile" ]] || { echo "No AmpSeeker Snakefile in $AMP_DIR (use -a)" >&2; exit 1; }
[[ -f "$COURSE_METADATA" ]] || { echo "Missing $COURSE_METADATA" >&2; exit 1; }

READS_DIR="$AMP_DIR/resources/reads"
REF_DIR="$AMP_DIR/resources/reference"
mkdir -p "$READS_DIR" "$REF_DIR" "$AMP_DIR/config"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
# 1. Choose samples and download reads
# ---------------------------------------------------------------------------
# Metadata subset: chosen locations, at most N per cohort (keeps the file's order)
awk -F'\t' -v OFS='\t' -v locs="$LOCATIONS" -v max="$MAX_PER_COHORT" '
  BEGIN { n = split(locs, a, ","); for (i = 1; i <= n; i++) keep[a[i]] = 1 }
  NR == 1 { for (i = 1; i <= NF; i++) col[$i] = i; print; next }
  ($col["location"] in keep) {
    c = $col["cohort"]; seen[c]++
    if (max == 0 || seen[c] <= max) print
  }' "$COURSE_METADATA" > "$TMP/metadata.tsv"

n_samples=$(( $(wc -l < "$TMP/metadata.tsv") - 1 ))
[[ $n_samples -gt 0 ]] || { echo "No samples selected (check -c)" >&2; exit 1; }
log "Selected $n_samples samples from $LOCATIONS"

log "Fetching the ENA file report for $PROJECT"
curl -fsSL --retry 5 "$ENA_REPORT" > "$TMP/ena.tsv"

# One line per file: sample_id, read (1/2), URL, md5
awk -F'\t' -v OFS='\t' '
  NR == FNR { if (FNR == 1) { for (i = 1; i <= NF; i++) col[$i] = i; next }
              want[$col["sample_id"]] = 1; next }
  FNR == 1 { for (i = 1; i <= NF; i++) ecol[$i] = i; next }
  ($ecol["sample_alias"] in want) {
    n = split($ecol["fastq_ftp"], url, ";"); split($ecol["fastq_md5"], md5, ";")
    if (n != 2) { print "Expected 2 FASTQs for " $ecol["sample_alias"] > "/dev/stderr"; exit 1 }
    for (i = 1; i <= 2; i++) print $ecol["sample_alias"], i, "https://" url[i], md5[i]
    found[$ecol["sample_alias"]] = 1
  }
  END { for (s in want) if (!(s in found)) { print "Not in ENA report: " s > "/dev/stderr"; bad = 1 }
        if (bad) exit 1 }' "$TMP/metadata.tsv" "$TMP/ena.tsv" > "$TMP/files.tsv"

download_one() {
  # args: sample read url md5 reads_dir md5_command
  local sample="$1" read="$2" url="$3" md5="$4" dir="$5" md5cmd="$6"
  local out="$dir/${sample}_${read}.fastq.gz"
  if [[ -s "$out" ]] && [[ "$($md5cmd "$out" | cut -d' ' -f1)" == "$md5" ]]; then return 0; fi
  curl -fsSL --retry 5 -o "$out.part" "$url"
  if [[ "$($md5cmd "$out.part" | cut -d' ' -f1)" != "$md5" ]]; then
    echo "MD5 mismatch for $url" >&2; rm -f "$out.part"; return 1
  fi
  mv "$out.part" "$out"
}
export -f download_one

log "Downloading $(wc -l < "$TMP/files.tsv") FASTQ files to $READS_DIR ($JOBS at a time)"
# NUL-separated arguments work with both GNU and BSD (macOS) xargs
awk -F'\t' -v OFS='\t' -v d="$READS_DIR" -v m="$MD5" '{ print $1, $2, $3, $4, d, m }' "$TMP/files.tsv" \
  | tr '\t\n' '\0\0' \
  | xargs -0 -n 6 -P "$JOBS" bash -c 'download_one "$@"' _
log "Reads ready"

# ---------------------------------------------------------------------------
# 2. Config and metadata for AmpSeeker
# ---------------------------------------------------------------------------
cp "$TMP/metadata.tsv" "$AMP_DIR/config/siaya-metadata.tsv"
cp "$COURSE_CONFIG" "$AMP_DIR/config/siaya.yaml"
log "Wrote $AMP_DIR/config/siaya.yaml and config/siaya-metadata.tsv ($n_samples samples)"

# ---------------------------------------------------------------------------
# 3. Reference genome (Ensembl Metazoa AgamP4)
# ---------------------------------------------------------------------------
if [[ $DO_REFERENCE -eq 1 ]]; then
  if [[ ! -s "$REF_DIR/AgamP4.fa" ]]; then
    log "Downloading AgamP4 chromosome arms from Ensembl Metazoa"
    : > "$REF_DIR/AgamP4.fa.part"
    for c in "${CONTIGS[@]}"; do
      curl -fsSL --retry 5 "$ENSEMBL/fasta/anopheles_gambiae/dna/Anopheles_gambiae.AgamP4.dna.chromosome.${c}.fa.gz" \
        | gzip -dc | awk '/^>/ { print $1; next } { print }' >> "$REF_DIR/AgamP4.fa.part"
    done
    mv "$REF_DIR/AgamP4.fa.part" "$REF_DIR/AgamP4.fa"
  fi
  if [[ ! -s "$REF_DIR/AgamP4.gff3" ]]; then
    log "Downloading the AgamP4 GFF3 (chromosome arms only)"
    curl -fsSL --retry 5 "$ENSEMBL/gff3/anopheles_gambiae/Anopheles_gambiae.AgamP4.63.gff3.gz" \
      | gzip -dc \
      | awk -F'\t' '/^##sequence-region/ { if ($0 ~ / (2L|2R|3L|3R|X) /) print; next }
                    /^#/ { print; next }
                    $1 ~ /^(2L|2R|3L|3R|X)$/' > "$REF_DIR/AgamP4.gff3.part"
    mv "$REF_DIR/AgamP4.gff3.part" "$REF_DIR/AgamP4.gff3"
  fi
  log "Reference ready in $REF_DIR"
fi

log "Done. Next: cd $AMP_DIR && snakemake --cores 4 --use-conda --configfile config/siaya.yaml -n"
