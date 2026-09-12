#!/usr/bin/env python3
"""Hunter Online — Quality Pack cast regen (reference-faithful).

1) Fit south_ref PNG into 96x96 (~64px tall, feet Y=84)
2) create_character mode=v3 + reference_image_base64
3) animate_character: breathing-idle, walk, taking-punch
4) Export npc_*_8dir.png + idle/walk/hit sheets

Usage:
  python3 scripts/tools/pixellab_regen_cast_from_quality_refs.py --only gon,killua,netero,chrollo
  python3 scripts/tools/pixellab_regen_cast_from_quality_refs.py --skip-anim
  python3 scripts/tools/pixellab_regen_cast_from_quality_refs.py --reuse-meta
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
SOUTH_REFS = ROOT / "assets" / "reference" / "cast_quality_pack" / "south_refs"
OUT_CHARS = ROOT / "assets" / "sprites" / "characters"
ARCHIVE = OUT_CHARS / "_archive_96px_pre_quality_pack"
OUT_FITTED = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "quality_pack_fitted"
OUT_META = ROOT / "assets" / "sprites" / "tilesets" / "pixellab" / "cast_quality_pack_regen.json"

FRAME = 96
TARGET_H = 64
FEET_Y = 84
MAX_W = 52

# (ref_stem, asset_stem, identity hint)
CAST: list[tuple[str, str, str]] = [
    ("gon", "npc_gon", "Gon Freecss green jacket tall black spikes green tips"),
    ("killua", "npc_killua", "Killua Zoldyck silver upward spikes dark turtleneck"),
    ("kurapika", "npc_kurapika", "Kurapika blond bob scarlet eyes blue tabard"),
    ("leorio", "npc_leorio", "Leorio short black hair blue suit round sunglasses"),
    ("hisoka", "npc_hisoka", "Hisoka magenta swept hair face paint jester suit"),
    ("biscuit", "npc_biscuit", "Biscuit blonde pigtails pink ribbons red dress"),
    ("chrollo", "npc_chrollo", "Chrollo slick black hair purple forehead cross white fur collar coat"),
    ("pakunoda", "npc_pakunoda", "Pakunoda blonde bob purple suit"),
    ("feitan", "npc_feitan", "Feitan messy black hair dark skull collar cloak"),
    ("shizuku", "npc_shizuku", "Shizuku short black hair glasses black turtleneck"),
    ("shalnark", "npc_shalnark", "Shalnark sandy blond messy hair teal vest"),
    ("machi", "npc_machi", "Machi pink bun blue ribbon purple sleeveless top"),
    ("meruem", "npc_meruem", "Meruem green skin purple armor segmented tail"),
    ("pitou", "npc_pitou", "Neferpitou white cat-ear hair dark blue coat striped stockings"),
    ("pouf", "npc_pouf", "Shaiapouf blond antenna strands ruffled white collar"),
    ("youpi", "npc_youpi", "Youpi dark red muscular skin shirtless"),
    ("komugi", "npc_komugi", "Komugi white hair buns thick brows pink dress cane"),
    ("kite", "npc_kite", "Kite long white hair oversized blue beret"),
    ("palm", "npc_palm", "Palm long black hair covering face purple top"),
    ("kalluto", "npc_kalluto", "Kalluto black bob purple floral kimono"),
    ("alluka", "npc_alluka", "Alluka long black hair emotion headband red white miko"),
    ("wing", "npc_wing", "Wing messy black hair pink untucked shirt khaki pants"),
    ("canary", "npc_canary", "Canary dark skin puff braids black butler suit"),
    ("gotoh", "npc_gotoh", "Gotoh slick black hair glasses butler bowtie"),
    ("netero", "npc_netero", "Netero white topknot bushy brows mustache heart training shirt"),
    ("illumi", "npc_illumi", "Illumi knee-length black hair green needle vest"),
    ("knuckle", "npc_knuckle", "Knuckle massive black pompadour white gakuran"),
    ("morel", "npc_morel", "Morel white parted hair round shades giant pipe"),
    ("nobunaga", "npc_nobunaga", "Nobunaga chonmage topknot haori hakama katana"),
    ("phinks", "npc_phinks", "Phinks spiky blond hair teal tracksuit"),
    ("uvogin", "npc_uvogin", "Uvogin wild silver mane muscular loincloth"),
]

DIR_ORDER = [
    "south",
    "south-east",
    "east",
    "north-east",
    "north",
    "north-west",
    "west",
    "south-west",
]

ANIMATIONS: list[tuple[str, str, list[str]]] = [
    ("breathing-idle", "idle_8xN", ["breathing-idle", "breathing_idle", "idle"]),
    ("walk", "walk_8xN", ["walk", "walking"]),
    ("taking-punch", "hit_8xN", ["taking-punch", "taking_punch", "punch", "hit"]),
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
        images: list = []
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


def is_busy(text: str) -> bool:
    low = text.lower()
    return any(
        x in low
        for x in ("processing", "pending", "queued", "in progress", "generating", "creating")
    )


def fit_quality_pack(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    bb = im.split()[-1].getbbox()
    if not bb:
        return Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    crop = im.crop(bb)
    nh = TARGET_H
    nw = max(1, int(round(crop.width * (nh / max(1, crop.height)))))
    if nw > MAX_W:
        nw = MAX_W
        nh = max(1, int(round(crop.height * (nw / max(1, crop.width)))))
    if crop.height <= TARGET_H and crop.width <= MAX_W:
        int_scale = min(TARGET_H // max(1, crop.height), MAX_W // max(1, crop.width))
        int_scale = max(1, int_scale)
        if int_scale > 1:
            scaled = crop.resize(
                (crop.width * int_scale, crop.height * int_scale), Image.NEAREST
            )
        elif (crop.width, crop.height) != (nw, nh):
            scaled = crop.resize((nw, nh), Image.NEAREST)
        else:
            scaled = crop
        if scaled.height < TARGET_H - 6:
            scaled = crop.resize((nw, nh), Image.NEAREST)
    else:
        scaled = crop.resize((nw, nh), Image.NEAREST)
    nw, nh = scaled.size
    canvas = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    ox = (FRAME - nw) // 2
    oy = max(0, FEET_Y - nh)
    canvas.paste(scaled, (ox, oy), scaled)
    return canvas


def poll_char(mcp: MCP, character_id: str, timeout: int = 1200) -> dict:
    t0 = time.time()
    last = {"text": "", "images": [], "isError": True}
    while time.time() - t0 < timeout:
        last = mcp.tool(
            "get_character", {"character_id": character_id, "include_preview": True}
        )
        print(
            f"    char[{int(time.time()-t0):3d}s] {last['text'][:120].replace(chr(10), ' ')}",
            flush=True,
        )
        if last["isError"]:
            return last
        low = last["text"].lower()
        if not is_busy(last["text"]) and "completed" in low:
            return last
        if "failed" in low and "status" in low:
            return last
        time.sleep(8)
    return last


def zip_has_anim_keys(zdata: bytes, keys: list[str]) -> bool:
    try:
        z = zipfile.ZipFile(io.BytesIO(zdata))
    except Exception:
        return False
    names = [n.lower() for n in z.namelist()]
    return any(any(k in n for k in keys) for n in names)


def wait_for_animation(
    mcp: MCP,
    token: str,
    character_id: str,
    keys: list[str],
    timeout: int = 900,
) -> bytes | None:
    """Poll until zip contains animation frames matching keys (slot-safe)."""
    t0 = time.time()
    while time.time() - t0 < timeout:
        st = mcp.tool(
            "get_character", {"character_id": character_id, "include_preview": False}
        )
        print(
            f"    anim[{int(time.time()-t0):3d}s] {st['text'][:140].replace(chr(10), ' ')}",
            flush=True,
        )
        zdata = download_zip(token, character_id)
        if zdata and zip_has_anim_keys(zdata, keys):
            # Prefer also not busy, but frames in zip are the source of truth
            if not is_busy(st["text"]) or (time.time() - t0) > 45:
                return zdata
        time.sleep(12)
    return download_zip(token, character_id)


def queue_animation(mcp: MCP, character_id: str, template: str) -> bool:
    """Submit one template animation; retry while job slots are full."""
    for attempt in range(40):
        ar = mcp.tool(
            "animate_character",
            {
                "character_id": character_id,
                "template_animation_id": template,
                "animation_name": template,
            },
        )
        text = ar["text"]
        print(
            f"    animate {template} try{attempt+1}: {text[:220].replace(chr(10), ' ')}",
            flush=True,
        )
        low = text.lower()
        if "need 8 job slots" in low or "only 0 available" in low or "8/8 used" in low:
            time.sleep(20)
            continue
        if ar.get("isError") and "error" in low:
            time.sleep(15)
            continue
        if "error" in low and "character" not in low[:30]:
            # soft: still may have queued
            if "animation" in low or "directions" in low or "group" in low:
                return True
            time.sleep(15)
            continue
        return True
    return False


def archive_existing(stem: str) -> None:
    ARCHIVE.mkdir(parents=True, exist_ok=True)
    for name in (
        f"{stem}_8dir.png",
        f"{stem}.png",
        f"{stem}_idle_8xN.png",
        f"{stem}_walk_8xN.png",
        f"{stem}_hit_8xN.png",
    ):
        src = OUT_CHARS / name
        if src.exists():
            dest = ARCHIVE / name
            if not dest.exists():
                shutil.copy2(src, dest)
                print(f"    archived {name}", flush=True)


def download_zip(token: str, character_id: str) -> bytes | None:
    headers = {
        "Authorization": f"Bearer {token}",
        "User-Agent": "HunterOnline/quality-pack",
    }
    url = f"https://api.pixellab.ai/mcp/characters/{character_id}/download"
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=180) as resp:
            data = resp.read()
        if data[:2] == b"PK":
            return data
        print(f"    download not zip ({len(data)} bytes)", flush=True)
    except Exception as e:
        print(f"    download fail: {e}", flush=True)
    return None


def _is_base_rotation(path: str) -> bool:
    low = path.lower()
    banned = ("animation", "walk", "idle", "punch", "hit", "breathing", "frame")
    return not any(b in low for b in banned)


def export_rotations(zdata: bytes, stem: str) -> bool:
    z = zipfile.ZipFile(io.BytesIO(zdata))
    rot_dir = OUT_CHARS / f"{stem}_rotations"
    rot_dir.mkdir(parents=True, exist_ok=True)
    frames: list[Image.Image] = []
    for direction in DIR_ORDER:
        candidates = [
            n
            for n in z.namelist()
            if n.lower().endswith(f"{direction}.png") and _is_base_rotation(n)
        ]
        if not candidates:
            candidates = [
                n for n in z.namelist() if n.lower().endswith(f"{direction}.png")
            ]
        if not candidates:
            print(f"    missing rot {direction}; sample={z.namelist()[:24]}", flush=True)
            return False
        match = sorted(candidates, key=len)[0]
        im = Image.open(io.BytesIO(z.read(match))).convert("RGBA")
        if im.size != (FRAME, FRAME):
            im = fit_quality_pack(im)
        im.save(rot_dir / f"{direction}.png")
        frames.append(im)
        print(f"    rot {direction} <- {match}", flush=True)
    sheet = Image.new("RGBA", (FRAME * 8, FRAME), (0, 0, 0, 0))
    for i, fr in enumerate(frames):
        sheet.paste(fr, (i * FRAME, 0), fr)
    sheet.save(OUT_CHARS / f"{stem}_8dir.png")
    frames[0].save(OUT_CHARS / f"{stem}.png")
    print(f"    sheet {stem}_8dir.png {sheet.size}", flush=True)
    return True


def export_animation(zdata: bytes, stem: str, keys: list[str], out_suffix: str) -> bool:
    z = zipfile.ZipFile(io.BytesIO(zdata))
    dir_frames: dict[str, list[tuple[int, str]]] = {d: [] for d in DIR_ORDER}
    for n in z.namelist():
        low = n.lower()
        if not low.endswith(".png"):
            continue
        if not any(k in low for k in keys):
            continue
        for d in DIR_ORDER:
            if (
                f"/{d}/" in low
                or low.endswith(f"/{d}.png")
                or f"_{d}_" in low
                or f"-{d}-" in low
            ):
                m = re.search(r"(?:frame[_-]?|_)(\d+)\.png$", low)
                idx = int(m.group(1)) if m else len(dir_frames[d])
                dir_frames[d].append((idx, n))
                break
    if not any(dir_frames.values()):
        print(f"    anim {out_suffix}: no frames for keys={keys}", flush=True)
        return False
    for d in DIR_ORDER:
        dir_frames[d].sort(key=lambda t: t[0])
    nframes = max((len(dir_frames[d]) for d in DIR_ORDER), default=0)
    if nframes == 0:
        return False
    sheet = Image.new("RGBA", (FRAME * 8, FRAME * nframes), (0, 0, 0, 0))
    counts = {}
    for di, d in enumerate(DIR_ORDER):
        frames = dir_frames[d]
        counts[d] = len(frames)
        if not frames:
            continue
        for fi in range(nframes):
            _idx, path = frames[min(fi, len(frames) - 1)]
            im = Image.open(io.BytesIO(z.read(path))).convert("RGBA")
            if im.size != (FRAME, FRAME):
                im = fit_quality_pack(im)
            sheet.paste(im, (di * FRAME, fi * FRAME), im)
    dest = OUT_CHARS / f"{stem}_{out_suffix}.png"
    sheet.save(dest)
    print(
        f"    anim {dest.name} {sheet.size} frames={nframes} counts={counts}",
        flush=True,
    )
    return True


def save_meta(meta: dict) -> None:
    OUT_META.parent.mkdir(parents=True, exist_ok=True)
    OUT_META.write_text(json.dumps(meta, indent=2), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="", help="comma-separated ref ids")
    ap.add_argument("--skip-anim", action="store_true")
    ap.add_argument("--reuse-meta", action="store_true")
    ap.add_argument(
        "--anims-only",
        action="store_true",
        help="Reuse character_id from meta; only (re)run animations",
    )
    ap.add_argument("--fit-only", action="store_true")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    if args.anims_only:
        args.reuse_meta = True

    disk_refs = {
        p.name.replace("_south_ref.png", ""): p
        for p in SOUTH_REFS.glob("*_south_ref.png")
    }
    print("[refs]", sorted(disk_refs.keys()), flush=True)

    OUT_FITTED.mkdir(parents=True, exist_ok=True)
    meta: dict = {
        "batch": "cast_quality_pack",
        "created_at": time.time(),
        "characters": [],
    }
    if args.reuse_meta and OUT_META.exists():
        try:
            meta = json.loads(OUT_META.read_text(encoding="utf-8"))
        except Exception:
            pass
    existing = {
        c.get("ref"): c for c in meta.get("characters", []) if isinstance(c, dict)
    }

    fitted_map: dict[str, Path] = {}
    for ref_id, stem, _desc in CAST:
        if only and ref_id not in only and stem not in only:
            continue
        rp = disk_refs.get(ref_id)
        if rp is None:
            print(f"[skip] missing south_ref for {ref_id}", flush=True)
            continue
        fitted = fit_quality_pack(Image.open(rp))
        fp = OUT_FITTED / f"{stem}_south_fitted.png"
        fitted.save(fp)
        bb = fitted.split()[-1].getbbox()
        h = (bb[3] - bb[1]) if bb else 0
        print(
            f"[fit] {ref_id} <- {rp.name} h={h} feetY={bb[3] if bb else None}",
            flush=True,
        )
        fitted_map[ref_id] = fp

    if args.fit_only:
        return 0

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
            "clientInfo": {"name": "hunter-quality-pack", "version": "1"},
        },
    )
    try:
        mcp.call("notifications/initialized", {})
    except Exception:
        pass
    bal = mcp.tool("get_balance", {})
    print("[balance]", bal["text"][:300], flush=True)

    for ref_id, stem, desc in CAST:
        if ref_id not in fitted_map:
            continue
        print(f"\n=== {ref_id} -> {stem} ===", flush=True)
        if not args.anims_only:
            archive_existing(stem)

        cid = None
        if args.reuse_meta and ref_id in existing and existing[ref_id].get("character_id"):
            cid = existing[ref_id]["character_id"]
            print(f"    reuse character_id={cid}", flush=True)
        elif args.anims_only:
            print(f"    [skip] anims-only but no character_id in meta for {ref_id}", flush=True)
            continue
        else:
            fitted = Image.open(fitted_map[ref_id]).convert("RGBA")
            buf = io.BytesIO()
            fitted.save(buf, format="PNG")
            ref_b64 = base64.b64encode(buf.getvalue()).decode()
            prompt = (
                f"Preserve EXACT pixel identity from the reference south sprite. {desc}. "
                "Rotate faithfully into 8 directions for a 2D RPG. Keep hair silhouette, "
                "outfit colors, proportions and outline identical to the reference. "
                "Transparent background, 96x96."
            )
            cr = None
            for _attempt in range(12):
                cr = mcp.tool(
                    "create_character",
                    {
                        "name": stem + "_quality_pack",
                        "description": prompt,
                        "mode": "v3",
                        "size": FRAME,
                        "view": "low top-down",
                        "outline": "single color black outline",
                        "detail": "high detail",
                        "reference_image_base64": ref_b64,
                    },
                )
                print("   ", cr["text"][:240].replace("\n", " "), flush=True)
                if "429" in cr["text"] or "Maximum" in cr["text"]:
                    time.sleep(25)
                    continue
                break
            cid = uuid_from(cr["text"]) if cr else None
            if not cid:
                meta["characters"] = [
                    c for c in meta["characters"] if c.get("ref") != ref_id
                ]
                meta["characters"].append(
                    {"ref": ref_id, "stem": stem, "ok": False, "stage": "create"}
                )
                save_meta(meta)
                continue
            done = poll_char(mcp, cid)
            if "failed" in done["text"].lower() and "completed" not in done["text"].lower():
                meta["characters"] = [
                    c for c in meta["characters"] if c.get("ref") != ref_id
                ]
                meta["characters"].append(
                    {
                        "ref": ref_id,
                        "stem": stem,
                        "ok": False,
                        "stage": "char_failed",
                        "character_id": cid,
                    }
                )
                save_meta(meta)
                continue

        ok_sheet = False
        if args.anims_only and (OUT_CHARS / f"{stem}_8dir.png").exists():
            ok_sheet = True
            print(f"    keep existing {stem}_8dir.png", flush=True)
        else:
            for _attempt in range(8):
                zdata = download_zip(token, cid)
                if zdata and export_rotations(zdata, stem):
                    ok_sheet = True
                    break
                time.sleep(8)

        anim_ok: dict[str, bool] = {}
        prev_anims = (existing.get(ref_id) or {}).get("anims") or {}
        if not args.skip_anim and ok_sheet:
            # One animation at a time (PixelLab has 8 concurrent job slots =
            # exactly one 8-dir template). Wait for zip frames before next.
            for template, suffix, keys in ANIMATIONS:
                if args.anims_only and prev_anims.get(suffix):
                    print(f"    skip {template} (already ok in meta)", flush=True)
                    anim_ok[suffix] = True
                    continue
                ok_submit = queue_animation(mcp, cid, template)
                if not ok_submit:
                    print(f"    animate {template}: give up after retries", flush=True)
                    anim_ok[suffix] = False
                    continue
                zdata = wait_for_animation(mcp, token, cid, keys, timeout=900)
                if zdata:
                    anim_ok[suffix] = export_animation(zdata, stem, keys, suffix)
                else:
                    anim_ok[suffix] = False
                time.sleep(5)

        entry = {
            "ref": ref_id,
            "stem": stem,
            "ok": ok_sheet,
            "character_id": cid,
            "fitted": str(fitted_map[ref_id].relative_to(ROOT)),
            "anims": anim_ok,
        }
        meta["characters"] = [c for c in meta["characters"] if c.get("ref") != ref_id]
        meta["characters"].append(entry)
        save_meta(meta)

    selected = [
        c
        for c in meta["characters"]
        if not only or c.get("ref") in only or c.get("stem") in only
    ]
    ok_n = sum(1 for c in selected if c.get("ok"))
    print(f"\n[done] {ok_n}/{len(selected)} ok -> {OUT_META}", flush=True)
    return 0 if selected and ok_n == len(selected) else 1


if __name__ == "__main__":
    raise SystemExit(main())
