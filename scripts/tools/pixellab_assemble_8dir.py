#!/usr/bin/env python3
"""
Monta uma folha 8-direções no padrão do Hunter Online (384x48, 8 frames de
48x48) a partir das rotações de um personagem do PixelLab.

Aplica o Style Lock:
  - frame 48x48, corpo reescalado para caber (<=18 larg, <=24 alt),
  - pés (base do conteúdo) em Y=42, centralizado no X,
  - ordem de direções do jogo: S, SE, E, NE, N, NW, W, SW,
  - paleta reduzida (quantização global preservando transparência).

Uso:
  PIXELLAB_API_TOKEN=... python3 scripts/tools/pixellab_assemble_8dir.py \
      <character_id> <saida.png> [--rot-dir <dir_rotacoes>]

Sem --rot-dir, baixa as rotações via API (get_character).
"""
import os
import sys
import json
import io
import urllib.request

from PIL import Image

FRAME = 48
FEET_Y = 42
MAX_W = 18
MAX_H = 24
# Ordem canônica dos frames no jogo (index 0 = South).
ORDER = ["south", "south-east", "east", "north-east",
         "north", "north-west", "west", "south-west"]
MAX_COLORS = 13  # <=14 cores/frame e <=22/folha exigidos pelo validador


def _http_get(url: str, token: str | None = None) -> bytes:
    req = urllib.request.Request(url)
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def _mcp_get_character(cid: str, token: str) -> dict:
    body = json.dumps({
        "jsonrpc": "2.0", "id": 1, "method": "tools/call",
        "params": {"name": "get_character",
                   "arguments": {"character_id": cid, "include_preview": False}},
    }).encode()
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


def _place(rot: Image.Image) -> Image.Image:
    """Autocrop + reescala para caber e posiciona pés em Y=42 num frame 48x48."""
    bbox = rot.getbbox()
    if bbox is None:
        return Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    content = rot.crop(bbox)
    w, h = content.size
    scale = min(MAX_W / w, MAX_H / h, 1.0)
    nw, nh = max(1, round(w * scale)), max(1, round(h * scale))
    content = content.resize((nw, nh), Image.LANCZOS)
    frame = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    x = (FRAME - nw) // 2
    y = FEET_Y - nh
    frame.alpha_composite(content, (x, max(0, y)))
    return frame


def _quantize_sheet(sheet: Image.Image, colors: int) -> Image.Image:
    """Quantiza a paleta preservando a transparência (alpha binário)."""
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
    token = os.environ.get("PIXELLAB_API_TOKEN")

    imgs = _load_rotations(cid, token, rot_dir)
    sheet = Image.new("RGBA", (FRAME * len(ORDER), FRAME), (0, 0, 0, 0))
    for i, d in enumerate(ORDER):
        sheet.alpha_composite(_place(imgs[d]), (i * FRAME, 0))
    sheet = _quantize_sheet(sheet, MAX_COLORS)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    sheet.save(out_path)
    print(f"[assemble] folha salva: {out_path} ({sheet.size[0]}x{sheet.size[1]}, {len(ORDER)} frames)")


if __name__ == "__main__":
    main()
