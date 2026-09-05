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

## 5. STREAMING HIERÁRQUICO & OTIMIZAÇÃO (64 CHUNKS)
- Mapas de mundo aberto contínuos (como o Vale de Padokia de 512x512 tiles / 8192x8192 px) são subdivididos em 64 chunks (8x8 de 64x64 tiles).
- Entidades distantes (> 480px do jogador) entram em estado dormente (física e IA suspensas) via distance culling no `LivingNPCBehavior` e `EnemyAI`.
- Spawners utilizam `WorldSpawner` para garantir recarga determinística sem memory leaks ou duplicação.

---

## 6. ECOLOGIA DE COMBATE & ARQUÉTIPOS VIVOS
- O bestiário canônico é dividido em famílias vivas (`BEAST`, `HUMANOID/BANDIT`, `ANCIENT CONSTRUCTS`, `NEN USERS`).
- Inimigos adotam 6 arquétipos de combate declarativos (`bruiser`, `fast`, `tank`, `ranged`, `tactician`, `ambusher`, `nen_user`).
- Chefes e Minibosses possuem 3 fases mecânicas orientadas a dados com telegrafia no chão, summons de suporte, sobrecarga de aura e falas de `BattlePersonality`.

---

## 7. ILUMINAÇÃO AMBIENTE & WEATHER ENGINE
- `TimeManager` governa as 4 fases solares (`DAWN`, `DAY`, `DUSK`, `NIGHT`).
- Mapas abertos aplicam modulação suave de luz através de `CanvasModulate`.
- `WorldStateManager` modula o clima (`LIMPO`, `CHUVA`, `NEBLINA`, `TEMPESTADE_AURA`), influenciando a velocidade de caminhada dos NPCs, rotinas de abrigo e visibilidade de Gyo.
- Horários e climas são integralmente persistidos no `SaveManager` (Schema 2.3).

---

## 8. MATRIZ DE STATUS DE IMPLEMENTAÇÃO (FASE J)

| Subsistema de Mundo | Status | Detalhes & Componentes |
| :--- | :--- | :--- |
| **Hunter Plaza Hub World** | `[IMPLEMENTED]` | `world/Lobby.tscn`, câmera clamped, folhas flutuantes |
| **Limites de Câmera Dinâmicos** | `[IMPLEMENTED]` | `Player.configurar_limites_camera()` por zona/mapa |
| **Partículas e Clima Ambiente** | `[IMPLEMENTED]` | Folhas no Lobby, chuva, neblina via `WorldStateManager` |
| **Passos Cadenciados por Piso** | `[IMPLEMENTED]` | Detecção de piso (grama, pedra, terra) com áudio |
| **Streaming de 64 Chunks** | `[IMPLEMENTED]` | Distance culling em `LivingNPCBehavior` e `EnemyAI` |
| **Ciclo Dia/Noite & Persistência**| `[IMPLEMENTED]` | `TimeManager`, persistido no Schema 2.3 |
| **Ruínas de Zaban (Dungeon)** | `[IMPLEMENTED]` | Conexão com Guardião Ancestral e setup_from_data |
| **Transição Suave de Cenas** | `[IMPLEMENTED]` | `SceneTransition.gd` com overlay e fade |
| **Interiores em Camadas (Dóris)**| `[IN PROGRESS]` | Transição de telhados transparentes sem trocar de cena |
| **Sistema de Trens & Rotas** | `[PLANNED]` | Viagem rápida com cutscenes curtas de viagem |
| **Continente Negro Procedural** | `[FUTURE]` | Biomas hostis infinitos com geração determinística de sementes |


