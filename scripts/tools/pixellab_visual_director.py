#!/usr/bin/env python3
"""Hunter Online — PixelLab Visual Director

Gera tilesets Wang + NPCs 48px (style lock) + walk animations via MCP PixelLab.
Requer PIXELLAB_API_TOKEN válido (https://api.pixellab.ai/mcp).

Direção visual:
- Personagens: 48x48, chibi baixo detalhe (PIXEL_ART_STYLE_BIBLE) — NÃO foto/anexo.
- Mapas/props: tiles 16px Wang com mais densidade de pixels no tile, sem photoreal.
- Animações: walk 4–8 dirs quando a API completar o character.
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.request
from pathlib import Path

MCP_URL = "https://api.pixellab.ai/mcp"
ROOT = Path(__file__).resolve().parents[2]
OUT_TILES = ROOT / "assets" / "sprites" / "tilesets" / "pixellab"
OUT_CHARS = ROOT / "assets" / "sprites" / "characters"
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "director_jobs.json"

# Style-lock character prompt stem (Bible 16)
CHAR_STYLE = (
    "retro 16-bit 48x48 rpg sprite, tiny low detail character, chibi 2.5 heads proportion, "
    "20 pixels tall character centered inside 48x48 transparent frame, simple chunky shapes, "
    "dot eyes no sclera, flat shading, basic outline, 2 colors per material, game sprite, "
    "NOT photorealistic, NOT high detail, NOT anime portrait"
)

TILESET_JOBS = [
    {
        "name": "yorknew_avenue_wang",
        "lower": "dark cobblestone night city street, muted navy shadow cracks, pixel art 16x16",
        "upper": "worn plaza tiles with faint gold inlay, neon-free classic rpg pavement",
        "size": 16,
    },
    {
        "name": "arena_corridor_wang",
        "lower": "polished arena stone floor warm beige, subtle wear, pixel art 16x16",
        "upper": "training hall tile with faint ring marks, clean rpg tileset",
        "size": 16,
    },
    {
        "name": "kukuroo_path_wang",
        "lower": "mountain forest dirt path brown soil, moss edges, pixel art 16x16",
        "upper": "dense dark green grass with small stones, classic top-down rpg",
        "size": 16,
    },
    {
        "name": "padokia_road_wang",
        "lower": "vibrant green mmo grass soft clumps, pixel art 16x16",
        "upper": "reddish-brown worn dirt road wagon tracks, top-down rpg",
        "size": 16,
    },
]

NPC_JOBS = [
    {
        "name": "npc_mafioso_yorknew_ambient",
        "description": f"{CHAR_STYLE}, mafia street thug dark suit, short black hair, yorknew night",
    },
    {
        "name": "npc_lutador_arena_ambient",
        "description": f"{CHAR_STYLE}, arena fighter bandages, short sport gi, heavens arena",
    },
    {
        "name": "npc_mordomo_zoldyck_ambient",
        "description": f"{CHAR_STYLE}, butler black suit white gloves, kukuroo mansion staff",
    },
    {
        "name": "npc_herbalista_floresta",
        "description": f"{CHAR_STYLE}, forest herbalist green cloak pouch, soft brown hair",
    },
]


class PixelLabMCP:
    def __init__(self, token: str):
        self.token = token.strip()
        self.session = None
        self.req_id = 0

    def call(self, method: str, params=None) -> dict:
        self.req_id += 1
        payload = {"jsonrpc": "2.0", "id": self.req_id, "method": method}
        if params is not None:
            payload["params"] = params
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json",
            "Accept": "application/json, text/event-stream",
        }
        if self.session:
            headers["Mcp-Session-Id"] = self.session
        req = urllib.request.Request(
            MCP_URL, data=json.dumps(payload).encode(), headers=headers, method="POST"
        )
        with urllib.request.urlopen(req, timeout=180) as resp:
            sid = resp.headers.get("Mcp-Session-Id") or resp.headers.get("mcp-session-id")
            if sid:
                self.session = sid
            raw = resp.read().decode("utf-8", errors="replace")
        if "data:" in raw:
            datas = [ln[5:].strip() for ln in raw.splitlines() if ln.startswith("data:")]
            return json.loads(datas[-1]) if datas else {"raw": raw[:500]}
        return json.loads(raw)

    def tool(self, name: str, arguments: dict) -> dict:
        res = self.call("tools/call", {"name": name, "arguments": arguments})
        result = res.get("result") or res
        content = result.get("content") if isinstance(result, dict) else None
        text = ""
        if content:
            for c in content:
                if c.get("type") == "text":
                    text += c.get("text", "")
        return {"text": text, "raw": result}

    def initialize(self) -> None:
        self.call(
            "initialize",
            {
                "protocolVersion": "2024-11-05",
                "capabilities": {},
                "clientInfo": {"name": "hunter-online-visual-director", "version": "1.0"},
            },
        )
        try:
            self.call("notifications/initialized", {})
        except Exception:
            pass


def get_token() -> str:
    token = (os.environ.get("PIXELLAB_API_TOKEN") or "").strip()
    if not token or token in ("YOUR_API_TOKEN", "***REMOVED***"):
        print("[-] PIXELLAB_API_TOKEN ausente/ inválido. Obtenha em https://api.pixellab.ai/mcp")
        sys.exit(2)
    return token


def download(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    urllib.request.urlretrieve(url, dest)


def queue_tilesets(mcp: PixelLabMCP, jobs_meta: dict) -> None:
    for job in TILESET_JOBS:
        print(f"[*] tileset {job['name']}...")
        r = mcp.tool(
            "create_topdown_tileset",
            {
                "lower_description": job["lower"],
                "upper_description": job["upper"],
                "tile_size": {"width": job["size"], "height": job["size"]},
                "mode": "standard",
                "view": "high top-down",
            },
        )
        print(r["text"][:400])
        jobs_meta.setdefault("tilesets", []).append({"name": job["name"], "response": r["text"][:1000]})


def queue_characters(mcp: PixelLabMCP, jobs_meta: dict) -> None:
    for job in NPC_JOBS:
        print(f"[*] character {job['name']}...")
        r = mcp.tool(
            "create_character",
            {
                "name": job["name"],
                "description": job["description"],
                "mode": "standard",
                "size": 48,
                "detail": "low detail",
                "shading": "flat shading",
                "outline": "single color black outline",
                "view": "low top-down",
                "n_directions": 4,
                "proportions": '{"type": "preset", "name": "chibi"}',
            },
        )
        print(r["text"][:400])
        jobs_meta.setdefault("characters", []).append({"name": job["name"], "response": r["text"][:1000]})


def main() -> None:
    token = get_token()
    mcp = PixelLabMCP(token)
    mcp.initialize()
    bal = mcp.tool("get_balance", {})
    print("[balance]", bal["text"][:300])
    if "Invalid API token" in bal["text"] or "401" in bal["text"]:
        print("[-] Token rejeitado pela API PixelLab.")
        sys.exit(2)

    jobs_meta: dict = {"created_at": time.time(), "tilesets": [], "characters": []}
    OUT_TILES.mkdir(parents=True, exist_ok=True)
    queue_tilesets(mcp, jobs_meta)
    queue_characters(mcp, jobs_meta)
    OUT_META.write_text(json.dumps(jobs_meta, indent=2, ensure_ascii=False))
    print(f"[+] Jobs registrados em {OUT_META}")
    print("[*] Use get_topdown_tileset / get_character / animate_character para baixar quando completed.")


if __name__ == "__main__":
    main()
