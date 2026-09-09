# STORY SYSTEM ARCHITECTURE
## HUNTER ONLINE — SAGA, CHAPTER & CANONICAL PROGRESSION

### 1. Visão Geral
O `StoryManager` é o único detentor canônico da progressão narrativa do jogador, operando como a **Single Source of Truth** para Sagas, Capítulos, Missões Principais e Story Gates.

### 2. Hierarquia Estrutural
```text
Story
 └── Saga (Arco Canônico 1 a 9)
      └── Chapter (Etapa do Arco: 18 a 48 capítulos)
           └── Mission (Missão Ativa da Etapa)
                ├── Objectives (Array de QuestObjective)
                ├── Dialogue (Sequência visual ou cinemática)
                ├── Conditions (StoryGate e requisitos de nível/Nen)
                ├── Rewards (XP, Nen XP, Jenny, SP, Licença)
                └── Completion (Avanço atômico da etapa)
```

### 3. Arcos Canônicos Oficiais
1. **Arco 1:** 287º Exame Hunter (24 etapas)
2. **Arco 2:** Montanha Kukuroo & Família Zoldyck (18 etapas)
3. **Arco 3:** Arena Celestial & Despertar do Nen (26 etapas)
4. **Arco 4:** Yorknew City & Trupe Fantasma (34 etapas)
5. **Arco 5:** Greed Island & Treino de Biscuit (36 etapas)
6. **Arco 6:** Formigas Chimera & NGL (48 etapas)
7. **Arco 7:** Eleição do 13º Presidente Hunter & Alluka (20 etapas)
8. **Arco 8:** Expedição ao Continente Negro & Árvore do Mundo (22 etapas)
9. **Arco 9:** Guerra de Sucessão de Kakin & Black Whale 1 (26 etapas)

### 4. Regras Anti-Bypass
* Nenhuma entidade (portal, NPC, gatilho de cena) pode avançar arcos ou liberar passagens sem a aprovação do `StoryManager`.
* Se o jogador tentar forçar passagem para um mapa posterior, o `StoryGate` consulta `StoryManager.pode_avancar()` e exibe uma lista formatada de pendências para o jogador.
