#!/usr/bin/env python3
"""Hunter Online — Phase 2 world density batch.

Calibrated against assets/reference/world_detail_grass_dirt_trees_ref.png
(soft olive grass + jagged dirt patches + bubbly canopy trees).
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
OUT_OBJS = ROOT / "assets" / "sprites" / "objects"
OUT_META = OUT_TILES / "phase2_density_jobs.json"

WORLD_LOCK = (
    "HUNTER ONLINE WORLD DETAIL STYLE. Soft modern pixel-art MMORPG environment. "
    "Olive/light-green grass with sparse darker tufts (2-4 pixels), NOT flat, NOT noisy. "
    "Dirt paths: desaturated warm tan/brownish-grey irregular patches with jagged "
    "pixel-staircased edges into grass — no smooth gradients. "
    "Trees: rounded bubbly overlapping canopy clusters, 3-4 green tones, short brown trunk, "
    "readable silhouette, richer than tiny player sprites. "
    "Hard pixel edges, dark outlines, top-left lighting, cast oval ground shadow. "
    "No photographic texture, no anti-aliasing, no painterly brushes."
)

TILESETS = [
    {
        "name": "phase2_grass_dirt_wang",
        "lower_description": (
            f"{WORLD_LOCK} Lower terrain: worn soft dirt footpath — warm tan to light brown, "
            "subtle pebbles, compacted patches, sparse grass intrusion at edges. 16x16 wang tileset."
        ),
        "upper_description": (
            f"{WORLD_LOCK} Upper terrain: soft olive grassland base with scattered darker green "
            "tufts and occasional tiny white flower dots. Calm readable texture. 16x16 wang tileset."
        ),
        "transition_description": (
            "organic jagged grass-to-dirt blend with pixel stair steps, small grass fingers "
            "into dirt and dirt bites into grass, no straight artificial border"
        ),
        "transition_size": 0.25,
    }
]

OBJECTS = [
    (
        "phase2_tree_green_a.png",
        f"{WORLD_LOCK} Temperate deciduous tree: lush green bubbly canopy (overlapping rounded "
        "leaf masses), short brown trunk with simple roots, soft oval shadow, top-down RPG prop, "
        "transparent background. Medium-large environmental detail.",
        48,
        64,
    ),
    (
        "phase2_tree_green_b.png",
        f"{WORLD_LOCK} Temperate deciduous tree VARIANT: same family as green forest trees but "
        "different canopy silhouette and branch layout, lush green tones, short trunk, oval shadow, "
        "top-down RPG prop, transparent background.",
        48,
        64,
    ),
    (
        "phase2_tree_autumn_a.png",
        f"{WORLD_LOCK} Autumn deciduous tree: orange and warm yellow bubbly canopy clusters, "
        "same scale/lighting as green forest trees, short brown trunk, oval shadow, "
        "top-down RPG prop, transparent background.",
        48,
        64,
    ),
    (
        "phase2_bush_berry.png",
        f"{WORLD_LOCK} Medium round leafy bush with a few bright red berry clusters, "
        "layered green pixel masses, irregular silhouette, soft shadow, top-down RPG prop.",
        32,
        32,
    ),
    (
        "phase2_bush_round.png",
        f"{WORLD_LOCK} Medium irregular green bush without berries, layered foliage clusters, "
        "same palette family as berry bush, soft shadow, top-down RPG prop.",
        32,
        32,
    ),
    (
        "phase2_rock_boulder.png",
        f"{WORLD_LOCK} Medium weathered grey boulder, irregular facets, dark crevices, "
        "lighter top-left highlights, tiny moss hints, soft ground shadow, top-down RPG prop.",
        40,
        32,
    ),
    (
        "phase2_rock_cluster.png",
        f"{WORLD_LOCK} Cluster of 2-3 small grey stones forming a natural group, moss accents, "
        "soft shadows, top-down RPG ground prop.",
        48,
        32,
    ),
    (
        "phase2_flowers_white.png",
        f"{WORLD_LOCK} Sparse ground decoration: several tiny white flowers (2-3 pixels with "
        "yellow centers) and a few dark green grass tufts on transparent background. "
        "Reusable scatter detail, not a character.",
        48,
        32,
    ),
    (
        "phase2_stump.png",
        f"{WORLD_LOCK} Cut tree stump with ringed wood top, short brown bark sides, "
        "tiny moss, soft oval shadow, top-down RPG prop.",
        32,
        32,
    ),
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
    req = urllib.request.Request(url, headers={"User-Agent": "HunterOnline/phase2"})
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
    return any(x in low for x in ("processing", "pending", "queued", "in progress", "generating", "creating"))


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
            "clientInfo": {"name": "hunter-phase2", "version": "1.0"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass

    print("[balance]", mcp.tool("get_balance", {})["text"][:280], flush=True)

    meta: dict = {
        "batch": "phase2_world_density",
        "reference": "assets/reference/world_detail_grass_dirt_trees_ref.png",
        "created_at": time.time(),
        "tilesets": [],
        "objects": [],
    }
    OUT_TILES.mkdir(parents=True, exist_ok=True)
    OUT_OBJS.mkdir(parents=True, exist_ok=True)

    for ts in TILESETS:
        print(f"[*] queue tileset {ts['name']}", flush=True)
        args = {
            "lower_description": ts["lower_description"],
            "upper_description": ts["upper_description"],
            "tile_size": {"width": 16, "height": 16},
            "mode": "standard",
            "transition_size": ts.get("transition_size", 0.25),
            "transition_description": ts.get("transition_description"),
        }
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

    OUT_META.write_text(json.dumps(meta, indent=2))
    summary = {
        "tiles": sum(1 for j in meta["tilesets"] if j.get("path")),
        "objs": sum(1 for j in meta["objects"] if j.get("path")),
    }
    print("[DONE]", json.dumps(summary), flush=True)
    if summary["tiles"] < 1 or summary["objs"] < 6:
        sys.exit(1)


if __name__ == "__main__":
    main()
