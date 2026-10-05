# STEAM MID/LATE DENSITY CHECKLIST — Kukuroo → Black Whale

> **Canon:** [`../bibles/STEAM_POLISH_BIBLE.md`](../bibles/STEAM_POLISH_BIBLE.md) §4–§6  
> **Early:** [`STEAM_EARLY_DENSITY_CHECKLIST.md`](STEAM_EARLY_DENSITY_CHECKLIST.md)  
> **Factory / kit:** `NenSensorFactory` + `MidLateDensityKit` + `CompanionChatter` + `CheckpointCutsceneLibrary`  
> **Suite:** `scratch/test_steam_mid_late_density_suite.tscn` · LAN: `scratch/test_lan_zaban_2client_proof_suite.tscn`  
> **Fora de escopo deste PR:** playtest humano gravado (G5) · sprites PixelLab novos

---

## Gates mid/late

- [x] **G1** Regra dos 10s — baús + placas + sensores + crowd nos hubs mid/late
- [x] **G2** Gyo/Ko/Zetsu por mapa (canon + densify extra)
- [x] **G3** Inimigos ambient + telegraph (Combat Density early portado)
- [x] **G4** Clareiras recompensam — `MidLateDensityKit` baús Pedra/Gourmet/itens de arco
- [ ] **G5** Playtest humano mid — **excluído** (pedido do diretor)
- [x] **LAN 2-client Zaban** — suite de prova automatizada (não substitui smoke físico opcional)

---

## 1. `montanha_kukuroo` (arco 2)

| Item | Status | Notas |
| :--- | :---: | :--- |
| ≥8 sensores rota | [x] | Gyo/Ko/Zetsu + extras jardim/dormitório |
| Baús clareira | [x] | Portão / Alameda / Mansão |
| CompanionChatter | [x] | saga 2 |
| Checkpoint cutscenes | [x] | alameda + mansão |
| Momento Hatsu | [x] | Pressão Zoldyck |
| Ko → pedra_aura | [x] | sem poção clássica |

---

## 2. `arena_celestial` (arco 3)

| Item | Status | Notas |
| :--- | :---: | :--- |
| Sensores + Zetsu corredor | [x] | 100º / 190º / vestiário |
| Training Wing respiro | [x] | nó mapa + botão tower UI |
| Baús / Hatsu / ckpt | [x] | Dojo + Pré-200º |
| CompanionChatter | [x] | saga 3 |

---

## 3. `yorknew_city` (arco 4)

| Item | Status | Notas |
| :--- | :---: | :--- |
| Crowd mínimo viável | [x] | CrowdYork_A–E + walkers |
| Baús por distrito | [x] | Leilão / Avenida / Cemitério / Hotel |
| CompanionChatter | [x] | Gon/Killua/Kurapika/Leorio |
| Checkpoints 15–40s | [x] | avenida + cemitério |
| Momento Hatsu | [x] | Contrato sob Neon |
| Ko rewards canônicos | [x] | pedra / cristal_leilao / seda |

---

## 4. `greed_island` (arco 5)

| Item | Status | Notas |
| :--- | :---: | :--- |
| Baús Antokiba/Desfiladeiro/Soufrabi | [x] | cartas + biscoito |
| Ckpt Biscuit + Soufrabi | [x] | |
| Hatsu moment treino | [x] | |
| CompanionChatter | [x] | |

---

## 5. Late (`ngl` → `associacao` → `continente` → `black_whale`)

| Mapa | Baús | Companion | Hatsu | Extra sensores |
| :--- | :---: | :---: | :---: | :--- |
| NGL | [x] | [x] | [x] | ckpt palácio |
| Associação | [x] | [x] | [x] | ckpt eleição + placas hunter |
| Continente Negro | [x] | [x] | [x] | ckpt acampamento + essência Brion |
| Black Whale | [x] | [x] | [x] | ≥8 Gyo/Ko/Zetsu densificados |

---

## 6. Sistemas / balance

| Item | Status |
| :--- | :---: |
| Economy 30–50 IDs identidade | [x] (~52) |
| PowerScale docs ↔ cap 1000 | [x] |
| Ko mid/late sem `pocao_aura` | [x] |
| LAN 2-client proof suite | [x] |

---

## Como rodar

```bash
godot --headless --path . res://scratch/test_steam_mid_late_density_suite.tscn
godot --headless --path . res://scratch/test_lan_zaban_2client_proof_suite.tscn
godot --headless --path . res://scratch/test_steam_polish_pass_suite.tscn
```
