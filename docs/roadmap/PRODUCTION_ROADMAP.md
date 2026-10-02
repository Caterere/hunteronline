# PRODUCTION ROADMAP — Hunter Online

> **O que é:** plano de produção ativo (agora / next / later).  
> **Não é:** lista de sistemas MMO futuros → ver [`MMO_FEATURES_BACKLOG.md`](MMO_FEATURES_BACKLOG.md).  
> **Diretriz (AGENTS.md):** qualidade de gameplay > quantidade de sistemas · foco **COMBATE + NEN + HATSU + PROGRESSÃO**.  
> **Contrato Steam:** [`../bibles/STEAM_POLISH_BIBLE.md`](../bibles/STEAM_POLISH_BIBLE.md).

Histórico de sprints diários: [`_history/`](_history/)

---

## 0. STEAM_POLISH (prioridade ativa)

> Sistemas prontos ≠ jogo Steam. Foco: **densidade + feedback + pacing deliberado**.  
> Gates G1–G5: regra 10s · Nen fora do combate · legibilidade · reward em clareira · playtest humano P0.

### 0.1 Agora (early review-proof)
1. **Canon Steam** — bible + checklist early `[x]` docs
2. **Densidade Exame→Padokia→Floresta→Ruínas** — ver [`STEAM_EARLY_DENSITY_CHECKLIST.md`](STEAM_EARLY_DENSITY_CHECKLIST.md)
   - [x] Sensores Gyo/Ko/Zetsu na regra dos 10s (factory existente)
   - [x] Tutorial Nen 3 beats antes da dungeon (Gyo→Zetsu→Ko)
   - [x] Desagregar vila OVERDENSE · matar Vila Exterior / Floresta Profunda DEAD
   - [x] Baús periféricos (Pedra de Aura / Gourmet — sem poções clássicas)
   - [ ] Playtest humano G5 gravado
3. **Combate early** — 3 arquétipos legíveis/bioma · TTK 4–8s · speeds ~112/58
4. **Boss Guardião** — preservar 3 fases · juice entrada/saída · loot ritual

### 0.2 DENSITY (pilares — sem sistemas novos)
| Pilar | Meta | Status |
| :--- | :--- | :---: |
| Combate | ≥4 `EnemyData`/bioma · elite puzzle Nen/mapa · Hatsu inimigo em elites | [ ] |
| Nen mundo | 8–15 sensores/mapa mid · SFX discovery 100% · falha Zetsu/En legível | [ ] |
| Hatsu | Momento Hatsu/arco · mastery UI a cada 10 · CDs MH-style | [ ] |
| Progressão | Identidade por cluster · training como respiro Arena · alinhar PowerScale docs | [ ] |
| Quests/Story | Beats com fala/ORDEM · cutscenes 15–40s checkpoints | [ ] |
| Economia | 30–50 itens identidade · sinks Hatsu/blacksmith/gourmet | [ ] |
| Mundo vivo | Schedules NPC · crowd Yorknew mínimo · 1 evento facção Estrada | [ ] |
| Áudio/UI | Barks mentores · stingers reward · crossfade gates | [ ] |

Detalhe: [`STEAM_POLISH_BIBLE.md` §6](../bibles/STEAM_POLISH_BIBLE.md).

### 0.3 PACING (números canônicos)
| Bracket | Níveis | Sessão |
| :--- | :--- | :--- |
| EARLY (1–3) | 1–60 | 1º NPC <2s · combate 15–25s · dead ≤6s · boss rota 60–90s |
| MID (4–5) | 61–130 | Missões 8–15 min · combate 20–40s · micro-reward a cada 10s caminhada |
| LATE (6–9) | 131–350 | Arcos 40–90+ min · TTK elite 20–40s · boss phase 45–90s |

Reward cadence: **micro** (ação) · **médio** (3–5 min) · **macro** (arco).  
Knobs: `ProgressionConfig` · `HatsuConfig` · `Economy` — ver bible §4.

### 0.4 Review slice (90–120 min) — gate antes de LAN/VPS
1. Character select → Exame  
2. Lobby Elena  
3. Padokia investigativa (Nen tools)  
4. Floresta → Ruínas (boss 3 fases)  
5. Hub → Skill Tree → Hatsu moment  
6. (Opcional) Arena rank 1  

**VPS bloqueado** até early review-proof + prova LAN 2 clientes em raid Zaban.

---

## 1. IMMEDIATE (histórico — concluído)

1. **Sensores de Nen no mundo semiaberto**
   - [x] `GyoInspectable` Floresta / Ruínas Zaban / Padokia
   - [x] `KoObstacle` extras
   - [x] `ZetsuSensorZone` acampamentos
   - [x] Factory: `world/components/exploration/NenSensorFactory.gd`
2. **Variedade visual de criaturas**
   - [x] Arquétipos fast / ambusher / tank
   - [x] Sprites PixelLab Lobo + Fera Alada
   - [x] Sentinela de Pedra
3. **Feedback de Gyo**
   - [x] SFX `gyo_detect` / `nen_gyo`
4. **Feel Gap Close (Maple/RO/Tibia)**
   - [x] Morte com dissipação de aura + hit-stop
   - [x] `LootDrop` no chão + pickup juice
   - [x] Texto `IMUNE` + afterimages de dash + assinatura Hatsu
   - [x] +XP/+Jenny float, buffs HUD, level-up juice, SFX posicional
   - [x] Raid vertical Ruínas de Zaban wired
   - [x] PREREQ-1 player/auction/guild binary sync
   - [x] Raid Zaban density (3+ fases, telegraph AoE, loot no chão, wipe/revive legível)
   - [x] A7 Blacklist open hunt (world boss co-op)
   - [x] A8 Gourmet life skills (leve, buffs temporários)

---

## 2. NEXT (média prioridade)

1. **STEAM early density** — checklist [`STEAM_EARLY_DENSITY_CHECKLIST.md`](STEAM_EARLY_DENSITY_CHECKLIST.md) (ativo)
2. Itens históricos de quests investigativas, NPCs vivos, eventos de facção, Style Lock PixelLab, escolta, baús e ContentDirector — **concluídos** (detalhe em `_history/TASKS_AMANHA_2026-09-09.md` e `…-09-10.md`). Reabrir só se playtest G5 falhar o gate.

---

## 3. LATER (longo prazo / host público)

1. **Regiões** — Yorknew / Kukuroo densificados `[x]` (re-auditar com regra 10s após early)
2. **Arena Celestial & PvP async** — torre real + ghosts `[x]`
3. **Multiplayer autoritativo (LAN → VPS)**
   - [x] Dedicated ENet, puppets, 20 TPS, combate RPC, proxies, morte/respawn, server list, AoI/delta
   - [x] Master server registry UDP 7780 + announce
   - [x] Matchmaking filas (`MatchmakingQueue` + `DutyFinderSystem` + linha `QUEUE|` no registry)
   - [x] Autosave VPS periódico (`ServerStorageManager.persist_all_peers_periodic`)
   - [x] Compressão DEFLATE + `snapshot_send_hz` / `snapshot_compress` (`ServerConfig`)
   - [x] **PREREQ-2:** revive de aliados (canalização 3s) — ver backlog MMO
   - [x] **PREREQ-1:** sync binário compacto via `NetworkProtocol` — ver backlog MMO
   - [ ] **Prova LAN 2 clientes** raid Zaban (gate Steam antes de VPS público)
4. **Progressão** — soft-caps XP/Jenny `[x]`
5. **Backlog MMO (não diluir COMBATE+NEN+HATSU)**
   - Tier S/A/B: [`MMO_FEATURES_BACKLOG.md`](MMO_FEATURES_BACKLOG.md)
   - Só puxar quando sistemas atuais não bastam; PREREQ-1/2 bloqueiam AH / ranked / raids

---

## Links rápidos

| Doc | Papel |
| :--- | :--- |
| [`../bibles/STEAM_POLISH_BIBLE.md`](../bibles/STEAM_POLISH_BIBLE.md) | Gates · pacing · pilares · review slice |
| [`STEAM_EARLY_DENSITY_CHECKLIST.md`](STEAM_EARLY_DENSITY_CHECKLIST.md) | Checklist operacional early |
| [`MMO_FEATURES_BACKLOG.md`](MMO_FEATURES_BACKLOG.md) | Sistemas MMO futuros priorizados |
| [`LIVE_OPS_CONTENT.md`](LIVE_OPS_CONTENT.md) | Live ops + versão + migração de save |
| [`../multiplayer/LAN_MULTIPLAYER_GUIDE.md`](../multiplayer/LAN_MULTIPLAYER_GUIDE.md) | Como rodar LAN |
| [`../multiplayer/SERVER_SETUP.md`](../multiplayer/SERVER_SETUP.md) | Host / VPS |
| [`../README.md`](../README.md) | Índice mestre de toda a documentação |
