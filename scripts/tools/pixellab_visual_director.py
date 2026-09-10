#!/usr/bin/env python3
"""Hunter Online — PixelLab visual director pipeline."""

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
OUT_META = OUT_TILES / "director_jobs.json"

CHAR_STYLE = (
    "retro 16-bit 48x48 rpg sprite, tiny low detail character, chibi 2.5 heads proportion, "
    "20 pixels tall character centered inside 48x48 transparent frame, simple chunky shapes, "
    "dot eyes no sclera, flat shading, basic outline, 2 colors per material, game sprite, "
    "NOT photorealistic, NOT high detail, NOT anime portrait"
)

TILESETS = [
    (
        "yorknew_avenue_wang",
        "dark cobblestone night city street, muted navy shadow cracks, pixel art 16x16",
        "worn plaza tiles with faint gold inlay, neon-free classic rpg pavement",
    ),
    (
        "arena_corridor_wang",
        "polished arena stone floor warm beige, subtle wear, pixel art 16x16",
        "training hall tile with faint ring marks, clean rpg tileset",
    ),
    (
        "kukuroo_path_wang",
        "mountain forest dirt path brown soil, moss edges, pixel art 16x16",
        "dense dark green grass with small stones, classic top-down rpg",
    ),
    (
        "padokia_road_wang",
        "vibrant green mmo grass soft clumps, pixel art 16x16",
        "reddish-brown worn dirt road wagon tracks, top-down rpg",
    ),
]

NPCS = [
    ("npc_mafioso_yorknew_ambient", f"{CHAR_STYLE}, mafia street thug dark suit, short black hair, yorknew night"),
    ("npc_lutador_arena_ambient", f"{CHAR_STYLE}, arena fighter bandages, short sport gi, heavens arena"),
    ("npc_mordomo_zoldyck_ambient", f"{CHAR_STYLE}, butler black suit white gloves, kukuroo mansion staff"),
    ("npc_herbalista_floresta", f"{CHAR_STYLE}, forest herbalist green cloak pouch, soft brown hair"),
]

OBJECTS = [
    ("yorknew_street_crate.png", "pixel art wooden shipping crate with metal straps, top-down rpg prop, transparent background, low detail", 32, 32),
    ("arena_training_post.png", "pixel art wooden training post with rope wraps, top-down rpg prop, transparent background, low detail", 32, 48),
    ("kukuroo_stone_lantern.png", "pixel art mossy stone lantern pillar, top-down rpg prop, transparent background, low detail", 32, 48),
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
    req = urllib.request.Request(url, headers={"User-Agent": "HunterOnline/1.1"})
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
            "clientInfo": {"name": "hunter-director", "version": "1.1"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass

    print("[balance]", mcp.tool("get_balance", {})["text"][:250], flush=True)

    meta: dict = {"created_at": time.time(), "tilesets": [], "characters": [], "objects": []}
    OUT_TILES.mkdir(parents=True, exist_ok=True)
    OUT_CHARS.mkdir(parents=True, exist_ok=True)
    OUT_OBJS.mkdir(parents=True, exist_ok=True)

    for name, lower, upper in TILESETS:
        print(f"[*] queue tileset {name}", flush=True)
        r = mcp.tool(
            "create_topdown_tileset",
            {
                "lower_description": lower,
                "upper_description": upper,
                "tile_size": {"width": 16, "height": 16},
                "mode": "standard",
            },
        )
        print("   ", r["text"][:220].replace("\n", " | "), flush=True)
        meta["tilesets"].append({"name": name, "id": uuid_from(r["text"]), "queue": r["text"][:500]})

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
        print("   ", r["text"][:220].replace("\n", " | "), flush=True)
        meta["characters"].append({"name": name, "id": uuid_from(r["text"]), "queue": r["text"][:500]})

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
                "shading": "flat shading",
                "detail": "low detail",
            },
        )
        print("   ", r["text"][:220].replace("\n", " | "), flush=True)
        meta["objects"].append({"out": out, "id": uuid_from(r["text"]), "queue": r["text"][:500]})

    OUT_META.write_text(json.dumps(meta, indent=2))
    print("[+] queued", flush=True)

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
        print(f"[*] animate walk {job['name']}", flush=True)
        ar = mcp.tool(
            "animate_character",
            {
                "character_id": job["id"],
                "template_animation_id": "walk",
                "animation_name": "walk",
            },
        )
        print("   ", ar["text"][:220].replace("\n", " | "), flush=True)
        job["animate"] = ar["text"][:700]

    for job in meta["objects"]:
        if not job.get("id"):
            continue
        print(f"[*] finish object {job['out']}", flush=True)
        r = poll(mcp, "get_map_object", "object_id", job["id"], timeout=300)
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
        print(f"[*] wait walk {job['name']}", flush=True)
        t0 = time.time()
        while time.time() - t0 < 600:
            r = mcp.tool("get_character", {"character_id": job["id"]})
            text = r["text"]
            print(f"    [{int(time.time()-t0):3d}s] {text[:140].replace(chr(10), ' ')}", flush=True)
            low = text.lower()
            if "walk" in low and not busy(text):
                dest = OUT_CHARS / f"{job['name']}_walk.png"
                if save_images(r["images"], dest):
                    job["walk_path"] = str(dest.relative_to(ROOT))
                    break
                urls = [u for u in urls_from(text) if "walk" in u.lower() or u.lower().endswith(".png")]
                if urls:
                    download(urls[0], dest)
                    job["walk_path"] = str(dest.relative_to(ROOT))
                    break
                if "animation" in low and "completed" in low:
                    break
            if "failed" in low and "walk" in low:
                break
            time.sleep(10)

    OUT_META.write_text(json.dumps(meta, indent=2))
    print(
        "[DONE]",
        json.dumps(
            {
                "tiles": sum(1 for j in meta["tilesets"] if j.get("path")),
                "chars": sum(1 for j in meta["characters"] if j.get("path")),
                "objs": sum(1 for j in meta["objects"] if j.get("path")),
                "walks": sum(1 for j in meta["characters"] if j.get("walk_path")),
            }
        ),
        flush=True,
    )


if __name__ == "__main__":
    main()
