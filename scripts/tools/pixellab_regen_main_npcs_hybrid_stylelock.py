#!/usr/bin/env python3
"""Main NPC Style Lock hybrid regen.

Pipeline (unique identity + calibrated scale):
1) create_image_pixen → unique south sprite (often too tall/detailed)
2) fit into Style Lock geometry (~20px tall, feet Y≈42, max width ~18)
3) create_character mode=v3 + reference=fitted south → 8 directions

Do NOT use v3+player-ref for unique NPCs (clones player identity).
Do NOT use bare standard/v3 without fit (fills ~34–44px, breaks Style Lock).
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
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "main_npc_hybrid_stylelock.json"
OUT_SOUTH = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "hybrid_south_refs"

LOCK = (
    "tiny low-detail 16-bit RPG chibi character sprite, ONLY about 20 pixels tall inside the canvas, "
    "large head ~60% of body height, DOT EYES exactly 1x2 black pixels NO white sclera, NO mouth NO nose, "
    "flat shading, hard 1px black outline, 2 colors per material, transparent background, "
    "NOT a full-body tall figure, keep huge empty transparent padding around the tiny character"
)

NPCS = [
    (
        "npc_recepcionista_elena",
        f"{LOCK}. Elena Hunter Association receptionist young woman, neat brown hair in low bun, "
        "navy blue formal vest over white shirt, dark navy skirt, tiny gold pin, female",
    ),
    (
        "npc_instrutor_combate",
        f"{LOCK}. Wing Nen instructor, messy dark hair, thin glasses bridge, dark green kimono tunic "
        "with sash over white shirt, beige pants, calm mentor",
    ),
    (
        "npc_examinador_oficial",
        f"{LOCK}. Satotz examiner gentleman, compact charcoal bowler hat, purple suit coat, white cravat, "
        "thin cane, upright posture",
    ),
    (
        "npc_ferreiro_mestre",
        f"{LOCK}. blacksmith Duran, short rugged brown hair, leather apron over grey shirt, brown pants, stocky",
    ),
    (
        "npc_vendedor_mercador",
        f"{LOCK}. merchant trader, green cloth hat, brown vest over cream shirt, pouch belt",
    ),
    (
        "npc_discipulo_zushi",
        f"{LOCK}. child disciple Zushi, short dark bowl-cut hair, white training gi with green sash",
    ),
    (
        "npc_guarda_fronteira",
        f"{LOCK}. frontier guard Zebro, grey helmet, grey armor vest, upright spear, stocky sentry",
    ),
    (
        "npc_viajante_scout",
        f"{LOCK}. wilderness scout, green scarf, brown traveler cloak, small backpack",
    ),
    (
        "npc_gon",
        f"{LOCK}. Gon-inspired hunter boy, spiky jet-black hair, green sleeveless jacket, white shorts",
    ),
    (
        "npc_killua",
        f"{LOCK}. Killua-inspired assassin boy, silver-white spiky hair, dark blue sleeveless top, baggy pants",
    ),
    (
        "npc_kurapika",
        f"{LOCK}. Kurapika-inspired blond youth, short blond hair, white shirt black vest, chain hint",
    ),
    (
        "npc_leorio",
        f"{LOCK}. Leorio-inspired young man chibi, short dark hair, teal suit jacket, white shirt, briefcase hint",
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


def save_img(images: list, dest: Path) -> bool:
    if not images:
        return False
    data = images[0].get("data") or images[0].get("blob")
    if not data:
        return False
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(base64.b64decode(data))
    return True


def fit_stylelock(im: Image.Image, target_h: int = 20, feet_y: int = 42, max_w: int = 18) -> Image.Image:
    im = im.convert("RGBA")
    bb = im.split()[-1].getbbox()
    if not bb:
        return Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    crop = im.crop(bb)
    nh = target_h
    nw = max(1, int(round(crop.width * (nh / max(1, crop.height)))))
    if nw > max_w:
        nw = max_w
        nh = max(1, int(round(crop.height * (nw / max(1, crop.width)))))
    scaled = crop.resize((nw, nh), Image.NEAREST)
    # strip near-white sclera leftovers in head band
    px = scaled.load()
    for y in range(min(nh, max(1, nh // 2))):
        for x in range(nw):
            r, g, b, a = px[x, y]
            if a > 200 and r > 220 and g > 220 and b > 220:
                px[x, y] = (0, 0, 0, 0)
    canvas = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    ox = (48 - nw) // 2
    oy = max(0, feet_y - nh)
    canvas.paste(scaled, (ox, oy), scaled)
    return canvas


def poll_image(mcp: MCP, job_id: str, timeout: int = 240) -> dict:
    t0 = time.time()
    last = {"text": "", "images": [], "isError": True}
    while time.time() - t0 < timeout:
        last = mcp.tool("get_image", {"job_id": job_id})
        print(f"    img[{int(time.time()-t0):3d}s] {last['text'][:110].replace(chr(10),' ')}", flush=True)
        if last["images"] or ("completed" in last["text"].lower() and not busy(last["text"])):
            return last
        if "failed" in last["text"].lower():
            return last
        time.sleep(4)
    return last


def poll_char(mcp: MCP, job_id: str, timeout: int = 900) -> dict:
    t0 = time.time()
    last = {"text": "", "images": [], "isError": True}
    while time.time() - t0 < timeout:
        last = mcp.tool("get_character", {"character_id": job_id, "include_preview": True})
        print(f"    char[{int(time.time()-t0):3d}s] {last['text'][:110].replace(chr(10),' ')}", flush=True)
        if last["isError"]:
            return last
        if not busy(last["text"]) and "completed" in last["text"].lower():
            return last
        if "failed" in last["text"].lower() and "status" in last["text"].lower():
            return last
        time.sleep(8)
    return last


def download_sheet(token: str, character_id: str, dest_sheet: Path, rot_dir: Path) -> bool:
    headers = {"Authorization": f"Bearer {token}", "User-Agent": "HunterOnline/hybrid"}
    url = f"https://api.pixellab.ai/mcp/characters/{character_id}/download"
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=120) as resp:
        data = resp.read()
    if data[:2] != b"PK":
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
            return False
        im = Image.open(io.BytesIO(z.read(match))).convert("RGBA")
        if im.size != (48, 48):
            im = fit_stylelock(im)
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
    print(f"    sheet {dest_sheet}", flush=True)
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
            "clientInfo": {"name": "hunter-npc-hybrid", "version": "1"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass
    print("[balance]", mcp.tool("get_balance", {})["text"][:260], flush=True)

    viajante = Image.open(
        OUT_CHARS / "npc_calibration_viajante_padokia_rotations" / "south.png"
    ).convert("RGBA")
    OUT_SOUTH.mkdir(parents=True, exist_ok=True)
    meta = {"batch": "main_npc_hybrid_stylelock", "created_at": time.time(), "characters": []}

    for name, desc in NPCS:
        print(f"\n=== {name} ===", flush=True)
        # 1) pixen unique
        r = None
        for attempt in range(16):
            r = mcp.tool(
                "create_image_pixen",
                {
                    "description": desc,
                    "width": 48,
                    "height": 48,
                    "no_background": True,
                    "view": "low top-down",
                    "direction": "south",
                    "outline": "single color black outline",
                    "detail": "low detail",
                },
            )
            print("   ", r["text"][:200].replace("\n", " "), flush=True)
            if "429" in r["text"] or "Maximum" in r["text"]:
                time.sleep(20)
                continue
            break
        jid = uuid_from(r["text"]) if r else None
        if not jid:
            meta["characters"].append({"name": name, "ok": False, "stage": "pixen"})
            continue
        img = poll_image(mcp, jid)
        raw_path = OUT_SOUTH / f"{name}_pixen_raw.png"
        if not save_img(img["images"], raw_path):
            m = re.search(r"https://\S+", img["text"])
            if not m:
                meta["characters"].append({"name": name, "ok": False, "stage": "pixen_save"})
                continue
            url = m.group(0).rstrip(").,")
            req = urllib.request.Request(url, headers={"User-Agent": "ho"})
            with urllib.request.urlopen(req, timeout=60) as resp:
                raw_path.write_bytes(resp.read())

        fitted = fit_stylelock(Image.open(raw_path))
        fitted_path = OUT_SOUTH / f"{name}_fitted_south.png"
        fitted.save(fitted_path)
        bb = fitted.split()[-1].getbbox()
        h = (bb[3] - bb[1]) if bb else 0
        print(f"    fitted h={h} feetY={bb[3] if bb else None}", flush=True)

        buf = io.BytesIO()
        fitted.save(buf, format="PNG")
        ref_b64 = base64.b64encode(buf.getvalue()).decode()

        # 2) v3 rotate
        cr = None
        for attempt in range(20):
            cr = mcp.tool(
                "create_character",
                {
                    "name": name + "_hybrid",
                    "description": desc + ", keep this exact character identity while rotating 8 directions",
                    "mode": "v3",
                    "size": 48,
                    "view": "low top-down",
                    "reference_image_base64": ref_b64,
                },
            )
            print("   ", cr["text"][:220].replace("\n", " "), flush=True)
            if "429" in cr["text"] or "Maximum" in cr["text"]:
                time.sleep(20)
                continue
            break
        cid = uuid_from(cr["text"]) if cr else None
        if not cid:
            meta["characters"].append({"name": name, "ok": False, "stage": "v3"})
            continue
        poll_char(mcp, cid)
        sheet = OUT_CHARS / f"{name}_8dir.png"
        rot = OUT_CHARS / f"{name}_rotations"
        ok = download_sheet(token, cid, sheet, rot)
        sim = 0.0
        if ok:
            south = Image.open(rot / "south.png").convert("RGBA")
            sim = opaque_sim(south, viajante)
            sbb = south.split()[-1].getbbox()
            sh = (sbb[3] - sbb[1]) if sbb else 0
            print(f"    result h={sh} feetY={sbb[3] if sbb else None} sim_viajante={sim:.1f}%", flush=True)
        meta["characters"].append(
            {
                "name": name,
                "id": cid,
                "ok": ok,
                "opaque_sim_viajante": sim,
                "fitted_path": str(fitted_path.relative_to(ROOT)),
                "path": str(sheet.relative_to(ROOT)),
            }
        )
        OUT_META.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(
        "[DONE]",
        json.dumps(
            {
                "chars": len(meta["characters"]),
                "ok": sum(1 for c in meta["characters"] if c.get("ok")),
                "unique": sum(
                    1 for c in meta["characters"] if c.get("ok") and c.get("opaque_sim_viajante", 100) < 40
                ),
            }
        ),
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
