# GAME VISION ALIGNMENT REPORT
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

> **Data da Auditoria:** 2026-09-03  
> **Status Geral do Projeto:** Em Transição Arquitetural para RPG Clássico 2D / MMORPG  
> **Referência de Design:** Master Prompt — Hunter Online Definitive Direction

---

## 1. RESUMO EXECUTIVO

Esta auditoria compara rigorosamente a base de código herdada com a nova **Fonte de Verdade de Design** estabelecida para o Hunter Online:
- **Abandono do conceito "Dragon Ball Xenoverse":** O jogo não é mais uma colagem de missões isoladas que interferem no anime.
- **Identidade Própria:** O protagonista é o jogador ("Eu sou um Hunter dentro desse mundo").
- **Mundo Conectado:** O Lobby é um **Hub World** jogável de onde partem explorações, lojas, facções, side quests e o Story Mode.
- **Save & Checkpoint:** Carregar jogo sempre posiciona o jogador no Hub World; o Story Mode é retomado conversando com o **Story Gateway NPC**.
- **Nen 100% Passivo:** Técnicas como Ten, Ren, Zetsu e Gyo são modificadores passivos permanentes investidos na **Skill Tree** com Skill Points de Level Up (+1 SP por nível).
- **Hatsu 100% Ativo:** Hatsu opera como magias/skills ativas de RPG (Slots 1 a 4) com custos de Aura, cooldown e alcance tático.

---

## 2. MATRIZ DE ALINHAMENTO POR SUBSISTEMA

| Item da Visão | Estado Atual do Código | Status | Gap Identificado | Alteração Obrigatória |
| :--- | :--- | :--- | :--- | :--- |
| **1. Identidade de RPG 2D Clássico** | Estrutura de mapas em nós 2D com movimentação, HUD e menus. | `PARTIALLY ALIGNED` | Resquícios de progressão linear e menus que operavam como telas isoladas. | Unificar fluxo de mundo aberto interconectado com cidades e rotas. |
| **2. Lobby como Hub World Central** | `world/lobby.tscn` possui NPCs e praça central. | `ALIGNED` | O carregamento de save abria diretamente o mapa onde o jogador salvou (inclusive arenas). | Forçar save/load a sempre inicializar no Hub World (`res://world/lobby.tscn`). |
| **3. Story Checkpoint System** | `StoryManager` gerencia sagas (1-9) e capítulos. | `PARTIALLY ALIGNED` | Faltava granularidade de checkpoints nomeados e `Last Safe Checkpoint`. | Adicionar catálogo de checkpoints formais com destino, spawn e estado seguro. |
| **4. Story Gateway NPC** | Diálogos dispersos entre Elena e portais avulsos. | `OUTDATED` | Ausência de um NPC exclusivo que funcione como portal de despacho da história. | Criar `StoryGatewayNPC.gd` no Lobby para coordenar a continuação do Story Checkpoint. |
| **5. Combate: Ataque Básico** | Ataque básico funcional em `Player.gd` com velocidade/cooldown. | `ALIGNED` | Nenhum gap estrutural. | Preservar ataque básico como núcleo físico sem depender de ativação de Nen. |
| **6. Hatsu: Skills Ativas (1-4)** | `HatsuSystem.gd` possui 4 slots disparados por teclas 1 a 4. | `PARTIALLY ALIGNED` | O sistema exigia ativação manual prévia de Ten/Ren via teclado para liberar certos golpes. | Desacoplar dos botões de Ten/Ren; verificar apenas se a proficiência passiva está destravada. |
| **7. Nen: Filosofia Passiva** | `NenSystem.gd` escutava teclas físicas (T, R, G, K) em `_physics_process()`. | `OUTDATED` | Contradição frontal com a visão: o jogador tinha que ficar segurando teclas de stance. | **REMOVER** teclas ativas de Nen; transformar todas as técnicas em modificadores passivos contínuos. |
| **8. Level Up & Skill Points (+1 SP)** | `XPSystem.gd` adiciona +1 `nen_skill_points` por nível e emite sinal. | `ALIGNED` | Sincronização direta com a Skill Tree. | Garantir que subir de nível abra a possibilidade de alocar pontos na Skill Tree sem atrito. |
| **9. Nen Skill Tree** | `NenSkillTree.gd` contém 11 categorias de nós e aplica modificadores. | `ALIGNED` | Validação de autoridade: garantir que a UI apenas apresente e não valide nós. | Manter a Skill Tree como autoridade central de cálculo e concessão de buffs passivos. |
| **10. Facções & Reputação** | `FactionManager.gd` (6 facções) e `ReputationSystem.gd` (-1000 a +1000). | `ALIGNED` | Persistência entre sessões precisava ser blindada no SaveManager. | Conectar dados de reputação formalmente ao dicionário de save e aos lojistas do Hub. |
| **11. Side Quests Independentes** | `QuestManager.gd` suporta quests paralelas. | `PARTIALLY ALIGNED` | O avanço de capítulos da história por vezes limpava ou misturava objetivos. | Isolar `MissionInstance` para que Side Quests coexistam sem conflito com a Main Story. |
| **12. World Beyond Story** | Mapas como Hunter Exam, Arena Celestial, Kukuroo e Yorknew. | `PARTIALLY ALIGNED` | Alguns mapas eram acessíveis apenas durante o Story Mode estrito. | Permitir retorno a áreas já desbloqueadas via rotas e estações do Hub World. |
| **13. Save Atomic & Sanitization** | `SaveManager.gd` grava `.tmp`, `.bak` e `.json` com `save_version = 1`. | `ALIGNED` | Mapa padrão precisa ser sempre o Lobby. | Garantir inicialização no Hub e persistência de checkpoints narrativos. |
| **14. Protagonista do Jogador** | Personagem com nome customizável, afinidade sorteada e cores. | `ALIGNED` | Nenhum gap estrutural. | Preservar identidade única do Hunter criado pelo jogador. |

---

## 3. PLANO DE AÇÃO IMEDIATO

1. **Atualização da Documentação (`docs/bibles/`):**
   - Criação das 9 Bibles técnicas obrigatórias refletindo a nova direção canônica.
2. **Refatoração do NenSystem:**
   - Eliminação completa de `Input.is_key_pressed(KEY_T/R/G/K)`.
   - Modificadores contínuos aplicados através da `NenSkillTree`.
3. **Refatoração do HatsuSystem:**
   - Remoção de checagens de stances ativas; execução direta como Skills ativas com custo de Aura.
4. **Implementação do Story Gateway NPC & Checkpoint System:**
   - Adicionar checkpoints formais em `StoryManager.gd`.
   - Adicionar `StoryGatewayNPC` na praça central do Lobby.
   - Forçar `SaveManager` a sempre iniciar no Lobby ao carregar qualquer slot.
5. **Validação Automatizada:**
   - Criação e execução de `test_game_vision_suite.gd`.
