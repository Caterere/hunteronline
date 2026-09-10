# HUNTER ONLINE — NEXT PRODUCTION ROADMAP (PLANO DE EVOLUÇÃO)

## Diretriz Permanente (AGENTS.md)
* **GAMEPLAY QUALITY > SYSTEM COUNT**
* **NÃO criar novos sistemas quando os existentes resolvem a necessidade.**
* **Foco em: COMBATE + NEN + HATSU + PROGRESSÃO.**

> Tasks detalhadas do dia seguinte: [`TASKS_AMANHA_2026-09-09.md`](TASKS_AMANHA_2026-09-09.md)

---

## 1. IMMEDIATE (Próxima Iteração Prioritária)
1. **Alimentar Sensores de Nen no Mundo Semiaberto**:
   * [x] Instanciar pistas `GyoInspectable` na Floresta dos Vestígios e Ruínas de Zaban (+ Padokia).
   * [x] Instanciar `KoObstacle` extras (atalhos/baús Padokia + Floresta + Zaban).
   * [x] Instanciar `ZetsuSensorZone` em acampamentos (Floresta + ravina Padokia + corredor Zaban).
   * [x] Factory reutilizável: `world/components/exploration/NenSensorFactory.gd`
2. **Variedade Visual de Criaturas Básicas**:
   * [x] Arquétipos `fast` / `ambusher` / `tank` + tintas na Floresta.
   * [x] Sprites PixelLab Lobo + Fera Alada (idle 8dir + walk 8×8) integrados.
   * [x] Sentinela de Pedra (tank) — `enemy_sentinela_pedra_8dir.png` integrado.
3. **Refinamento de Feedback de Gyo**:
   * [x] SFX `gyo_detect` / `nen_gyo` via `AudioSynth` + `AudioManager` ao revelar/inspecionar.

---

## 2. NEXT (Média Prioridade)
1. **Cadeias de Quests Secundárias Investigativas**:
   * [x] Missão de investigação de furto em Padokia com rastreamento Gyo (`PadokiaQuestCatalog.obter_quest_investigacao_furto` + 3 pistas na vila).
   * [x] Missão de escolta de caravana na Estrada Real com emboscada dinâmica em horário noturno (`EstradaPadokiaMap` + Guarda).
2. **Rotinas Dinâmicas de NPCs**:
   * [x] Ferreiro Duran + Mercador Zael: `LivingNPCBehavior` + `NPCScheduleData` (forja/loja de dia → praça à noite).
3. **Novos Eventos Dinâmicos de Facção**:
   * [x] Disputa territorial Associação Hunter × Salteadores na Grande Ponte (`EstradaPadokiaMap` + `WorldEventManager`).
4. **Personagens PixelLab (Style Lock 48px)**:
   * [x] Melody, Battera, Tsezguerra, Sentinela de Pedra — folhas `_8dir.png` integradas.
   * [x] Yorknew/Kukuroo deixam de forçar `player.png` — usam `NpcSpriteBinder` + assets existentes.
   * [x] Auditoria Style Lock (44/44) + restyle Canary/Gotoh/Silva + Melody/Battera/Tsezguerra/Sentinela.
   * [x] Canary / Gotoh / Silva dedicados (`npc_mordoma_canary`, `npc_mordomo_gotoh`, `npc_silva_zoldyck`).
5. **Escolta polish**:
   * [x] Zona de proteção da carroça + falha se sair do mapa à noite / afastar 8s.
6. **Baús Floresta**:
   * [x] 3 baús de clareira (poção/elixir aura) em `FlorestaVestigiosMap`.
7. **ContentDirector ↔ disputa ponte**:
   * [x] Evento noturno perto de `poi_ponte_rio` chama `WorldEventManager.iniciar_evento_disputa_ponte`.

---

## 3. LATER (Longo Prazo / Pré-Multiplayer)
1. **Novas Regiões do Mundo**:
   * [~] Yorknew + Kukuroo densificados (`MapAtmosphereDecorator` YORKNEW/KUKUROO) — conteúdo de arco já existia.
   * [x] Yorknew: trilha Gyo / Zetsu / fillers pós-Nen (`YorknewCityMap`).
   * [x] Kukuroo: mesmo padrão de densidade pós-Nen (`MontanhaKukurooMap` + PixelLab ambient).
2. **Arena Celestial & PvP Assíncrono**:
   * [x] `HeavensArenaTowerUI` → combate real em `CelestialTowerArena` (progresso unificado `andar_arena`/`torre_andar_atual`).
   * [ ] Sistema de andares 1v1 assíncrono contra outros usuários / Bestas de Nen.
3. **Sistemas Multiplayer Autoritativos**:
   * Sincronização de pacotes binários utilizando o `NetworkProtocol` já arquitetado.
4. **Progressão**:
   * [x] Soft-cap XP por saga + escala narrativa canônica (`CanonQuestCatalog.escalar_xp_narrativo`).
