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

## Ainda pendente (play / polish)

### P0 — Validar jogando
1. [x] Smoke Estrada escolta + emboscada + zona — `scratch/test_p0_play_smoke_suite.tscn`
2. [x] Smoke Grande Ponte +rep — mesma suíte (+80 Associação)
3. [x] Smoke Padokia Gyo furto — wiring `[E]` em `GyoInspectable` + factory
4. [x] Smoke UI pergaminho — `HunterUIStyle` + `HunterMissionContractUI`

### P2 residual
5. Zetsu ambush playtest (Floresta + ravina)
6. Arena Celestial densidade (P3)

---

## Critério do dia

- [x] Sprites novos aprovados no Style Lock
- [x] Escolta noturna validada (zona + fail 8s) via smoke headless
- [x] Disputa da ponte dá +rep (ID evento alinhado + smoke)

### Fixes desta sessão (2026-09-09 noite)
- `GyoInspectable`: input `[E]`/`interact` quando jogador perto + Gyo ativo
- `EstradaPadokiaMap`: ID `evento_disputa_ponte_estrada_padokia` alinhado com `WorldEventManager`
- Suíte P0: **20/20** headless

*Atualizado na sessão 2026-09-09.*
