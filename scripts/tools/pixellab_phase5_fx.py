#!/usr/bin/env python3
"""Hunter Online — Phase 5 combat FX + weather + night (ART_PIPELINE_CANON)."""

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
OUT_FX = ROOT / "assets" / "sprites" / "effects"
OUT_OBJS = ROOT / "assets" / "sprites" / "objects"
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "phase5_fx_jobs.json"

FX = (
    "Hunter Online pixel-art combat VFX sprite, hard pixel edges, limited palette, "
    "strong silhouette, transparent background, compact readable effect for 48x48 characters, "
    "no photographic texture, no smooth glow bloom, no UI text, no full-screen explosion."
)

WORLD = (
    "HUNTER ONLINE WORLD DETAIL STYLE. Soft modern top-down pixel-art MMORPG. "
    "Hard pixel edges, dark outlines, top-left lighting. Transparent background. "
    "No photographic texture, no anti-aliasing, no UI text."
)

# Freeform image FX (create_image_pixen)
IMAGE_FX = [
    (
        "phase5_fx_hit.png",
        f"{FX} Compact physical hit impact burst: small star-shock core, directional "
        "pixel fragments, short readable punch impact. Single still frame.",
        32,
        32,
    ),
    (
        "phase5_fx_slash.png",
        f"{FX} Compact melee slash arc: curved bright slash stroke, small impact point, "
        "few pixel fragments. Side-facing directional slash. Single still frame.",
        48,
        32,
    ),
    (
        "phase5_fx_nen_aura.png",
        f"{FX} Restrained Nen aura ring: compact pixel clusters, subtle aura outline, "
        "small upward energy fragments, cool teal-cyan limited palette. Subordinate to character. "
        "Single still frame.",
        48,
        48,
    ),
    (
        "phase5_fx_heal.png",
        f"{FX} Small healing Nen effect: gentle upward particles, compact circular energy, "
        "soft positive light impression, limited warm green palette. Single still frame.",
        32,
        32,
    ),
    (
        "phase5_fx_dash_dust.png",
        f"{FX} Compact dash dust kick: short directional dust streaks and dirt pixels, "
        "speed accent without giant energy trail. Single still frame.",
        32,
        32,
    ),
]

# Map objects for weather / night atmosphere props
MAP_OBJS = [
    (
        "phase5_weather_puddle.png",
        f"{WORLD} Small rain puddle / wet ground patch on dirt-grass, soft oval shape, "
        "subtle reflection hint, dark wet edge. Compact ground decal 32x32.",
        32,
        32,
    ),
    (
        "phase5_weather_leaf.png",
        f"{WORLD} Single fallen autumn leaf particle prop, readable silhouette, "
        "soft shadow. Tiny weather detail 32x32.",
        32,
        32,
    ),
    (
        "phase5_night_lantern_glow.png",
        f"{WORLD} Warm night lantern glow orb / soft light bloom impression as pixel clusters "
        "(not smooth gradient), amber-yellow limited palette, transparent. Compact 32x32 light accent.",
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


def busy(text: str) -> bool:
    low = text.lower()
    return any(
        x in low
        for x in ("processing", "pending", "queued", "in progress", "generating", "creating")
    )


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


def poll_image(mcp: MCP, job_id: str, timeout: int = 300) -> dict:
    t0 = time.time()
    last = {"text": "", "images": [], "isError": True}
    while time.time() - t0 < timeout:
        last = mcp.tool("get_image", {"job_id": job_id})
        print(f"    [{int(time.time()-t0):3d}s] {last['text'][:140].replace(chr(10), ' ')}", flush=True)
        if last["isError"]:
            return last
        if last["images"] or ("completed" in last["text"].lower() and not busy(last["text"])):
            return last
        if "failed" in last["text"].lower():
            return last
        time.sleep(4)
    return last


def poll_obj(mcp: MCP, job_id: str, timeout: int = 400) -> dict:
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


def main() -> int:
    token = os.environ.get("PIXELLAB_API_TOKEN")
    if not token:
        print("PIXELLAB_API_TOKEN missing", file=sys.stderr)
        return 1
    mcp = MCP(token)
    mcp.call(
        "initialize",
        {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "hunteronline-phase5", "version": "1"},
        },
    )
    mcp.call("notifications/initialized")
    bal = mcp.tool("get_balance", {})
    print("[balance]", bal["text"][:300], flush=True)

    meta: dict = {"batch": "phase5_fx_weather_night", "created_at": time.time(), "images": [], "objects": []}
    OUT_FX.mkdir(parents=True, exist_ok=True)
    OUT_OBJS.mkdir(parents=True, exist_ok=True)

    queued_img = []
    for out_name, desc, w, h in IMAGE_FX:
        print(f"[*] queue image {out_name}", flush=True)
        q = mcp.tool(
            "create_image_pixen",
            {
                "description": desc,
                "width": w,
                "height": h,
                "no_background": True,
                "view": "side",
                "outline": "single color outline",
                "detail": "medium detail",
            },
        )
        print("   ", q["text"][:220].replace("\n", " "), flush=True)
        jid = uuid_from(q["text"])
        if not jid:
            print("    FAIL no job id", flush=True)
            continue
        queued_img.append((out_name, jid, q["text"]))

    queued_obj = []
    for out_name, desc, w, h in MAP_OBJS:
        print(f"[*] queue object {out_name}", flush=True)
        q = mcp.tool(
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
        print("   ", q["text"][:220].replace("\n", " "), flush=True)
        oid = uuid_from(q["text"])
        if not oid:
            print("    FAIL no object id", flush=True)
            continue
        queued_obj.append((out_name, oid, q["text"]))

    for out_name, jid, qtext in queued_img:
        print(f"[*] finish image {out_name}", flush=True)
        r = poll_image(mcp, jid)
        dest = OUT_FX / out_name
        if not save_images(r["images"], dest):
            # try download URL from text if any
            m = re.search(r"https://\S+", r["text"])
            if m:
                url = m.group(0).rstrip(").,")
                try:
                    req = urllib.request.Request(url, headers={"User-Agent": "HunterOnline/phase5"})
                    with urllib.request.urlopen(req, timeout=60) as resp:
                        dest.write_bytes(resp.read())
                    print(f"    downloaded {dest} ({dest.stat().st_size}B)", flush=True)
                except Exception as e:
                    print(f"    FAIL download {e}", flush=True)
            else:
                print("    FAIL no image", flush=True)
        meta["images"].append(
            {"out": out_name, "id": jid, "queue": qtext[:400], "result": r["text"][:800], "path": str(dest.relative_to(ROOT))}
        )

    for out_name, oid, qtext in queued_obj:
        print(f"[*] finish object {out_name}", flush=True)
        r = poll_obj(mcp, oid)
        dest = OUT_OBJS / out_name
        if not save_images(r["images"], dest):
            print("    FAIL no image", flush=True)
        meta["objects"].append(
            {"out": out_name, "id": oid, "queue": qtext[:400], "result": r["text"][:800], "path": str(dest.relative_to(ROOT))}
        )

    OUT_META.parent.mkdir(parents=True, exist_ok=True)
    OUT_META.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(
        "[DONE]",
        json.dumps({"images": len(meta["images"]), "objects": len(meta["objects"])}),
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
