#!/usr/bin/env bash
# First-time setup for the course codespace (run by postCreateCommand).
#
# - installs pixi, then the Snakemake environment defined in workflows/pixi.toml
#   (Snakemake 7.32.4, conda, and the Python packages used in the course notebooks),
#   and activates it in every new terminal
# - writes a Snakemake profile shared by both workflows
# - clones the pinned workflow releases next to the course repo:
#     /workspaces/rna-seq-pop  (RNA-Seq-Pop v2.3.0, Day 1)
#     /workspaces/AmpSeeker    (AmpSeeker v0.7.0, Day 4)
#
# Safe to run again: finished steps are skipped.

set -euo pipefail

RNASEQPOP_VERSION="v2.3.0"
AMPSEEKER_VERSION="v0.7.0"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # /workspaces/malaria-software-training
WORKSPACE="$(dirname "$REPO_DIR")"                              # /workspaces
MANIFEST="$REPO_DIR/workflows/pixi.toml"
PROFILE_DIR="${SNAKEMAKE_PROFILE:-$HOME/.config/snakemake/codespace}"

log() { echo "[setup] $*"; }

# 1. pixi
if ! command -v pixi >/dev/null 2>&1 && [[ ! -x "$HOME/.pixi/bin/pixi" ]]; then
  log "Installing pixi"
  curl -fsSL https://pixi.sh/install.sh | PIXI_NO_PATH_UPDATE=1 bash
fi
export PATH="$HOME/.pixi/bin:$PATH"
grep -q '.pixi/bin' "$HOME/.bashrc" || echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> "$HOME/.bashrc"

# 2. The Snakemake environment, exactly as in workflows/pixi.lock
log "Installing the Snakemake environment (a few minutes)"
pixi install --locked --manifest-path "$MANIFEST"

# Activate it in every new terminal, so `snakemake` and `conda` are on PATH
HOOK="eval \"\$(pixi shell-hook --manifest-path $MANIFEST)\""
grep -qF "$HOOK" "$HOME/.bashrc" || echo "$HOOK" >> "$HOME/.bashrc"

# Snakemake's --use-conda builds each rule's own conda environment with the conda from
# the pixi environment. Both workflows mix bioconda and conda-forge: use flexible priority.
pixi run --manifest-path "$MANIFEST" conda config --set channel_priority flexible

# 3. Snakemake profile (picked up through $SNAKEMAKE_PROFILE, set in devcontainer.json).
# Snakemake 7 defaults to mamba, which is not installed; conda uses the fast libmamba solver.
mkdir -p "$PROFILE_DIR"
cat > "$PROFILE_DIR/config.yaml" <<'YAML'
conda-frontend: conda
rerun-incomplete: true
YAML

# 4. The workflows, at pinned releases
clone() {
  local url="$1" tag="$2" dest="$3"
  if [[ -d "$dest/.git" ]]; then
    log "$dest already exists; leaving it as it is"
  else
    log "Cloning $url at $tag into $dest"
    git clone -q --depth 1 --branch "$tag" "$url" "$dest"
  fi
}
clone https://github.com/sanjaynagi/rna-seq-pop.git "$RNASEQPOP_VERSION" "$WORKSPACE/rna-seq-pop"
clone https://github.com/sanjaynagi/AmpSeeker.git "$AMPSEEKER_VERSION" "$WORKSPACE/AmpSeeker"

log "Done. Open a new terminal, then check: snakemake --version  (expect 7.32.4)"
log "Workflows: $WORKSPACE/rna-seq-pop  and  $WORKSPACE/AmpSeeker"
