# Documentação — Hunter Online (ÍNDICE MESTRE)

> **Porta de entrada única.** Código e cenas vencem docs desatualizados — reporte o conflito.  
> **Design canônico (SSOT):** [`bibles/`](bibles/)  
> **Agente Cursor:** [`.agent/docs/bibles/`](../.agent/docs/bibles/) são **pontes** para as bibles canônicas (não uma segunda fonte).

---

## 1. Design canônico — `bibles/`

Regras do que o jogo *deve ser*. Lista completa: [`bibles/README.md`](bibles/README.md).

| Doc | O que define |
| :--- | :--- |
| [GAME_MASTER_BIBLE.md](bibles/GAME_MASTER_BIBLE.md) | Pilares e visão geral |
| [GAMEPLAY_BIBLE.md](bibles/GAMEPLAY_BIBLE.md) | Loop e fundamentos |
| [NEN_BIBLE.md](bibles/NEN_BIBLE.md) | Técnicas de Nen |
| [HATSU_BIBLE.md](bibles/HATSU_BIBLE.md) · [HATSU_CREATOR_BIBLE.md](bibles/HATSU_CREATOR_BIBLE.md) | Hatsu + criador |
| [COMBAT_BIBLE.md](bibles/COMBAT_BIBLE.md) · [COMBAT_2_BIBLE.md](bibles/COMBAT_2_BIBLE.md) | Combate |
| [PROGRESSION_BIBLE.md](bibles/PROGRESSION_BIBLE.md) · [SKILL_TREE_BIBLE.md](bibles/SKILL_TREE_BIBLE.md) | Progressão |
| [MISSION_BIBLE.md](bibles/MISSION_BIBLE.md) · [QUEST_CONTENT_BIBLE.md](bibles/QUEST_CONTENT_BIBLE.md) | Missões |
| [WORLD_BIBLE.md](bibles/WORLD_BIBLE.md) · [LIVING_WORLD_BIBLE.md](bibles/LIVING_WORLD_BIBLE.md) · [REGIONS_BIBLE.md](bibles/REGIONS_BIBLE.md) | Mundo |
| [UI_UX_BIBLE.md](bibles/UI_UX_BIBLE.md) · [VISUAL_BIBLE.md](bibles/VISUAL_BIBLE.md) | UI / visual |
| [PIXEL_ART_STYLE_BIBLE.md](bibles/PIXEL_ART_STYLE_BIBLE.md) · [PIXEL_ART_PRODUCTION_BIBLE.md](bibles/PIXEL_ART_PRODUCTION_BIBLE.md) · [ART_PIPELINE_CANON.md](bibles/ART_PIPELINE_CANON.md) | Pixel art |
| [TECHNICAL_ARCHITECTURE_BIBLE.md](bibles/TECHNICAL_ARCHITECTURE_BIBLE.md) | Arquitetura técnica |

---

## 2. Como está no código — `systems/`

| Doc | Sistema |
| :--- | :--- |
| [NEN_SYSTEM.md](systems/NEN_SYSTEM.md) | Nen runtime |
| [HATSU_SYSTEM.md](systems/HATSU_SYSTEM.md) | Hatsu runtime |
| [SAVE_SYSTEM.md](systems/SAVE_SYSTEM.md) | SaveManager |
| [MISSION_SYSTEM.md](systems/MISSION_SYSTEM.md) | Missões |
| [PLAYER_DATA.md](systems/PLAYER_DATA.md) | Dados do jogador |
| [WORLD_STATE.md](systems/WORLD_STATE.md) | Estado de mundo |
| [PIXELLAB_MCP.md](systems/PIXELLAB_MCP.md) | Integração PixelLab |
| [DIALOGUE_SYSTEM.md](systems/DIALOGUE_SYSTEM.md) · [SPAWN_SYSTEM.md](systems/SPAWN_SYSTEM.md) · [STORY_SYSTEM.md](systems/STORY_SYSTEM.md) | Diálogo / spawn / story |
| [ASSET_REGISTRY.md](systems/ASSET_REGISTRY.md) · [CONTENT_PIPELINE.md](systems/CONTENT_PIPELINE.md) | Assets / pipeline |
| [TESTING_STRATEGY.md](systems/TESTING_STRATEGY.md) · [DEVELOPMENT_LOG.md](systems/DEVELOPMENT_LOG.md) | QA / log |

---

## 3. Decisões técnicas — `architecture/`

| ADR | Tema |
| :--- | :--- |
| [ADR-001-NEN-ARCHITECTURE.md](architecture/ADR-001-NEN-ARCHITECTURE.md) | Arquitetura de Nen |
| [ADR-002-STORY-CHECKPOINT.md](architecture/ADR-002-STORY-CHECKPOINT.md) | Checkpoints de história |
| [ADR-003-HUB-WORLD.md](architecture/ADR-003-HUB-WORLD.md) | Hub world |
| [ADR-004-DATA-DRIVEN-MISSIONS.md](architecture/ADR-004-DATA-DRIVEN-MISSIONS.md) | Missões data-driven |
| [ADR-005-PERCEPTION-SYSTEM.md](architecture/ADR-005-PERCEPTION-SYSTEM.md) | Percepção |

---

## 4. Como criar conteúdo — `guides/`

| Doc | Uso |
| :--- | :--- |
| [NPC_CREATION_GUIDE.md](guides/NPC_CREATION_GUIDE.md) | NPCs |
| [BOSS_CREATION_GUIDE.md](guides/BOSS_CREATION_GUIDE.md) | Bosses |
| [QUEST_CONTENT_GUIDE.md](guides/QUEST_CONTENT_GUIDE.md) | Quests |
| [REGION_CREATION_GUIDE.md](guides/REGION_CREATION_GUIDE.md) · [SAGA_CREATION_GUIDE.md](guides/SAGA_CREATION_GUIDE.md) | Mundo / sagas |
| [HATSU_CONTENT_GUIDE.md](guides/HATSU_CONTENT_GUIDE.md) | Conteúdo de Hatsu |
| [PIXELLAB_PROMPT_LIBRARY.md](guides/PIXELLAB_PROMPT_LIBRARY.md) | Prompts PixelLab |
| [HOW_TO_EXPORT_WINDOWS_EXE.md](guides/HOW_TO_EXPORT_WINDOWS_EXE.md) | Export Windows |

---

## 5. Multiplayer — `multiplayer/`

| Doc | Uso |
| :--- | :--- |
| [MULTIPLAYER_ARCHITECTURE.md](multiplayer/MULTIPLAYER_ARCHITECTURE.md) | Arquitetura de rede |
| [MULTIPLAYER_GAMEPLAY.md](multiplayer/MULTIPLAYER_GAMEPLAY.md) | Party, bosses, duelos, revive |
| [NETWORK_PROTOCOL.md](multiplayer/NETWORK_PROTOCOL.md) | Protocolo / opcodes |
| [LAN_MULTIPLAYER_GUIDE.md](multiplayer/LAN_MULTIPLAYER_GUIDE.md) | Jogar em LAN |
| [SERVER_SETUP.md](multiplayer/SERVER_SETUP.md) | Dedicated / VPS |
| [MULTIPLAYER_SECURITY.md](multiplayer/MULTIPLAYER_SECURITY.md) | Segurança |
| [MULTIPLAYER_TEST_PLAN.md](multiplayer/MULTIPLAYER_TEST_PLAN.md) | Testes |

---

## 6. Roadmap — `roadmap/`

| Doc | Uso |
| :--- | :--- |
| [PRODUCTION_ROADMAP.md](roadmap/PRODUCTION_ROADMAP.md) | **O que fazer agora / next / later** |
| [MMO_FEATURES_BACKLOG.md](roadmap/MMO_FEATURES_BACKLOG.md) | **Sistemas MMO futuros** (Tier S/A/B + PREREQs) |
| [LIVE_OPS_CONTENT.md](roadmap/LIVE_OPS_CONTENT.md) | Live ops + versionamento + migração de save |
| [roadmap/_history/](roadmap/_history/) | Tasks diárias e fases antigas (arquivo) |

---

## 7. Arquivo — `archive/`

| Pasta / doc | Conteúdo |
| :--- | :--- |
| [archive/audits/](archive/audits/) | Auditorias e playtests históricos |
| [archive/root-dumps/](archive/root-dumps/) | Stubs/dumps que estavam na raiz |
| [DOCUMENTACAO_COMPLETA.md](archive/DOCUMENTACAO_COMPLETA.md) | Dump legado |

---

## 8. Raiz do repositório

| Arquivo | Papel |
| :--- | :--- |
| [`README.md`](../README.md) | Overview do projeto |
| `Hunter Online — AGENTS.md` (raiz) | Regras para agentes / contribuidores |

---

## Agente Cursor

1. Leia `Hunter Online — AGENTS.md` na raiz  
2. Use [`.agent/docs/bibles/00_BIBLE_INDEX.md`](../.agent/docs/bibles/00_BIBLE_INDEX.md) — aponta para **`docs/bibles/`**  
3. Conflito design vs código → preferir código + reportar  
4. Conflito stub do agente vs `docs/bibles/` → **`docs/bibles/` vence**
