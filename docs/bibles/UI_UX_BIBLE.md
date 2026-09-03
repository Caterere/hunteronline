# UI / UX DESIGN BIBLE
## HUNTER ONLINE — HUD, INTERFACES, GPS & PLAYER READABILITY

---

## 1. O PRINCÍPIO DA CLAREZA VISUAL

> **"A interface deve permitir que o jogador compreenda sua condição, seus recursos e seu objetivo em menos de um segundo, sem poluir a tela com texto técnico desnecessário."**

---

## 2. O LAYOUT DA HUD DE COMBATE

A HUD é organizada em 4 zonas cardeais periféricas, liberando o centro da tela para o gameplay:

```text
┌────────────────────────────────────────────────────────┐
│ [SUPERIOR ESQUERDO]               [SUPERIOR DIREITO]   │
│ - Retrato do Hunter               - Mini-mapa Circular │
│ - Barra de Vida (HP - Verde)      - GPS de Missão Ativa│
│ - Barra de Aura (Nen - Ciano)     - Relógio Solar / Dia│
│ - Nível e Skill Points disponíveis                     │
│                                                        │
│                                                        │
│                    [CENTRO DE JOGO]                    │
│                                                        │
│                                                        │
│ [INFERIOR ESQUERDO]               [INFERIOR DIREITO]   │
│ - Ícones de Técnicas Ativas:      - Slots de Hatsu:    │
│   [Z] Zetsu  [X] En  [G] Gyo        [1] [2] [3] [4]    │
│ - Badges de Passivos (Ten/Ren)    - Ataque Básico      │
└────────────────────────────────────────────────────────┘
```

---

## 3. GPS DE MISSÃO E NAVEGAÇÃO CONTEXTUAL

O jogador nunca deve ficar perdido sem saber para onde ir:
1. **Marcador de Bússola:** Seta direcional discreta no topo da tela apontando para o objetivo da missão ativa.
2. **Distância em Tempo Real:** Exibição da metragem até o próximo NPC ou área de checkpoint.
3. **Indicador Visual no Alvo:** Círculo pontilhado de aura ou ícone flutuante sobre o NPC ou portão de história.

---

## 4. FEEDBACK DE TÉCNICAS ATIVAS DE NEN

- **Zetsu Ativo:** Bordas da tela recebem uma vinheta acinzentada suave; o sprite do jogador fica levemente translúcido (alpha 0.70). O ícone [Z] acende em verde esmeralda.
- **En Ativo:** Cúpula de aura translúcida pulsante ao redor do jogador; monstros no raio exibem o ícone de intimidação sobre a cabeça. O ícone [X] acende em ciano radiante.
- **Gyo Ativo:** Olhos do caçador emitem brilho focado; elementos do grupo `gyo_inspectable` compatíveis tornam-se nítidos e reluzentes com partículas. O ícone [G] acende em âmbar dourado.
