#!/usr/bin/env python3
"""Hunter Online — PixelLab Calibration Batch (Prompt Library §94).

First real pipeline call: small set, then assemble a Godot test area.
"""

from __future__ import annotations

import base64
import json
import os
import re
import sys
import time
import urllib.request
from pathlib import Path

MCP_URL = "https://api.pixellab.ai/mcp"
ROOT = Path("/workspace")
OUT_TILES = ROOT / "assets" / "sprites" / "tilesets" / "pixellab"
OUT_CHARS = ROOT / "assets" / "sprites" / "characters"
OUT_OBJS = ROOT / "assets" / "sprites" / "objects"
OUT_META = OUT_TILES / "calibration_batch_jobs.json"

STYLE_LOCK = (
    "HUNTER ONLINE VISUAL STYLE LOCK. Production-ready 2D top-down pixel art. "
    "Crisp pixel clusters, hard pixel edges, no anti-aliasing, no photographic textures, "
    "no soft gradients, controlled palette, coherent light, game-ready asset."
)

CHAR_STYLE = (
    "retro 16-bit 48x48 rpg sprite, tiny low detail character, chibi 2.5 heads proportion, "
    "20 pixels tall character centered inside 48x48 transparent frame, simple chunky shapes, "
    "dot eyes no sclera, flat shading, basic outline, 2 colors per material, game sprite"
)

# §94 first batch — grass+dirt+transition as one Wang tileset, then props, then 1 NPC
TILESETS = [
    {
        "name": "calibration_grass_dirt_wang",
        "lower_description": (
            f"{STYLE_LOCK} Lower terrain: compact warm brown natural earth dirt path with "
            "tiny stones, occasional cracks, sparse grass intrusion, worn areas. "
            "Connected 16x16 top-down RPG tileset for Hunter Online."
        ),
        "upper_description": (
            f"{STYLE_LOCK} Upper terrain: soft temperate green grassland with subtle grass "
            "tufts, occasional tiny flowers, darker soil hints, irregular ground marks. "
            "Not flat repeated green. Connected 16x16 top-down RPG tileset."
        ),
        "transition_description": (
            "natural grass edge blending into worn dirt path with sparse tufts and soil crumbs"
        ),
        "transition_size": 0.25,
    }
]

OBJECTS = [
    (
        "calibration_tree_a.png",
        f"{STYLE_LOCK} Top-down RPG deciduous tree, medium canopy, brown trunk, "
        "clustered green leaf pixels, readable silhouette, transparent background, "
        "medium environmental detail, Hunter Online forest prop",
        48,
        64,
    ),
    (
        "calibration_tree_b.png",
        f"{STYLE_LOCK} Top-down RPG pine/cypress tree, taller thinner canopy, "
        "darker green needle clusters, simple trunk, transparent background, "
        "variant of tree family, Hunter Online forest prop",
        40,
        64,
    ),
    (
        "calibration_bush_a.png",
        f"{STYLE_LOCK} Top-down RPG round leafy bush, soft green pixel clusters, "
        "small shadow, transparent background, medium detail, Hunter Online vegetation",
        32,
        32,
    ),
    (
        "calibration_rock_a.png",
        f"{STYLE_LOCK} Top-down RPG single weathered gray rock, moss hints, "
        "hard edges, transparent background, low-medium detail, Hunter Online prop",
        32,
        32,
    ),
    (
        "calibration_rock_b.png",
        f"{STYLE_LOCK} Top-down RPG small rock cluster of 2-3 stones, irregular shapes, "
        "subtle moss, transparent background, Hunter Online ground prop",
        40,
        32,
    ),
    (
        "calibration_ground_details.png",
        f"{STYLE_LOCK} Top-down RPG ground detail patch: sparse grass tufts, tiny flowers, "
        "pebbles and leaf litter on transparent background, reusable decoration strip, "
        "Hunter Online environmental storytelling detail",
        48,
        32,
    ),
]

NPCS = [
    (
        "npc_calibration_viajante_padokia",
        f"{CHAR_STYLE}, traveling hunter apprentice with brown travel cloak, "
        "small backpack, short messy hair, leather boots, Padokia road traveler, "
        "identity distinct from player",
    )
]


class MCP:
    def __init__(self, token: str):
        self.token = token
        self.session = None
        self.rid = 0

    def call(self, method: str, params=None) -> dict:
        self.rid += 1
        payload: dict = {"jsonrpc": "2.0", "id": self.rid, "method": method}
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
            return json.loads(datas[-1])
        return json.loads(raw)

    def tool(self, name: str, args: dict) -> dict:
        res = self.call("tools/call", {"name": name, "arguments": args})
        result = res.get("result") or res
        content = result.get("content") if isinstance(result, dict) else None
        text = ""
        images = []
        if content:
            for c in content:
                if c.get("type") == "text":
                    text += c.get("text", "")
                elif c.get("type") == "image":
                    images.append(c)
        return {
            "text": text,
            "images": images,
            "isError": bool(isinstance(result, dict) and result.get("isError")),
        }


def uuid_from(text: str) -> str | None:
    m = re.search(
        r"\b([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\b",
        text,
    )
    return m.group(1) if m else None


def urls_from(text: str) -> list[str]:
    return re.findall(r"https://[^\s\)\]\"'<>]+", text)


def download(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(url, headers={"User-Agent": "HunterOnline/calibration"})
    with urllib.request.urlopen(req, timeout=180) as resp:
        dest.write_bytes(resp.read())
    print(f"    saved {dest} ({dest.stat().st_size}B)", flush=True)


def save_images(images: list, dest: Path) -> bool:
    if not images:
        return False
    data = images[0].get("data") or images[0].get("blob")
    if not data:
        return False
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(base64.b64decode(data))
    print(f"    saved inline {dest} ({dest.stat().st_size}B)", flush=True)
    return True


def busy(text: str) -> bool:
    low = text.lower()
    return any(x in low for x in ("processing", "pending", "queued", "in progress", "generating"))


def poll(mcp: MCP, tool: str, key: str, job_id: str, timeout: int = 800) -> dict:
    t0 = time.time()
    last = {"text": "", "images": [], "isError": True}
    while time.time() - t0 < timeout:
        last = mcp.tool(tool, {key: job_id})
        print(f"    [{int(time.time()-t0):3d}s] {last['text'][:160].replace(chr(10), ' ')}", flush=True)
        if last["isError"]:
            return last
        if not busy(last["text"]) and (
            "completed" in last["text"].lower()
            or "download" in last["text"].lower()
            or urls_from(last["text"])
            or last["images"]
        ):
            return last
        if "failed" in last["text"].lower() and "status" in last["text"].lower():
            return last
        time.sleep(8)
    return last


def pick_png(urls: list[str]) -> str | None:
    for u in urls:
        if ".png" in u.lower():
            return u
    return urls[0] if urls else None


def main() -> None:
    token = os.environ.get("PIXELLAB_API_TOKEN", "").strip()
    if not token:
        print("[-] PIXELLAB_API_TOKEN missing", flush=True)
        sys.exit(2)

    mcp = MCP(token)
    mcp.call(
        "initialize",
        {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "hunter-calibration", "version": "1.0"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass

    print("[balance]", mcp.tool("get_balance", {})["text"][:300], flush=True)

    meta: dict = {
        "batch": "prompt_library_94_calibration",
        "created_at": time.time(),
        "tilesets": [],
        "objects": [],
        "characters": [],
    }
    OUT_TILES.mkdir(parents=True, exist_ok=True)
    OUT_CHARS.mkdir(parents=True, exist_ok=True)
    OUT_OBJS.mkdir(parents=True, exist_ok=True)

    for ts in TILESETS:
        print(f"[*] queue tileset {ts['name']}", flush=True)
        args = {
            "lower_description": ts["lower_description"],
            "upper_description": ts["upper_description"],
            "tile_size": {"width": 16, "height": 16},
            "mode": "standard",
            "transition_size": ts.get("transition_size", 0.25),
        }
        if ts.get("transition_description"):
            args["transition_description"] = ts["transition_description"]
        r = mcp.tool("create_topdown_tileset", args)
        print("   ", r["text"][:240].replace("\n", " | "), flush=True)
        meta["tilesets"].append({"name": ts["name"], "id": uuid_from(r["text"]), "queue": r["text"][:500]})

    for out, desc, w, h in OBJECTS:
        print(f"[*] queue object {out}", flush=True)
        r = mcp.tool(
            "create_map_object",
            {
                "description": desc,
                "width": w,
                "height": h,
                "view": "high top-down",
                "outline": "single color outline",
                "shading": "basic shading",
                "detail": "medium detail",
            },
        )
        print("   ", r["text"][:240].replace("\n", " | "), flush=True)
        meta["objects"].append({"out": out, "id": uuid_from(r["text"]), "queue": r["text"][:500]})

    for name, desc in NPCS:
        print(f"[*] queue character {name}", flush=True)
        r = mcp.tool(
            "create_character",
            {
                "name": name,
                "description": desc,
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
        print("   ", r["text"][:240].replace("\n", " | "), flush=True)
        meta["characters"].append({"name": name, "id": uuid_from(r["text"]), "queue": r["text"][:500]})

    OUT_META.write_text(json.dumps(meta, indent=2))
    print("[+] queued — polling…", flush=True)

    for job in meta["tilesets"]:
        if not job.get("id"):
            continue
        print(f"[*] finish tileset {job['name']}", flush=True)
        r = poll(mcp, "get_topdown_tileset", "tileset_id", job["id"])
        job["result"] = r["text"][:1500]
        dest = OUT_TILES / f"{job['name']}.png"
        if save_images(r["images"], dest):
            job["path"] = str(dest.relative_to(ROOT))
        else:
            u = pick_png(urls_from(r["text"]))
            if u:
                download(u, dest)
                job["path"] = str(dest.relative_to(ROOT))

    for job in meta["objects"]:
        if not job.get("id"):
            continue
        print(f"[*] finish object {job['out']}", flush=True)
        r = poll(mcp, "get_map_object", "object_id", job["id"], timeout=400)
        job["result"] = r["text"][:1200]
        dest = OUT_OBJS / job["out"]
        if save_images(r["images"], dest):
            job["path"] = str(dest.relative_to(ROOT))
        else:
            u = pick_png(urls_from(r["text"]))
            if u:
                download(u, dest)
                job["path"] = str(dest.relative_to(ROOT))

    for job in meta["characters"]:
        if not job.get("id"):
            continue
        print(f"[*] finish character {job['name']}", flush=True)
        r = poll(mcp, "get_character", "character_id", job["id"], timeout=900)
        job["result"] = r["text"][:2000]
        dest = OUT_CHARS / f"{job['name']}_8dir.png"
        if save_images(r["images"], dest):
            job["path"] = str(dest.relative_to(ROOT))
        else:
            u = pick_png(urls_from(r["text"]))
            if u:
                download(u, dest)
                job["path"] = str(dest.relative_to(ROOT))

    OUT_META.write_text(json.dumps(meta, indent=2))
    summary = {
        "tiles": sum(1 for j in meta["tilesets"] if j.get("path")),
        "objs": sum(1 for j in meta["objects"] if j.get("path")),
        "chars": sum(1 for j in meta["characters"] if j.get("path")),
    }
    print("[DONE]", json.dumps(summary), flush=True)
    if summary["tiles"] < 1 or summary["objs"] < 4 or summary["chars"] < 1:
        sys.exit(1)


if __name__ == "__main__":
    main()
