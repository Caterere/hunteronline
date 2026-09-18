# LIVE OPS & CONTENT — Hunter Online

> **O que é:** pipeline de conteúdo ao vivo + versionamento + migração de saves (docs fundidos).  
> **Antes:** `LIVE_CONTENT_PIPELINE.md` · `CONTENT_VERSIONING.md` · `SAVE_MIGRATION.md`  
> **Engine:** Godot 4.6 · **Alinhamento:** [`PRODUCTION_ROADMAP.md`](PRODUCTION_ROADMAP.md)

---

## Parte A — Live Content Pipeline

O Live Content Pipeline transforma a campanha linear em plataforma modular data-driven. Sagas, capítulos, regiões, chefes, eventos e segredos vêm de Resources/dicionários — sem recompilar o motor.

### Princípios
1. Single-player offline 100% autônomo.
2. Pacotes com flags `coop` / `solo` / `server_authoritative`.
3. Persistência incremental (schema save) sem perda de progresso.
4. Validação automática (`ContentValidator`) antes do runtime.

### Implementado (módulos)
- `SagaDefinition` / `ChapterDefinition` — arcos e capítulos declarativos
- `StoryGatingEvaluator` + `StoryManager` — gating sem hardcode; sagas custom sem alterar as 9 canônicas
- `NPCMemorySystem` / `NPCStoryArc` — memória e arcos de NPC
- `RegionPackage` + `TravelSystem` — regiões e viagens
- `LiveEventManager` — eventos temporários
- `BossDefinition` — chefes com fases/loot/coop
- `CollectionManager` — Códex do Caçador
- `ContentValidator` + `ContentVersionConfig` — validação e tripla-versão

### Planejado / Futuro
- Hot-reload de `.tres`, patching client, modding sandbox
- Editor visual de sagas, eventos globais via backend, temporadas competitivas

---

## Parte B — Tripla-versão (Content Versioning)

Gerenciado em `ContentVersionConfig.gd`:

| Camada | Exemplo | Quando sobe |
| :--- | :--- | :--- |
| `GAME_VERSION` | `1.0.0` | Motor / sistemas centrais |
| `CONTENT_VERSION` | `1.2.0` | Sagas, regiões, balance de pacotes |
| `SAVE_VERSION` | `2.4` | Schema do JSON de save |

**Multiplayer:** `NetworkManager` exige `GAME_VERSION` compatível; `CONTENT_VERSION` diferente usa fallback (sem viajar a regiões sem assets).

**Implementado:** header de versão nos saves · `get_version_info()`  
**Planejado:** aviso de versão no menu · rejeição suave de pacotes · log de auditoria  
**Futuro:** live patching delta · checksum cross-platform

---

## Parte C — Migração de Saves

### Histórico de schemas
| Schema | Fase | Acrescentou |
| :--- | :--- | :--- |
| v2.0 | G | PlayerData, inventário, level, gold |
| v2.1 | H | world_state, flags, time |
| v2.2 | I | progressão alta, 4 Hatsu, títulos |
| v2.3 | K | multiplayer / co-op stats |
| **v2.4** | **L (atual)** | collections, npc_memories, live_events, unlocked_routes |

### Regras
1. Zero data loss  
2. Migração automática e silenciosa na desserialização  
3. Idempotente em v2.4  
4. Save atômico com backup do arquivo anterior  

Motor: `ContentVersionConfig.migrate_save_data()` chamado por `SaveManager` para saves ≤ 2.3.

**Planejado:** backups rotativos · SHA-256 · tabela de itens obsoletos  
**Futuro:** cloud save com resolução de conflitos

---

## Links
- Roadmap de produção: [`PRODUCTION_ROADMAP.md`](PRODUCTION_ROADMAP.md)
- Backlog MMO: [`MMO_FEATURES_BACKLOG.md`](MMO_FEATURES_BACKLOG.md)
- Histórico de tasks diárias: [`_history/`](_history/)
