# Beyond WGS: transcriptomics, selection and assay design in malaria vectors

Training course materials (Jupyter Book 2 / MyST). The course follows one public study of
pyrethroid resistance around Lake Victoria, from RNA-seq to field amplicon surveillance, using
RNA-Seq-Pop, AnoExpress, malariagen_data, the selection atlas, AnoPrimer, multiply and AmpSeeker.

It follows on from the [MalariaGEN–PAMCA course](https://anopheles-genomic-surveillance.github.io/home.html).

- `course-plan.md`: scope and plan
- `facilitators/authoring-guide.md`: how module notebooks are written
- `data/README.md`: data sources and what still needs preparing

## Build locally

We use [pixi](https://pixi.sh) to manage the environment. Install pixi once
(`curl -fsSL https://pixi.sh/install.sh | sh`), then from the repository root:

```bash
pixi install      # create the environment from pixi.lock
pixi run start    # live preview of the book
pixi run build    # build the HTML book into _build/
pixi run lab      # run the course notebooks locally in JupyterLab
```

`pixi.toml` lists what we asked for; `pixi.lock` records the exact versions for Linux and macOS.
Colab users do not need any of this: each notebook installs its own pinned packages.
`requirements.txt` is kept for anyone who prefers `pip install -r requirements.txt`
(book build only).

Licence: [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/).
