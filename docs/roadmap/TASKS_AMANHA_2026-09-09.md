# HUNTER ONLINE — TASKS PARA AMANHÃ
**Data:** 2026-09-09  
**Base:** roadmap `docs/roadmap/NEXT_PRODUCTION_ROADMAP.md` + sessão 2026-09-08/09

---

## Concluído hoje (2026-09-09)

- [x] Style Lock 44/44 (Melody/Battera/Tsezguerra/Sentinela + Canary/Gotoh/Silva)
- [x] Canary / Gotoh / Silva integrados (`*_8dir.png` + binder já apontava)
- [x] Escolta: zona `ZonaProtecaoEscolta` + fail se afastar 8s / sair mapa à noite
- [x] Baús clareira Floresta (3× poção/elixir aura)
- [x] ContentDirector liga `poi_ponte_rio` → `iniciar_evento_disputa_ponte`

---

## Validado por smoke tests headless (Godot 4.6 `--headless`)

Runners em `scratch/` (rodar: `godot --headless --path . res://scratch/<runner>.tscn`).

### P0 — Validar jogando
1. [x] Smoke Estrada escolta + emboscada + zona — `test_escolta_noturna_smoke` (17/17)
2. [x] Smoke Grande Ponte +rep — `test_disputa_ponte_smoke` (10/10)
3. [x] Smoke Padokia Gyo furto — `test_furto_gyo_smoke` (20/20)
4. [x] Smoke UI pergaminho — `test_pergaminho_ui_smoke` (15/15)

### P2 residual
5. [x] Zetsu ambush (Floresta + ravina) — `test_zetsu_ambush_smoke` (13/13)
6. [x] Arena Celestial densidade — `test_arena_densidade_smoke` (10/10)

> Estes smokes validam a **lógica** ponta a ponta (eventos, progressão de
> quest, reputação, spawns). O playtest **visual** no Godot local continua
> recomendado para conferir apresentação/UX.

### Bugs corrigidos durante a validação
- `EstradaPadokiaMap`: contagem dupla de kills na escolta (objetivo "derrote 2"
  concluía com 1 morte) — sinal `died` ligado 2× a `register_enemy_kill`.
- `EnemySystem`: faltava `em_knockdown` (lido por `EnemyAI._update_state`).
- `EnemyAI`: acessava `enemy_sys.battle_personality` / `disparar_intro()`
  inexistentes (personalidade vive em `EnemyData`).
- `QuestJournalUI` (pergaminho): nunca era instanciado; botão 📜 do HUD e menu
  de pausa não abriam. Adicionado `QuestJournalUI.obter_ou_criar()`.

---

## Critério do dia

- [x] Sprites novos aprovados no Style Lock
- [x] Escolta noturna jogável ponta a ponta (lógica validada via smoke; falta play visual)
- [x] Disputa da ponte dá +rep (validado: +80 Associação Hunter, +100 Civis)

*Atualizado na sessão 2026-09-09 (validação headless + correções).*
