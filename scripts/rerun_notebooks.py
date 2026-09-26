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
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from plotly_outputs_to_mimetype import is_loader  # noqa: E402

# Stream lines that only appear in local runs: progress bars and spinners, gRPC fork
# logs, and warnings that print local file paths.
NOISE = re.compile(
    r"^(\s*\d+%\||.*\(\d+:\d\d:\d\d\.\d\d\)$|[IWE]\d{4} \d\d:\d\d:\d\d\.\d+ |/Users/|/home/|/private/|Warning: |This means that|Please upgrade|You can however|  warnings\.warn)"
)


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


def clean_outputs(outputs: list[dict]) -> list[dict]:
    kept = []
    for output in outputs:
        if is_loader(output):
            continue
        if output.get("output_type") == "stream":
            text = "".join(output["text"]).replace("\r", "\n")
            lines = [line for line in text.split("\n") if line.strip() and not NOISE.match(line)]
            if not lines:
                continue
            output["text"] = "\n".join(lines) + "\n"
        kept.append(output)
    # merge consecutive streams of the same name
    merged: list[dict] = []
    for output in kept:
        prev = merged[-1] if merged else None
        if prev and output.get("output_type") == "stream" == prev.get("output_type") and output["name"] == prev["name"]:
            prev["text"] = "".join(prev["text"]) + "".join(output["text"])
        else:
            merged.append(output)
    return merged


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("notebooks", nargs="+")
    parser.add_argument("--replace", action="append", default=[])
    parser.add_argument("--workdir")
    parser.add_argument("--timeout", type=int, default=3600)
    parser.add_argument("--clean-only", action="store_true", help="clean saved outputs without re-running")
    args = parser.parse_args()
    replacements = dict(r.split("=", 1) for r in args.replace)
    if not args.clean_only and not args.workdir:
        parser.error("--workdir is required unless --clean-only")
    workdir = Path(args.workdir or ".")
    if not args.clean_only:
        workdir.mkdir(parents=True, exist_ok=True)

    for path in map(Path, args.notebooks):
        nb = json.loads(path.read_text())
        if args.clean_only:
            for cell in nb["cells"]:
                if cell["cell_type"] == "code":
                    cell["outputs"] = clean_outputs(cell["outputs"])
            path.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n")
            print(f"cleaned {path}")
            continue
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
                original["outputs"] = clean_outputs(ran["outputs"])
                original["execution_count"] = ran.get("execution_count")
        path.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n")
        print(f"re-executed {path}")


if __name__ == "__main__":
    main()
