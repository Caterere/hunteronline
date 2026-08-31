# HUNTER ONLINE — PRODUCTION AUDIT (PROFESSIONAL PASS)

**Data da Auditoria:** 27 de Agosto de 2026  
**Auditor:** Technical Director & Gameplay Lead Engineer  
**Status do Projeto:** Transição para Base Profissional de Produção

---

## 1. MAPA DA ARQUITETURA DO PROJETO

- **Core Autoloads**: `EventBus`, `GameManager`, `WorldProgressionManager`, `TimeManager`, `DataManager`, `SaveManager`, `Economy`, `AudioManager`, `SceneTransition`, `CinematicManager`
- **Sistemas Globais**: `PlayerData`, `PowerScale`, `QuestSystem` (`QuestManager`), `HatsuManager` (v2.0 Rebalanceado), `NenBeastManager`, `FactionManager`, `ReputationSystem`, `PersonalitySystem`, `WorldEventManager`, `AchievementSystem`, `SurpriseQuestSystem`
- **Entidade Player (`Player.tscn`)**: `PlayerController`, `HunterCombatSystem` (`CombatSystem.gd`), `NenSystem`, `HatsuSystem`, `NenBeastSystem`, `XPSystem`, `DialogueSystem`, Posicionamento por `SpawnPoint`
- **Mundo & Conteúdo**: `SpawnPoint`, `MapTransitionArea`, `StoryGate`, `RegionWorldGenerator`, `ContentDirector`, `TileDatabase`, `RoomComposer`, `WorldChunkLoader`, Mapas contínuos e Dungeons dos 9 arcos canônicos
- **UI**: `PlayerHUD`, `StatusMenu`, `HunterMenuUI` (Abas Status, Nen, Hatsu 4 slots, Besta de Nen, Missões), `HatsuCreationUI` (Gauge de Créditos Dinâmico), `InventoryUI`, `ShopUI`, `BlacksmithUI`, `VisualDialogueUI`, `DialogueBox`, `CharacterCreationUI`, `CharacterSelectionUI`

---

## 2. AUDITORIA DETALHADA POR CATEGORIA

### 🔴 CRITICAL (RESOLVIDOS NA BASE DE PRODUÇÃO)
1. **Desincronização e Duplicidade de Salvamento (GameState vs SaveManager) — [RESOLVIDO ✅]**
   - **Arquivos:** `autoload/SaveManager.gd`, `autoload/PlayerData.gd`, `autoload/GameManager.gd`
   - **Sistema:** Persistência / Save & Load
   - **Status:** Consolidado em um único `SaveManager.gd` canônico, unificando a estrutura de dados (PlayerData, Economy, WorldState, Quests, Nen, Hatsu com IDs e slots equipados, Posição e Mapa).

2. **Loop / Falha de Filtragem de Eliminações em QuestManager — [RESOLVIDO ✅]**
   - **Arquivo:** `scripts/QuestManager.gd`
   - **Sistema:** Quests
   - **Status:** Corrigida a verificação estrita por `target_id` / categoria de inimigo, eliminando a cláusula permissiva hardcoded.

3. **Cálculo de Dano Fragmentado e Não-Convergente (CombatEngine vs HunterCombatSystem) — [RESOLVIDO ✅]**
   - **Arquivos:** `autoload/CombatEngine.gd`, `scripts/combat/CombatSystem.gd`, `scripts/systems/EnemySystem/EnemySystem.gd`
   - **Sistema:** Combate & Atributos
   - **Status:** Pipeline unificado no `CombatEngine` com suporte autoritativo a atacante vs defensor, mitigações canônicas de Ten/Ken/Ryu e escalonamento de Hatsu por juramentos.

---

### 🟠 HIGH
1. **Mutação Descontrolada e Ausência de Pipeline de Stats**
   - **Arquivo:** `autoload/PlayerData.gd`
   - **Sistema:** Stats / Atributos
   - **Problema:** Atributos (`vida`, `forca`, `defesa`, `velocidade`, `aura_max`) são dicionários soltos mutados diretamente por múltiplos scripts (ex: `aplicar_bonuses_afinidade()` multiplica `attributes["forca"] *= 1.2` diretamente; se chamado mais de uma vez, os status disparam exponencialmente).
   - **Impacto:** Inconsistência numérica e vulnerabilidade a bugs cumulativos de atributos.
   - **Solução:** Implementar `StatModifier` centralizado: `BASE + LEVEL + TRAINING + EQUIPMENT + NEN + BUFF + DEBUFF = FINAL STATS` com tipos Flat, Percentual e Multiplicativo.
   - **Prioridade:** HIGH

2. **Alocação Contínua de Nós Hitbox no Processamento de Ataques**
   - **Arquivo:** `scripts/combat/CombatSystem.gd` (Linhas 230-322)
   - **Sistema:** Combate / Performance
   - **Problema:** A cada golpe básico, um novo nó `Area2D` e `CollisionShape2D` são instanciados via `Area2D.new()`, adicionados à árvore e destruídos via `queue_free()` após 0.14s.
   - **Impacto:** Alocações contínuas na heap, sobrecarga no garbage collection e instabilidade de FPS em combates rápidos.
   - **Solução:** Reutilizar uma hitbox fixa pré-configurada no Player ou implementar pooling de detecção física.
   - **Prioridade:** HIGH

3. **Inconsistência de Esquema do Inventário entre UI e Core**
   - **Arquivos:** `autoload/PlayerData.gd`, `ui/inventory/InventoryUI.gd`, `ui/Blacksmith/BlacksmithUI.gd`
   - **Sistema:** Inventário & Equipamento
   - **Problema:** `PlayerData.gd` gerencia `inventory` como dicionário plano `item_id -> quantidade`, enquanto `BlacksmithUI.gd` tenta acessar `PlayerData.inventory["itens"]` e `PlayerData.inventory["equipamentos_upgrade"]` como subdicionários, causando verificações manuais de escape no `InventoryUI.gd`.
   - **Impacto:** Itens forjados ou aprimorados desaparecem ou quebram a visualização do inventário.
   - **Solução:** Padronizar a estrutura do `InventorySystem` e `EquipmentData`, desacoplando a UI do armazenamento interno de dados.
   - **Prioridade:** HIGH

---

### 🟡 MEDIUM
1. **Arquivos Duplicados / Arquivos Mortos no Projeto**
   - **Arquivos:** `autoload/NenSystem.gd` (0 bytes), `autoload/NenTechnique.gd` (RefCounted solto), `scripts/systems/dialogue/DialogueSystem.gd` (stub de 2 bytes), estados legados em `entities/Player/states/`.
   - **Sistema:** Organização e Core
   - **Impacto:** Confusão de manutenção e riscos de referências erradas.
   - **Solução:** Limpar e migrar referências para os scripts consolidados oficiais.
   - **Prioridade:** MEDIUM

2. **Hardcode de Nomes de Nós em EnemySystem para Auto-Resolução de Dados**
   - **Arquivo:** `scripts/systems/EnemySystem/EnemySystem.gd` (Linhas 118-149)
   - **Sistema:** PvE / Inimigos
   - **Problema:** `EnemySystem._ready()` busca substrings como `"pantanal"`, `"maratona"`, `"mike"` no nome do nó pai para carregar `.tres`.
   - **Impacto:** Quebra se o nó for renomeado na cena ou gerado dinamicamente com outro identificador.
   - **Solução:** Injetar `enemy_data` via configuração de spawn ou utilizar ID semântico configurável.
   - **Prioridade:** MEDIUM

3. **Independência Incompleta de QuestSystem via Script Mode**
   - **Arquivos:** Mapas em `world/maps/*.gd` e NPCs em `entities/npc/*.gd`
   - **Sistema:** Quests / Carregamento
   - **Problema:** Dependência direta do identificador global de autoload `QuestSystem` em scripts de mapa/NPC.
   - **Impacto:** Dificuldade em testes modulares isolados.
   - **Solução:** Usar `EventBus` para eventos de quest ou obter a referência de forma segura.
   - **Prioridade:** MEDIUM

---

### 🟢 LOW
1. **Logs Excessivos de Debug no Terminal**
   - **Arquivos:** `CombatSystem.gd`, `PlayerData.gd`, `QuestManager.gd`
   - **Solução:** Envelopar logs sob flag de debug.
   - **Prioridade:** LOW

2. **Tipagens Implícitas (Variant) em Retornos de Dicionários**
   - **Arquivos:** `PlayerData.gd`, `ContentDirector.gd`
   - **Solução:** Adicionar tipagem estática rigorosa.
   - **Prioridade:** LOW

---

### 🔧 TECH DEBT
1. **Separação de World State vs Player State**
   - Isolar `WorldState` (baús abertos, chefes mortos, portas destrancadas, facções, flags de mundo) do `PlayerData`.
2. **Memória de NPCs e Rotina Orientada a Tempo**
   - Integrar memória e rotina de horários com `TimeManager` e `LivingNPCBehavior`.
3. **Escalonamento Endgame Desconectado**
   - Conectar `PowerScale.gd` ao pipeline central de atributos do jogador e inimigos.

---

### ✨ POLISH
1. **Hit Stop & Camera Shake em Golpes Críticos e Hatsu**
   - Adicionar micro-congelamento (hit stop de 0.04s) e vibração de tela em acertos pesados.
2. **Audio SFX para Todas as Ações de Combate**
   - Garantir SFX dedicado para Dash, impacto de golpe, quebra de postura (stagger) e ativação de Nen.
3. **Menu de Pausa e Configurações de Volume Unificados**
   - Conectar sliders de áudio da UI diretamente ao `AudioManager`.

---

### 🚀 FUTURE
1. **Autoridade do Servidor vs Apresentação do Cliente**
   - Manter separação da lógica de cálculo para que no futuro o servidor execute a lógica e o cliente apenas renderize (`NetworkProtocol.gd`).
2. **Novas Técnicas de Nen Avançadas (Shu / Ken / Ryu / In / En)**
   - Expandir aprofundamento das técnicas avançadas mantendo compatibilidade com as fórmulas consolidadas.
