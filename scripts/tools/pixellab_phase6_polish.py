#!/usr/bin/env python3
"""Hunter Online — Phase 6 map polish + storytelling + secrets (ART_PIPELINE_CANON)."""

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
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "phase6_polish_jobs.json"

WORLD = (
    "HUNTER ONLINE WORLD DETAIL STYLE. Soft modern top-down pixel-art MMORPG. "
    "Hard pixel edges, dark outlines, top-left lighting. Transparent background. "
    "No photographic texture, no anti-aliasing, no UI text. Controlled detail, "
    "readable silhouette, restrained storytelling."
)

# Freeform image props via create_image_pixen
IMAGE_PROPS = [
    (
        "phase6_story_abandoned_camp.png",
        f"{WORLD} Environmental storytelling prop: small abandoned hunter camp — "
        "cold ash fire ring, two charred sticks, torn bedroll hint. Compact 48x48. "
        "Implies someone left in a hurry. No characters.",
        48,
        48,
    ),
    (
        "phase6_story_broken_cart.png",
        f"{WORLD} Environmental storytelling prop: damaged wooden merchant cart "
        "with broken wheel and spilled crate. Compact 48x48 roadside wreck. No characters.",
        48,
        48,
    ),
    (
        "phase6_story_scuffle_mark.png",
        f"{WORLD} Environmental storytelling ground decal: restrained dirt scuffle "
        "marks and faint dark stains on grass/dirt, not gore. Compact 32x32.",
        32,
        32,
    ),
    (
        "phase6_story_torn_banner.png",
        f"{WORLD} Environmental storytelling prop: torn Hunter Association cloth banner "
        "on a snapped wooden stake, frayed edges, muted navy/gold. Compact 32x48.",
        32,
        48,
    ),
    (
        "phase6_story_broken_weapon.png",
        f"{WORLD} Environmental storytelling prop: discarded broken spear shaft with "
        "snapped tip lying on ground. Compact 32x32. No characters.",
        32,
        32,
    ),
    (
        "phase6_secret_hollow_stump.png",
        f"{WORLD} Secret exploration prop: old tree stump with a dark hollow opening "
        "hinting at a hidden cache. Compact 32x32. Subtle, not glowing treasure.",
        32,
        32,
    ),
    (
        "phase6_secret_false_rock.png",
        f"{WORLD} Secret marker prop: slightly odd mossy rock with a faint unnatural "
        "seam suggesting a false rock / hidden alcove. Compact 32x32.",
        32,
        32,
    ),
    (
        "phase6_secret_glint.png",
        f"{WORLD} Tiny secret item glint sparkle: 2-3 bright pixel clusters, "
        "subtle treasure hint particle. Compact 16x16. Not a full treasure chest.",
        16,
        16,
    ),
    (
        "phase6_secret_trail_marker.png",
        f"{WORLD} Subtle secret trail marker stone with a tiny carved hunter rune. "
        "Compact 16x16 ground clue for exploration.",
        16,
        16,
    ),
    (
        "phase6_polish_path_crack.png",
        f"{WORLD} Map polish ground detail: small cracked dirt path wear patch. "
        "Compact 32x16 seamless-friendly decal.",
        32,
        16,
    ),
    (
        "phase6_polish_moss_patch.png",
        f"{WORLD} Map polish ground detail: soft moss/lichen patch for stone/dirt edges. "
        "Compact 32x16. Low contrast, supporting detail.",
        32,
        16,
    ),
    (
        "phase6_polish_fence_ruin.png",
        f"{WORLD} Map polish prop: broken wooden fence segment with two posts and "
        "one snapped rail. Compact 48x32. Weathered, not cluttered.",
        48,
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
            "clientInfo": {"name": "hunteronline-phase6", "version": "1"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass
    bal = mcp.tool("get_balance", {})
    print("[balance]", bal["text"][:300], flush=True)

    meta: dict = {"batch": "phase6_polish_story_secrets", "created_at": time.time(), "images": []}
    OUT_OBJS.mkdir(parents=True, exist_ok=True)

    for out_name, desc, w, h in IMAGE_PROPS:
        dest = OUT_OBJS / out_name
        print(f"\n[*] {out_name}", flush=True)
        q = None
        for _attempt in range(12):
            q = mcp.tool(
                "create_image_pixen",
                {
                    "description": desc,
                    "width": w,
                    "height": h,
                    "no_background": True,
                    "view": "low top-down",
                    "outline": "single color outline",
                    "detail": "medium detail",
                },
            )
            print("   ", q["text"][:220].replace("\n", " "), flush=True)
            if "429" in q["text"] or "Maximum" in q["text"]:
                time.sleep(15)
                continue
            break
        jid = uuid_from(q["text"]) if q else None
        if not jid:
            meta["images"].append({"name": out_name, "ok": False, "stage": "queue"})
            OUT_META.write_text(json.dumps(meta, indent=2), encoding="utf-8")
            continue
        img = poll_image(mcp, jid)
        ok = save_images(img["images"], dest)
        if not ok:
            m = re.search(r"https://\S+", img["text"])
            if m:
                url = m.group(0).rstrip(").,")
                req = urllib.request.Request(url, headers={"User-Agent": "HunterOnline/phase6"})
                with urllib.request.urlopen(req, timeout=60) as resp:
                    dest.write_bytes(resp.read())
                ok = dest.exists() and dest.stat().st_size > 0
                if ok:
                    print(f"    downloaded {dest} ({dest.stat().st_size}B)", flush=True)
        meta["images"].append({"name": out_name, "id": jid, "ok": ok, "path": str(dest.relative_to(ROOT))})
        OUT_META.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(
        "[DONE]",
        json.dumps({"ok": sum(1 for x in meta["images"] if x.get("ok")), "total": len(meta["images"])}),
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
