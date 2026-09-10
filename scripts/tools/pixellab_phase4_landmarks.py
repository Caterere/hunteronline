#!/usr/bin/env python3
"""Hunter Online — Phase 4 landmarks + NPC + enemy (ART_PIPELINE_CANON)."""

from __future__ import annotations

import base64
import io
import json
import os
import re
import sys
import time
import urllib.request
import zipfile
from pathlib import Path

from PIL import Image

MCP_URL = "https://api.pixellab.ai/mcp"
ROOT = Path("/workspace")
OUT_OBJS = ROOT / "assets" / "sprites" / "objects"
OUT_CHARS = ROOT / "assets" / "sprites" / "characters"
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "phase4_landmark_jobs.json"

WORLD = (
    "HUNTER ONLINE WORLD DETAIL STYLE. Soft modern top-down pixel-art MMORPG. "
    "Hard pixel edges, dark outlines, top-left lighting, soft oval ground shadow. "
    "Memorable silhouette, medium-high environmental detail, transparent background. "
    "No photographic texture, no anti-aliasing, no UI text."
)

CHAR = (
    "retro 16-bit 48x48 rpg sprite, tiny low detail character, chibi 2.5 heads proportion, "
    "20 pixels tall character centered inside 48x48 transparent frame, simple chunky shapes, "
    "DOT EYES 1x2 no white sclera, no mouth, no nose, flat shading, basic outline, "
    "2 colors per material, game sprite"
)

LANDMARKS = [
    (
        "phase4_landmark_hunter_arch.png",
        f"{WORLD} Unique landmark: weathered stone Hunter Association road arch / gate remnant "
        "on Padokia road. Two pillars + cracked lintel with simple crest blank (no text), "
        "moss, memorable silhouette. Compact 64x64 gameplay landmark.",
        64,
        64,
    ),
    (
        "phase4_landmark_nen_shrine.png",
        f"{WORLD} Unique landmark: small forest Nen shrine — carved stone monolith with "
        "subtle aura-carved rings, offering bowl, moss and root details. Memorable silhouette. "
        "Compact 48x64 landmark for Floresta dos Vestígios.",
        48,
        64,
    ),
    (
        "phase4_landmark_ruin_pillar.png",
        f"{WORLD} Unique landmark: broken ancient ruin pillar / column stump with engraved "
        "worn glyphs, rubble base, ivy hints. Memorable silhouette. Compact 40x64 prop landmark.",
        40,
        64,
    ),
]

NPCS = [
    (
        "npc_phase4_guarda_estrada",
        f"{CHAR}, Padokia road hunter guard ambient NPC, short dark hair, leather traveler "
        "vest over grey shirt, brown pants, simple spear or staff held upright, NEW identity "
        "different from player reference",
    )
]

ENEMIES = [
    (
        "enemy_phase4_fera_padokia",
        f"{CHAR}, small wild forest beast enemy for Padokia, quadruped-like crouched animal "
        "silhouette but humanoid-compatible chibi sprite, bristly brown fur clumps, pointed "
        "ears, aggressive posture, simple fangs hint, NOT photorealistic animal, game enemy sprite",
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


def poll_char(mcp: MCP, job_id: str, timeout: int = 900) -> dict:
    t0 = time.time()
    last = {"text": "", "images": [], "isError": True}
    while time.time() - t0 < timeout:
        last = mcp.tool("get_character", {"character_id": job_id, "include_preview": True})
        print(f"    [{int(time.time()-t0):3d}s] {last['text'][:140].replace(chr(10), ' ')}", flush=True)
        if last["isError"]:
            return last
        if not busy(last["text"]) and "completed" in last["text"].lower():
            return last
        if "failed" in last["text"].lower() and "status" in last["text"].lower():
            return last
        time.sleep(8)
    return last


def download_character_sheet(token: str, character_id: str, dest_sheet: Path, rot_dir: Path) -> bool:
    headers = {"Authorization": f"Bearer {token}", "User-Agent": "HunterOnline/phase4"}
    url = f"https://api.pixellab.ai/mcp/characters/{character_id}/download"
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=120) as resp:
        data = resp.read()
    if data[:2] != b"PK":
        print("    download not zip", flush=True)
        return False
    z = zipfile.ZipFile(io.BytesIO(data))
    order = [
        "south",
        "south-east",
        "east",
        "north-east",
        "north",
        "north-west",
        "west",
        "south-west",
    ]
    rot_dir.mkdir(parents=True, exist_ok=True)
    frames = []
    for name in order:
        # find matching file
        match = None
        for n in z.namelist():
            if n.lower().endswith(f"{name}.png"):
                match = n
                break
        if not match:
            print("    missing rotation", name, flush=True)
            return False
        raw = z.read(match)
        im = Image.open(io.BytesIO(raw)).convert("RGBA")
        im.save(rot_dir / f"{name}.png")
        frames.append(im)
        print(f"    rot {name} {im.size}", flush=True)
    w, h = frames[0].size
    sheet = Image.new("RGBA", (w * len(frames), h), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        sheet.paste(f, (i * w, 0))
    dest_sheet.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(dest_sheet)
    print(f"    sheet {dest_sheet} {sheet.size}", flush=True)
    return True


def player_ref_b64() -> str:
    p3 = Image.open(ROOT / "assets" / "reference" / "player(3).png").convert("RGBA")
    if p3.size[0] >= 48 and p3.size[1] >= 48:
        p3 = p3.crop((0, 0, 48, 48))
    buf = io.BytesIO()
    p3.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


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
            "clientInfo": {"name": "hunter-phase4", "version": "1.0"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass

    print("[balance]", mcp.tool("get_balance", {})["text"][:250], flush=True)
    meta = {
        "batch": "phase4_landmarks_npc_enemy",
        "created_at": time.time(),
        "landmarks": [],
        "characters": [],
    }
    OUT_OBJS.mkdir(parents=True, exist_ok=True)
    OUT_CHARS.mkdir(parents=True, exist_ok=True)

    for out, desc, w, h in LANDMARKS:
        print(f"[*] queue landmark {out}", flush=True)
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
        meta["landmarks"].append({"out": out, "id": uuid_from(r["text"]), "queue": r["text"][:400]})
        time.sleep(2)

    ref = player_ref_b64()
    for name, desc in NPCS + ENEMIES:
        print(f"[*] queue character {name}", flush=True)
        r = mcp.tool(
            "create_character",
            {
                "name": name,
                "description": desc,
                "mode": "v3",
                "size": 48,
                "detail": "low detail",
                "outline": "single color black outline",
                "view": "low top-down",
                "reference_image_base64": ref,
            },
        )
        print("   ", r["text"][:240].replace("\n", " | "), flush=True)
        meta["characters"].append({"name": name, "id": uuid_from(r["text"]), "queue": r["text"][:500]})
        time.sleep(2)

    OUT_META.write_text(json.dumps(meta, indent=2))

    ok_l = 0
    for job in meta["landmarks"]:
        if not job.get("id"):
            continue
        print(f"[*] finish landmark {job['out']}", flush=True)
        r = poll_obj(mcp, job["id"])
        job["result"] = r["text"][:800]
        dest = OUT_OBJS / job["out"]
        if save_images(r["images"], dest):
            job["path"] = str(dest.relative_to(ROOT))
            ok_l += 1

    ok_c = 0
    for job in meta["characters"]:
        if not job.get("id"):
            continue
        print(f"[*] finish character {job['name']}", flush=True)
        r = poll_char(mcp, job["id"])
        job["result"] = r["text"][:1200]
        sheet = OUT_CHARS / f"{job['name']}_8dir.png"
        rots = OUT_CHARS / f"{job['name']}_rotations"
        if download_character_sheet(token, job["id"], sheet, rots):
            job["path"] = str(sheet.relative_to(ROOT))
            ok_c += 1
        elif save_images(r["images"], sheet):
            job["path"] = str(sheet.relative_to(ROOT))
            ok_c += 1

    OUT_META.write_text(json.dumps(meta, indent=2))
    print("[DONE]", json.dumps({"landmarks": ok_l, "chars": ok_c}), flush=True)
    if ok_l < 2 or ok_c < 1:
        sys.exit(1)


if __name__ == "__main__":
    main()
