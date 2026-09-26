"""Re-execute course notebooks locally and save their outputs back.

Cells that only make sense in Colab are neutralised in a temporary copy: `%pip install`
lines are skipped (the pixi environment provides the packages), and `--replace NAME=VALUE`
swaps a constant's value (e.g. a data URL that is not public yet). The original sources are
kept; only outputs are written back. Run from the repo root with the course pixi env:

    pixi run python scripts/rerun_notebooks.py day-3/3-2-selection-atlas.ipynb \
        --replace SIGNALS_URL=/path/to/h12-signal-detection-all.csv --workdir /tmp/run
"""

import argparse
import copy
import json
import re
import subprocess
from pathlib import Path


def prepare(nb: dict, replacements: dict[str, str]) -> dict:
    run = copy.deepcopy(nb)
    for cell in run["cells"]:
        if cell["cell_type"] != "code":
            continue
        src = "".join(cell["source"])
        src = re.sub(r"^%pip install.*$", "# (pip install skipped locally)", src, flags=re.M)
        for name, value in replacements.items():
            src = re.sub(rf'^{name}\s*=\s*"[^"]*"', f'{name} = "{value}"', src, flags=re.M)
        cell["source"] = src
    return run


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("notebooks", nargs="+")
    parser.add_argument("--replace", action="append", default=[])
    parser.add_argument("--workdir", required=True)
    parser.add_argument("--timeout", type=int, default=3600)
    args = parser.parse_args()
    replacements = dict(r.split("=", 1) for r in args.replace)
    workdir = Path(args.workdir)
    workdir.mkdir(parents=True, exist_ok=True)

    for path in map(Path, args.notebooks):
        nb = json.loads(path.read_text())
        tmp = workdir / path.name
        tmp.write_text(json.dumps(prepare(nb, replacements)))
        subprocess.run(
            ["jupyter", "nbconvert", "--to", "notebook", "--execute", "--inplace",
             f"--ExecutePreprocessor.timeout={args.timeout}", str(tmp)],
            check=True,
        )
        executed = json.loads(tmp.read_text())
        for original, ran in zip(nb["cells"], executed["cells"], strict=True):
            if original["cell_type"] == "code":
                original["outputs"] = ran["outputs"]
                original["execution_count"] = ran.get("execution_count")
        path.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n")
        print(f"re-executed {path}")


if __name__ == "__main__":
    main()
