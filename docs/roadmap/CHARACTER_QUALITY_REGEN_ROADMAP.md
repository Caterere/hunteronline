# CHARACTER QUALITY REGEN — Hunter Online

> **Update 2026-09:** cast nomeado regenera a partir de
> `assets/reference/cast_quality_pack/south_refs/` (fidelidade às refs do diretor)
> via `scripts/tools/pixellab_regen_cast_from_quality_refs.py` (idle/walk/hit).
> Corpo ~64px no frame 96×96.
>
> **Audit overnight (chibi):** o plano original continua **chibi ~2.5 cabeças**.
> Cast priority (Gon/Killua/Kurapika/Leorio/Hisoka/Biscuit/Chrollo/Netero) já está
> em **96×96**. O **player** (`assets/sprites/characters/player.png` = 288×480 →
> frames **48×48**) ainda é **legado** — regenerar no Style Lock v2 é **P0 de arte**.
> Não escalar 2× em runtime: quebra `AnimationPlayer` (position tracks).
> Bloqueio atual: sem `PIXELLAB_API_KEY` no ambiente Cloud.


> **Objetivo:** regenerar **todos** os personagens com Style Lock v2 (frame **96×96**,
> corpo **~40–44 px** / Quality Pack ~60–68 px, chibi uniforme) via PixelLab MCP.
> **SSOT de métricas:** [`../bibles/PIXEL_ART_STYLE_BIBLE.md`](../bibles/PIXEL_ART_STYLE_BIBLE.md)
> **Script:** `scripts/tools/pixellab_regen_cast_v96_stylelock.py`

---

## Regras de produção

1. **Cast principal primeiro**, depois saga a saga (não misturar batches).
2. Manter **mesmo tamanho chibi** entre todos (só silhueta/outfit muda).
3. Backup do legado 48px em `assets/sprites/characters/_archive_48px/` antes de sobrescrever.
4. Registrar IDs PixelLab em [`../systems/ASSET_REGISTRY.md`](../systems/ASSET_REGISTRY.md).
5. Validar com `tools/validate_sprite_style.gd` após cada batch.
6. Mundo/tiles **não** entram neste roteiro (só characters/NPCs/enemies humanoides).

---

## Status por saga

| Saga | Foco | Status |
| :--- | :--- | :--- |
| **S0** | Âncora + hub (Elena, Wing, Satotz; **player sheet ainda 48px**) | `PARTIAL` (hub NPCs OK; **player P0**) |
| **S1** | Main four (Gon, Killua, Kurapika, Leorio) + Hisoka + Netero + Chrollo | `DONE` |
| **S2** | Hunter Exam secundários (Tonpa, Hanzo, Pokkle, Ponzu, Menchi, Buhara, Illumi, Bodorro, Nicol…) | `PENDING` |
| **S3** | Zoldyck (Canary, Gotoh, Silva, mordomos ambient) | `PENDING` |
| **S4** | Heaven’s Arena (Zushi, lutadores ambient) | `PENDING` |
| **S5** | Yorknew (Chrollo, Melody, Battera, Tsezguerra, mafiosos) | `PENDING` |
| **S6** | Greed Island (Biscuit, Razor, bombers) | `PENDING` |
| **S7** | Chimera Ant / endgame (Netero, Meruem, formigas, guarda real) | `PENDING` |
| **S8** | Generics / calibration leftovers | `PENDING` |

---

## S0 — Âncora + Hub

| Asset | Personagem | Prioridade |
| :--- | :--- | :--- |
| `player.png` / `player_8dir` | Hunter jogador (style anchor) | P0 |
| `npc_recepcionista_elena_8dir.png` | Elena | P0 |
| `npc_instrutor_combate_8dir.png` | Wing | P0 |
| `npc_examinador_oficial_8dir.png` | Satotz | P0 |

## S1 — Principais da trama

| Asset | Personagem | Prioridade |
| :--- | :--- | :--- |
| `npc_gon_8dir.png` | Gon | P0 |
| `npc_killua_8dir.png` | Killua | P0 |
| `npc_kurapika_8dir.png` | Kurapika | P0 |
| `npc_leorio_8dir.png` | Leorio | P0 |
| `npc_hisoka_8dir.png` | Hisoka | P0 |

## S2+ — ver tabela de status (expandir conforme batch)

Inimigos nomeados (`enemy_*_8dir.png`) seguem a **mesma métrica 96×96** quando a saga correspondente for regenerada.

---

## Pipeline por personagem

```text
create_image_pixen (96×96, medium detail, unique identity)
        ↓
fit_stylelock_v2 (~42px tall, feet Y=84, max width ~34)
        ↓
create_character mode=v3 + reference=fitted south, size=96
        ↓
download 8 rotations → sheet 768×96
        ↓
validate_sprite_style.gd → ASSET_REGISTRY
```

---

## Critério de “pronto” por batch

- [ ] Todos os assets do batch em 768×96 (ou player sheet equivalente)
- [ ] Silhueta reconhecível em 1× no editor
- [ ] Validator 100% no batch
- [ ] Bind no jogo sem offset quebrado (pés / Y-sort)
- [ ] Registry atualizado com PixelLab IDs
