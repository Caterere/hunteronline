# Autoloads — mapa rápido

Singletons registrados em `project.godot`.  
**Regra:** não criar outro singleton se um destes já cobre a responsabilidade.

## Núcleo
- `EventBus` — sinais globais
- `GameManager` — flow de alto nível (enum interno `GameState` ≠ antigo wrapper)
- `DataManager` — catálogos estáticos
- `PlayerData` — estado do jogador
- `SaveManager` — save/load/slots (**única API de persistência**)
- `ProgressionConfig` / `PowerScale` — números de progressão

## Combate / Nen / Hatsu
- `CombatEngine`, `DamageNumberSystem`
- `HatsuManager`, `HatsuProgressionManager`, `NenBeastManager`
- `PerceptionSystem` (`scripts/systems/PerceptionSystem.gd`)

## História / missões
- `StoryManager`
- `QuestSystem` → `scripts/missions/QuestManager.tscn`
- `SurpriseQuestSystem`, `TutorialManager`, `CinematicManager`

## Mundo
- `TimeManager`, `WorldState`, `WorldStateManager`, `WorldEventManager`
- `WorldProgressionManager`, `LiveEventManager`, `TravelSystem`

## Social / meta
- `Economy`, `ReputationSystem`, `FactionManager`
- `RelationshipSystem`, `RumorSystem`, `BountySystem`
- `AchievementSystem`, `PersonalitySystem`, `NPCMemorySystem`
- `CollectionManager`, `SecretBossManager`, `PartyManager`

## Infra / UI
- `AudioManager`, `SceneTransition`, `InputContextManager`
- `UIManager`, `PlaytestTelemetry`, `NetworkManager`

## Dívida conhecida
- `WorldState` = dados persistentes de causalidade (regiões, flags, facções mundiais)
- `WorldStateManager` = orquestração viva (clima, rotinas NPC) — **não fundir**; são papéis distintos
- `ReputationSystem` vs `FactionManager` — overlapping
- `PlayerData` ainda guarda campos de arco para save; **escrita de progressão narrativa** deve passar por `StoryManager`
