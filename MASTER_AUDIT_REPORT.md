# MASTER AUDIT REPORT — HUNTER MMORPG
## FULL PROJECT AUDIT, REFACTOR & REBUILD REPORT

**Project:** Hunter Online (Godot 4.4 / 4.6 Forward Plus)  
**Lead Game Architect & Technical Director**  
**Delivery:** FASE 2 — Audit & Diagnostic Deliverable

---

### 1. ESTADO ATUAL DO PROJETO
O projeto possui implementações extensas de gameplay (combate ágil, técnicas de Nen, Hatsu modular, 9 arcos canônicos, 254 etapas de história, 3 slots de save e múltiplos mapas mundiais). Contudo, a evolução do código ocorreu através de acréscimos incrementais de scripts e autoloads sem um pipeline centralizado de ciclo de vida, gerando duplicações, acoplamentos diretos entre UI e lógica e dependência de nós estáticos nas cenas.

---

### 2. ARQUITETURA ENCONTRADA
* **Autoloads Globais:** 32 autoloads registrados em `project.godot`.
* **Fluxo de Dados:** Bidirecional e circular em vários pontos (ex: nós de UI lendo e escrevendo diretamente em `PlayerData`, NPCs manipulando estados de quest diretamente).
* **Nível de Separação:**
  - `PlayerData` atua tanto como perfil de jogador quanto como controlador narrativo de arcos.
  - `QuestManager` gerencia abates e diálogos, mas sem instâncias isoladas de missões.
  - Cenas de mapas (`ExameMaratonaMap`, `ArenaCelestialMap`) manipulam nós de inimigos diretamente em seus scripts locais.

---

### 3. SISTEMAS EXISTENTES
* **Core:** GameManager, DataManager, SaveManager, EventBus, TimeManager, AudioManager, SceneTransition, PlaytestTelemetry, InputContextManager, DamageNumberSystem.
* **Gameplay:** PlayerData, CombatEngine, NenSystem, NenSkillTree, HatsuManager, NenBeastManager, Economy, ReputationSystem, FactionManager, AchievementSystem.
* **World & Narrative:** QuestSystem, CanonQuestCatalog, StoryGate, MapTransitionArea, StoryCutsceneManager, TutorialManager, WorldState, WorldProgressionManager.

---

### 4. SISTEMAS DUPLICADOS
1. **Criação de Personagem:** `ui/CharacterSelection/CharacterSelectionUI.gd` (sistema moderno de 3 slots) vs `ui/CharacterCreation/CharacterCreationUI.gd` (legado que força slot 1).
2. **Sistemas de Diálogo:** `scripts/dialogue/DialogueSystem.gd` (embutido na cena do Player) vs `ui/dialogue/VisualDialogueUI.gd` (CanvasLayer) vs balões de fala em `NPC.gd`.
3. **Persistência / Proxy:** `autoload/GameState.gd` apenas repassa chamadas para `SaveManager.salvar_jogo()`.
4. **Hatsu:** `scripts/systems/HatsuSystem.gd` (62 KB no Player) e `autoload/HatsuManager.gd` (67 KB global) possuem responsabilidades sobrepostas de banco de dados e execução.

---

### 5. SISTEMAS QUEBRADOS OU INCOMPLETOS
1. **Spawn & Respawn de Monstros:** Inimigos em mapas estáticos morrem com `enemy_body.queue_free()` e não possuem rotina de renascimento.
2. **Fighters da Arena Celestial:** `LutadorArena1`, `LutadorArena2`, `LutadorArena3`, `LutadorArena4` constam no código de `ArenaCelestialMap.gd`, mas **não existem** no `.tscn` de `arena_celestial.tscn`.
3. **Objetivo do Teste da Água:** Etapa 10 do Arco 3 exige investigar `&"teste_agua_wing"`, mas o objeto interativo não existe na cena.
4. **Diálogo de Elena no Tutorial:** Etapas intermediárias do tutorial (`MOVIMENTACAO`, `MENU_ABRIR`, etc.) não possuem tratador no `match`, travando `_interacao_em_processamento` em `true`.
5. **Pré-requisito de Biscuit:** Exige conclusão do Arco 5 antes de abrir diálogo de treino dentro do próprio Arco 5 em Greed Island.

---

### 6. BUGS ENCONTRADOS (CLASSIFICAÇÃO POR CATEGORIA)
* **[BUG-TUT-01]** Tutorial trava em loop quando o jogador fala com Elena durante passos de movimentação ou abertura de menu.
* **[BUG-EXM-02]** GPS de missão aponta para coordenadas nulas quando monstros do exame são eliminados.
* **[BUG-ARN-03]** Andares 1 a 190 da Arena Celestial não iniciam lutas devido à ausência física dos nós `LutadorArena1..4`.
* **[BUG-ARN-04]** Teste da Água de Mestre Wing na etapa 10 é bloqueado permanentemente por ausência de alvo interativo.
* **[BUG-HTS-05]** Biscuit Krueger bloqueia a forja de Hatsu durante o treinamento de Greed Island por inconsistência de flag de arco.
* **[BUG-SAV-06]** Telas de save falham ao carregar slots corrompidos ou criados pelo script legado `CharacterCreationUI.gd`.

---

### 7. CAUSAS-RAIZ
* Falta de **Single Source of Truth** na narrativa: múltiplos componentes decidem quando o arco avança.
* Falta de um **SpawnManager desacoplado**: nós de monstros colocados soltos na cena sem temporizador ou spawner.
* Ambiguidade no ciclo de vida de **Mission Instance**: missões alteram diretamente o mundo estático sem instanciamento isolado.

---

### 8. DEPENDÊNCIAS
* `QuestHUD` -> `QuestSystem` -> `PlayerData.arco_atual` -> `CanonQuestCatalog`.
* `TargetHUD` -> `EnemySystem` / `EnemyData`.
* `DamageNumberSystem` -> `EventBus` / `CombatEngine`.
* `SaveManager` -> `PlayerData` -> `FileAccess`.

---

### 9. RISCOS
* **Risco de Regressão em Saves:** Mudar a estrutura de dados sem versionamento pode invalidar slots existentes.
* **Risco de Ruptura de Sinais:** Desconectar autoloads pode quebrar listeners silenciosos caso não haja um barramento consolidado.

---

### 10. DÍVIDA TÉCNICA
* Acúmulo de scripts prototípicos não removidos (`scripts/systems/dialogue/`, `CharacterCreationUI.gd`, `GameState.gd`).
* Falta de classes Resource formais para `MissionInstance` e `SpawnPoint`.

---

### 11. SISTEMAS QUE PRECISAM SER REFEITOS OU REESTRUTURADOS
1. **Story Mode & Quest Flow:** Criação de `StoryManager` canônico desacoplado de `PlayerData`.
2. **Spawn System:** Criação de `SpawnManager` com separação explícita de `World Spawn` vs `Mission Spawn`.
3. **Instâncias de Missão:** Isolamento de ciclo de vida (`MissionInstance`) para reset limpo e prevenção de vazamento.
4. **NPC Interaction Pipeline:** Padronização do fluxo de interação em um único componente central.

---

### 12. SISTEMAS QUE PODEM SER PRESERVADOS
1. **Design System & UI Style:** `HunterUIStyle.gd` recém-centralizado com tipografia canônica e StyleBoxes.
2. **Status Menu RPG:** Reconstrução em 3 colunas (Atributos, Maestria e Licença Hunter).
3. **ConditionTrackerUI:** Componente modular de rastreamento de condições.
4. **DamageNumberSystem:** Floating combat text com animação de tween e fade out.
5. **CombatEngine & Fórmulas de Dano:** Mitigação canônica de Ten, Ren, Gyo, Ko e Ryu.
6. **SaveManager:** Gravação atômica com arquivo `.tmp` e backup `.bak`.

---

### 13. PLANO DE RECONSTRUÇÃO (ROADMAP ESTRUTURADO)
* **Etapa 1:** Remoção de código morto e consolidação dos Core Systems.
* **Etapa 2:** Implementação do `StoryManager` e data-driven `MissionInstance`.
* **Etapa 3:** Implementação do `SpawnManager` (World Spawn com timer + Mission Spawn vinculado).
* **Etapa 4:** Resolução das falhas de conteúdo nos mapas (Arena Celestial, Exame Hunter, Greed Island e Lobby).
* **Etapa 5:** Blindagem e integração do fluxo de Diálogos e Interação de NPCs.
* **Etapa 6:** Suíte de Testes Automatizados de Regressão.

---

### 14. ORDEM DE EXECUÇÃO
1. Core & Single Source of Truth (`StoryManager`, `SaveManager`)
2. Missões & Instâncias de Missão (`MissionInstance`, `ObjectiveData`)
3. Spawn & Ciclo de Vida de Inimigos (`SpawnManager`, `WorldSpawn`)
4. Correções de Mapas e Cenas (`arena_celestial.tscn`, `exame_maratona.tscn`, `Lobby.gd`)
5. Unificação de Diálogos de NPCs
6. Validação e Testes Automatizados no Godot 4.4

---

### 15. CRITÉRIOS DE VALIDAÇÃO
* O jogador cria um personagem, salva, fecha o jogo e restaura exatamente com 100% de integridade.
* O tutorial de Elena avança fluidamente sem loops nem travamentos.
* A Arena Celestial instancia e permite combater todos os lutadores dos andares 1 a 190 e completar o Teste da Água com Wing.
* Inimigos derrotados fora de missão renascem após o timer de respawn; inimigos de missão são limpos e resetados por instância.
* Portais bloqueiam passagens sem cumprir metas e liberam imediatamente ao atingir os objetivos.
