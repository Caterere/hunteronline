# Documentação completa

Este arquivo reúne os documentos Markdown atualmente presentes no projeto, inclusive `.agent`.

## Índice

- .agent/docs/bibles/00_BIBLE_INDEX.md
- .agent/docs/bibles/01_GAME_DESIGN_BIBLE.md
- .agent/docs/bibles/02_NEN_BIBLE.md
- .agent/docs/bibles/03_HATSU_BIBLE.md
- .agent/docs/bibles/04_COMBAT_BIBLE.md
- .agent/docs/bibles/05_CHARACTER_PROGRESSION_BIBLE.md
- .agent/docs/bibles/06_QUEST_MISSION_BIBLE.md
- .agent/docs/bibles/07_NPC_DIALOGUE_BIBLE.md
- .agent/docs/bibles/08_WORLD_SPAWN_BIBLE.md
- .agent/docs/bibles/09_SAVE_DATA_BIBLE.md
- .agent/docs/bibles/10_UI_UX_BIBLE.md
- .agent/docs/bibles/11_CONTENT_DESIGN_BIBLE.md
- .agent/docs/bibles/12_ARCHITECTURE_BIBLE.md
- .agent/docs/bibles/13_TESTING_DEBUG_BIBLE.md
- .agent/docs/bibles/14_DATA_SCHEMA_BIBLE.md
- .agent/docs/bibles/15_GAMEPLAY_FOUNDATION_BIBLE.md
- .agent/skills/hunter-development/SKILL.md
- NEN_SKILL_TREE_BIBLE.md

---

## .agent/docs/bibles/00_BIBLE_INDEX.md

# HUNTER ONLINE — BIBLE INDEX

## Purpose
These Bibles define WHAT the Hunter MMORPG is and how its systems should behave. They complement `.agent/skills/hunter-development/SKILL.md`, which defines HOW the agent should develop the project.

## Source of Truth
Priority:
1. Explicit user requirements for the current task
2. This Bible set
3. Existing project architecture and implementation
4. Agent assumptions

If code conflicts with the Bibles, do not silently rewrite the project. Analyze the conflict and report it.

## Bibles
- 01_GAME_DESIGN_BIBLE.md — global game rules and philosophy
- 02_NEN_BIBLE.md — Nen fundamentals and techniques
- 03_HATSU_BIBLE.md — Hatsu creation, categories and custom abilities
- 04_COMBAT_BIBLE.md — combat, damage, defense, aura and Ryu
- 05_CHARACTER_PROGRESSION_BIBLE.md — attributes, level, potential and progression
- 06_QUEST_MISSION_BIBLE.md — quests, objectives, stages and progression gates
- 07_NPC_DIALOGUE_BIBLE.md — NPCs, interactions and dialogue
- 08_WORLD_SPAWN_BIBLE.md — maps, portals, spawning and encounter rules
- 09_SAVE_DATA_BIBLE.md — persistence and character lifecycle
- 10_UI_UX_BIBLE.md — interfaces and player feedback
- 11_CONTENT_DESIGN_BIBLE.md — enemies, bosses, rewards and content scaling
- 12_ARCHITECTURE_BIBLE.md — system responsibilities and integration rules
- 13_TESTING_DEBUG_BIBLE.md — validation, regression and QA standards
- 14_DATA_SCHEMA_BIBLE.md — canonical data structures and persistence concepts
- NEN_SKILL_TREE_BIBLE.md (repository root) — current Nen Skill Tree ownership, modifier integration and expansion rules
- 15_GAMEPLAY_FOUNDATION_BIBLE.md — reusable conditions, tags and modifier integration


---

## .agent/docs/bibles/01_GAME_DESIGN_BIBLE.md

# GAME DESIGN BIBLE

## Identity
A 2D MMORPG/RPG inspired by Hunter x Hunter, built around strategy, Nen, Hatsu customization, exploration, progression and meaningful player choices.

## Core Pillars
1. Strategy over raw button-mashing.
2. Nen is a core gameplay system, not a cosmetic layer.
3. Hatsu should support different builds.
4. Player progression must feel persistent.
5. World progression must respect mission requirements.
6. Systems should interact rather than exist as isolated minigames.
7. Content should remain extensible.

## World Structure
The game may use semi-open regions connected by missions, portals, towns, hubs, instances and story progression.

## Story
The player can coexist with the Hunter x Hunter-inspired storyline and major saga structure while having their own progression and missions.

Planned broad progression includes Hunter Exam, Heaven's Arena, Yorknew, Greed Island, Chimera Ant and later content such as the Black Whale/Dark Continent direction.

## Design Rule
Anime-inspired content should preserve the strategic philosophy of Nen while gameplay numbers may be adapted for balance.


---

## .agent/docs/bibles/02_NEN_BIBLE.md

# NEN BIBLE

## Core Concept
Nen is the manipulation of aura. The player's Nen progression is central to combat and Hatsu.

## Techniques
### Ten
Maintains aura around the body. Defensive/basic aura control.

### Zetsu
Suppresses aura output. Useful for stealth, recovery and risk/reward situations.

### Ren
Increases aura output. Offensive pressure and aura-intensive actions.

### Gyo
Concentrates aura into a body part or sense, enabling enhanced perception and focused power.

### Shu
Extends aura into an object, empowering equipment or held objects.

### Ko
Concentrates an extreme amount of aura into one point, trading broad defense for focused power.

### En
Extends aura into an area for detection and awareness.

### Ryu
Dynamically redistributes aura between body regions according to tactical needs.

## Ryu Modes
The project supports:
- Offensive Ryu: favors attack/damage.
- Defensive Ryu: favors defense/survivability.
- Balanced Ryu: distributes benefits between offense and defense.

## Aura
Aura is a finite combat resource.
Relevant systems must respect `aura` and `aura_max`.

Suggested baseline from the project design:
- Outside combat: regeneration around 5% of maximum aura per second.
- In combat: regeneration around 3% of maximum aura per second.

These values are tunable balance values, not immutable engine constants.

## Nen Types
The six canonical affinities should remain represented:
- Enhancement
- Transmutation
- Conjuration
- Specialization
- Manipulation
- Emission

Affinity should influence Hatsu design and efficiency without preventing creative builds.

## Training
Nen techniques should be acquired/improved through training, progression, quests and/or controlled challenges rather than arbitrary instant unlocks.


---

## .agent/docs/bibles/03_HATSU_BIBLE.md

# HATSU BIBLE

## Purpose
Hatsu is the player's main build-creation system.

## Design Goals
A Hatsu should:
- have a clear fantasy;
- have a mechanical identity;
- interact with Nen;
- have meaningful costs;
- support strengths and weaknesses;
- be scalable;
- be understandable to the player.

## Slots
The character uses up to 4 active Hatsu slots as a baseline design.

## Hatsu Components
A custom ability may be assembled from:
- effect
- target
- range
- area
- duration
- activation
- cost
- cooldown
- restriction
- condition
- risk
- scaling attribute
- Nen affinity
- visual/audio presentation

## Restrictions and Vows
Restrictions can increase power when they create meaningful limitations.
The implementation should never treat a restriction as free damage.

## Presets
The system may contain presets for archetypes such as:
- offensive
- defensive
- utility
- stealing abilities
- draining Nen
- control
- mobility
- support
- transformation

Presets are starting points, not replacements for the custom system.

## Ability Theft / Credit Mechanics
Ability theft systems must explicitly validate:
- whether the target ability is stealable;
- required conditions;
- ownership;
- credits/currency/resource requirements;
- persistence;
- activation rules.

Never bypass a required cost simply because the UI or prototype currently allows it.

## Balance
Every Hatsu must be evaluated against:
- aura cost;
- cooldown;
- damage/effect strength;
- range;
- frequency;
- restrictions;
- counterplay;
- progression level.

## Implementation Rule
Hatsu definitions should be data-driven whenever practical so content creators can add abilities without duplicating combat logic.

## Gameplay Tags and Conditions
Hatsu tags use the canonical `GameplayTags` utility and are normalized when saved or loaded. Tags describe gameplay meaning such as `projectile`, `offensive`, `long_range`, `single_target`, `weapon` and `aura`; consumers may query them without hardcoding individual Hatsu IDs.

`GameplayCondition` resources may be attached to a Hatsu and are evaluated from the activation context. They support reusable checks such as HP thresholds, marked targets, nearby-enemy counts, En, stealth, unlocked skills, target states, weak points and Hatsu tags. The Hatsu system remains responsible for supplying the context and for presenting activation feedback.


---

## .agent/docs/bibles/04_COMBAT_BIBLE.md

# COMBAT BIBLE

## Combat Philosophy
Combat should reward positioning, timing, Nen management, build knowledge and tactical decisions.

## Core Resources
Player combat uses:
- HP
- Max HP
- Aura
- Max Aura
- Strength
- Defense
- Speed
- Level
- Hatsu

## Baseline Attributes
Current project data convention includes:
`vida`, `vida_max`, `forca`, `defesa`, `velocidade`, `aura`, `aura_max`, `nivel`.

Do not rename existing fields casually. If schema evolution is necessary, provide migration/compatibility handling.

## Damage
Damage should be calculated through a centralized combat system rather than scattered formulas.

Generic conceptual model:
Final Damage = Base Power × scaling factors × offensive modifiers × defensive mitigation.

Exact coefficients belong to balance data, not hardcoded across multiple scripts.

## Aura
Aura-intensive attacks should consume aura.
A player should not be able to execute abilities that require more aura than available unless the ability explicitly supports an overdraw mechanic.

## Cooldowns
Cooldowns belong to the ability state/system and must not be reset accidentally by scene changes, repeated signals or UI interactions.

## Death
Death must produce a deterministic state transition and cleanly notify relevant systems such as missions, spawning and UI.

## Enemy Combat
Enemies should use the same conceptual combat rules where practical. Special bosses may have controlled exceptions.


---

## .agent/docs/bibles/05_CHARACTER_PROGRESSION_BIBLE.md

# CHARACTER PROGRESSION BIBLE

## Attributes
Baseline physical attributes:
- Strength: 1–50 baseline design range.
- Defense
- Speed
- HP
- Aura
- Level

## Nen Progression
Nen progression is separate from ordinary character progression conceptually, even if stored in the same save structure.

## Potential / IV
Characters receive randomized potential in a baseline range of 60–100.

Potential affects XP gain from approximately 60% to 100%.

Potential affects:
- character XP;
- Nen XP.

Potential should not secretly modify unrelated stats unless explicitly designed.

## XP
XP should use an exponential/progressive curve so later levels require substantially more effort.

The exact formula belongs in balance data and must be changeable without rewriting progression code.

## Training
Training and rest are primary progression mechanisms for Nen and physical development.

The baseline design does not depend on consumable aura potions as the main recovery mechanism.

## Builds
The progression system must allow different builds rather than forcing every player toward one optimal stat distribution.


---

## .agent/docs/bibles/06_QUEST_MISSION_BIBLE.md

# QUEST & MISSION BIBLE

## Mission Principle
A mission is a state machine with explicit objectives and completion conditions.

## Objective Types
Supported conceptual objectives:
- kill
- collect
- talk
- escort
- protect
- reach location
- survive
- interact
- use ability
- defeat boss
- complete prerequisite
- conditional objective

## Progression Gate
A portal, NPC, cutscene or next stage must not advance the mission unless its required objectives are satisfied.

Example:
If the mission requires killing 3 swamp creatures, entering the next portal must not complete the stage before `3/3`.

## Multi-Step Missions
Saga missions may contain many stages. The project target can support missions with approximately 20 meaningful steps when appropriate.

Each step should have:
- objective;
- state;
- completion condition;
- failure condition when applicable;
- reward;
- next-step transition.

## Repeatable Missions
Repeatable side missions should explicitly define:
- reset conditions;
- reward;
- cooldown if any;
- spawn behavior;
- objective tracking.

## Mission Enemy Spawning
Mission targets and non-target enemies must be distinguished.

Killing a non-objective enemy must not permanently remove it from the world unless the design explicitly says so.

Mission spawns should be owned by a mission/encounter lifecycle and cleanly reset when appropriate.

## GPS
Navigation markers must derive from actual objective state rather than hardcoded coordinates whenever possible.

## Persistence
Mission state must survive save/load when the mission is persistent.

## Completion
Mission completion must be validated server-authoritatively at the system level, even in a single-player prototype.


---

## .agent/docs/bibles/07_NPC_DIALOGUE_BIBLE.md

# NPC & DIALOGUE BIBLE

## NPC Principles
NPCs should have:
- identity;
- role;
- location;
- interaction rules;
- dialogue state;
- quest relationships;
- progression requirements where needed.

## Interaction
Use the existing interaction architecture when possible, including InteractionComponent and the project's NPC interaction conventions.

## Dialogue
Dialogue should be state-aware.

An NPC may show different dialogue depending on:
- quest state;
- player progression;
- saga;
- previous choices;
- Hatsu/Nen progression;
- mission completion.

## Tutorial NPCs
Tutorial NPCs must not create infinite dialogue loops.

A tutorial step should transition exactly when its completion condition is satisfied.

## NPC Quest Integration
Dialogue options that start or advance quests must call the canonical quest system rather than maintaining a duplicate quest state.

## Availability
NPC interactions may be gated by story progression, but the reason should be explicit and debuggable.


---

## .agent/docs/bibles/08_WORLD_SPAWN_BIBLE.md

# WORLD & SPAWN BIBLE

## Spawn Principles
Spawning must be deterministic from game state and encounter rules.

## Enemy Categories
At minimum distinguish:
- ambient enemies;
- mission objectives;
- elite enemies;
- bosses;
- event encounters.

## Respawn
Ambient enemies can respawn according to world rules.
Mission enemies should follow mission lifecycle rules.
Bosses should follow encounter reset rules.

## Scene Changes
Leaving and re-entering a mission area must not accidentally duplicate enemies or permanently delete required enemies.

## Portal Rules
Portals can have:
- unconditional access;
- quest-gated access;
- level-gated access;
- story-gated access;
- objective-gated access.

Objective-gated portals must query the canonical mission state.

## Arena / Encounter
Special arenas should explicitly initialize their required combatants and verify that all expected entities spawned successfully.

## GPS
Targets should expose a stable objective reference or location source to navigation rather than relying on manually duplicated coordinates.


---

## .agent/docs/bibles/09_SAVE_DATA_BIBLE.md

# SAVE DATA BIBLE

## Principle
Anything that represents meaningful player progression must be persisted when intended to survive closing the game.

## Character Data
Conceptual persistent data includes:
- character identity;
- appearance;
- level;
- XP;
- potential;
- physical attributes;
- HP state where appropriate;
- aura state where appropriate;
- Nen progression;
- Nen affinity;
- Hatsu definitions;
- Hatsu slots;
- inventory;
- currencies/credits;
- quests;
- story progression;
- unlocks.

## Lifecycle
Required flow:
Create Character → Save → Exit → Relaunch → Load → Continue.

## Load Validation
Loading must validate:
- file existence;
- schema version;
- required fields;
- missing optional fields;
- corrupted values.

## Versioning
Save data should have a schema version so future updates can migrate old characters.

## Atomicity
Saving should minimize the chance of leaving a partially written character.

## Regression Test
Every major save-system change must test:
1. fresh character;
2. save;
3. restart;
4. load;
5. verify progression;
6. modify;
7. save again;
8. reload.


---

## .agent/docs/bibles/10_UI_UX_BIBLE.md

# UI/UX BIBLE

## Principles
UI should communicate state without requiring the player to inspect hidden systems.

## Required Feedback
Important actions should communicate:
- success;
- failure;
- unavailable requirement;
- cooldown;
- insufficient aura;
- mission progress;
- objective completion.

## Dialogue
Dialogue boxes must remain inside intended screen bounds and adapt to text length.

## Mission UI
Display:
- current objective;
- progress;
- optional objectives;
- completion state.

## Combat UI
Display relevant:
- HP;
- aura;
- cooldowns;
- active Nen technique;
- important status effects.

## GPS
Navigation should clearly indicate the active objective and update when objective state changes.

## Interaction
Interact prompts should only appear when interaction conditions are satisfied.

## Accessibility
Avoid communicating critical gameplay information through color alone.


---

## .agent/docs/bibles/11_CONTENT_DESIGN_BIBLE.md

# CONTENT DESIGN BIBLE

## Enemies
Every enemy should define:
- identity;
- level;
- HP;
- aura if applicable;
- attack;
- defense;
- speed;
- behavior;
- rewards;
- spawn category;
- weaknesses/resistances where appropriate.

## Bosses
Bosses should introduce mechanics, not merely inflated HP.

## Rewards
Rewards should correspond to difficulty and progression.

Possible rewards:
- XP;
- Nen XP;
- money;
- items;
- unlocks;
- Hatsu components;
- story progression.

## Difficulty
Difficulty should scale through a combination of:
- enemy stats;
- AI behavior;
- mechanics;
- encounter composition;
- objective complexity;
- resource pressure.

Avoid relying solely on HP inflation.

## Mission Length
Main saga missions can be designed as long multi-stage sequences, while side missions can be shorter and repeatable.

## Content Consistency
New content must use canonical systems for:
- damage;
- rewards;
- quests;
- spawning;
- persistence;
- dialogue.


---

## .agent/docs/bibles/12_ARCHITECTURE_BIBLE.md

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


---

## .agent/docs/bibles/13_TESTING_DEBUG_BIBLE.md

# TESTING & DEBUG BIBLE

## Bug Workflow
REPRODUCE → ISOLATE → IDENTIFY ROOT CAUSE → FIX → REGRESSION TEST → DOCUMENT.

## Do Not
- hide errors;
- add arbitrary delays as a permanent fix;
- duplicate calls until something works;
- disable systems to avoid symptoms;
- declare success because the editor stopped showing an error.

## Test Levels
### Unit/System
Validate individual formulas and state transitions.

### Integration
Validate interactions between systems.

### Gameplay
Perform the actual player flow.

### Regression
Verify existing functionality after changes.

## Mandatory Regression Areas
When relevant, test:
- character creation;
- save/load;
- mission progression;
- portal gates;
- NPC interaction;
- dialogue;
- enemy spawn;
- combat;
- Nen;
- Hatsu;
- UI.

## Debugging
Prefer temporary diagnostic logging that can be removed or disabled after the root cause is known.

Logs should identify:
- system;
- event;
- entity;
- state;
- relevant IDs;
- expected vs actual value.

## Completion Standard
A fix is complete only when the original bug is resolved and the surrounding workflow still works.


---

## .agent/docs/bibles/14_DATA_SCHEMA_BIBLE.md

# DATA SCHEMA BIBLE

## Purpose
This document defines conceptual canonical data rather than forcing every field into a single implementation.

## Player
Conceptual:
- id
- name
- appearance
- level
- xp
- potential
- attributes
- Nen data
- Hatsu data
- inventory
- currency
- quest state
- story state
- schema_version

## Attributes
Baseline:
- vida
- vida_max
- forca
- defesa
- velocidade
- aura
- aura_max
- nivel

## Nen
Conceptual:
- affinity/type
- technique progression
- aura control
- Nen XP

## Hatsu
Conceptual:
- id
- name
- category
- components
- cost
- cooldown
- restrictions
- level
- slot
- unlocked
- normalized gameplay tags
- serializable gameplay conditions

## Quest
Conceptual:
- quest_id
- current_step
- objectives
- objective_progress
- status
- prerequisites
- rewards
- repeatable
- timestamps when needed

## Migration
Any schema change must consider existing saves.

Never delete or rename a persistent field without a migration/compatibility strategy.


---

## .agent/docs/bibles/15_GAMEPLAY_FOUNDATION_BIBLE.md

# Gameplay Foundation Bible

## Objective

Provide reusable conditions, tags and modifiers so systems can express gameplay rules without hardcoded Hatsu IDs, duplicated combat logic or private state copies.

## Responsibilities

### GameplayTags

Normalizes labels and answers tag queries. It does not determine combat outcomes or own a tag registry. Tags remain extensible strings; use normalized snake_case names such as `projectile`, `offensive`, `long_range`, `single_target`, `weapon` and `aura`.

### GameplayCondition

Stores one declarative requirement and evaluates a context dictionary. It does not query scene nodes, modify state or emit UI. Supported context keys include `player_hp_percent`, `seconds_since_damage`, `target_marked`, `nearby_enemy_count`, `target_hp_percent`, `player_in_en`, `player_stealth`, `active_hatsu_ids`, `unlocked_skill_ids`, `target_states`, `target_weak_point_revealed` and `hatsu_tags`.

`evaluate()` returns `{ met, type, actual }`. Consumers decide the effect, feedback and state transition.

### StatModifier

`StatModifier` is the sole modifier representation used by `PlayerData`. Feature systems create it and identify their source; `PlayerData` recalculates attributes.

## Current integrations

`HatsuData` persists normalized tags and its optional `gameplay_conditions`. Hatsu activation merges player and target contexts, evaluates these resources and denies activation when a requirement is unmet. `NenSkillTree` now creates `StatModifier` directly.

## Extension rules

Add a condition type only when it is reusable by more than one domain. Keep world scans, target selection, timers and gameplay effects in the owning system; pass their result in the context. Future Skill Tree, enemy, boss, quest, event and HUD work should consume these interfaces rather than clone them.

## Validation

Test tag normalization/query behavior, each condition's true and false cases, Hatsu serialization round-trip, Hatsu activation denial, and Skill Tree modifier application/removal. Test save/load whenever persistent fields change.


---

## .agent/skills/hunter-development/SKILL.md

---
name: hunter-development
description: Develop, diagnose, or review the Hunter Online Godot project while preserving its canonical systems and applying the relevant project Bibles. Use for gameplay, world, UI, quest, combat, Nen, Hatsu, save, and architecture work in this repository.
---

# Hunter Online Development

Use this skill for changes and reviews in the Hunter Online Godot project. Build small, compatible increments that support a persistent, strategic Hunter x Hunter-inspired RPG world.

## Source of truth

Apply requirements in this order:

1. The user's current request.
2. The relevant project Bible, beginning with [the Bible index](../../docs/bibles/00_BIBLE_INDEX.md).
3. The existing implementation and scene structure.
4. Reasonable implementation decisions.

The Bibles define intended behavior. If they conflict with the existing code, investigate and report the conflict before a broad or breaking rewrite.

## Investigation and scope

Before changing code or scenes:

1. Locate and read the related scripts, scenes, resources, signals, groups, autoloads, and call sites.
2. Read only the Bibles governing the requested system. For cross-system work, also read `12_ARCHITECTURE_BIBLE.md` and `13_TESTING_DEBUG_BIBLE.md`.
3. Identify the canonical owner of state and rules. Reuse it rather than introducing parallel state or systems.
4. Make the smallest change that meets the request. Do not turn an unrelated request into a broad refactor.

## Canonical ownership

- `PlayerData` is the canonical player progression/state source.
- `CombatEngine` owns shared damage calculation and mitigation; callers integrate with it instead of duplicating formulas.
- The existing Nen system owns aura, techniques, and Nen progression.
- `QuestSystem` / `QuestManager` owns objective state, transitions, completion, and rewards.
- `SaveManager` owns persistent save/load lifecycle and compatibility.
- UI presents canonical state; it must not own gameplay state.
- Reuse the current NPC interaction, dialogue, world transition/spawn, Hatsu, and event systems when their responsibility already exists.

Do not casually rename persistent fields, autoloads, scripts, scenes, or resources. A persistent-data change requires a compatible migration strategy.

## Implementation rules

- Prefer Godot-native nodes, scenes, signals, resources, groups, and autoloads when appropriate.
- Keep responsibilities separated. Do not place unrelated system logic in `Player.gd` or UI controls.
- Centralize gameplay constants with the responsible system or data resource; do not spread formulas or magic values among callers.
- Keep Hatsu data-driven where practical. Aura cost, cooldown, restriction, affinity, ownership, and persistence must remain meaningful.
- Derive quest dialogue, portal gates, GPS, and mission progression from the canonical quest/progression state, never duplicate flags or coordinates.
- Distinguish ambient, mission, elite, boss, and event encounters. Scene transitions must not duplicate or lose required mission entities.
- Do not mask a defect with arbitrary guards, duplicated state, disabled functionality, or unexplained delays. Correct the cause.

## Validation and handoff

After a change, inspect affected resource paths, node paths, signal connections, types, and dependent callers. Run the narrowest meaningful Godot, system, or gameplay validation available. For progression changes, verify the affected save/load flow when feasible.

Report what was changed, what was validated, and any validation that could not be performed. Update the relevant documentation only when an architectural or persistent design decision changed.


---

## NEN_SKILL_TREE_BIBLE.md

# Nen Skill Tree Bible

## Current responsibility

`NenSkillTree` owns the unlocked nodes, prerequisites, Nen-point investment and Ryu path selection. `PlayerData` remains the source of player progression and owns the resulting active modifiers.

## Modifier integration

Every passive stat effect created by the Nen Skill Tree uses `StatModifier`. The tree must not define a second modifier representation or mutate base player attributes directly. Recalculation is performed through the existing `PlayerData` modifier pipeline.

## Current nodes

The current tree contains progression for Ten, Zetsu, Ren, Gyo, Ko, Ryu and a reserved Shu node. Its existing numerical effects remain compatible with the current Nen design; contextual nodes and cross-technique synergies are a subsequent expansion, not a replacement for those nodes.

## Contextual effects and synergies

Behavioral effects such as First Strike, Bloodied, Surrounded, Isolated Target and Hunter's Mark must be expressed using reusable `GameplayCondition` resources and canonical gameplay tags. A node should describe its effect and required conditions instead of embedding target scans or combat formulas in the tree itself.

## Persistence

Persist node levels and the selected Ryu path through the existing `PlayerData` and `SaveManager` flow. New nodes must default safely for older saves and must not invalidate existing progress.

## Validation

For any tree change, test prerequisite checks, point consumption, mutually exclusive Ryu paths, modifier application/removal, save/load and the affected combat behavior.

