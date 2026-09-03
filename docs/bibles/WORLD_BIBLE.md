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
