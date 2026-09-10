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
5. [x] Zetsu ambush playtest (Floresta + ravina) — `scratch/test_zetsu_arena_density_suite.tscn`
6. [x] Arena Celestial densidade (P3) — fillers, placas, Wing alinhado, tower UI

---

## Critério do dia

- [x] Sprites novos aprovados no Style Lock
- [x] Escolta noturna validada (zona + fail 8s) via smoke headless
- [x] Disputa da ponte dá +rep (ID evento alinhado + smoke)

### Fixes desta sessão (2026-09-09 noite)
- `GyoInspectable`: input `[E]`/`interact` quando jogador perto + Gyo ativo
- `EstradaPadokiaMap`: ID `evento_disputa_ponte_estrada_padokia` alinhado com `WorldEventManager`
- Suíte P0: **20/20** headless

### Fixes P2 (2026-09-09 noite)
- `ZetsuSensorZone`: marcador visual, enemy_id temático, detecção via `esta_em_zetsu()`
- `NenSensorFactory.criar_zetsu`: enemy_id/name + marcador
- Floresta/Ravina: IDs temáticos (lobo_sombras / candidato_exame)
- `ActiveNenController` + `NenSystem`: Zetsu instintivo pré-despertar
- `ArenaCelestialMap`: densificar corredor, placas, Wing→dojo, tower UI/trigger, marcos
- Suíte P2: **27/27** headless

*Atualizado na sessão 2026-09-09.*
