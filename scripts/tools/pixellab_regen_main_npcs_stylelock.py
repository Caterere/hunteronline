#!/usr/bin/env python3
"""DEPRECATED for unique NPCs — kept for reference only.

CRITICAL: mode=v3 + reference_image_base64 ROTATES the reference sprite.
Passing player(3).png clones the player identity (~100% opaque match).
For unique main NPCs use: pixellab_regen_main_npcs_standard_lock.py
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
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "main_npc_stylelock_regen.json"

CHAR = (
    "retro 16-bit 48x48 rpg sprite, tiny low detail character, chibi 2.5 heads proportion, "
    "20 pixels tall character centered inside 48x48 transparent frame, simple chunky shapes, "
    "DOT EYES 1x2 no white sclera, no mouth, no nose, flat shading, basic outline, "
    "2 colors per material, game sprite, NEW identity different from player reference"
)

# Batch A: Lobby / early-game principals (highest priority)
NPCS = [
    (
        "npc_recepcionista_elena",
        f"{CHAR}, Elena Hunter Association receptionist young woman, neat brown hair in low bun, "
        "navy blue formal vest over white collared shirt, dark navy skirt, tiny gold pin, "
        "female silhouette, soft posture",
    ),
    (
        "npc_instrutor_combate",
        f"{CHAR}, Wing Shingen-ryu Nen master instructor, messy unkempt dark hair, thin glasses bridge, "
        "loose dark green kimono tunic with sash over white shirt, beige training pants, calm mentor stance",
    ),
    (
        "npc_examinador_oficial",
        f"{CHAR}, Satotz Hunter examiner gentleman, dark charcoal bowler hat, tailored purple suit coat, "
        "white formal cravat, thin wooden cane hint, upright posture, tall hat kept compact",
    ),
    (
        "npc_ferreiro_mestre",
        f"{CHAR}, master blacksmith Duran, short rugged brown hair, leather apron over grey shirt, "
        "brown pants, strong arms hint, forge worker NPC",
    ),
    (
        "npc_vendedor_mercador",
        f"{CHAR}, traveling merchant NPC, green cloth hat, brown vest over cream shirt, pouch belt, "
        "friendly trader silhouette",
    ),
    (
        "npc_discipulo_zushi",
        f"{CHAR}, young martial arts disciple Zushi child, short dark hair bowl cut, simple white training "
        "gi with green sash, smaller child proportions but same Style Lock scale",
    ),
    (
        "npc_guarda_fronteira",
        f"{CHAR}, frontier gate guard Zebro, grey helmet, grey armor vest, spear held upright, "
        "stocky sentry stance, NOT same as Padokia road guard",
    ),
    (
        "npc_viajante_scout",
        f"{CHAR}, wilderness scout traveler, green hood or scarf, brown traveler cloak, backpack hint, "
        "outdoor explorer NPC, NEW identity",
    ),
    # Batch B: main cast frequently on maps
    (
        "npc_gon",
        f"{CHAR}, Gon Freecss inspired hunter boy, spiky jet-black hair, green sleeveless jacket, "
        "white shorts, fishing rod strap hint, energetic child-teen chibi, NEW identity",
    ),
    (
        "npc_killua",
        f"{CHAR}, Killua Zoldyck inspired assassin boy, silver-white spiky hair, dark blue sleeveless top, "
        "baggy pants, pale skin, cool stance, NEW identity",
    ),
    (
        "npc_kurapika",
        f"{CHAR}, Kurapika inspired blond youth, short blond hair, white shirt with black vest, "
        "chain accessory hint, determined stance, NEW identity",
    ),
    (
        "npc_leorio",
        f"{CHAR}, Leorio inspired tall young man kept chibi, short dark hair, teal suit jacket, "
        "white shirt, brown pants, briefcase hint, NEW identity",
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


def player_ref_b64() -> str:
    p3 = Image.open(ROOT / "assets" / "reference" / "player(3).png").convert("RGBA")
    if p3.size[0] >= 48 and p3.size[1] >= 48:
        p3 = p3.crop((0, 0, 48, 48))
    buf = io.BytesIO()
    p3.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


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
    headers = {"Authorization": f"Bearer {token}", "User-Agent": "HunterOnline/npc-regen"}
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
            print(f"    missing rotation {name}", flush=True)
            return False
        raw = z.read(match)
        im = Image.open(io.BytesIO(raw)).convert("RGBA")
        if im.size != (48, 48):
            # Style Lock: force into 48 canvas (bottom-align feet)
            canvas = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
            # scale down if larger
            if im.width > 48 or im.height > 48:
                im.thumbnail((48, 48), Image.NEAREST)
            ox = (48 - im.width) // 2
            oy = 48 - im.height - 5  # aim feet near Y≈42-43
            if oy < 0:
                oy = 0
            canvas.paste(im, (ox, oy), im)
            im = canvas
        (rot_dir / f"{name}.png").write_bytes(
            # rewrite normalized
            (lambda i: (buf := io.BytesIO(), i.save(buf, format="PNG"), buf.getvalue())[2])(im)
        )
        frames.append(im)
        print(f"    rot {name} {im.size}", flush=True)
    sheet = Image.new("RGBA", (48 * 8, 48), (0, 0, 0, 0))
    for i, fr in enumerate(frames):
        sheet.paste(fr, (i * 48, 0), fr)
    dest_sheet.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(dest_sheet)
    print(f"    sheet {dest_sheet} {sheet.size}", flush=True)
    return True


def main() -> int:
    print("DEPRECATED: use pixellab_regen_main_npcs_standard_lock.py", file=sys.stderr)
    return 2
    # unreachable original follows for reference
    if False:
        return _main_impl()

def _main_impl() -> int:
    token = os.environ.get("PIXELLAB_API_TOKEN", "").strip()
    if not token:
        print("PIXELLAB_API_TOKEN missing", file=sys.stderr)
        return 1
    mcp = MCP(token)
    mcp.call(
        "initialize",
        {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "hunter-npc-stylelock", "version": "1"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass

    print("[balance]", mcp.tool("get_balance", {})["text"][:300], flush=True)
    ref = player_ref_b64()
    meta = {"batch": "main_npc_stylelock_v3", "created_at": time.time(), "characters": []}

    queued = []
    for name, desc in NPCS:
        print(f"[*] queue {name}", flush=True)
        r = mcp.tool(
            "create_character",
            {
                "name": name + "_v3lock",
                "description": desc,
                "mode": "v3",
                "size": 48,
                "detail": "low detail",
                "outline": "single color black outline",
                "view": "low top-down",
                "reference_image_base64": ref,
            },
        )
        print("   ", r["text"][:240].replace("\n", " "), flush=True)
        cid = uuid_from(r["text"])
        if not cid:
            print("    FAIL no id", flush=True)
            continue
        queued.append((name, cid, r["text"]))
        time.sleep(1)

    for name, cid, qtext in queued:
        print(f"[*] finish {name}", flush=True)
        r = poll_char(mcp, cid)
        sheet = OUT_CHARS / f"{name}_8dir.png"
        rot = OUT_CHARS / f"{name}_rotations"
        ok = download_character_sheet(token, cid, sheet, rot)
        meta["characters"].append(
            {
                "name": name,
                "id": cid,
                "ok": ok,
                "queue": qtext[:400],
                "result": r["text"][:600],
                "path": str(sheet.relative_to(ROOT)),
            }
        )

    OUT_META.parent.mkdir(parents=True, exist_ok=True)
    OUT_META.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print("[DONE]", json.dumps({"chars": len(meta["characters"]), "ok": sum(1 for c in meta["characters"] if c.get("ok"))}), flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
