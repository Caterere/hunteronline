# MASTER ARCHITECTURE AUDIT & DIAGNOSTIC REPORT
## HUNTER ONLINE — 2D MMORPG / RPG CORE SYSTEMS RECONSTRUCTION

**Role:** Technical Director, Lead Game Architect, Senior Godot Engine Engineer  
**Project:** Hunter Online (Godot 4.4 / 4.6 Forward Plus)  
**Date:** 2026-09-03  
**Status:** COMPLETE SYSTEM AUDIT & ARCHITECTURAL FOUNDATION

---

## 1. ESTADO ATUAL DO PROJETO & RESUMO EXECUTIVO

O projeto **Hunter Online** possui uma vasta ambição narrativa e sistêmica inspirada no universo canônico de *Hunter x Hunter*, contemplando os 9 arcos da obra (254 etapas catalogadas), as 9 técnicas canônicas de Nen, criação modular de Hatsu, Bestas de Nen, 3 slots de persistência e múltiplos mapas mundiais.

Contudo, a auditoria detalhada da base de código revelou que o projeto sofre de **hipertrofia de autoloads desacoplados, fragmentação de fontes de verdade (Single Source of Truth violado), ausência de gerenciadores de ciclo de vida para spawns e instâncias de missão, e dependências frágeis entre nós visuais da cena e regras de gameplay**.

### Métricas Gerais da Auditoria
* **Autoloads em `project.godot`:** 32 singletons ativos (vários com responsabilidades redundantes ou overlapping).
* **Mapas do Mundo:** 13 mapas e arenas em `world/maps/`.
* **Cenas e Componentes:** ~50 `.tscn` e centenas de recursos `.gd` e `.tres`.
* **Concorrência de Sistemas:**
  - 3 sistemas concorrentes de diálogo (`DialogueSystem.gd` em `Player`, `VisualDialogueUI.gd` e balões overhead em `NPC.gd`).
  - 2 telas concorrentes de criação de personagem (`CharacterSelectionUI.gd` e `CharacterCreationUI.gd`).
  - Progressão de história diluída entre `PlayerData.arco_atual`, `PlayerData.etapa_quest_arco`, `QuestManager.active_quests`, `StoryGate.gd`, scripts locais de mapas (`ExameMaratonaMap.gd`, `ArenaCelestialMap.gd`) e switches manuais em NPCs.
  - Inimigos do mundo e da missão usam o mesmo ciclo de vida estático: ao morrer, executam `enemy_body.queue_free()` e desaparecem para sempre até que a cena seja reiniciada.

---

## 2. AUDITORIA DETALHADA POR SUBSISTEMA

### 2.1 Core Systems

| Sistema | Localização | Responsabilidade Atual | Dependências | Quem Altera Seus Dados | Problemas Identificados | Risco | Prioridade |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **GameManager** | `autoload/GameManager.gd` | Máquina de estados de alto nível (`GameFlowState`, `GameState`). | SceneTree | CharacterSelection, UI | Pouco utilizado pelo loop de gameplay real; estados de transição não bloqueiam inputs órfãos. | Médio | P2 |
| **DataManager** | `autoload/DataManager.gd` | Catálogo central estático de itens, equipamentos e inimigos. | ItemData, EnemyData | Nenhum (apenas leitura) | Bem estruturado, porém pouco consultado por spawner e quests (que instanciam recursos ad-hoc). | Baixo | P2 |
| **SaveManager** | `autoload/SaveManager.gd` | Persistência atômica em disco, backups `.bak`, sanitização de mapa. | PlayerData, FileAccess | PlayerData, UI, Quests | Depende da extração direta do nó do Player na cena para colher posição no momento exato do save. | Alto | P1 |
| **EventBus** | `autoload/EventBus.gd` | Desacoplamento de eventos globais de combate, toast, cutscene e UI. | Nenhum | CombatSystem, Quests, HUD | Muitos sinais órfãos sem tipagem estrita; risco de vazamento se nós dinâmicos conectarem lambdas sem disconnect. | Médio | P2 |
| **GameState** | `autoload/GameState.gd` | Proxy redundante que repassa chamadas para `SaveManager.salvar_jogo()`. | SaveManager | PlayerData, Quests | **Totalmente redundante.** Adiciona uma camada inútil de indireção sem valor funcional. | Baixo | P3 (Remover) |
| **TimeManager** | `autoload/TimeManager.gd` | Ciclo dia/noite e relógio de jogo. | WorldEnvironment | Tempo processado | Funcional, mas desvinculado dos gatilhos de spawn e condições de missões noturnas. | Baixo | P3 |
| **AudioManager** | `autoload/AudioManager.gd` | Reprodução de trilhas sonoras e efeitos de áudio. | AudioStreamPlayer | Cenas, UIs | Mapeamento hardcoded de caminhos de cena para faixas de música. | Baixo | P3 |

---

### 2.2 Gameplay Systems

| Sistema | Localização | Responsabilidade Atual | Problemas & Causa-Raiz | Risco | Prioridade |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **PlayerData** | `autoload/PlayerData.gd` | Armazena atributos, Nen, Hatsu, inventário, história, facções e estatísticas. | **Problema crítico de violação de responsabilidade única:** PlayerData acumula papel de banco de dados do jogador, controlador de história (`arco_atual`, `avancar_arco`), cálculo de combate e persistência. | Crítico | P0 |
| **QuestSystem / QuestManager** | `scripts/QuestManager.gd` & `autoload/QuestSystem` | Controle de missões ativas, abates de inimigos e avanço de etapas. | Não é data-driven puro; depende de `_obter_active_objective_idx` em runtime. Não possui conceito de **instância de missão** isolada. | Crítico | P0 |
| **Story Progression** | Espalhado (`PlayerData`, `QuestManager`, `StoryGate`, `Map scripts`) | Determina em qual arco/capítulo o jogador está e o que pode acessar. | **Não existe um StoryManager canônico.** A história é inferida pelo número do arco em `PlayerData.arco_atual`. NPCs checam números inteiros hardcoded. | Crítico | P0 |
| **CombatEngine & CombatSystem** | `autoload/CombatEngine.gd` & `scripts/combat/CombatSystem.gd` | Fórmulas de dano, mitigação de Ten, Ren, Ko, Ryu e esquiva. | O `CombatSystem` está acoplado ao nó do Player (`entities/Player/Player.tscn`). Feedback flutuante estava com chamadas instáveis de autoload. | Médio | P1 |
| **Nen & Hatsu Systems** | `scripts/systems/NenSystem.gd`, `HatsuSystem.gd`, `autoload/HatsuManager.gd` | Execução de técnicas de Nen e habilidades ativas/passivas. | Duplicação entre `scripts/systems/HatsuSystem.gd` (62KB) e `autoload/HatsuManager.gd` (67KB). Condições de roubo e créditos não são validadas de forma homogênea. | Alto | P1 |
| **Enemy & AI System** | `scripts/systems/EnemySystem/` | Comportamento de inimigos, hurtbox, knockback e drop. | Ao morrer (`die()`), executa `enemy_body.queue_free()`. Inimigos de mapa não possuem lógica de respawn, sumindo para sempre. | Crítico | P0 |
| **NPC & Diálogos** | `entities/npc/NPC.gd`, `ui/dialogue/VisualDialogueUI.gd` | Interações com NPCs, balões e caixas de diálogo. | NPCs contêm lógica própria de avanço de quest e transição de estado. Elena e Wing têm fluxos que travam por falta de handlers em certos estados. | Crítico | P0 |

---

### 2.3 World & Map Systems

| Sistema | Localização | Responsabilidade Atual | Diagnóstico da Auditoria | Risco | Prioridade |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Portais & Transição** | `world/components/MapTransitionArea.gd` & `StoryGate.gd` | Troca de mapas e verificação de condições para passagem. | O `StoryGate` valida arcos e etapas, mas alguns portais (`PortalMontanhaKukuroo`) exigiam 24 etapas concluídas quando a lógica de objetivos do exame permitia pular nós ou colidia com o spawn de criaturas. | Alto | P1 |
| **Spawn de Entidades** | Estático nas cenas (`.tscn`) + `QuestManager.sincronizar_inimigos_do_mapa` | Criação e posicionamento de monstros, bosses e NPCs. | **Inexistência de um SpawnManager unificado.** Inimigos estáticos deletados da árvore nunca mais retornam. Inimigos da Arena Celestial (etapas 2 a 5) sequer existiam na cena `arena_celestial.tscn`. | Crítico | P0 |
| **WorldState** | `autoload/WorldState.gd` | Flags persistentes de baús, portas e quebra-cabeças do mundo. | Funcional para baús, mas desconectado da limpeza de instâncias de missões e checkpoints temporários. | Médio | P2 |

---

### 2.4 Interface do Usuário (UI / HUD)

| Componente | Localização | Diagnóstico da Auditoria |
| :--- | :--- | :--- |
| **PlayerHUD** | `ui/hud/PlayerHUD.gd` | Exibe HP, Aura, nível, mini-mapa, atalhos de Nen e condições ativas. Bem integrado. |
| **QuestHUD** | `ui/hud/QuestHUD.gd` | Exibe objetivos do arco. Anteriormente continha artefatos de encoding UTF-8 corrompidos e falta de distinção de tarefas secundárias (corrigido no Bloco ATTGRANDE). |
| **StatusMenu** | `ui/StatusMenu/StatusMenu.gd` | Reconstruído em 3 colunas de RPG (Atributos, Maestria/SP e Licença Hunter). Totalmente desacoplado e funcional. |
| **ConditionTrackerUI** | `ui/hud/ConditionTrackerUI.gd` | Componente modular recém-criado para rastreamento de condições de Hatsu e Chefes. |
| **NenSkillTreeUI** | `ui/SkillTree/NenSkillTreeUI.gd` | Grafo visual 2D com nós e conexões. Desacoplado da fonte de dados `NenSkillTree.gd`. |
| **CharacterSelectionUI** | `ui/CharacterSelection/CharacterSelectionUI.gd` | Gerencia os 3 slots de save e criação rápida. Concorria com `CharacterCreationUI.gd` legado. |

---

## 3. AUDITORIA DAS CAUSAS-RAIZ DOS BUGS CONHECIDOS (SEÇÃO 25)

### 3.1 BUG 1: Tutorial — Elena entra em loop, não avança ou trava diálogo
* **Arquivo:** `entities/npc/recepcionista/RecepcionistaHunter.gd` e `world/Lobby.gd`
* **Causa-Raiz:**
  1. Em `Lobby.gd`, `_ready()` dispara `elena._on_interacted(ply)` automaticamente via timer arbitrário de 0.6s se `not PlayerData.tutorial_concluido`.
  2. No script `RecepcionistaHunter.gd`, o método `_processar_interacao_tutorial` usava um `match etapa:` cobrindo apenas `INTRODUCAO`, `INTERACAO` e `NEN_CONCEITO`.
  3. Quando a etapa estava em `MOVIMENTACAO`, `MENU_ABRIR`, `INVENTARIO_VER` ou `COMBATE_GOLPES`, o `match` caía em branch vazia. Como `_interacao_em_processamento` era setado como `true` antes do `match`, a flag ficava eternamente presa em `true` sem que nenhum diálogo ou callback a destravasse. Interações subsequentes do jogador eram sumariamente ignoradas por `if _interacao_em_processamento: return`.

### 3.2 BUG 2: Hunter Exam — Jogador passa pelo portal sem matar criaturas / GPS não aponta
* **Arquivo:** `world/maps/ExameMaratonaMap.gd` e `world/components/StoryGate.gd`
* **Causa-Raiz:**
  1. No mapa `exame_maratona.tscn`, os sabotadores e monstros do pantanal eram instâncias estáticas configuradas no `_ready()`. Se o jogador morresse ou reiniciasse a área, o registro dinâmico no `QuestSystem` falhava caso o array de posições estivesse dessincronizado.
  2. O portal de saída para Kukuroo possuía um `StoryGate.new(1, 24, true)` que exigia etapa 24, mas se o jogador não estivesse com a quest do arco 1 ativa no índice correto, a verificação `can_advance()` podia avaliar condições de forma inconsistente.
  3. No `MissionGPSIndicator.gd`, o cálculo de alvos dependia de `get_tree().get_nodes_in_group("enemies")`. Quando os inimigos eram removidos via `queue_free()`, o GPS apontava para o centro do mapa ou para coordenadas inválidas.

### 3.3 BUG 3: Celestial Arena — Wing não inicia conversa / Lutadores não aparecem
* **Arquivo:** `world/maps/ArenaCelestialMap.gd`, `arena_celestial.tscn` e `resource/quest/CanonQuestCatalog.gd`
* **Causa-Raiz:**
  1. **Lutadores inexistentes na cena:** Em `ArenaCelestialMap.gd`, o código procurava por `LutadorArena1`, `LutadorArena2`, `LutadorArena3`, `LutadorArena4`. **Nenhum desses nós existia no arquivo `arena_celestial.tscn`** (apenas os chefes Gido, Riehlvelt, Kastro e MestreAndar200 estavam presentes). Assim, `get_node_or_null()` retornava `null`, nenhum spawn de missão era registrado e os andares 1 a 190 da Arena Celestial não podiam ser jogados.
  2. **Objetivo fantasma do Teste da Água:** Na etapa 10 do Arco 3 (`CanonQuestCatalog.gd`), o objetivo configurado era `_criar_obj_investigate(&"teste_agua_wing")`. No entanto, **não havia nenhum objeto físico ou gatilho interativo com ID `teste_agua_wing` em todo o mapa da Arena**. O jogador falava com Wing, a etapa 9 completava, a etapa 10 começava e ficava permanentemente impossível de ser cumprida.

### 3.4 BUG 4: Hatsu & Biscuit — Biscuit não abre criação quando deveria / Créditos ignorados
* **Arquivo:** `entities/npc/biscuit/Biscuit.gd` e `autoload/PlayerData.gd`
* **Causa-Raiz:**
  1. Biscuit verifica `PlayerData.is_greed_island_concluida()`, que exige `arco_atual > 5` ou flag `arco5_concluido`. Porém, a própria Mestra Biscuit é introduzida e encontrada **DURANTE** o Arco 5 (Greed Island) para treinar o jogador. O jogador chegava até Biscuit no próprio mapa de Greed Island, mas ela dizia que ele precisava terminar o Arco 5 antes de poder treinar, gerando um paradoxo insolúvel.
  2. No criador de Hatsu (`HatsuCreationUI.gd`), a validação de pontos de créditos permitia em certas combinações submeter a habilidade sem abater a pontuação estrita se o botão de confirmação fosse acionado repetidamente em sequência rápida.

### 3.5 BUG 5: Character Creation & Save — Personagem desaparece / Play volta para o menu
* **Arquivo:** `ui/CharacterSelection/CharacterSelectionUI.gd` vs `ui/CharacterCreation/CharacterCreationUI.gd`
* **Causa-Raiz:**
  1. Havia dois scripts concorrentes de criação de personagem. `CharacterCreationUI.gd` sobrescrevia forçadamente `PlayerData.slot_ativo = 1` mesmo que o jogador tivesse escolhido o slot 2 ou 3.
  2. Na leitura do save (`SaveManager.obter_resumo_slot`), se o arquivo estivesse presente mas faltasse alguma chave secundária, `resumo["existe"]` retornava `true` mas com dicionário incompleto, disparando exceções de leitura de chaves inexistentes no loop de renderização da UI.

---

## 4. MATRIZ DE DEPRECIAÇÃO & SISTEMAS QUE DEVEM SER REFATORADOS OU ELIMINADOS

| Componente Atual | Status Proposto | Justificativa Técnica |
| :--- | :--- | :--- |
| `autoload/GameState.gd` | **REMOVER** | Código redundante. Apenas repassa `salvar_jogo` para o `SaveManager`. |
| `ui/CharacterCreation/` (Legado) | **REMOVER** | Cena duplicada e conflitante com `ui/CharacterSelection/`. |
| `scripts/systems/dialogue/` | **REMOVER** | Diretório vazio e abandonado na raiz de `scripts/systems/`. |
| `scripts/dialogue/DialogueSystem.gd` (no Player) | **REFATORAR & CONSOLIDAR** | O Player não deve possuir um nó de sistema de diálogo dentro da sua árvore física. O sistema de diálogo deve ser gerenciado por um serviço ou nó de UI global. |
| Inimigos sem Spawner | **SUBSTITUIR POR SPAWNMANAGER** | Nenhum monstro deve ser posicionado estaticamente sem um componente ou gerenciador que governe seu tempo de renascimento e filiação a missões. |
| `PlayerData` como Controlador de História | **SEPARAR EM STORYSYSTEM** | `PlayerData` deve apenas guardar os dados serializáveis do perfil do jogador. As regras de progressão de sagas, capítulos e gates pertencem a um `StoryManager`. |

---

## 5. SINGLE SOURCE OF TRUTH (ARQUITETURA ALVO)

```text
[ PERSISTÊNCIA EM DISCO (user://savegame_slot_X.json) ]
                       │
                       ▼
              ┌─────────────────┐
              │   SaveManager   │ (Carrega / Salva Atômico)
              └────────┬────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      FONTE DA VERDADE                       │
├──────────────────────────────┬──────────────────────────────┤
│ PlayerData                   │ StoryManager (NOVO)          │
│ - Identidade (ID, Nome)      │ - Saga / Arco Atual          │
│ - Atributos Vitais           │ - Capítulo / Etapa           │
│ - Nen Data (Maestria, Nós)   │ - Missão Ativa               │
│ - Inventário e Jenny         │ - Objetivos Ativos           │
│ - Hatsus Criados             │ - Histórico Concluído        │
└──────────────┬───────────────┴──────────────┬───────────────┘
               │                              │
               ▼                              ▼
    ┌─────────────────────┐        ┌─────────────────────┐
    │  Gameplay Systems   │        │   World & Mission   │
    │  - CombatEngine     │        │   - MissionInstance │
    │  - NenSystem        │        │   - SpawnManager    │
    │  - HatsuManager     │        │   - StoryGate       │
    └──────────┬──────────┘        └──────────┬──────────┘
               │                              │
               └──────────────┬───────────────┘
                              │ (Sinais / EventBus)
                              ▼
                   ┌─────────────────────┐
                   │    Apresentação     │
                   │    - PlayerHUD      │
                   │    - QuestHUD       │
                   │    - StatusMenu     │
                   │    - Dialogues      │
                   └─────────────────────┘
```

---

## 6. DIRETRIZES DE RECONSTRUÇÃO (FASE A FASE)

1. **Fase 1 — Core Data & Story Architecture:** Criação do `StoryManager` canônico (desacoplando o controle de história de `PlayerData`), com definições de dados estruturados para Sagas, Capítulos, Missões e Objetivos.
2. **Fase 2 — Mission Instance & Objective System:** Implementação da classe `MissionInstance` para isolar temporariamente monstros, contadores e timers de missões sem poluir o estado persistente do mundo.
3. **Fase 3 — Unified Spawn System:** Criação do `SpawnManager` com separação explícita entre **World Spawn** (com respawn automático) e **Mission Spawn** (vinculado ao ciclo de vida da instância de missão).
4. **Fase 4 — Correção dos Pontos de Ruptura nos Mapas & NPCs:**
   - Adicionar os lutadores faltantes na Arena Celestial (`LutadorArena1..4`) e o objeto interativo do Teste da Água (`teste_agua_wing`).
   - Corrigir a máquina de estados de Elena no Tutorial de `Lobby.gd` para evitar loops e travamentos.
   - Ajustar os requisitos de diálogo de Biscuit para permitir treinamento em Greed Island.
   - Deletar cenas e scripts redundantes (`CharacterCreationUI`, `GameState.gd`).
5. **Fase 5 — Suíte de Testes Automatizados de Regressão:** Validação automatizada cobrindo Save/Load, Start/Progress/Complete de Missão, Gates de Portal e Respawn de Inimigos.
