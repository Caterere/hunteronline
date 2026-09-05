# REGIONS DESIGN BIBLE — HUNTER MMORPG
## ARQUITETURA, STREAMING E CONEXÕES DO MUNDO

---

## 1. DIRETRIZ MACRO DO MUNDO FÍSICO
O mundo do Hunter MMORPG é estruturado segundo uma cadeia física de transição progressiva, sem teleportes arbitrários:

```text
CIDADE (Hunter Plaza / Vila de Padokia)
  ↓ [Estrada Real — Pontes, viajantes, caravanas]
ESTRADA
  ↓ [Planícies do Rio & Floresta dos Vestígios — Feras, clareiras, segredos]
ÁREA SELVAGEM
  ↓ [Ravina da Névoa Tóxica — Desfiladeiro de perigo com Ten/Zetsu]
OUTRA SUB-REGIÃO
  ↓ [Pórtico das Ruínas de Zaban — Fachada monumental, totens de Nen]
DUNGEON
  ↓ [Santuário Ancestral de Zaban — Sentinelas, antecâmara, armadilhas]
ÁREA ESPECIAL (Câmara do Guardião Ancestral & Baú Dourado)
```

---

## 2. REGIÃO PILOTO DE REFERÊNCIA: VALE DE PADOKIA
- **Dimensões:** 512 x 512 tiles (8192 x 8192 px na escala 16x16).
- **Streaming:** Grade de 64 chunks (8x8 chunks de 64x64 tiles). Nós fora do raio de visão do jogador têm física e processamento suspensos (> 480px) para máxima performance.
- **Seed Fixa:** 184729 para persistência determinística de relevo e estradas.

### Os 5 Macro-Espaços Canônicos de Padokia:
1. **Vila de Padokia (100x100 tiles):**
   - Praça da Fonte, Residência do Caçador, Empório Comercial, Forja do Ferreiro Duran, Dojo de Mestre Wing e Alojamento.
   - Zona Segura com patrulhas da guarda e abrigo contra intempéries.
2. **Estrada Real & Grande Rio:**
   - Estrada curvilínea conectando a vila à ponte de pedra ancestral.
   - Tráfego de mercadores, salteadores da estrada e travessia fluvial.
3. **Floresta dos Vestígios:**
   - Clareiras naturais e o grande landmark da **Árvore Milenar**.
   - Ecologia de feras da floresta, lobos das planícies e ninho de pássaros gigantes.
4. **Ravina da Névoa Tóxica (Danger Zone):**
   - Desfiladeiro estreito com miasma ácido (`TenHazardZone`).
   - Requer **Ten** ativo do jogador para evitar perda contínua de pontos de vida.
   - Ninho de predadores camuflados exigindo aproximação em **Zetsu** (`ZetsuSensorZone`).
5. **Ruínas do Santuário de Zaban & Dungeon:**
   - Fachada monumental com pilares de ruínas e Totem Ancestral de Ren (`RenBeacon`).
   - Barreira de rocha maciça rompível com **Ko** (`KoObstacle`) após leitura de pista por **Gyo** (`GyoInspectable`).
   - Dungeon interna com 3 fases do Guardião Ancestral, Baú Dourado e Portão de Retorno direto para a estrada.

---

## 3. SISTEMA DE SPAWN & CICLO DE VIDA (WORLD SPAWNER)
- Nenhum monstro no mundo aberto é colocado como nó estático descartável.
- Todos os inimigos utilizam instâncias de `WorldSpawner`:
  - Respawn determinístico parametrizado por zona (20s na estrada, 25s na floresta, 45s para elites, 90s para minibosses).
  - Resolução automática de dados através de `DataManager.get_enemy(enemy_id)`.
  - Integração de aggro com raio de leash máximo de 420px.
  - Sincronização nativa com `QuestSystem.register_enemy_kill()`.

---

## 4. TRANSIÇÃO DE CENAS E CONEXÕES FÍSICAS
- Portais utilizam `MapTransitionArea` com verificação de tecla `[E]` e Story Gate (Anti-Bypass).
- `WorldProgressionManager.posicionar_player_no_spawn()` garante reconciliação de spawn id (`default`, `entrada`, `saida_ruinas`).
- Suporte canônico ao método `SceneTransition.mudar_cena()` e alias `trocar_cena()`.
