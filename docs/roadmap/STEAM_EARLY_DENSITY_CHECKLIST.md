# STEAM EARLY DENSITY CHECKLIST — Exame → Ruínas

> **Canon:** [`../bibles/STEAM_POLISH_BIBLE.md`](../bibles/STEAM_POLISH_BIBLE.md) §5  
> **Objetivo:** tornar a primeira hora review-proof (gates G1–G5).  
> Marcar `[x]` só após validação **in-map** (play humano ou suite de imersão + smoke visual).  
> Factory: `world/components/exploration/NenSensorFactory.gd`

---

## Gates (obrigatório em todos os mapas abaixo)

- [ ] **G1** Regra dos 10s — sem corredor vazio >10s
- [ ] **G2** ≥1 Gyo · ≥1 Zetsu · ≥1 Ko reais no mapa (não só tutorial)
- [ ] **G3** Inimigos com silhueta + telegraph + fraqueza Nen
- [ ] **G4** Clareiras sem combate ainda recompensam
- [ ] **G5** Playtest humano Exame→Ruínas gravado

---

## 1. `exame_maratona` (`world/maps/exame_maratona.tscn`)

| Item | Status | Notas de implementação |
| :--- | :---: | :--- |
| 1º NPC / toast <2s | [ ] | Mentoria direta; ContentDirector toasts |
| 1º combate 15–25s | [ ] | Telegraph legível; TTK 4–8s |
| ≥1 Gyo pista de rota | [ ] | `GyoInspectable` / clue canônico |
| ≥1 placa / prop “próximo passo” | [ ] | Sem assuntos vagos |
| Sem dead corridor >10s | [ ] | Plantar baú, rastro ou walker |
| Netero / beat canônico plantado | [ ] | IDs canônicos do arco 1 |

**Nen beats mínimos:** Gyo ×1 (pista). Zetsu/Ko podem ficar para Padokia se o Exame for curto — desde que a **rota early completa** cumpra G2.

---

## 2. Lobby hub (`world/lobby.tscn`)

| Item | Status | Notas |
| :--- | :---: | :--- |
| Elena mentor direto | [ ] | Diz o que fazer |
| Marcadores `?` / `!` | [ ] | `QuestMarkerBillboard` |
| Walkers sem overdense | [ ] | Espalhar praça |
| Nen **não** forçado | [ ] | Semiaberto |
| Saídas claras | [ ] | Padokia / Story Gateway / loja / ferreiro |
| Ambient / stinger leve | [ ] | Crossfade OST |

---

## 3. Padokia — `estrada_padokia` + `regiao_vale_padokia`

| Item | Status | Notas |
| :--- | :---: | :--- |
| Desagregar praça OVERDENSE | [ ] | NPCs → loja / dojo / periferia |
| Vila Exterior UNDERDENSE | [ ] | Baú **ou** glifo Gyo atrás das casas |
| Estrada regra 10s | [ ] | Pista / recurso / rastro a cada >10s |
| 1 evento social/facção | [ ] | Associação × Máfia × Guardas |
| Quest “um de cada vez” | [ ] | Mentores diretos |
| Objetivos Investigate / Stealth / Ko | [ ] | Padrão Trilha de Aura / Selos |
| **Tutorial Nen 3 beats** antes da dungeon | [ ] | **Gyo pista → Zetsu acampamento → Ko obstáculo** |
| Markers `?`/`!` em quest NPCs | [ ] | Billboard |

**Sensores alvo:** ≥6 na rota Vila→Estrada→Ponte (mix Gyo/Ko/Zetsu).

---

## 4. `floresta_vestigios`

| Item | Status | Notas |
| :--- | :---: | :--- |
| 3 arquétipos (fast / ambusher / tank) | [ ] | Silhuetas distintas |
| ≥8 sensores na rota + clareiras | [ ] | `NenSensorFactory` |
| Floresta Profunda DEAD ZONE | [ ] | Ninho / evento noturno / baú |
| Obstáculos Ko em clareiras | [ ] | Bloqueia atalho / loot |
| ZetsuSensorZone acampamento | [ ] | Alarme se falhar |
| SFX `gyo_detect` 100% inspectables | [ ] | UX gate |
| Respiro 4–8s sem mob | [ ] | ContentDirector 300–600px |
| Baús periféricos (Pedra de Aura / Gourmet mat) | [ ] | Sem poções clássicas |

---

## 5. `dungeon_ruinas_zaban` (+ `vertical_slice_zaban`)

| Item | Status | Notas |
| :--- | :---: | :--- |
| Entrada: aviso sonoro + runas Gyo | [ ] | Transição ameaçadora |
| Selos Ko / Zetsu internos | [ ] | G2 dungeon |
| Boss Guardião 3 fases | [ ] | Template mestre — preservar |
| Juice entrada / saída de boss | [ ] | Banner + stinger |
| Loot ritual no chão | [ ] | MH-style pickup juice |
| Telegraph AoE ~1.2s | [ ] | Raid solo polish |
| Enrage warning 60s | [ ] | Legível |
| Wipe solo → checkpoint | [ ] | Sem softlock |
| Adds controlados (não spam) | [ ] | Espaço Hatsu |

---

## 6. Balance early (retune fino)

| Knob | Alvo | Onde |
| :--- | :--- | :--- |
| Player move speed | ~112 | player / config early |
| Enemy move speed | ~58 | `EnemyData` early |
| Enemy attack CD | alto o bastante p/ telegraph | EnemyData windup/recovery |
| Jenny kill lv≤15 | soft (fator 0.45) | `Economy.calcular_drop_jenny_inimigo` |
| XP | soft-cap saga 1 = lv25 | `ProgressionConfig.SAGA_LEVEL_RANGES` |
| Encontros | 300–600px · SAFE vila | ContentDirector |
| Bônus resolver com Nen | pequeno XP/mastery | quest Investigate/Stealth complete |

---

## 7. Ordem de plantio recomendada

1. Padokia 3 beats Nen (Gyo→Zetsu→Ko) + desagregar vila  
2. Floresta sensores ≥8 + Floresta Profunda  
3. Ruínas entrada + selos + validar boss polish  
4. Exame toasts / 1º combate timing  
5. Lobby walkers + saídas claras  
6. Playtest humano G5 (gravar)  

---

## 8. Definição de pronto (early slice)

- Todos os checkboxes das seções 1–5 marcados **ou** justificados como N/A com link para issue  
- G1–G5 verdes  
- Suite de imersão early existente ainda verde + play humano sem dead corridor  
- Nenhuma poção clássica introduzida; consumíveis = Pedra de Aura / Gourmet  
