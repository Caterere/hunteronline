#!/usr/bin/env python3
"""Hunter Online — Character Quality Pass (Style Lock v2 / 96px).

Pipeline:
1) create_image_pixen @ 96×96 (highly detailed, HAIR-FIRST identity)
2) fit ~46px tall, feet Y=84, max width ~40 (hair volume budget)
3) create_character mode=v3 + reference=fitted south, size=96 → 8 directions
4) assemble sheet 768×96 + archive legacy 48px sheets

Usage:
  PIXELLAB_API_TOKEN=… python3 scripts/tools/pixellab_regen_cast_v96_stylelock.py
  PIXELLAB_API_TOKEN=… python3 scripts/tools/pixellab_regen_cast_v96_stylelock.py --only npc_gon,npc_killua
"""

from __future__ import annotations

import argparse
import base64
import io
import json
import os
import re
import shutil
import sys
import time
import urllib.request
import zipfile
from pathlib import Path

from PIL import Image

MCP_URL = "https://api.pixellab.ai/mcp"
ROOT = Path("/workspace")
OUT_CHARS = ROOT / "assets" / "sprites" / "characters"
ARCHIVE = OUT_CHARS / "_archive_48px"
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "cast_v96_stylelock.json"
OUT_SOUTH = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "v96_south_refs"

FRAME = 96
# Hair-volume budget: iconic HxH silhouettes need more than the old 42×34 box
TARGET_H = 46
FEET_Y = 84
MAX_W = 40

LOCK = (
    "readable 16-bit RPG chibi sprite, about 44-46 pixels tall in a 96x96 transparent canvas, "
    "HAIR SILHOUETTE IS THE #1 IDENTITY SIGNAL — spend most pixels on distinctive anime-accurate hair shape, "
    "large head ~55% of body, BLOCK eyes 2x3/2x4 dark pixels NO white sclera, NO mouth NO nose idle, "
    "flat shading, hard 1px black outline, 2-3 colors per material, transparent background, "
    "do NOT use generic mushroom hair or round blob hair"
)

# Hair-first prompts (Hunter x Hunter 2011 silhouette fidelity)
CAST: list[tuple[str, str]] = [
    (
        "npc_gon",
        f"{LOCK}. HAIR FIRST: Gon Freecss — jet-black hair with subtle dark-green edge tint, "
        "TALL VERTICAL jagged spikes pointing mostly UPWARD like a porcupine crown (longest spikes on TOP), "
        "shorter side spikes, NOT a round radial ball, NOT a bob. Body: green sleeveless jacket, white shorts, "
        "tan skin, boy hunter. Reject smooth hair and sideways-only spikes.",
    ),
    (
        "npc_killua",
        f"{LOCK}. HAIR FIRST: Killua Zoldyck — SILVER-WHITE hair gelled sharply UPWARD and BACKWARD, "
        "tall irregular crown spikes (cat-ear silhouette), uneven bangs over forehead, volume on top, "
        "NOT short buzz spikes, NOT blue, NOT purple. Body: dark blue sleeveless turtleneck, baggy white pants.",
    ),
    (
        "npc_kurapika",
        f"{LOCK}. HAIR FIRST: Kurapika — short layered golden-blond hair, soft messy layers, longer strands "
        "framing both sides of the face, NOT spiky, NOT a black bowl cut. Body: white shirt, black formal vest, "
        "thin chain hint, serious blond youth.",
    ),
    (
        "npc_leorio",
        f"{LOCK}. HAIR FIRST: Leorio — short dark brown hair with slightly fluffy messy top volume, ordinary "
        "young-man cut, NOT gelled spikes, NOT bald. Body: teal suit jacket, white shirt, tall thin chibi legs, "
        "briefcase hint.",
    ),
    (
        "npc_hisoka",
        f"{LOCK}. HAIR FIRST: Hisoka — magenta/hot-pink hair swept BACK in long pointed needles, "
        "pure pink/magenta only — ABSOLUTELY NO yellow tips, NO gold antenna. "
        "Face: pale with blue teardrop + red star cheek marks as blocks. Body: dark suit, lean.",
    ),
    (
        "npc_netero",
        f"{LOCK}. HAIR FIRST: Isaac Netero — BALD wrinkled scalp (no hair on top), thick long WHITE beard and "
        "mustache mass under chin as the main silhouette. Body: orange prayer beads, yellow martial robe, "
        "elderly calm master.",
    ),
    (
        "npc_chrollo",
        f"{LOCK}. HAIR FIRST: Chrollo — neat black bowl cut with straight bangs across forehead, small dark "
        "cross tattoo visible on forehead below bangs, NOT spiky hair. Body: dark coat with simple white skull "
        "hand shapes, calm leader.",
    ),
    (
        "npc_recepcionista_elena",
        f"{LOCK}. HAIR FIRST: Elena — neat medium-brown hair in a tight low bun, clean office silhouette, "
        "NOT loose long hair. Body: navy vest over white shirt, dark navy skirt, tiny gold pin, female.",
    ),
    (
        "npc_instrutor_combate",
        f"{LOCK}. HAIR FIRST: Wing — messy unkempt dark hair, slightly floppy and uneven (mentor look), "
        "thin glasses. Body: dark green kimono tunic with sash, beige pants.",
    ),
    (
        "npc_examinador_oficial",
        f"{LOCK}. HAIR FIRST: Satotz — hair hidden under charcoal bowler hat (hat is the head silhouette). "
        "Body: tailored purple suit, white cravat, thin wooden cane, upright gentleman.",
    ),
    (
        "npc_tonpa",
        f"{LOCK}. HAIR FIRST: Tonpa — balding greasy dark fringe with shiny bald crown, sparse side hair. "
        "Body: green tracksuit, stocky sneaky exam veteran.",
    ),
    (
        "npc_hanzo",
        f"{LOCK}. HAIR FIRST: Hanzo — hair fully covered by navy ninja headwrap/scarf silhouette. "
        "Body: dark ninja outfit with sash, slim agile stance.",
    ),
    (
        "npc_pokkle",
        f"{LOCK}. HAIR FIRST: Pokkle — hair mostly under green hood; small brown bangs peek if visible. "
        "Body: green hooded cloak, bow on back.",
    ),
    (
        "npc_ponzu",
        f"{LOCK}. HAIR FIRST: Ponzu — pink-lilac bob haircut, rounded soft silhouette, female. "
        "Body: yellow jacket, simple bee motif.",
    ),
    (
        "npc_menchi",
        f"{LOCK}. HAIR FIRST: Menchi — long dark hair flowing down back/sides plus bright pink chef headband. "
        "Body: black outfit with pink accents, female gourmet examiner.",
    ),
    (
        "npc_buhara",
        f"{LOCK}. HAIR FIRST: Buhara — short dark buzz/crew cut on a huge head. "
        "Body: massive muscular orange-shirt gourmet examiner.",
    ),
    (
        "npc_gittarackur",
        f"{LOCK}. HAIR FIRST: Gittarackur — dark hair under green hoodie hood; pale face with forehead pins as dots. "
        "Body: green hoodie, lanky eerie chibi.",
    ),
    (
        "npc_bodoro",
        f"{LOCK}. HAIR FIRST: Bodoro — white hair with full white beard mass, elderly fighter silhouette. "
        "Body: brown training gi.",
    ),
    (
        "npc_nicol",
        f"{LOCK}. HAIR FIRST: short dark tidy hair. Body: simple traveler coat, exam candidate.",
    ),
    (
        "npc_discipulo_zushi",
        f"{LOCK}. HAIR FIRST: Zushi — short dark bowl-cut kid hair. Body: white gi with green sash, child.",
    ),
    (
        "npc_guarda_fronteira",
        f"{LOCK}. HAIR FIRST: hair hidden under grey helmet. Body: grey armor vest, spear, stocky sentry Zebro.",
    ),
    (
        "npc_ferreiro_mestre",
        f"{LOCK}. HAIR FIRST: short rugged brown hair, slightly messy. Body: leather apron, grey shirt, stocky smith.",
    ),
    (
        "npc_vendedor_mercador",
        f"{LOCK}. HAIR FIRST: hair under green cloth hat. Body: brown vest, cream shirt, pouch belt.",
    ),
    (
        "npc_viajante_scout",
        f"{LOCK}. HAIR FIRST: short windblown brown hair with green scarf. Body: brown traveler cloak, backpack.",
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


def fit_stylelock_v2(
    im: Image.Image,
    target_h: int = TARGET_H,
    feet_y: int = FEET_Y,
    max_w: int = MAX_W,
) -> Image.Image:
    im = im.convert("RGBA")
    bb = im.split()[-1].getbbox()
    if not bb:
        return Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    crop = im.crop(bb)
    nh = target_h
    nw = max(1, int(round(crop.width * (nh / max(1, crop.height)))))
    if nw > max_w:
        nw = max_w
        nh = max(1, int(round(crop.height * (nw / max(1, crop.width)))))
    scaled = crop.resize((nw, nh), Image.NEAREST)
    px = scaled.load()
    for y in range(min(nh, max(1, nh // 2))):
        for x in range(nw):
            r, g, b, a = px[x, y]
            if a > 200 and r > 220 and g > 220 and b > 220:
                px[x, y] = (0, 0, 0, 0)
    canvas = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    ox = (FRAME - nw) // 2
    oy = max(0, feet_y - nh)
    canvas.paste(scaled, (ox, oy), scaled)
    return canvas


def poll_image(mcp: MCP, job_id: str, timeout: int = 300) -> dict:
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


def poll_char(mcp: MCP, character_id: str, timeout: int = 1200) -> dict:
    t0 = time.time()
    last = {"text": "", "images": [], "isError": True}
    while time.time() - t0 < timeout:
        last = mcp.tool("get_character", {"character_id": character_id, "include_preview": True})
        print(f"    char[{int(time.time()-t0):3d}s] {last['text'][:110].replace(chr(10),' ')}", flush=True)
        if last["isError"]:
            return last
        if not busy(last["text"]) and "completed" in last["text"].lower():
            return last
        if "failed" in last["text"].lower() and "status" in last["text"].lower():
            return last
        time.sleep(8)
    return last


def archive_legacy(stem: str) -> None:
    ARCHIVE.mkdir(parents=True, exist_ok=True)
    src = OUT_CHARS / f"{stem}_8dir.png"
    if not src.exists():
        return
    try:
        im = Image.open(src)
        if im.size[1] == 48:
            dest = ARCHIVE / f"{stem}_8dir.png"
            if not dest.exists():
                shutil.copy2(src, dest)
                print(f"    archived {dest.name}", flush=True)
    except Exception as e:
        print(f"    archive skip: {e}", flush=True)


def download_sheet(token: str, character_id: str, dest_sheet: Path, rot_dir: Path) -> bool:
    headers = {"Authorization": f"Bearer {token}", "User-Agent": "HunterOnline/v96"}
    hosts = [
        f"https://api.pixellab.ai/mcp/characters/{character_id}/download",
        f"https://api.pixellab.ai/mcp/characters/{character_id}/download",
    ]
    data = b""
    for url in hosts:
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=180) as resp:
                data = resp.read()
            if data[:2] == b"PK":
                break
        except Exception as e:
            print(f"    download try fail: {e}", flush=True)
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
    frames: list[Image.Image] = []
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
            print(f"    missing rot {name}; zip has {z.namelist()[:16]}", flush=True)
            return False
        im = Image.open(io.BytesIO(z.read(match))).convert("RGBA")
        im = fit_stylelock_v2(im)
        buf = io.BytesIO()
        im.save(buf, format="PNG")
        (rot_dir / f"{name}.png").write_bytes(buf.getvalue())
        frames.append(im)
        print(f"    rot {name} {im.size}", flush=True)

    sheet = Image.new("RGBA", (FRAME * 8, FRAME), (0, 0, 0, 0))
    for i, fr in enumerate(frames):
        sheet.paste(fr, (i * FRAME, 0), fr)
    dest_sheet.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(dest_sheet)
    print(f"    sheet {dest_sheet} {sheet.size}", flush=True)
    return True


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="", help="comma-separated stems")
    ap.add_argument(
        "--reuse-fitted",
        action="store_true",
        help="Skip pixen when v96_south_refs/<name>_south_fitted.png already exists",
    )
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}

    token = (
        os.environ.get("PIXELLAB_API_TOKEN")
        or os.environ.get("PIXELLAB_API_KEY")
        or ""
    ).strip()
    if not token:
        print("Missing PIXELLAB_API_TOKEN", file=sys.stderr)
        return 1

    mcp = MCP(token)
    mcp.call(
        "initialize",
        {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "hunter-cast-v96", "version": "1"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass
    print("[balance]", mcp.tool("get_balance", {})["text"][:260], flush=True)

    OUT_SOUTH.mkdir(parents=True, exist_ok=True)
    meta = {"batch": "cast_v96_hair_pass", "created_at": time.time(), "characters": []}

    for name, desc in CAST:
        if only and name not in only:
            continue
        print(f"\n=== {name} ===", flush=True)
        archive_legacy(name)

        fit_path = OUT_SOUTH / f"{name}_south_fitted.png"
        jid = None
        if args.reuse_fitted and fit_path.exists():
            print(f"    reuse fitted {fit_path.name}", flush=True)
            fitted = Image.open(fit_path).convert("RGBA")
            bb = fitted.split()[-1].getbbox()
            h = (bb[3] - bb[1]) if bb else 0
            print(f"    fitted h={h} feetY={bb[3] if bb else None}", flush=True)
        else:
            r = None
            for _attempt in range(12):
                r = mcp.tool(
                    "create_image_pixen",
                    {
                        "description": desc,
                        "width": FRAME,
                        "height": FRAME,
                        "no_background": True,
                        "view": "low top-down",
                        "direction": "south",
                        "outline": "single color black outline",
                        "detail": "highly detailed",
                    },
                )
                print("   ", r["text"][:220].replace("\n", " "), flush=True)
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
                    meta["characters"].append({"name": name, "ok": False, "stage": "pixen_save", "job": jid})
                    continue
                url = m.group(0).rstrip(").,")
                req = urllib.request.Request(url, headers={"User-Agent": "ho"})
                with urllib.request.urlopen(req, timeout=60) as resp:
                    raw_path.write_bytes(resp.read())

            fitted = fit_stylelock_v2(Image.open(raw_path))
            fitted.save(fit_path)
            bb = fitted.split()[-1].getbbox()
            h = (bb[3] - bb[1]) if bb else 0
            print(f"    fitted h={h} feetY={bb[3] if bb else None}", flush=True)

        buf = io.BytesIO()
        fitted.save(buf, format="PNG")
        ref_b64 = base64.b64encode(buf.getvalue()).decode()

        cr = None
        for _attempt in range(12):
            cr = mcp.tool(
                "create_character",
                {
                    "name": name + "_v96_hair",
                    "description": desc + ", preserve the EXACT hair silhouette while rotating 8 directions",
                    "mode": "v3",
                    "size": FRAME,
                    "view": "low top-down",
                    "outline": "single color black outline",
                    "detail": "high detail",
                    "reference_image_base64": ref_b64,
                },
            )
            print("   ", cr["text"][:220].replace("\n", " "), flush=True)
            if "429" in cr["text"] or "Maximum" in cr["text"]:
                time.sleep(25)
                continue
            break
        cid = uuid_from(cr["text"]) if cr else None
        if not cid:
            meta["characters"].append({"name": name, "ok": False, "stage": "create_character"})
            continue

        done = poll_char(mcp, cid)
        if "failed" in done["text"].lower() and "completed" not in done["text"].lower():
            meta["characters"].append({"name": name, "ok": False, "stage": "character_failed", "id": cid})
            continue

        sheet = OUT_CHARS / f"{name}_8dir.png"
        rot_dir = OUT_CHARS / f"{name}_rotations"
        ok = False
        for _attempt in range(8):
            try:
                ok = download_sheet(token, cid, sheet, rot_dir)
                if ok:
                    break
            except Exception as e:
                print(f"    download err: {e}", flush=True)
            time.sleep(8)

        meta["characters"].append(
            {
                "name": name,
                "ok": ok,
                "character_id": cid,
                "pixen_job": jid,
                "fitted_h": h,
                "sheet": str(sheet.relative_to(ROOT)) if ok else None,
            }
        )
        OUT_META.parent.mkdir(parents=True, exist_ok=True)
        OUT_META.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    ok_n = sum(1 for c in meta["characters"] if c.get("ok"))
    print(f"\n[done] {ok_n}/{len(meta['characters'])} ok → {OUT_META}", flush=True)
    return 0 if meta["characters"] and ok_n == len(meta["characters"]) else 1


if __name__ == "__main__":
    raise SystemExit(main())
