# GAME EXPERIENCE AUDIT — HUNTER ONLINE
## Auditoria Técnica e Narrativa da Experiência do Jogador (Fase F)

> **Data de Realização**: Setembro de 2026  
> **Classificação de Status**: `IMPLEMENTED` | `PARTIAL` | `ABSENT` | `LEGACY` | `CONFLICT`  
> **Níveis de Prioridade**: `PRIORITY S` (Crítico/Base) | `PRIORITY A` (Essencial) | `PRIORITY B` (Refinamento) | `PRIORITY C` (Endgame/Expansão)

---

### 1. Story Mode
- **Status**: `PARTIAL`
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - `autoload/StoryManager.gd` possui o catálogo das 9 Sagas Canônicas e checkpoints para os arcos.
  - O catálogo `CanonQuestCatalog.gd` tem 254 etapas catalogadas.
  - **Lacuna**: Falta de orquestração de ritmo entre gameplay, diálogo, cutscene, treinamento e respiro. A alternância ainda dependia de transições de cena abruptas ou checkpoints estáticos.
  - **Ação**: Implementar `StoryState` com estados de ritmo (Exploração, Diálogo, Cutscene, Combate, Treinamento, Respiro) e checkpoints contextuais com causalidade.

---

### 2. Cutscenes e Diálogos
- **Status**: `PARTIAL`
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - `autoload/CinematicManager.gd` gerencia letterbox preto e Manga Splash Cards com apresentação visual estilizada de personagens (Hisoka, Chrollo, Netero, etc.).
  - `scripts/cutscenes/StoryCutsceneManager.gd` possui sequências narrativas com múltiplos personagens e balões de fala, mas estava estruturado com rotinas estáticas hardcoded por saga (`executar_maratona_hunter`, `executar_pantanal_hisoka`).
  - **Lacuna**: Ausência de um motor genérico de cutscenes data-driven (`CutsceneSequenceRunner`) com passos reutilizáveis (mover atores, câmera/zoom/shake, diálogos, escolhas e devolução de controle).
  - **Ação**: Criar `CutsceneSequenceRunner.gd` unificado e data-driven.

---

### 3. DialogueBox
- **Status**: `IMPLEMENTED`
- **Prioridade**: `PRIORITY A`
- **Diagnóstico Técnico**:
  - `ui/dialogue/DialogueBox.gd` e `scripts/dialogue/DialogueSystem.gd` implementam caixa de diálogo com suporte a `DialogueTree`, `DialogueNode`, `DialogueBranch` (múltipla escolha) e estilização de tema `HunterUIStyle`.
  - Conecta com balões de mangá `ComicBalloon.gd` para falas rápidas de campo.
  - **Ação**: Integrar a `DialogueBox` diretamente ao novo motor de cutscenes e checkpoints de escolhas narrativas.

---

### 4. Quests e Objetivos
- **Status**: `IMPLEMENTED`
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - `scripts/QuestManager.gd`, `Quest.gd`, `QuestObjective.gd` e `QuestReward.gd` operam com reconciliação de monstros no mapa, objetivos múltiplos (Talk, Kill, Deliver, Explore), tracking de progresso e persistência.
  - **Ação**: Manter estrutura e integrar com a nova hierarquia de objetivos no HUD.

---

### 5. Quest Tracker (HUD)
- **Status**: `PARTIAL`
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - `ui/hud/QuestHUD.gd` exibe a saga ativa, nome da quest, objetivo imediato e bússola cardinal com distância.
  - **Lacuna**: Falta a separação categórica mandatada pela Seção 5 de `FASE_F_ALMA_DO_JOGO.md`: visualização clara de `HISTÓRIA PRINCIPAL` com barra de progresso em percentual (`[██████░░░░] 60%`) e seção de `ATIVIDADES` secundárias (Treinamento, Side Quests, Exploração, Eventos, Hatsu).
  - **Ação**: Atualizar `QuestHUD.gd` para acomodar hierarquia em dois blocos.

---

### 6. NPCs e Living World
- **Status**: `PARTIAL`
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - `entities/npc/LivingNPCBehavior.gd` adiciona badges com ícone/cargo, patrulha com pausas, rumores de vilas e reação a fases do dia (`MORNING`, `DAY`, `EVENING`, `NIGHT`).
  - Diversos NPCs presentes: Gon, Killua, Kurapika, Leorio, Hisoka, Satotz, Menchi, Wing, Zushi, Biscuit, Netero, etc.
  - **Lacuna**: Falta de rotinas entre posições específicas de mapa (schedules de caminho), reação contextual a escolhas do protagonista e suporte a sessões de treinamento direto com instrutores.
  - **Ação**: Expandir `LivingNPCBehavior.gd` com waypoints de rotina, memória contextual e treinamento.

---

### 7. Mapas, Portais e Transições
- **Status**: `PARTIAL`
- **Prioridade**: `PRIORITY A`
- **Diagnóstico Técnico**:
  - `world/maps/` contém mapas para as sagas (`exame_maratona.tscn`, `montanha_kukuroo.tscn`, `arena_celestial.tscn`, `yorknew_city.tscn`, `greed_island.tscn`, `ngl_formigas.tscn`).
  - `autoload/SceneTransition.gd` executa fade out, title card e fade in.
  - `StoryGate.gd` impede bypass de arcos sem pré-requisitos.
  - **Lacuna**: Transições puramente instantâneas/teleportes sem a sensação de viagem, estradas e pequenos eventos de caminho prescritos na Seção 19.
  - **Ação**: Introduzir `StoryPacingManager.gd` com eventos de viagem e transições graduais.

---

### 8. Lobby (Hub World)
- **Status**: `IMPLEMENTED`
- **Prioridade**: `PRIORITY A`
- **Diagnóstico Técnico**:
  - `world/Lobby.gd` e `world/lobby.tscn` atuam como centro social persistente (Praça Central dos Caçadores), com Elena, quadro de bounties, ferreiro, estátua de Netero e portais.
  - **Ação**: Preservar como hub persistente e ponto de retorno após arcos.

---

### 9. Combate (Filosofia 2D em Tempo Real)
- **Status**: `PARTIAL`
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - `autoload/CombatEngine.gd` provê pipeline central de dano, defesa, mitigação por Ten passivo, fraquezas/resistências elementais e multiplicadores de Nen.
  - `scripts/combat/CombatSystem.gd` possui combo de 3 golpes, esquiva com i-frames, perfect dodge com contra-ataque.
  - **Lacunas**:
    1. Falta de ataque forte e lento (`ataque_pesado`) com telegrafia e quebra de postura/escudo.
    2. Inimigos necessitam de arquétipos comportamentais explícitos: `Brute`, `Assassin`, `Ranged`, `Tactician`, `Nen User` e `Boss`.
  - **Ação**: Implementar `tentar_ataque_pesado` no jogador e os 6 arquétipos em `EnemyAI.gd`.

---

### 10. Hatsu
- **Status**: `IMPLEMENTED` (Jogador) / `PARTIAL` (Inimigos)
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - `resource/hatsu/HatsuData.gd` contempla 10 grandes arquétipos, Power Budget Engine, 3 Tiers de Vows & Limitations e progressão até Lv. 100.
  - `scripts/systems/HatsuSystem.gd` suporta 4 slots com ativação instantânea, canalizada e sustentada, além de restrições em tempo real.
  - `autoload/HatsuProgressionManager.gd` desbloqueia os 4 slots estritamente por pré-requisitos canônicos (Slot 1 em Greed Island; Slots 2, 3 e 4 nos níveis 600, 800 e 1000).
  - **Lacuna**: Inimigos possuem `obter_hatsu_real()` em `EnemyData.gd`, mas a IA não executava o Hatsu pelo motor central do jogo.
  - **Ação**: Integrar disparo de `HatsuData` por inimigos através de `EnemyAI.gd`.

---

### 11. Nen Skill Tree
- **Status**: `IMPLEMENTED`
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - 437 nós divididos em 10 regiões temáticas na constelação de Nen.
  - 8 caminhos principais derivados de Nen.
  - Funcionamento estritamente passivo (sem toggles manuais).
  - Validado com 29/29 testes automatizados aprovados em `test_skill_tree_massive_suite.tscn`.
  - **Ação**: Preservar integralmente como fonte de verdade passiva de Nen.

---

### 12. Save / Load
- **Status**: `IMPLEMENTED`
- **Prioridade**: `PRIORITY A`
- **Diagnóstico Técnico**:
  - `autoload/SaveManager.gd` persiste dados de `PlayerData`, atributos, inventário, Nen Skill Tree, Hatsu slots e flags mundiais.
  - **Ação**: Garantir sincronização contínua com novos campos de `StoryState` e escolhas narrativas.

---

### 13. Progressão Multifatorial
- **Status**: `PARTIAL`
- **Prioridade**: `PRIORITY A`
- **Diagnóstico Técnico**:
  - Curva de XP e níveis até 1000 em `ProgressionConfig.gd`.
  - Progressão de atributos, maestria de Hatsu e nós de Nen.
  - **Lacuna**: Falta de sistema formal de sessões de treinamento com mestres (Wing, Biscuit, Dojos) que forneça melhorias permanentes fora do farm de monstros.
  - **Ação**: Implementar `TrainingSystem.gd`.

---

### 14. Câmera
- **Status**: `PARTIAL`
- **Prioridade**: `PRIORITY A`
- **Diagnóstico Técnico**:
  - `Camera2D` anexada ao jogador com suavização e trauma de screen shake.
  - **Lacuna**: Ausência de controlador cinematográfico dedicado para transitar o foco suavemente do jogador para NPCs ou pontos de interesse durante cutscenes e diálogos.
  - **Ação**: Implementar `CinematicCameraController.gd`.

---

### 15. Áudio, Música e Efeitos
- **Status**: `IMPLEMENTED`
- **Prioridade**: `PRIORITY B`
- **Diagnóstico Técnico**:
  - `autoload/AudioManager.gd` e `AudioSynth.gd` possuem 28 faixas canônicas catalogadas e geração procedural de efeitos de impacto, passos e auras.
  - **Ação**: Conectar gatilhos de áudio nas etapas do `CutsceneSequenceRunner`.

---

### 16. Triggers e Flags
- **Status**: `IMPLEMENTED`
- **Prioridade**: `PRIORITY S`
- **Diagnóstico Técnico**:
  - `StoryManager.set_story_flag()` e `WorldState.definir_flag_regional()` gerenciam causalidade no mundo.
  - **Ação**: Mapear flags de escolhas éticas do protagonista e consequências no Vertical Slice.

---

### Resumo Executivo da Auditoria

| Item | Status | Prioridade | Próxima Ação |
|---|---|---|---|
| **Story Mode** | `PARTIAL` | S | Criar estados de StoryState no StoryManager |
| **Cutscenes / Diálogos** | `PARTIAL` | S | Implementar CutsceneSequenceRunner genérico |
| **DialogueBox** | `IMPLEMENTED` | A | Integrar com escolhas de cutscene |
| **Quests e Objetivos** | `IMPLEMENTED` | S | Integrar com tracker hierárquico |
| **Quest Tracker** | `PARTIAL` | S | Reformular HUD com História Principal % vs Atividades |
| **NPCs & Living World** | `PARTIAL` | S | Rotinas, memória contextual e treinamento |
| **Mapas e Transições** | `PARTIAL` | A | Adicionar eventos de viagem e travessia |
| **Lobby** | `IMPLEMENTED` | A | Preservar como Hub principal |
| **Combate** | `PARTIAL` | S | Ataque pesado + 6 arquétipos de IA |
| **Hatsu** | `PARTIAL` | S | Ativação de HatsuData por inimigos via EnemyAI |
| **Nen Skill Tree** | `IMPLEMENTED` | S | Preservar 100% passivo (437 nós) |
| **Save / Load** | `IMPLEMENTED` | A | Serializar escolhas e StoryState |
| **Progressão** | `PARTIAL` | A | Implementar TrainingSystem com mestres |
| **Câmera** | `PARTIAL` | A | Criar CinematicCameraController |
| **Áudio / SFX** | `IMPLEMENTED` | B | Conectar com novas cutscenes |
| **Triggers e Flags** | `IMPLEMENTED` | S | Mapear consequências narrativas |
