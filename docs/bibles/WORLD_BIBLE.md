# WORLD & EXPLORATION DESIGN BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. O CONCEITO DO HUB WORLD (LOBBY ≠ MENU)

O **Lobby** do Hunter Online é uma **cidade jogável completa** (Hunter Plaza), e não uma simples tela de menu:
- O jogador se movimenta livremente, interage com civis, comerciantes, guardas e outros Hunters.
- Acessa lojas de suprimentos, correios, quadros de recompensa e o dojo de treino.
- Interage com o **Story Gateway NPC** para despachar para a campanha principal.
- É o ponto obrigatório de renascimento e de inicialização de todo save carregado.

---

## 2. MAPA DO MUNDO E REGIÕES CONECTADAS

O mundo é estruturado como um arquipélago de regiões conectadas por rotas, trens e portões dimensionais:

```text
                             [HUNTER PLAZA]
                           (Hub World Central)
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         │                          │                          │
   [CIDADE DE ZABAN]       [ROTA DA FLORESTA]         [ARENA CELESTIAL]
  • Exame Hunter 287        • Pântano Numere           • Ringues 1 a 190
  • Porto de Dolle          • Bichos Mágicos           • Dojo do 200º Andar (Wing)
         │                          │                          │
         └──────────────────────────┼──────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
           [MONTANHA KUKUROO]               [YORKNEW CITY]
          • Portão da Verificação          • Leilão Subterrâneo
          • Mansão dos Zoldyck             • Cemitério & Trupe Fantasma
                    │                               │
                    └───────────────┬───────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
            [GREED ISLAND]                  [NGL & PALÁCIO]
          • Planícies e Cidades            • Ninho das Formigas Chimera
          • Mestra Biscuit Krueger         • Campo de Batalha Real
```

---

## 3. TRANSIÇÃO ENTRE CENAS (SCENE TRANSITION)

- Se uma região atingir alta complexidade de colisões ou nós de renderização, ela é dividida em sub-cenas conectadas por `MapTransitionArea`.
- A transição deve ser instantânea, com tela de carregamento estilizada (`SceneTransition`), sem perda de dados ou duplicação de entidades.
- A reconciliação de posição no spawn point da nova área é garantida por `WorldProgressionManager.posicionar_player_no_spawn()`.

---

## 4. PERSISTÊNCIA DO ESTADO DO MUNDO (WORLD STATE)

O `WorldState` rastreia:
- Portas e atalhos desbloqueados.
- Baús e colecionáveis abertos.
- Chefes mundiais derrotados.
- Lojas e NPCs resgatados.
Essas flags são organizadas por região e não poluem as variáveis globais da história principal.

---

## 5. PADRÃO CANÔNICO DE COLISÃO FOOTPRINT (BASE FÍSICA VS PADDING)

Para garantir que o jogador possa caminhar rente a portas e paredes sem barreiras invisíveis:
- **Proibição de Colisão em Padding:** Sprites e tilesets com transparência inferior/superior não devem conter polígonos de colisão física nas faixas vazias.
- **Fundação Real (Footprint):** A física de edificações é aplicada exclusivamente na última linha sólida de fundação (altura de $8$ a $12\,\text{px}$, base de $Y=-2$ a $Y=+8$).
- **Y-Sorting Canônico:** A base do pé do jogador e a base da parede determinam a profundidade z-index, permitindo passar atrás e na frente das estruturas naturalmente.
- **Eliminação de Duplicatas:** Corpos estáticos duplicados e deslocados em código (`ColisoesEstruturasLobby`) são terminantemente banidos em favor do `TileMapLayer` com camada física nativa.

---

## 6. MAPAS CONECTADOS PERMANENTES (EXPANSÃO DE PADOKIA)

1. **Estrada Real de Padokia (`estrada_padokia.tscn`):**
   - Rota comercial imperial entre a Capital e a região selvagem.
   - Ponto Norte: Portão Sul do Lobby (`from_world`).
   - Ponto Sul: Entrada da Floresta dos Vestígios (`from_estrada`).
   - POIs: Fogueira de Descanso de Caçador (cura de HP/Aura), Marco de Pedra da Associação, Posto de Patrulha Hunter (NPC de alerta).
2. **Floresta dos Vestígios (`floresta_vestigios.tscn`):**
   - Zona selvagem ancestral densa e contígua à estrada.
   - Ponto Norte: Estrada Real de Padokia (`from_floresta`).
   - Ponto Sul: Dungeon das Ruínas Ancestrais de Zaban (`entrada`).
   - POIs: Árvore Milenar Sagrada (meditação e recarga de Nen), Rocha Fraturada KoObstacle (requer Ko para liberar atalho), Bestas de Sombra.

---

## 7. MATRIZ DE PORTAIS BIDIRECIONAIS

```text
[LOBBY / CAPITAL] (world/lobby.tscn)
        ↕ Portão Sul [E] / Spawn: from_world
[ESTRADA REAL DE PADOKIA] (world/maps/estrada_padokia.tscn)
        ↕ Portão Sul [E] / Spawn: from_estrada
[FLORESTA DOS VESTÍGIOS] (world/maps/floresta_vestigios.tscn)
        ↕ Entrada da Cripta [E] / Spawn: default
[RUÍNAS ANCESTRAIS DE ZABAN] (world/maps/dungeon_ruinas_zaban.tscn)
```
- Cada mapa conectado é permanente, funcional e possui spawn points dedicados, impedindo loops ou perdas de posicionamento.

