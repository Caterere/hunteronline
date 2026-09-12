# Cast Quality Pack — visual SSOT

Artist reference PNGs. **Fidelity to these assets** beats text prompts.
Pipeline: `scripts/tools/pixellab_regen_cast_from_quality_refs.py`.

## Grid 24 (`grid_24_cast.png`)

Order L→R, top→bottom:

| # | id | # | id |
|---|---|---|---|
| 1 | gon | 13 | meruem |
| 2 | killua | 14 | pitou |
| 3 | kurapika | 15 | pouf |
| 4 | leorio | 16 | youpi |
| 5 | hisoka | 17 | komugi |
| 6 | biscuit | 18 | kite |
| 7 | chrollo_suit (grid only) | 19 | palm |
| 8 | pakunoda | 20 | kalluto |
| 9 | feitan | 21 | alluka |
| 10 | shizuku | 22 | wing |
| 11 | shalnark | 23 | canary |
| 12 | machi | 24 | gotoh |

## High-fidelity overrides

| File | Role |
|---|---|
| `netero_heart_uniform_ref.jpg` | Canonical Netero (heart uniform) → `south_refs/netero_south_ref.png` |
| `chrollo_troupe_coat_ref.png` | Canonical Chrollo (troupe coat) → `south_refs/chrollo_south_ref.png` |
| `illumi_ref.png`, `knuckle_ref.png`, `morel_ref.png`, `nobunaga_ref.png`, `phinks_ref.png`, `uvogin_ref.png` | Standalone refs (filename = character) |
| `netero_combat_ref.png` | Netero combat pose (future skills) |
| `silva_sheet_ref.jpg` | Silva sheet (future animations) |

South slices: `south_refs/<id>_south_ref.png`.

## Pipeline targets

- Canvas: **96×96**, body ~**64 px**, feet **Y≈84**
- Outputs: `npc_<id>_8dir.png`, `npc_<id>_idle_8xN.png`, `npc_<id>_walk_8xN.png`, `npc_<id>_hit_8xN.png`
- Anims MVP: **breathing-idle**, **walk**, **taking-punch** (8 dirs)
- Skills/Hatsu animations: later
