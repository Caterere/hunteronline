#!/usr/bin/env python3
"""Monta folha 8-dir Style Lock v2 (768x96, frames 96x96).

- corpo reescalado (<=34 larg, <=48 alt), pés em Y=84, centrado em X
- ordem: S, SE, E, NE, N, NW, W, SW
"""
from __future__ import annotations

import io
import json
import os
import sys
import urllib.request

from PIL import Image

FRAME = 96
FEET_Y = 84
MAX_W = 34
MAX_H = 48
ORDER = [
    "south",
    "south-east",
    "east",
    "north-east",
    "north",
    "north-west",
    "west",
    "south-west",
]
MAX_COLORS = 28


def _http_get(url: str, token: str | None = None) -> bytes:
    req = urllib.request.Request(url)
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def _mcp_get_character(cid: str, token: str) -> dict:
    body = json.dumps(
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
                "name": "get_character",
                "arguments": {"character_id": cid, "include_preview": False},
            },
        }
    ).encode()
    req = urllib.request.Request("https://api.pixellab.ai/mcp", data=body, method="POST")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json, text/event-stream")
    with urllib.request.urlopen(req, timeout=60) as r:
        text = r.read().decode()
    data_line = [l[6:] for l in text.replace("\r", "").splitlines() if l.startswith("data: ")][-1]
    payload = json.loads(data_line)
    content = payload["result"]["content"][0]["text"]
    urls = {}
    for line in content.splitlines():
        line = line.strip()
        for d in ORDER:
            if line.startswith(d + ": http"):
                urls[d] = line.split(": ", 1)[1]
    return urls


def _load_rotations(cid: str, token: str, rot_dir: str | None) -> dict:
    imgs = {}
    if rot_dir:
        for d in ORDER:
            p = os.path.join(rot_dir, f"{d}.png")
            imgs[d] = Image.open(p).convert("RGBA")
        return imgs
    urls = _mcp_get_character(cid, token)
    missing = [d for d in ORDER if d not in urls]
    if missing:
        raise SystemExit(f"Rotações ausentes: {missing}")
    for d in ORDER:
        imgs[d] = Image.open(io.BytesIO(_http_get(urls[d]))).convert("RGBA")
    return imgs


def place(rot: Image.Image) -> Image.Image:
    bbox = rot.getbbox()
    if bbox is None:
        return Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    content = rot.crop(bbox)
    w, h = content.size
    scale = min(MAX_W / w, MAX_H / h, 1.0)
    nw, nh = max(1, round(w * scale)), max(1, round(h * scale))
    content = content.resize((nw, nh), Image.NEAREST)
    frame = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    x = (FRAME - nw) // 2
    y = FEET_Y - nh
    frame.alpha_composite(content, (x, max(0, y)))
    return frame


def quantize_sheet(sheet: Image.Image, colors: int) -> Image.Image:
    alpha = sheet.split()[3]
    rgb = Image.new("RGB", sheet.size, (0, 0, 0))
    rgb.paste(sheet.convert("RGB"), mask=alpha)
    q = rgb.quantize(colors=colors, method=Image.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    out = q.convert("RGBA")
    out.putalpha(alpha.point(lambda a: 255 if a >= 128 else 0))
    return out


def main() -> None:
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    cid = sys.argv[1]
    out_path = sys.argv[2]
    rot_dir = None
    if "--rot-dir" in sys.argv:
        rot_dir = sys.argv[sys.argv.index("--rot-dir") + 1]
    token = os.environ.get("PIXELLAB_API_TOKEN") or os.environ.get("PIXELLAB_API_KEY")
    imgs = _load_rotations(cid, token or "", rot_dir)
    sheet = Image.new("RGBA", (FRAME * 8, FRAME), (0, 0, 0, 0))
    for i, d in enumerate(ORDER):
        sheet.paste(place(imgs[d]), (i * FRAME, 0), place(imgs[d]))
    sheet = quantize_sheet(sheet, MAX_COLORS)
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    sheet.save(out_path)
    print(f"[ok] {out_path} {sheet.size}")


if __name__ == "__main__":
    main()
