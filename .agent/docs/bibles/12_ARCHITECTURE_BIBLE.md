# ARCHITECTURE BIBLE

## Principle
The project is a collection of interconnected systems. Each system must have a clear responsibility.

## Core Systems
Known conceptual systems include:
- GameManager
- DataManager
- EventBus
- TimeManager
- PlayerData
- NenSystem
- HunterCombatSystem
- quest/mission systems
- NPC/interaction systems
- dialogue systems
- save/load systems
- UI systems

## Responsibilities
### GameManager
Coordinates high-level game state and lifecycle.

### DataManager
Owns or coordinates persistent/game data access according to the existing project implementation.

### EventBus
Provides decoupled communication for global events. Do not turn it into a dumping ground for arbitrary state.

### PlayerData
Represents canonical player progression data.

### Combat System
Owns combat calculations and combat state.

### Nen System
Owns Nen techniques, aura behavior and related rules.

### Gameplay Foundation Resources
`GameplayTags` normalizes and queries extensible gameplay labels. `GameplayCondition` is a serializable, context-driven Resource shared by Hatsu now and by Skill Tree, quests, enemies, bosses and events as they adopt it. These resources do not own player, combat or world state.

`StatModifier` remains the single modifier representation consumed by `PlayerData`; feature systems must reuse it instead of defining private modifier classes.

### Quest System
Owns objective state, progression and completion.

### NPC System
Owns NPC behavior and interactions.

## Dependency Rule
Prefer:
Data → Systems → Presentation

UI should request/display canonical state instead of becoming the owner of gameplay state.

## Duplication Rule
Before adding a system, search the repository for equivalent responsibility.

## Refactoring
Refactor incrementally. Do not perform broad rewrites during unrelated feature work.
