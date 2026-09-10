#!/usr/bin/env python3
"""Regen main NPCs with Style Lock proportions WITHOUT player-ref cloning.

Uses mode=standard (unique identity) + Style Lock prompt constraints.
Sequential to respect Tier-1 concurrency.
"""

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
OUT_CHARS = ROOT / "assets" / "sprites" / "characters"
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "main_npc_stylelock_standard.json"

LOCK = (
    "retro 16-bit 48x48 rpg sprite, tiny low detail character, chibi 2.5 heads proportion, "
    "20 pixels tall character centered inside 48x48 transparent frame, simple chunky shapes, "
    "DOT EYES 1x2 no white sclera, no mouth, no nose, flat shading, basic outline, "
    "2 colors per material, game sprite, feet near bottom of frame"
)

# Unique identities — standard mode creates NEW characters matching Style Lock scale
NPCS = [
    (
        "npc_recepcionista_elena",
        f"{LOCK}, young woman receptionist Elena, neat brown hair in low bun, navy blue formal vest "
        "over white shirt, dark navy skirt, tiny gold pin, female chibi silhouette",
    ),
    (
        "npc_instrutor_combate",
        f"{LOCK}, Wing Nen instructor, messy dark hair, thin glasses, dark green kimono tunic with "
        "sash over white shirt, beige pants, calm mentor stance",
    ),
    (
        "npc_examinador_oficial",
        f"{LOCK}, Satotz examiner, charcoal bowler hat (compact), purple suit coat, white cravat, "
        "thin cane, upright gentleman chibi",
    ),
    (
        "npc_ferreiro_mestre",
        f"{LOCK}, blacksmith Duran, short rugged brown hair, leather apron over grey shirt, brown pants, "
        "strong stocky forge worker",
    ),
    (
        "npc_vendedor_mercador",
        f"{LOCK}, merchant trader, green cloth hat, brown vest over cream shirt, pouch belt, friendly stance",
    ),
    (
        "npc_discipulo_zushi",
        f"{LOCK}, child disciple Zushi, short dark bowl-cut hair, white training gi with green sash, "
        "smaller child body still ~20px tall",
    ),
    (
        "npc_guarda_fronteira",
        f"{LOCK}, frontier guard Zebro, grey helmet, grey armor vest, upright spear, stocky sentry",
    ),
    (
        "npc_viajante_scout",
        f"{LOCK}, wilderness scout, green scarf, brown traveler cloak, small backpack, explorer NPC",
    ),
    (
        "npc_gon",
        f"{LOCK}, Gon-inspired hunter boy, spiky jet-black hair, green sleeveless jacket, white shorts, "
        "energetic child-teen chibi",
    ),
    (
        "npc_killua",
        f"{LOCK}, Killua-inspired assassin boy, silver-white spiky hair, dark blue sleeveless top, "
        "baggy pants, pale skin, cool stance",
    ),
    (
        "npc_kurapika",
        f"{LOCK}, Kurapika-inspired blond youth, short blond hair, white shirt black vest, chain hint, "
        "determined stance",
    ),
    (
        "npc_leorio",
        f"{LOCK}, Leorio-inspired young man chibi, short dark hair, teal suit jacket, white shirt, "
        "brown pants, briefcase hint",
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


def normalize_48(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    if im.size == (48, 48):
        return im
    # Keep feet near Y≈42
    if im.width > 48 or im.height > 48:
        im.thumbnail((48, 48), Image.NEAREST)
    canvas = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    ox = (48 - im.width) // 2
    oy = max(0, 48 - im.height - 5)
    canvas.paste(im, (ox, oy), im)
    return canvas


def download_character_sheet(token: str, character_id: str, dest_sheet: Path, rot_dir: Path) -> bool:
    headers = {"Authorization": f"Bearer {token}", "User-Agent": "HunterOnline/npc-standard"}
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
        match = None
        for n in z.namelist():
            if n.endswith(f"{name}.png") or f"/{name}.png" in n:
                match = n
                break
        if match is None:
            for n in z.namelist():
                if name in n.lower() and n.lower().endswith(".png"):
                    match = n
                    break
        if match is None:
            print(f"    missing {name}", flush=True)
            return False
        im = normalize_48(Image.open(io.BytesIO(z.read(match))))
        buf = io.BytesIO()
        im.save(buf, format="PNG")
        (rot_dir / f"{name}.png").write_bytes(buf.getvalue())
        frames.append(im)
        print(f"    rot {name} {im.size}", flush=True)
    sheet = Image.new("RGBA", (48 * 8, 48), (0, 0, 0, 0))
    for i, fr in enumerate(frames):
        sheet.paste(fr, (i * 48, 0), fr)
    dest_sheet.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(dest_sheet)
    print(f"    sheet {dest_sheet} {sheet.size}", flush=True)
    return True


def opaque_sim(a: Image.Image, b: Image.Image) -> float:
    same = tot = 0
    for pa, pb in zip(a.getdata(), b.getdata()):
        if pa[3] < 20 and pb[3] < 20:
            continue
        tot += 1
        if pa == pb:
            same += 1
    return (100.0 * same / tot) if tot else 0.0


def main() -> int:
    token = os.environ.get("PIXELLAB_API_TOKEN", "").strip()
    if not token:
        return 1
    mcp = MCP(token)
    mcp.call(
        "initialize",
        {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "hunter-npc-standard-lock", "version": "1"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass
    print("[balance]", mcp.tool("get_balance", {})["text"][:280], flush=True)

    # clone-detect reference (calibrated viajante)
    viajante = Image.open(
        OUT_CHARS / "npc_calibration_viajante_padokia_rotations" / "south.png"
    ).convert("RGBA")

    meta = {"batch": "main_npc_stylelock_standard", "created_at": time.time(), "characters": []}

    for name, desc in NPCS:
        print(f"[*] queue {name} (standard)", flush=True)
        r = None
        for attempt in range(24):
            r = mcp.tool(
                "create_character",
                {
                    "name": name + "_stdlock",
                    "description": desc,
                    "mode": "standard",
                    "size": 48,
                    "n_directions": 8,
                    "detail": "low detail",
                    "shading": "flat shading",
                    "outline": "single color black outline",
                    "view": "low top-down",
                    "body_type": "humanoid",
                },
            )
            print("   ", r["text"][:240].replace("\n", " "), flush=True)
            if "429" in r["text"] or "Maximum" in r["text"]:
                print(f"    wait concurrency {attempt+1}", flush=True)
                time.sleep(20)
                continue
            break
        cid = uuid_from(r["text"]) if r else None
        if not cid:
            meta["characters"].append({"name": name, "ok": False, "error": (r or {}).get("text", "")[:400]})
            continue
        print(f"[*] finish {name}", flush=True)
        done = poll_char(mcp, cid)
        sheet = OUT_CHARS / f"{name}_8dir.png"
        rot = OUT_CHARS / f"{name}_rotations"
        ok = download_character_sheet(token, cid, sheet, rot)
        sim = 0.0
        if ok:
            south = Image.open(rot / "south.png").convert("RGBA")
            sim = opaque_sim(south, viajante)
            print(f"    opaque_sim_vs_viajante={sim:.1f}%", flush=True)
            if sim > 70:
                print("    WARN too similar to viajante — identity may be weak", flush=True)
        meta["characters"].append(
            {
                "name": name,
                "id": cid,
                "ok": ok,
                "opaque_sim_viajante": sim,
                "queue": r["text"][:400],
                "result": done["text"][:500],
                "path": str(sheet.relative_to(ROOT)),
            }
        )
        OUT_META.parent.mkdir(parents=True, exist_ok=True)
        OUT_META.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(
        "[DONE]",
        json.dumps(
            {
                "chars": len(meta["characters"]),
                "ok": sum(1 for c in meta["characters"] if c.get("ok")),
                "unique_enough": sum(
                    1 for c in meta["characters"] if c.get("ok") and c.get("opaque_sim_viajante", 100) < 70
                ),
            }
        ),
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
