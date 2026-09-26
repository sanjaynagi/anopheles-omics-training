"""Convert Plotly figures saved as HTML into Plotly's JSON output type, which MyST renders.

Notebooks executed with an HTML renderer (e.g. "notebook_connected" or "colab") save each
figure as an HTML page with a script. The book does not run those scripts, so the figures
are blank. This finds the `Plotly.newPlot(...)` call in each output, decodes its data and
layout, and replaces the output with `application/vnd.plotly.v1+json`. It also drops the
Plotly and Bokeh loader outputs, which carry no figure.

Usage: python scripts/plotly_outputs_to_mimetype.py day-3/*.ipynb
"""

import json
import sys

PLOTLY_MIME = "application/vnd.plotly.v1+json"
LOADER_MIMES = {"application/vnd.bokehjs_load.v0+json", "application/javascript"}


def extract_figure(html: str) -> dict | None:
    start = html.find("Plotly.newPlot(")
    if start == -1:
        return None
    decoder = json.JSONDecoder()
    pos = start + len("Plotly.newPlot(")

    def next_value(pos: int):
        while html[pos] in " \t\r\n,":
            pos += 1
        return decoder.raw_decode(html, pos)

    _div_id, pos = next_value(pos)
    data, pos = next_value(pos)
    layout, pos = next_value(pos)
    return {"data": data, "layout": layout}


def is_loader(output: dict) -> bool:
    data = output.get("data", {})
    if not data:
        return False
    if set(data) - {"text/plain"} <= LOADER_MIMES:
        return True
    html = "".join(data.get("text/html", ""))
    return set(data) <= {"text/html", "text/plain"} and "window.PlotlyConfig" in html and "newPlot" not in html


def convert(path: str) -> int:
    with open(path) as f:
        nb = json.load(f)
    n = 0
    for cell in nb["cells"]:
        outputs = []
        for output in cell.get("outputs", []):
            if is_loader(output):
                continue
            data = output.get("data", {})
            html = "".join(data.get("text/html", ""))
            figure = extract_figure(html) if PLOTLY_MIME not in data else None
            if figure is not None:
                output["data"] = {PLOTLY_MIME: figure, "text/plain": ["<Figure>"]}
                n += 1
            outputs.append(output)
        if "outputs" in cell:
            cell["outputs"] = outputs
    with open(path, "w") as f:
        json.dump(nb, f, indent=1, ensure_ascii=False)
        f.write("\n")
    return n


if __name__ == "__main__":
    for path in sys.argv[1:]:
        print(f"{path}: converted {convert(path)} figures")
