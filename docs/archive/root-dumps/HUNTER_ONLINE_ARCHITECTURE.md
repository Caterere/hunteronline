# HUNTER ONLINE — ARCHITECTURE DOCUMENTATION

> Technical architecture reference for AI agents and developers.
>
> This document describes the intended architecture and relationships between major systems.
>
> **IMPORTANT:** The actual source code is authoritative. If this document conflicts with the implementation, inspect the implementation and update this document when appropriate.

---

# 1. PROJECT OVERVIEW

## Project

Hunter Online

## Engine

Godot 4.6

## Language

GDScript 2.0

## Genre

2D RPG / MMORPG

## Core Design

Hunter Online is a 2D RPG/MMORPG inspired by the Hunter x Hunter universe.

The game focuses heavily on:

- Story progression
- Missions
- Exploration
- NPC interaction
- Strategic combat
- Nen
- Hatsu
- Character progression
- Anime-inspired mechanics
- Persistent character progression

The project is designed as a collection of interconnected gameplay systems rather than one monolithic game controller.

---

# 2. ARCHITECTURAL PHILOSOPHY

The project follows these principles:

```text
Gameplay Systems
      ↓
Managers / Services
      ↓
Persistent Data
      ↓
EventBus / Signals
      ↓
UI / World / Entities
```

The exact implementation may differ between systems.

The important principle is:

> Gameplay state should be authoritative in the appropriate gameplay system, while UI and presentation systems reflect that state.

---

# 3. HIGH-LEVEL SYSTEM MAP

Conceptual architecture:

```text
                         ┌──────────────────┐
                         │   GameManager    │
                         └────────┬─────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
              ▼                   ▼                   ▼
       ┌────────────┐      ┌────────────┐      ┌────────────┐
       │ DataManager│      │ TimeManager│      │  EventBus  │
       └──────┬─────┘      └────────────┘      └──────┬─────┘
              │                                        │
              ▼                                        │
       ┌──────────────┐                                │
       │  PlayerData  │                                │
       └──────┬───────┘                                │
              │                                        │
      ┌───────┴────────┐                               │
      ▼                ▼                               ▼
┌──────────┐     ┌────────────┐                ┌────────────┐
│ NenSystem│     │HatsuSystem │                │MissionSystem│
└────┬─────┘     └─────┬──────┘                └──────┬─────┘
     │                  │                              │
     └──────────┬───────┴──────────────┬───────────────┘
                │                      │
                ▼                      ▼
        ┌───────────────┐      ┌────────────────┐
        │Combat Systems │      │ Dialogue/NPC   │
        └───────┬───────┘      └───────┬────────┘
                │                      │
                └──────────┬───────────┘
                           ▼
                    ┌─────────────┐
                    │     UI      │
                    └─────────────┘
```

This is a conceptual map, not a literal node hierarchy.

---

# 4. CORE MANAGERS

## 4.1 GameManager

Responsible for global game-level coordination.

Potential responsibilities:

- Game state
- Scene transitions
- Global gameplay coordination
- Access to major systems

Do not place feature-specific gameplay logic here unless the existing implementation already requires it.

Avoid turning GameManager into a "god object".

---

# 5. DATAMANAGER

DataManager is responsible for persistent and centralized gameplay data.

Typical responsibilities include:

- Character data
- Save/load operations
- Persistent progression
- Player state
- Mission state
- Nen state
- Hatsu state

Before changing persistent data:

```text
Find WRITE
   ↓
Find READ
   ↓
Find INITIALIZATION
   ↓
Check SAVE/LOAD
   ↓
Implement change
   ↓
Validate compatibility
```

Never modify a save field without checking every important reader/writer.

---

# 6. PLAYER DATA

Player data contains character progression and gameplay attributes.

Known attributes include:

```text
vida
vida_max
forca
defesa
velocidade
aura
aura_max
nivel
```

This list is not necessarily exhaustive.

The actual PlayerData implementation is authoritative.

Player data should represent state.

It should not contain large amounts of presentation logic.

---

# 7. EVENTBUS

EventBus provides decoupled communication between systems.

Conceptually:

```text
System A
   │
   │ emit event
   ▼
 EventBus
   │
   ├──────► System B
   ├──────► System C
   └──────► UI
```

Use EventBus when systems need to communicate without creating unnecessary direct dependencies.

Before adding a new event:

1. Search for an equivalent existing event.
2. Reuse it if possible.
3. Create a new event only if necessary.

Avoid event duplication.

---

# 8. TIMEMANAGER

TimeManager provides centralized time-related functionality.

Potential uses:

- Cooldowns
- Timers
- World time
- Scheduled events
- Gameplay timing

Systems that require persistent or coordinated timing should prefer the existing TimeManager architecture instead of creating independent global timers.

---

# 9. PLAYER ENTITY

The Player is the runtime representation of the player's character.

Typical responsibilities:

- Movement
- Animation
- Input
- Physical interaction
- Combat participation
- Interaction with NPCs
- World presence

The Player should not become the central owner of unrelated global systems.

For example:

```text
Player
  ↓
requests action

CombatSystem
  ↓
resolves combat

MissionSystem
  ↓
updates mission

DataManager
  ↓
persists state
```

---

# 10. STATE SYSTEM

The project may use State and StateMachine patterns for player behavior.

Typical states may include:

```text
Idle
Walk
Attack
Hit
Death
Interact
```

Exact states depend on the implementation.

When adding player behavior:

Prefer the existing state architecture instead of adding large conditional blocks to Player.gd.

---

# 11. NPC ARCHITECTURE

NPCs are world entities capable of interaction.

Conceptually:

```text
NPC
 │
 └── InteractionComponent
          │
          ▼
      Interaction
          │
          ▼
      Dialogue
          │
          ▼
   Mission progression
```

The exact implementation should be discovered from the source.

NPCs may participate in:

- Dialogue
- Missions
- Story progression
- Shops
- Training
- Hatsu creation
- Tutorials
- World events

---

# 12. INTERACTION COMPONENT

InteractionComponent provides reusable interaction behavior.

Typical responsibilities:

- Detect interaction
- Receive player/interactor
- Emit interaction signal
- Trigger NPC/object behavior

Conceptual flow:

```text
Player
  ↓
enters interaction range
  ↓
Input: interact
  ↓
InteractionComponent
  ↓
interacted(interactor)
  ↓
NPC / Object
```

Avoid implementing independent interaction detection for individual NPCs when InteractionComponent already provides the required behavior.

---

# 13. DIALOGUE SYSTEM

Dialogue is responsible for presentation and progression of conversations.

Potential architecture:

```text
NPC
 ↓
Dialogue request
 ↓
Dialogue System
 ↓
DialogueBox
 ↓
Dialogue completion
 ↓
Mission / Story system
```

Important distinction:

```text
Dialogue opened
≠
Dialogue completed
≠
Mission objective completed
```

Mission progression should explicitly validate the required condition.

---

# 14. MISSION SYSTEM

MissionSystem is one of the most important gameplay systems.

Conceptual hierarchy:

```text
Mission
 ├── Stage 1
 │    ├── Objective 1
 │    ├── Objective 2
 │    └── Objective 3
 │
 ├── Stage 2
 │    ├── Objective 1
 │    └── Objective 2
 │
 └── Stage N
```

Do not assume:

```text
Mission = Stage = Objective
```

These are separate concepts.

---

# 15. MISSION DATA MODEL

Conceptually:

```text
Mission
    ↓
Current Stage
    ↓
Current Objective
    ↓
Objective Type
    ↓
Objective Target
    ↓
Completion State
```

Potential objective types:

```text
TALK
KILL
COLLECT
REACH
INTERACT
ESCORT
DEFEAT
ENTER_AREA
COMPLETE_DIALOGUE
CUSTOM
```

The actual project implementation determines the valid types.

---

# 16. MISSION OBJECTIVE STATE

A mission objective should have a clearly identifiable state.

Conceptually:

```text
NOT_STARTED
      ↓
ACTIVE
      ↓
COMPLETED
```

Some objectives may additionally support:

```text
FAILED
BLOCKED
SKIPPED
```

Do not introduce new states without checking whether the existing system already models the requirement differently.

---

# 17. MISSION TARGETS

Targets are the actual world entities or locations associated with an objective.

Examples:

```text
Objective:
Talk to Wing

Target:
Wing NPC
```

```text
Objective:
Kill 3 Swamp Creatures

Target:
Swamp Creature
Required Count:
3
```

```text
Objective:
Reach Arena

Target:
Arena location
```

The distinction between objective and target is critical for GPS and gameplay validation.

---

# 18. MISSION COMPLETION

Mission completion should be determined by MissionSystem.

Avoid having individual systems independently decide that a mission is complete.

For example:

```text
Portal
NPC
GPS
UI
```

should not independently maintain mission completion.

Instead:

```text
Objective
   ↓
MissionSystem
   ↓
Mission complete
   ↓
Other systems react
```

---

# 19. MISSION PORTALS

A portal that advances mission progression must validate the authoritative mission state.

Conceptual flow:

```text
Player enters portal
        ↓
Portal asks MissionSystem
        ↓
Required objective complete?
      /       \
    NO         YES
    ↓           ↓
 BLOCK       PROGRESS
```

Never use player location alone to determine mission completion.

---

# 20. MISSION GPS

GPS should resolve the target of the current objective.

Conceptual pipeline:

```text
MissionSystem
      ↓
Current Stage
      ↓
Current Objective
      ↓
Objective Target
      ↓
Target Resolver
      ↓
World Position
      ↓
GPS
```

GPS should NOT simply resolve:

```text
Current Stage → generic location
```

when the objective contains a specific target.

---

# 21. GPS TARGET TYPES

Potential target categories:

```text
NPC
Enemy
Item
Location
Object
Area
Boss
Quest Marker
```

The resolver should use the actual objective's target definition.

Example:

```text
Objective:
Talk to Wing

GPS:
Wing.position
```

Example:

```text
Objective:
Kill Swamp Creature x3

GPS:
appropriate enemy/area target
```

---

# 22. COMBAT ARCHITECTURE

Combat involves multiple systems.

Conceptual structure:

```text
Player
  │
  ▼
HunterCombatSystem
  │
  ├── NenSystem
  │
  ├── HatsuSystem
  │
  ├── Enemy
  │
  └── MissionSystem
```

Combat resolution should remain separated from mission progression.

MissionSystem should react to relevant combat events rather than combat becoming responsible for mission logic.

---

# 23. ENEMY DEATH EVENTS

A generic enemy death event may be consumed by MissionSystem.

Conceptual flow:

```text
Enemy dies
   ↓
Combat/Enemy system emits event
   ↓
MissionSystem checks:
   ├── Is this enemy relevant?
   ├── Is the mission active?
   ├── Is this the correct stage?
   └── Is this the correct objective?
   ↓
Update objective
```

Do not globally increment mission counters for every enemy death.

---

# 24. ENEMY SPAWNING

Enemy spawning should distinguish between:

```text
WORLD ENEMY
MISSION ENEMY
STORY ENCOUNTER
BOSS
ARENA FIGHTER
TEMPORARY EVENT
```

Mission-specific spawning should not unnecessarily modify global world spawning.

Conceptually:

```text
Mission starts
      ↓
Mission spawn requirements
      ↓
Spawn mission entities
      ↓
Mission completes
      ↓
Cleanup / lifecycle handling
```

The actual lifecycle depends on the implementation.

---

# 25. ARENAS AND SPECIAL ENCOUNTERS

Special areas such as arenas may have their own encounter requirements.

Examples:

- Required fighters
- Story NPCs
- Combat waves
- Boss encounters

When debugging an arena:

Check:

```text
Scene loaded
    ↓
Encounter initialized
    ↓
Required entities spawned
    ↓
NPC interaction enabled
    ↓
Mission state synchronized
```

Do not assume that simply loading the scene guarantees encounter initialization.

---

# 26. NEN SYSTEM

Nen is a core progression and combat system.

Known Nen techniques include:

```text
TEN
REN
ZETSU
GYO
SHU
KO
EN
RYU
```

Nen interacts with:

- Player attributes
- Aura
- Combat
- Hatsu
- Training
- Progression

---

# 27. AURA

Aura is a persistent gameplay resource.

Known concepts include:

```text
aura
aura_max
```

Aura may affect:

- Nen techniques
- Hatsu
- Combat
- Abilities
- Resource management

When changing aura behavior, inspect all consumers.

Do not create a second aura resource inside a subsystem.

---

# 28. HATSU SYSTEM

Hatsu is a major character customization system.

Conceptually:

```text
Nen Type
    ↓
Hatsu Creation
    ↓
Hatsu Definition
    ↓
Hatsu Storage
    ↓
Hatsu Mastery
    ↓
Hatsu Equip
    ↓
Combat Usage
```

Potential components:

- Creation
- Ability definition
- Effects
- Requirements
- Costs
- Cooldowns
- Mastery
- Archive
- Active slots
- Progression locks

---

# 29. HATSU MASTERy

Hatsu is intended to reward specialization and repeated usage.

Conceptually:

```text
New Hatsu
   ↓
Low mastery
   ↓
Use ability
   ↓
Gain mastery
   ↓
Improve ability
```

Do not replace mastery with simple level-based scaling unless explicitly requested.

---

# 30. HATSU CREATION

Hatsu creation may involve player choices and Nen-related logic.

The architecture should keep:

```text
Player choices
        ↓
Hatsu definition
        ↓
Validation
        ↓
Creation
        ↓
Storage
```

Creation logic should not directly manipulate unrelated UI or mission state unless through appropriate interfaces/events.

---

# 31. HATSU ARCHIVE AND ACTIVE SLOTS

The Hatsu collection/archive is conceptually separate from active combat slots.

```text
Hatsu Archive
 ├── Hatsu A
 ├── Hatsu B
 ├── Hatsu C
 └── ...
```

Active combat configuration:

```text
Active Slots
 ├── Slot 1
 ├── Slot 2
 ├── Slot 3
 └── ...
```

Do not assume archive size equals active slot count.

---

# 32. HATSU ACQUISITION / SPECIAL MECHANICS

Special Hatsu mechanics may include:

- Ability stealing
- Nen draining
- Ability copying
- Restrictions
- Credits/resources
- Special conditions

These mechanics must obey the project's existing validation system.

Never allow an ability to be acquired simply because the UI requested it.

The authoritative system must validate:

```text
Requirement
   ↓
Cost
   ↓
Eligibility
   ↓
Restriction
   ↓
Acquisition
```

---

# 33. PROGRESSION GATES

Story-based systems may unlock functionality based on progression.

Examples:

```text
Story progression
      ↓
Saga completed
      ↓
Feature unlocked
```

For systems such as Hatsu creation:

Do not rely only on UI visibility.

The gameplay system should verify the actual progression requirement.

---

# 34. STORY / SAGAS

Story progression is composed of missions and stages.

Conceptually:

```text
Saga
 ├── Mission
 ├── Mission
 ├── Mission
 └── ...
```

Potential story progression:

```text
Hunter Exam
      ↓
Heavens Arena
      ↓
Yorknew
      ↓
Greed Island
      ↓
Chimera Ant
      ↓
Election
      ↓
Beyond / Ship
      ↓
Dark Continent
```

The actual game progression may evolve.

Do not hardcode story progression into unrelated systems.

---

# 35. TUTORIAL ARCHITECTURE

Tutorials should be state-driven.

Conceptual structure:

```text
Tutorial
 ↓
Current Step
 ↓
Required Action
 ↓
Completion
 ↓
Next Step
```

Avoid recursive or circular transitions such as:

```text
Step A
 ↓
Step B
 ↓
Step A
```

unless explicitly intended.

When a tutorial loops, inspect the state transition rather than adding arbitrary counters.

---

# 36. UI ARCHITECTURE

UI should primarily display state.

Conceptual architecture:

```text
Gameplay System
      ↓
Authoritative State
      ↓
Signal/Event
      ↓
UI
```

Examples:

```text
MissionSystem → Mission UI
MissionSystem → GPS
HatsuSystem → Hatsu UI
PlayerData → Character UI
DialogueSystem → DialogueBox
CombatSystem → Combat UI
```

Avoid:

```text
UI → directly modifies gameplay state
```

unless that behavior is intentionally part of the architecture.

---

# 37. SCENE ARCHITECTURE

Godot scenes represent runtime entities and environments.

Typical categories:

```text
World
Character
NPC
Enemy
UI
Mission
Interaction
Effects
```

Before changing a scene:

Check:
- Instantiation
- Node paths
- Script references
- Signals
- Groups
- Mission references

---

# 38. GROUPS

The project may use Godot groups for entity discovery.

Known examples may include:

```text
player
enemy
npc
```

Do not assume group names.

Search the project before depending on a group.

Avoid replacing reliable direct references with broad group searches unnecessarily.

---

# 39. NODE REFERENCES

When a system needs another entity:

Prefer the project's established reference mechanism.

Possible mechanisms include:

- Direct references
- Node paths
- Groups
- IDs
- Registries
- EventBus
- Managers

Do not introduce a new reference strategy simply because it is convenient for one feature.

---

# 40. RESOURCE / DATA-DRIVEN DESIGN

Where existing systems already use resources or structured data, prefer extending the data model rather than hardcoding mission-specific behavior.

Example:

Instead of:

```gdscript
if mission_id == "hunter_exam":
    ...
```

prefer a generic objective/data mechanism when the architecture supports it.

Mission-specific exceptions are acceptable when the behavior is genuinely unique.

---

# 41. SAVE / LOAD FLOW

Conceptual save flow:

```text
Gameplay state
      ↓
DataManager
      ↓
Serialized character data
      ↓
Save file
```

Load:

```text
Save file
      ↓
DataManager
      ↓
PlayerData / systems
      ↓
Runtime state
```

Every new persistent feature must define:

```text
Default value
Save representation
Load representation
Runtime representation
Migration behavior if needed
```

---

# 42. CHARACTER CREATION

Character creation should establish the initial persistent character state.

Conceptual flow:

```text
Character Creation
      ↓
Validate input
      ↓
Create PlayerData
      ↓
Initialize progression
      ↓
Save
      ↓
Enter game
```

A character should remain recoverable after restarting the game.

When debugging character creation persistence:

Inspect:

```text
Creation
 ↓
Save
 ↓
File existence
 ↓
Load
 ↓
Character selection
 ↓
Game initialization
```

Do not solve save bugs by forcing deletion of the character.

---

# 43. SCENE TRANSITIONS

Scene transitions should preserve required persistent state.

Conceptually:

```text
Current Scene
     ↓
Transition
     ↓
GameManager / Scene system
     ↓
New Scene
     ↓
Restore required runtime state
```

Persistent data should not depend exclusively on nodes from the previous scene.

---

# 44. PERFORMANCE CONSIDERATIONS

The project is large.

Avoid unnecessary global operations.

Avoid:

```text
get_tree().get_nodes_in_group(...)
```

every frame when an event-driven alternative exists.

Avoid repeatedly:

- Searching the scene tree
- Instantiating expensive objects
- Rebuilding UI
- Resolving static references
- Performing filesystem operations

Prefer cached references where appropriate.

Do not optimize code without evidence of a problem.

---

# 45. DEBUGGING STRATEGY

Debug from the symptom toward the authoritative state.

Example:

Problem:

```text
GPS points to wrong NPC
```

Do NOT immediately modify GPS.

Trace:

```text
GPS
 ↓
resolved target
 ↓
objective target
 ↓
current objective
 ↓
current stage
 ↓
mission state
```

The bug may exist upstream.

---

# 46. DEBUGGING CHECKLIST

When a system behaves incorrectly:

```text
1. Reproduce
2. Identify visible symptom
3. Identify authoritative state
4. Trace state backwards
5. Find first incorrect value
6. Fix source of incorrect state
7. Validate downstream behavior
```

Do not patch only the final visible symptom when the source is elsewhere.

---

# 47. COMMON BUG PATTERNS

## BUG: GPS points to wrong target

Investigate:

```text
Current Objective
Objective Target
Target ID
Target Resolution
World Position
GPS
```

---

## BUG: Portal bypasses mission requirement

Investigate:

```text
Portal
 ↓
Mission state
 ↓
Objective completion
 ↓
Required count
```

---

## BUG: Mission enemy disappears permanently

Investigate:

```text
Enemy lifecycle
 ↓
Mission lifecycle
 ↓
Scene lifecycle
 ↓
Spawn manager
 ↓
Respawn rules
```

---

## BUG: NPC interaction does nothing

Investigate:

```text
NPC scene
 ↓
NPC script
 ↓
InteractionComponent
 ↓
CollisionShape2D
 ↓
Signal
 ↓
Dialogue
 ↓
Mission integration
```

---

## BUG: Tutorial loops

Investigate:

```text
Current step
 ↓
Completion condition
 ↓
State transition
 ↓
Next step
```

Look for circular transitions.

---

## BUG: Save disappears after restart

Investigate:

```text
Character creation
 ↓
Save
 ↓
Save location
 ↓
Load
 ↓
Character list
 ↓
Selection
 ↓
Runtime initialization
```

---

# 48. AI AGENT SEARCH STRATEGY

When working on an unknown feature, search narrowly first.

Example:

```text
Task: Fix Mission GPS
```

Search:

```text
Mission
GPS
objective
target
marker
navigation
```

Then identify the smallest relevant dependency chain.

Do not immediately read the entire project.

---

# 49. AI AGENT CONTEXT STRATEGY

Use this hierarchy:

```text
AGENTS.md
    ↓
This architecture document
    ↓
Relevant source files
    ↓
Relevant scene files
    ↓
Specific task prompt
```

Do not copy large sections of this document into prompts.

The agent should consult this document when architectural context is required.

---

# 50. AI AGENT MODIFICATION STRATEGY

Before editing:

```text
Search
 ↓
Read
 ↓
Trace
 ↓
Plan
 ↓
Modify
 ↓
Validate
```

Avoid:

```text
Guess
 ↓
Rewrite
 ↓
Hope
```

---

# 51. MINIMAL CHANGE PRINCIPLE

If a bug can be fixed by changing one function, do not rewrite an entire system.

If three files are required, change three files.

If a new abstraction is necessary, create it deliberately.

The goal is:

> Minimum code change that produces correct behavior without damaging architecture.

---

# 52. TESTING ARCHITECTURE

Testing should occur at multiple levels.

## Level 1 — Static

Check:

- Syntax
- Parser errors
- References
- Signals
- Node paths

## Level 2 — System

Check:

- Mission state
- Combat state
- Hatsu state
- Save state

## Level 3 — Gameplay

Check the actual player flow.

Example:

```text
Start mission
 ↓
Perform objective
 ↓
Objective completes
 ↓
GPS updates
 ↓
Portal validates
 ↓
Next stage
```

---

# 53. REGRESSION TESTING

When changing a shared system, test the nearest related features.

Example:

Changing MissionSystem should potentially validate:

```text
Mission start
Objective progression
GPS
NPC interaction
Enemy kills
Rewards
Stage progression
Save/load
```

The scope of regression testing should match the risk of the change.

---

# 54. DOCUMENTATION MAINTENANCE

If a major architectural change is made, update this document.

Do not update documentation for trivial implementation details.

Update when:

- A major system is introduced
- A major system is removed
- Architecture changes
- Data flow changes
- Save format changes
- Mission architecture changes
- Hatsu architecture changes
- Communication architecture changes

---

# 55. SOURCE CODE AUTHORITY

This document is a guide.

The actual implementation is authoritative.

If documentation says:

```text
System A → System B
```

but source code shows:

```text
System A → EventBus → System B
```

trust the source code.

After discovering a significant discrepancy, update this document.

---

# 56. QUICK ARCHITECTURE REFERENCE

```text
PLAYER
 ├── Movement
 ├── Animation
 ├── Interaction
 └── Combat
       │
       ├── Nen
       └── Hatsu


MISSION
 ├── Mission
 │    ├── Stage
 │    │    ├── Objective
 │    │    │    └── Target
 │    │    └── Objective
 │    └── Stage
 │
 ├── GPS
 ├── NPC
 ├── Dialogue
 ├── Enemy
 └── Portal


PERSISTENCE
 └── DataManager
      ├── PlayerData
      ├── MissionData
      ├── NenData
      └── HatsuData


COMMUNICATION
 └── EventBus / Signals


UI
 ├── DialogueBox
 ├── Mission UI
 ├── GPS
 ├── Hatsu UI
 └── Combat UI
```

---

# 57. FINAL RULE FOR AI AGENTS

When working on Hunter Online:

```text
UNDERSTAND THE EXISTING SYSTEM
            ↓
FIND THE REAL SOURCE OF THE BUG
            ↓
CHANGE THE SMALLEST NECESSARY PART
            ↓
PRESERVE EXISTING DATA AND ARCHITECTURE
            ↓
TEST THE ACTUAL GAMEPLAY FLOW
            ↓
DOCUMENT MAJOR ARCHITECTURAL CHANGES
```

Never optimize for writing more code.

Optimize for:

- Correctness
- Compatibility
- Maintainability
- Minimal scope
- Consistency
- Gameplay integrity

# END OF ARCHITECTURE DOCUMENT