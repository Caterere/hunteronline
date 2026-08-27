# HUNTER ONLINE — GAMEPLAY POLISH PLAN (MASTER ROADMAP)

**Data de Planejamento:** 27 de Agosto de 2026  
**Documento de Referência:** `GAME_QUALITY_AUDIT.md` & `FIRST_30_MINUTES.md`  
**Diretrizes:** Foco em Game Feel, Juice, Telegrafia de IA, Fases de Bosses, Navegação, Utilidade de Nen e Reatividade de Mundo sem quebrar sistemas existentes e preservando 100% o Hatsu System.

---

## 📋 MATRIZ GERAL DE IMPLEMENTAÇÃO POR FASE

| Fase | Feature / Subsistema | Arquivo Responsável | Dependências | Risco | Impacto | Status |
|:---:|---|---|---|:---:|:---:|:---:|
| **0** | Auditoria Prévia & Mapeamento | `GAMEPLAY_POLISH_PLAN.md` | Todos os sistemas | Baixo | Estrutural | **CONCLUÍDA** |
| **1** | Combat Game Feel (Hit Stop, Camera Shake, Hit Flash, SFX) | `scripts/combat/CombatSystem.gd`, `autoload/EventBus.gd`, `entities/Player/Player.gd` | `EventBus`, `AudioManager`, `CombatEngine` | Baixo | Crítico / S | **CONCLUÍDA** |
| **2** | Enemy Windup & Telegraph (PREPARE_ATTACK, Data-Driven) | `scripts/systems/EnemySystem/EnemyAI.gd`, `resource/status/EnemyData.gd` | `EnemySystem`, `DamageNumber` | Médio | Crítico / S | **CONCLUÍDA** |
| **3** | Boss Design & Fases (Guardião de Zaban & BossPhase Framework) | `scripts/systems/EnemySystem/EnemyAI.gd`, `world/maps/DungeonRuinasZabanMap.gd` | `EnemyAI`, `EnemySystem`, `PlayerHUD` | Médio | Alto / A | **CONCLUÍDA** |
| **4** | Navegação (Sprint do Jogador & Minimap com Névoa de Exploração) | `entities/Player/Player.gd`, `ui/hud/PlayerHUD.tscn`, `ui/Minimap/` | `Player`, `TileDatabase`, `RegionContentConfig` | Baixo | Alto / A | **CONCLUÍDA** |
| **5** | Onboarding & Tutorial Orgânico (Primeiros 5 Minutos) | `ONBOARDING_DESIGN.md`, `entities/npc/wing/Wing.gd`, `ui/hud/PlayerHUD.gd` | `DialogueSystem`, `QuestManager`, `NenSystem` | Baixo | Crítico / S | **CONCLUÍDA** |
| **6** | Nen Fora do Combate (Gyo Revela Pistas, Ko Quebra Rochas, Zetsu Furtivo) | `scripts/systems/NenSystem.gd`, `world/components/WorldInteractionObject.gd` | `NenSystem`, `InteractionComponent`, `EventBus` | Médio | Muito Alto | **CONCLUÍDA** |
| **7** | Interação com o Mundo (Objetos Interativos, Pistas & Obstáculos) | `world/components/WorldInteractionObject.gd`, `world/catalog/TileDatabase.gd` | `InteractionComponent`, `PlayerData`, `SaveManager` | Baixo | Alto | **CONCLUÍDA** |
| **8** | Memória & Reatividade de NPCs (Consequências de Reputação e Ações) | `entities/npc/NPC.gd`, `entities/npc/LivingNPCBehavior.gd`, `resource/dialogue/` | `ReputationSystem`, `PersonalitySystem`, `PlayerData` | Baixo | Alto / A | **CONCLUÍDA** |
| **9** | Facções Reativas (Preços, Restrições & Diálogos Dinâmicos) | `autoload/FactionManager.gd`, `autoload/ReputationSystem.gd`, `autoload/Economy.gd` | `FactionManager`, `Economy`, `PlayerData` | Baixo | Médio / B | **CONCLUÍDA** |
| **10** | Eventos Contextuais no ContentDirector (Hora, HP, Nen & Reputação) | `world/content/ContentDirector.gd`, `autoload/WorldEventManager.gd` | `TimeManager`, `PlayerData`, `ContentDirector` | Médio | Alto | **CONCLUÍDA** |
| **11** | Densidade de Experiência do Mundo (Ritmo entre Combate, Diálogo e Segredos)| `world/content/ContentDirector.gd`, `world/generator/RegionWorldGenerator.gd` | `ContentDirector`, `RegionContentConfig` | Médio | Alto | **CONCLUÍDA** |
| **12** | PvE Variado & Papéis de Inimigos (Bruiser, Fast, Ambusher, Tank) | `resource/status/EnemyData.gd`, `scripts/systems/EnemySystem/EnemyAI.gd` | `EnemyAI`, `DataManager` | Baixo | Alto | **CONCLUÍDA** |
| **13** | Qualidade & Variedade de Quests (Investigação, Escolhas e Dedução) | `resource/quest/CanonQuestCatalog.gd`, `resource/quest/PadokiaQuestCatalog.gd` | `QuestManager`, `PlayerData`, `EventBus` | Baixo | Alto | **CONCLUÍDA** |
| **14** | Consequências de Quests no Mundo (WorldState & Mudança de Cidades) | `scripts/QuestManager.gd`, `autoload/EventBus.gd`, `autoload/SaveManager.gd` | `QuestSystem`, `SaveManager` | Baixo | Médio | **CONCLUÍDA** |
| **15** | Discovery System (Descobertas Visíveis, Escondidas, Secretas e Muito Secretas)| `world/components/WorldDiscoveryTracker.gd`, `autoload/AchievementSystem.gd` | `TileDatabase`, `PlayerData`, `SaveManager` | Baixo | Médio | **CONCLUÍDA** |
| **16** | Ciclo Dia/Noite com Efeitos de Gameplay & Iluminação Dinâmica | `autoload/TimeManager.gd`, `world/components/WorldLightingController.gd` | `TimeManager`, `LivingNPCBehavior` | Baixo | Alto | **CONCLUÍDA** |
| **17** | Atmosfera Viva (Sons Ambientais, Pássaros, Movimento de Cidade) | `autoload/AudioManager.gd`, `world/components/AmbientSoundController.gd` | `AudioManager`, `TimeManager` | Baixo | Médio / C | **CONCLUÍDA** |
| **18** | UI/UX Refinement (Hierarquia Visual, Legibilidade de Teclas e Menus) | `ui/hud/PlayerHUD.gd`, `ui/inventory/InventoryUI.gd`, `ui/nen/NenMenu.gd` | `PlayerHUD`, `PlayerData` | Baixo | Alto | **CONCLUÍDA** |
| **19** | Audio & Feedback Abrangente (SFX para Ações Chave com Fallback Seguro) | `autoload/AudioManager.gd`, `scripts/combat/CombatSystem.gd` | `AudioManager`, `EventBus` | Baixo | Alto | **CONCLUÍDA** |
| **20** | Performance & Anti-Spam (Stress Test de 100 Entidades e Chunks) | `world/components/WorldChunkLoader.gd`, `world/content/ContentDirector.gd` | `ContentDirector` | Médio | Técnico | **CONCLUÍDA** |
| **21** | Testes Automatizados Expandidos (Testes de Cada Novo Recurso) | `scratch/test_master_system_suite.gd`, `scratch/test_gameplay_polish_suite.gd` | Todas as novas APIs | Baixo | Qualidade | **CONCLUÍDA** |
| **22** | Playable Quality Test (Sessão Completa de 45 Minutos do Vertical Slice) | `scratch/test_vertical_slice_suite.gd` | Todos os sistemas | Médio | Produto | **CONCLUÍDA** |
| **23** | Regressão & Validação Final Zero-Bugs | Master Test Suites | Todos os sistemas | Baixo | Crítico | **CONCLUÍDA** |


---

## 🔍 DETALHAMENTO TÉCNICO DAS FASES IMEDIATAS

### ⚔️ FASE 1: COMBAT GAME FEEL
- **1. Hit Stop:** Adicionar função `EventBus.emit_hitstop(duracao: float)` que aciona um micro-congelamento temporal suave (`0.04s` para golpes normais, `0.08s` para críticos de Ko e `0.12s` para Hatsu pesado), desacelerando brevemente a árvore física sem travar a interface nem acumular atrasos.
- **2. Camera Shake:** Adicionar lógica de trauma exponencial (`trauma²`) em um nó `Camera2D` anexado ao Player, disparado via `EventBus.camera_shake_requested(intensidade, duracao)`.
- **3. Hit Reaction & Flash:** Animação de recuo e flash do shader do atacado, conectando o impacto ao `DamageNumber`.

### 👁️ FASE 2: ENEMY WINDUP & TELEGRAPH
- **1. Máquina de Estados de IA:** Inserir o estado `State.PREPARE_ATTACK` no `EnemyAI.gd`:
  `IDLE -> CHASE -> PREPARE_ATTACK (Windup 0.25s) -> ATTACK -> RECOVERY (0.35s) -> IDLE`.
- **2. Telegrafia Visual Data-Driven:** Exibir indicador de aviso (ponto de exclamação vermelho / flash da silhueta) durante o windup antes de disparar o cálculo de dano, permitindo *Perfect Dodges* reativos baseados em habilidade.

### 👹 FASE 3: BOSS DESIGN & FASES
- **1. Componente / Estrutura `BossPhase`:** O Guardião Ancestral de Zaban passará a ter:
  - **Fase 1 (100% - 60% HP):** Ataques físicos de martelo com aviso no chão.
  - **Fase 2 (59% - 0% HP):** Frenesi de Aura Vermelha (+25% velocidade), invocação de 2 Sentinelas menores e ataque em área de Terremoto Ancestral.

### 🏃 FASE 4: NAVEGAÇÃO
- **1. Sprint Responsivo:** Segurar `Shift` ou duplo toque em `Player.gd` eleva velocidade de 64 px/s para 110 px/s fora de combate com rastro suave de poeira.
- **2. Minimap de Exploração:** Widget no canto do HUD exibindo posição, terreno descoberto e ícones de NPCs relevantes sem revelar segredos precocemente.

### 🎓 FASE 5: ONBOARDING & TUTORIAL ORGÂNICO
- **1. Sequência Guiada:** Criação de `ONBOARDING_DESIGN.md` com dicas de controle sutis e progressivas durante os primeiros passos na Vila de Padokia.

---

## 🛡️ CRITÉRIO DE NÃO-REGRESSÃO
- Todas as alterações preservarão as chamadas existentes de `CombatEngine`, `NenSystem`, `HatsuSystem`, `SaveManager`, `QuestManager` e `EventBus`.
- Após cada fase, os testes automatizados serão executados imediatamente via Godot 4.6 headless.