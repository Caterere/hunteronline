# STEAM EARLY DENSITY CHECKLIST — Exame → Ruínas

> **Canon:** [`../bibles/STEAM_POLISH_BIBLE.md`](../bibles/STEAM_POLISH_BIBLE.md) §5  
> **Objetivo:** tornar a primeira hora review-proof (gates G1–G5).  
> Marcar `[x]` só após validação **in-map** (play humano ou suite de imersão + smoke visual).  
> Factory: `world/components/exploration/NenSensorFactory.gd`  
> Suite: `scratch/test_steam_early_density_suite.tscn` (37/37)

---

## Gates (obrigatório em todos os mapas abaixo)

- [x] **G1** Regra dos 10s — densificado Estrada/Vale/Floresta (validar play humano)
- [x] **G2** ≥1 Gyo · ≥1 Zetsu · ≥1 Ko — tutorial 3-beat + mapas early
- [x] **G3** Inimigos com silhueta + telegraph + fraqueza Nen — arquétipos Floresta
- [x] **G4** Clareiras sem combate ainda recompensam — baús Pedra/Gourmet
- [ ] **G5** Playtest humano Exame→Ruínas gravado — **ainda P0 humano**
  - Agent 2026-10-05: lobby live HUD História%/Atividades OK; suite rota 34/34;
    Estrada/Floresta/Ruínas carregados visualmente. Transição portal via automação flaky
    (chat/pause roubam input) — **mitigado**: chat `MOUSE_FILTER_IGNORE` fechado +
    LineEdit `FOCUS_NONE`. **Luiz ainda precisa gravar o G5 perceptivo.**

---

## 1. `exame_maratona`

| Item | Status | Notas |
| :--- | :---: | :--- |
| 1º NPC / toast <2s | [x] | `_toast_abertura_exame` |
| 1º combate 15–25s | [x] | Pacing X em `_alinhar_atores` + ambient hub |
| ≥1 Gyo pista de rota | [x] | Marca sabotador + clues |
| ≥1 placa “próximo passo” | [x] | `PlacaProximoPassoExame` |
| Sem dead corridor >10s | [x] | Fillers placas + Gyo meio corredor |
| Netero plantado | [x] | `_garantir_netero_exame` |

---

## 2. Lobby hub

| Item | Status | Notas |
| :--- | :---: | :--- |
| Elena mentor direto | [x] | Fluxo auto tutorial |
| Marcadores `?` / `!` | [x] | QuestMarkerBillboard |
| Walkers sem overdense | [x] | LivingNPC hub |
| Nen **não** forçado | [x] | Toast hub |
| Saídas claras | [x] | `PlacaSaidasLobby` + portão SUL |
| Ambient / stinger | [x] | BGM lobby |

---

## 3. Padokia — Estrada + Vale

| Item | Status | Notas |
| :--- | :---: | :--- |
| Desagregar praça OVERDENSE | [x] | NPCs espalhados no gerador |
| Vila Exterior UNDERDENSE | [x] | `BauVilaExterior` + `GyoGlifoVilaExterior` |
| Estrada regra 10s | [x] | Sensores + baú clareira |
| 1 evento social/facção | [x] | Associação × Máfia + placa |
| Quest “um de cada vez” | [x] | Principal + tutorial ORDEM |
| Investigate / Stealth / Ko | [x] | Tutorial + investigativas |
| **Tutorial Nen 3 beats** | [x] | `obter_quest_tutorial_nen_tres_beats` |
| Markers `?`/`!` | [x] | Existente |

---

## 4. `floresta_vestigios`

| Item | Status | Notas |
| :--- | :---: | :--- |
| 3 arquétipos | [x] | fast / ambusher / tank |
| ≥8 sensores | [x] | Gyo≥8 + Ko/Zetsu |
| Floresta Profunda DEAD | [x] | Ninho Gyo/Ko/Zetsu + baú |
| Obstáculos Ko | [x] | Atalho + ninho |
| Zetsu acampamento | [x] | Norte + ninho |
| SFX gyo_detect | [x] | Pipeline Gyo |
| Respiro 4–8s | [x] | Packs afastados do spawn + detection ↓ |
| Baús Pedra/Gourmet | [x] | Sem poções clássicas |

---

## 5. `dungeon_ruinas_zaban`

| Item | Status | Notas |
| :--- | :---: | :--- |
| Entrada aviso + runas Gyo | [x] | Toast + SFX + Gyo portão |
| Selos Ko / Zetsu | [x] | Clues antecâmara + corredor |
| Boss 3 fases | [x] | Template mestre |
| Juice boss | [x] | Raid solo polish |
| Loot ritual | [x] | Pedra/Cristal (sem poção) |
| Telegraph ~1.2s | [x] | Existente |
| Enrage 60s | [x] | Existente |
| Wipe → checkpoint | [x] | Existente |
| Adds controlados | [x] | Existente |

---

## 6. Balance early (retune fino)

| Knob | Alvo | Status |
| :--- | :--- | :---: |
| Player move speed | ~112 | [x] já no código |
| Enemy move speed | ~58 | [x] default AI |
| Jenny kill lv≤15 | soft 0.45 | [x] Economy |
| XP soft-cap saga 1 | lv25 | [x] ProgressionConfig |
| Encontros 300–600px | SAFE vila | [x] ContentDirector |
| Consumíveis | Pedra/Erva/Gourmet | [x] Economy + baús |

---

## 7. Definição de pronto (early slice)

- [x] Código densificado + suite `test_steam_early_density_suite` verde  
- [x] ABC: HatsuMoment + cutscenes early + ORDEM secundárias + QuestHUD História%  
- [ ] G5 playtest humano gravado  
- [x] Nenhuma poção clássica nos baús early novos  

---

## 8. Roteiro G5 (Luiz — gravar)

Rota: **Character Select → Exame → Lobby Elena → Vale (tutorial Nen 3-beat) → Estrada → Floresta → Ruínas (Guardião 3 fases)**.

Checklist durante gravação:
1. Dead time contínuo ≤6s? Anotar corredores vazios.
2. Usou Gyo / Zetsu / Ko de verdade fora do tutorial?
3. HatsuMoment + checkpoint cutscene dispararam?
4. Elite Alfa (Floresta) / Guardião Menor (Ruínas) legíveis?
5. Quest HUD mostra História % vs Atividades?
6. Boss Guardião: telegraph, loot no chão, wipe→checkpoint?

Marcar G5 `[x]` só com gravação + notas.