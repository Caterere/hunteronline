# MASTER REBUILD PLAN — HUNTER MMORPG
## CONCRETE & VERIFIABLE ARCHITECTURAL REBUILD ROADMAP

**Lead Game Architect & Technical Director**  
Consulte o detalhamento completo em `docs/MASTER_REBUILD_PLAN.md`.

### Resumo Executivo das Prioridades:
* **P0-01 (Arena Celestial):** Spawns de `LutadorArena1..4` e gatilho de investigação `teste_agua_wing`.
* **P0-02 (Tutorial Elena):** Tratamento total de todas as etapas no `match` e proteção contra deadlock de `_interacao_em_processamento`.
* **P0-03 (Spawn & Respawn):** `WorldSpawner` com timer para monstros de mapa livre e `MissionInstance` para missões.
* **P0-04 (Biscuit Krueger):** Desbloqueio contextual do diálogo de treino no Arco 5 (Greed Island).
* **P1-05 (StoryManager):** Fonte única de verdade para Sagas, Capítulos, Missões e Gates.
* **P1-06 (MissionInstance):** Isolamento de ciclo de vida de entidades e estado de missão.
* **P1-07 (SaveManager):** Versionamento formal (`save_version = 1`) e remoção do proxy `GameState.gd`.
* **P1-08 (Clean Up):** Deletar criador legado `CharacterCreationUI` e unificar em `CharacterSelectionUI`.
* **P2-09 a P2-11:** Blindagem anti-bypass de portais, GPS resiliente e unificação de diálogos.
* **P3-12 a P3-13:** Bibles técnicas e suíte de testes de ponta a ponta `test_master_rebuild_suite.tscn`.
