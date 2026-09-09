# SAVE SYSTEM & PERSISTENCE ARCHITECTURE
## HUNTER ONLINE — ATOMIC STORAGE, SLOTS & VERSIONING

### 1. Visão Geral
O `SaveManager` é o único autorizador e executor de operações de persistência em disco. Ele suporta até 3 slots de personagens de jogadores (`user://savegame_slot_1.json` a `3.json`), além de slots reservados para testes e debug.

### 2. Protocolo de Gravação Atômica
Para evitar corrupção por queda de energia ou fechamento abrupto:
1. Os dados consolidados são gravados em arquivo temporário: `savegame_slot_X.tmp`.
2. O arquivo temporário é validado via parser JSON (`JSON.parse`).
3. Se válido: o save antigo é renomeado para `savegame_slot_X.bak`.
4. O arquivo `.tmp` é renomeado para `savegame_slot_X.json`.

### 3. Versionamento de Save (`save_version`)
* O cabeçalho do arquivo contém `save_version: int`.
* Se um save de versão legada (ex: v1) for detectado pelo `SaveManager`, um pipeline de migração preenche campos ausentes com defaults seguros antes de entregá-lo aos sistemas de gameplay.

### 4. Estrutura Canônica do Save
```json
{
  "save_version": 1,
  "character_id": "HX-8492041",
  "nome_personagem": "Killua",
  "afinidade_nen": 1,
  "attributes": {
    "vida": 100,
    "vida_max": 100,
    "forca": 14,
    "defesa": 12,
    "velocidade": 18,
    "aura": 120,
    "aura_max": 120,
    "nivel": 5,
    "xp": 320,
    "nivel_nen": 1,
    "xp_nen": 450
  },
  "story": {
    "arco_atual": 3,
    "etapa_quest_arco": 10,
    "sagas_completas": [1, 2]
  },
  "nen": {
    "skill_points": 4,
    "skill_tree_progress": { "ten_1": 1, "ren_1": 1 },
    "ryu_caminho": "ofensivo"
  },
  "inventory": [],
  "mapa_atual": "res://world/maps/arena_celestial.tscn",
  "posicao_salva": [1100.0, -80.0]
}
```
