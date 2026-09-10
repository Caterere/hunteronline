#!/usr/bin/env python3
"""Hunter Online — Phase 3 props batch (fences, signs, crates, barrel, well)."""

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
OUT_OBJS = ROOT / "assets" / "sprites" / "objects"
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "phase3_props_jobs.json"

WORLD = (
    "HUNTER ONLINE WORLD DETAIL STYLE. Soft modern top-down pixel-art MMORPG props. "
    "Hard pixel edges, dark outlines, top-left lighting, soft oval ground shadow. "
    "Medium environmental detail, readable silhouette. No photographic texture, "
    "no anti-aliasing, no isometric 3D cubes unless natural for the prop. "
    "Transparent background. Match density of approved phase2 trees/rocks."
)

OBJECTS = [
    (
        "phase3_fence_wood.png",
        f"{WORLD} Reusable wooden fence segment, old but maintained: two posts + "
        "horizontal boards, subtle cracks, darker joints, simple ground shadow. "
        "Side-facing segment for path borders. Compact readable prop ~48x32.",
        48,
        32,
    ),
    (
        "phase3_fence_wood_post.png",
        f"{WORLD} Single wooden fence post / end post with small ground contact, "
        "worn wood, subtle cracks, soft shadow. Compact 32x32 prop.",
        32,
        32,
    ),
    (
        "phase3_signpost.png",
        f"{WORLD} Wooden path signpost: vertical post + blank rectangular sign board "
        "with clean EMPTY board area (no fake text). Worn edges, small metal nail dots, "
        "ground shadow. High top-down RPG navigation prop ~32x48.",
        32,
        48,
    ),
    (
        "phase3_barrel.png",
        f"{WORLD} Wooden storage barrel, iron rings, subtle wood grain clusters, "
        "soft shadow. Top-down RPG prop, compact 32x32.",
        32,
        32,
    ),
    (
        "phase3_crate.png",
        f"{WORLD} Wooden shipping crate with simple planks and corner bands, "
        "soft shadow. Top-down RPG prop 32x32.",
        32,
        32,
    ),
    (
        "phase3_crate_large.png",
        f"{WORLD} Larger wooden crate / stacked crate look, same wood family as "
        "small crate, soft shadow. Top-down RPG prop 40x32.",
        40,
        32,
    ),
    (
        "phase3_well.png",
        f"{WORLD} Stone village well with circular stone rim, wooden winch crossbar, "
        "bucket hint, soft shadow. Memorable but compact top-down RPG prop 48x48.",
        48,
        48,
    ),
    (
        "phase3_lantern_post.png",
        f"{WORLD} Wooden roadside lantern post with warm lantern head, simple pole, "
        "soft shadow. Top-down RPG prop 32x48. Not a character.",
        32,
        48,
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


def busy(text: str) -> bool:
    low = text.lower()
    return any(x in low for x in ("processing", "pending", "queued", "in progress", "generating", "creating"))


def save_images(images: list, dest: Path) -> bool:
    if not images:
        return False
    data = images[0].get("data") or images[0].get("blob")
    if not data:
        return False
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(base64.b64decode(data))
    print(f"    saved {dest} ({dest.stat().st_size}B)", flush=True)
    return True


def poll(mcp: MCP, job_id: str, timeout: int = 400) -> dict:
    t0 = time.time()
    last = {"text": "", "images": [], "isError": True}
    while time.time() - t0 < timeout:
        last = mcp.tool("get_map_object", {"object_id": job_id})
        print(f"    [{int(time.time()-t0):3d}s] {last['text'][:140].replace(chr(10), ' ')}", flush=True)
        if last["isError"]:
            return last
        if not busy(last["text"]) and (last["images"] or "completed" in last["text"].lower()):
            return last
        if "failed" in last["text"].lower():
            return last
        time.sleep(5)
    return last


def main() -> None:
    token = os.environ.get("PIXELLAB_API_TOKEN", "").strip()
    if not token:
        sys.exit(2)
    mcp = MCP(token)
    mcp.call(
        "initialize",
        {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "hunter-phase3", "version": "1.0"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass

    print("[balance]", mcp.tool("get_balance", {})["text"][:250], flush=True)
    meta = {"batch": "phase3_props", "created_at": time.time(), "objects": []}
    OUT_OBJS.mkdir(parents=True, exist_ok=True)

    for out, desc, w, h in OBJECTS:
        print(f"[*] queue {out}", flush=True)
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
        print("   ", r["text"][:220].replace("\n", " | "), flush=True)
        meta["objects"].append({"out": out, "id": uuid_from(r["text"]), "queue": r["text"][:400]})
        time.sleep(2)

    OUT_META.write_text(json.dumps(meta, indent=2))

    ok = 0
    for job in meta["objects"]:
        if not job.get("id"):
            continue
        print(f"[*] finish {job['out']}", flush=True)
        r = poll(mcp, job["id"])
        job["result"] = r["text"][:800]
        dest = OUT_OBJS / job["out"]
        if save_images(r["images"], dest):
            job["path"] = str(dest.relative_to(ROOT))
            ok += 1

    OUT_META.write_text(json.dumps(meta, indent=2))
    print("[DONE]", json.dumps({"objs": ok}), flush=True)
    if ok < 5:
        sys.exit(1)


if __name__ == "__main__":
    main()
