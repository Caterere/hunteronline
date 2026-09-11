# PRODUCTION ROADMAP — Hunter Online

> **O que é:** plano de produção ativo (agora / next / later).  
> **Não é:** lista de sistemas MMO futuros → ver [`MMO_FEATURES_BACKLOG.md`](MMO_FEATURES_BACKLOG.md).  
> **Diretriz (AGENTS.md):** qualidade de gameplay > quantidade de sistemas · foco **COMBATE + NEN + HATSU + PROGRESSÃO**.

Histórico de sprints diários: [`_history/`](_history/)

---

## 1. IMMEDIATE (próxima iteração)

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

---

## 2. NEXT (média prioridade)

Itens de quests investigativas, NPCs vivos, eventos de facção, Style Lock PixelLab, escolta, baús e ContentDirector — **todos concluídos** (detalhe em `_history/TASKS_AMANHA_2026-09-09.md` e `…-09-10.md`).

---

## 3. LATER (longo prazo / host público)

1. **Regiões** — Yorknew / Kukuroo densificados `[x]`
2. **Arena Celestial & PvP async** — torre real + ghosts `[x]`
3. **Multiplayer autoritativo (LAN → VPS)**
   - [x] Dedicated ENet, puppets, 20 TPS, combate RPC, proxies, morte/respawn, server list, AoI/delta
   - [ ] Master server / matchmaking (frota VPS)
   - [ ] Compressão / cap de taxa VPS
   - [x] **PREREQ-2:** revive de aliados (canalização 3s) — ver backlog MMO
   - [ ] **PREREQ-1:** sync binário compacto via `NetworkProtocol` — ver backlog MMO
4. **Progressão** — soft-caps XP/Jenny `[x]`
5. **Backlog MMO (não diluir COMBATE+NEN+HATSU)**
   - Tier S/A/B: [`MMO_FEATURES_BACKLOG.md`](MMO_FEATURES_BACKLOG.md)
   - Só puxar quando sistemas atuais não bastam; PREREQ-1/2 bloqueiam AH / ranked / raids

---

## Links rápidos

| Doc | Papel |
| :--- | :--- |
| [`MMO_FEATURES_BACKLOG.md`](MMO_FEATURES_BACKLOG.md) | Sistemas MMO futuros priorizados |
| [`LIVE_OPS_CONTENT.md`](LIVE_OPS_CONTENT.md) | Live ops + versão + migração de save |
| [`../multiplayer/LAN_MULTIPLAYER_GUIDE.md`](../multiplayer/LAN_MULTIPLAYER_GUIDE.md) | Como rodar LAN |
| [`../multiplayer/SERVER_SETUP.md`](../multiplayer/SERVER_SETUP.md) | Host / VPS |
| [`../README.md`](../README.md) | Índice mestre de toda a documentação |
