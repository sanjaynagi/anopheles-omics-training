# GitHub Codespaces for the Snakemake sessions

The two workflow sessions (1.4 RNA-Seq-Pop, 4.3 AmpSeeker) run in a GitHub Codespace: a
Linux machine in the cloud with VS Code in the browser. Participants create it from **their
own fork** of the course repository, so it uses their own free allowance, not ours.

## What the codespace contains

Defined in `.devcontainer/`:

- Image: the plain `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`.
- Machine: 4 cores, 16 GB RAM, 32 GB disk (`hostRequirements`).
- `setup.sh` runs once, when the codespace is created (about 5 minutes). It:
  - installs [pixi](https://pixi.sh) and the environment in `workflows/pixi.toml`, locked by
    `workflows/pixi.lock`: Snakemake 7.32.4 (the version both workflows' CI uses), `conda`,
    graphviz, pandas, scikit-allel, statsmodels and plotly;
  - adds `pixi shell-hook` to `~/.bashrc`, so `snakemake` is on the PATH in every terminal;
  - writes a Snakemake profile (`conda-frontend: conda`, `rerun-incomplete: true`);
  - clones the pinned workflows next to the course repo:
    `/workspaces/rna-seq-pop` (v2.3.0) and `/workspaces/AmpSeeker` (v0.7.0).
- There are no prebuilds, so setup runs on each participant's own allowance.

Why conda as well as pixi? Snakemake's `--use-conda` builds a separate conda environment for
each rule from the workflow's `envs/*.yaml` files. The pixi environment provides the `conda`
that does this.

Each workflow's own conda environments are built the first time it runs (another
10–20 minutes). Ask participants to start their run early in the session.

## Before the course (facilitators)

1. Create a codespace from a fork yourself, run both workflows end to end, and note the times.
2. Remind participants to bring a GitHub account (a free personal account is enough) and
   to fork the course repository into their **personal** account, not an organisation.
   A codespace from an organisation-owned repo can be billed to that organisation or blocked.

## Creating a codespace (participants)

1. Fork `sanjaynagi/malaria-software-training` (**Fork** button, top right).
2. On your fork, click **Code → Codespaces → ⋯ → New with options**.
3. Check that **Machine type** is **4-core**, then **Create codespace**.
4. Wait for setup to finish (the terminal says `[setup] Done`). Open a **new** terminal and run
   `snakemake --version`; it should print `7.32.4`.

Next time, reopen the same codespace from **Code → Codespaces** or
<https://github.com/codespaces>. Do not create a new one each day.

## Cost and allowance

- A free personal account includes **120 core-hours** of compute and **15 GB-month** of
  storage each month (GitHub Pro and the Student pack: 180 core-hours and 20 GB-month).
- A 4-core codespace uses 4 core-hours per hour, so the free allowance gives **30 hours** a
  month. The two workflow sessions need well under that.
- Storage is charged while a codespace **exists**, even when stopped. One 32 GB codespace
  kept for a whole month uses more than the 15 GB-month allowance, so delete it after the course.
- Personal accounts have a **$0 spending limit** by default. Nobody can be charged: when the
  allowance runs out, the codespace stops and cannot be restarted until the next month.
- Participants can check their usage at **Settings → Billing and licensing**.
- Beyond the allowance: $0.36/hour (4-core), $0.07 per GB-month.

## Stopping and deleting

- **Stop** a codespace when you are not using it (compute is only charged while it runs):
  <https://github.com/codespaces> → ⋯ → **Stop codespace**, or in VS Code press
  `F1` and run **Codespaces: Stop Current Codespace**.
- A codespace also stops by itself after the **idle timeout** (default 30 minutes with no
  activity in the editor). A long Snakemake run does not count as activity. Set the timeout
  to the maximum (240 minutes) in **Settings → Codespaces → Default idle timeout** before
  starting a long run.
- **Delete** it after the course: <https://github.com/codespaces> → ⋯ → **Delete**. Push
  any work you want to keep to your fork first. Unused codespaces are also deleted
  automatically after the retention period (default 30 days).

## Troubleshooting

| Problem | Fix |
|---|---|
| Setup failed or was interrupted | `F1` → **Codespaces: View Creation Log** to see the error, then run `bash .devcontainer/setup.sh` again in a terminal. It skips steps already done. |
| `snakemake: command not found` | Open a new terminal, or run `eval "$(pixi shell-hook --manifest-path /workspaces/malaria-software-training/workflows/pixi.toml)"`. |
| No 4-core option | The repo must be your personal fork. If only 2-core is offered, use it: runs take longer. |
| The run stopped when the codespace went idle | Restart the codespace and run the same `snakemake` command. Finished jobs are not repeated, and half-finished ones are redone: the profile sets `--rerun-incomplete` (add it yourself if you run without the profile). Raise the idle timeout to 240 min first. |
| `LockException` / "Directory cannot be locked" | A previous run was killed. Run `snakemake --unlock` (with the same `--configfile`), then rerun. |
| Error creating a conda environment | Usually a network hiccup: rerun. Check `conda config --show channel_priority` says `flexible`. |
| Disk full (`df -h /workspaces`) | Delete `results/` from failed test runs and run `conda clean --all -y` and `pixi clean cache`. Each workflow's rule environments live in its own `.snakemake/conda`. |
| A rule failed | Read the log file named in the error message (under `logs/`). For notebook rules, the partly run notebook is in `results/notebooks/`. |
| How do I see the results book? | In the workflow folder run `python -m http.server 8000 -d results/ampseeker-results/_build/html` (or `results/rna-seq-pop-results/_build/html`), then open port 8000 from the **Ports** tab. |
| Participant has run out of allowance | Pair them with a neighbour, or use the precomputed results (every Colab notebook reads those, so nobody is blocked). |
