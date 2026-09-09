# HUNTER ONLINE — AGENTS.md

## 1. PROJECT IDENTITY

Project: Hunter Online  
Engine: Godot 4.6  
Language: GDScript 2.0  
Genre: 2D MMORPG / RPG  
Universe: Hunter x Hunter inspired

Hunter Online is a large-scale 2D RPG/MMORPG project focused on:
- Story progression
- Missions
- NPC interactions
- Nen
- Hatsu
- Combat
- Character progression
- Exploration
- Anime-faithful events and characters

The project is already established. Prefer extending existing systems over creating replacements.

---

# 2. CORE DEVELOPMENT PRINCIPLE

## MODIFY, DON'T REBUILD

Before creating a new system, class, manager, signal, resource, or utility:

1. Search the existing project.
2. Identify whether an equivalent already exists.
3. Reuse it whenever possible.
4. Extend the existing implementation if appropriate.
5. Only create something new when the existing architecture genuinely cannot support the requirement.

Do NOT duplicate functionality.

---

# 3. SCOPE CONTROL

Every task must have a clearly defined scope.

When the user requests a specific bug fix or feature:

- Work primarily on the systems directly related to the task.
- Do not refactor unrelated systems.
- Do not rename unrelated classes.
- Do not reorganize the project unnecessarily.
- Do not rewrite working systems simply because a different architecture might be cleaner.
- Do not modify unrelated scenes or assets.
- Do not "improve" unrelated code without explicit permission.

### IMPORTANT

A bug fix is NOT an invitation to perform a project-wide refactor.

If fixing Mission GPS requires modifying 3 files, modify those 3 files.

Do not modify 30 files because they are theoretically related.

---

# 4. AGENT WORKFLOW

For every development task, follow this sequence:

## STEP 1 — LOCATE

Search the project for the systems directly related to the requested task.

Do not immediately edit files.

Identify:
- Main script
- Supporting scripts
- Relevant scenes
- Relevant signals
- Relevant data structures

## STEP 2 — UNDERSTAND

Read only the relevant portions of the identified files.

Determine:
- Current behavior
- Expected behavior
- Where the behavior is decided
- Dependencies
- Existing events/signals

## STEP 3 — PLAN

Before making substantial changes, briefly determine:

- Root cause
- Files that need modification
- Minimal implementation required

Avoid large speculative plans.

## STEP 4 — IMPLEMENT

Make the smallest safe change that solves the requested problem.

Preserve:
- Existing APIs
- Existing save data
- Existing signals
- Existing scene structure
- Existing gameplay behavior

unless changing them is necessary.

## STEP 5 — VALIDATE

After implementation:

- Check for GDScript syntax/parser errors.
- Check references to renamed/removed properties.
- Check signal connections.
- Check scene references.
- Check null/invalid references.
- Check that the original behavior still works.
- Check that the requested behavior now works.

## STEP 6 — REPORT

At the end, report briefly:

1. Root cause
2. Files changed
3. What was changed
4. Validation performed
5. Any remaining limitation

Do not produce a huge explanation unless requested.

---

# 5. EXISTING ARCHITECTURE

The project contains several major systems.

Important known systems include:

- EventBus
- GameManager
- DataManager
- TimeManager
- Mission systems
- Dialogue systems
- NPC systems
- Player systems
- HunterCombatSystem
- NenSystem
- HatsuSystem
- Save/Load systems
- UI systems
- GPS/navigation systems

These names are architectural references, not permission to assume their exact implementation.

ALWAYS inspect the actual project before modifying them.

---

# 6. EVENT-DRIVEN ARCHITECTURE

Prefer existing events and signals over tightly coupling unrelated systems.

Before creating a new signal:

1. Search for an existing signal/event that represents the same event.
2. Reuse it if possible.
3. If a new signal is necessary, follow the existing project's naming and architecture.

Avoid direct references between unrelated systems when EventBus or an existing signal is already intended for communication.

---

# 7. DATA AND SAVE SYSTEM

Save compatibility is extremely important.

Never casually change:
- Save keys
- Character identifiers
- Mission state structures
- Progression data
- Nen data
- Hatsu data
- Player attributes

Before changing persistent data:

1. Search where it is written.
2. Search where it is read.
3. Search where it is initialized.
4. Consider existing saved characters.
5. Preserve backward compatibility whenever possible.

Never invalidate existing player saves just to simplify implementation.

---

# 8. PLAYER DATA

Known player attributes include concepts such as:

- vida
- vida_max
- forca
- defesa
- velocidade
- aura
- aura_max
- nivel

Do not assume these are the only attributes.

Search the actual PlayerData implementation before modifying player attributes.

---

# 9. NEN SYSTEM

Nen techniques currently include concepts such as:

- TEN
- REN
- ZETSU
- GYO
- SHU
- KO
- EN
- RYU

The Nen system should remain strategically oriented and consistent with the Hunter x Hunter-inspired design.

Do not simplify Nen mechanics merely to make implementation easier.

When modifying Nen:

- Preserve existing technique relationships.
- Preserve aura calculations.
- Preserve combat integration.
- Preserve progression.
- Avoid hardcoded values when the existing system already provides configuration/data.

---

# 10. HATSU SYSTEM

Hatsu is a core gameplay system.

Priorities:

- Player-created abilities
- Ability progression
- Mastery
- Nen compatibility
- Cooldowns
- Damage/effects
- Ability storage/archive
- Ability acquisition
- Ability usage
- Story progression requirements

Before modifying Hatsu:

Search for the existing implementation and understand how:

- Hatsu is created
- Hatsu is stored
- Hatsu is loaded
- Hatsu is equipped
- Hatsu is used
- Hatsu mastery progresses
- Hatsu requirements are validated

Do not create a second Hatsu architecture.

---

# 11. MISSION SYSTEM

Missions are state-driven gameplay sequences.

A mission may contain:

- Stages
- Objectives
- NPC interactions
- Enemy objectives
- Locations
- Dialogue
- Combat
- Rewards
- Progression requirements
- Portals
- GPS targets

## CRITICAL RULE

Never assume that "current stage" and "current objective" are the same thing.

A stage may contain multiple objectives.

The system must distinguish between:

- Mission
- Stage
- Objective
- Objective target
- Completion condition

When fixing mission progression, inspect the actual data flow.

---

# 12. MISSION OBJECTIVES

Objectives can represent different types of requirements.

Examples:

- Talk to NPC
- Kill enemy
- Reach location
- Enter area
- Collect item
- Interact with object
- Defeat specific target
- Complete dialogue
- Complete multiple requirements

Do not implement a special-case solution for one mission if the existing architecture is intended to support generic objectives.

Prefer extending the generic objective system.

---

# 13. MISSION PROGRESSION

Mission progression must be validated by the mission system.

Do not rely exclusively on:
- Scene changes
- Player position
- Portal entry
- UI state
- Dialogue state

If a portal requires mission completion, the portal must consult the authoritative mission state.

Example:

BAD:

```gdscript
if player_inside_portal:
    next_stage()
```

BETTER:

```gdscript
if mission_manager.is_current_objective_complete():
    next_stage()
```

Use the project's actual MissionSystem implementation rather than copying this example literally.

---

# 14. MISSION GPS

The GPS/navigation system must identify the actual target of the current objective.

Examples:

If the objective is:

"Talk to Wing"

GPS should target Wing.

If the objective is:

"Kill 3 Swamp Creatures"

GPS should identify the appropriate enemy/objective area or target according to the mission design.

If the objective changes:

NPC → Enemy → Location → NPC

the GPS must update accordingly.

Do not make GPS simply point to "the next stage".

The authoritative source should be the current mission objective/target.

Before modifying GPS:

Search for:
- Mission state
- Current stage
- Current objective
- Objective target
- GPS target resolution
- NPC/entity identifiers
- World positions

---

# 15. NPC SYSTEM

NPC interactions should use the existing interaction architecture.

Before modifying NPC interaction:

Search for:
- NPC base class
- InteractionComponent
- interaction signals
- DialogueBox
- dialogue manager/system
- mission objective validation

Do not create a separate interaction system for a single NPC.

---

# 16. COMBAT SYSTEM

Combat currently integrates with systems such as:

- Player
- Nen
- Hatsu
- Enemy
- Mission objectives

When modifying combat:

Do not break mission kill tracking.

A mission requiring:

"Kill 3 specific enemies"

must distinguish between:

- Any enemy killed
- Correct objective enemy killed
- Required quantity
- Correct mission/stage

Do not globally count every enemy kill unless the mission explicitly requires it.

---

# 17. ENEMY SPAWNING

Mission enemies and normal world enemies may have different spawning requirements.

When modifying enemy spawning:

Determine whether the enemy is:

- World enemy
- Mission objective
- Temporary encounter
- Story encounter
- Arena fighter
- Boss
- Event enemy

Do not globally change respawn behavior to solve a mission-specific problem.

A mission-specific spawn rule should remain mission-specific whenever possible.

---

# 18. DIALOGUE SYSTEM

Dialogue may affect:

- Mission progression
- NPC interaction
- Story progression
- Hatsu progression
- Tutorial progression

When modifying dialogue:

Check whether dialogue completion emits or triggers mission progression.

Do not assume closing the dialogue means the objective is complete.

The system should distinguish between:

- Dialogue opened
- Dialogue displayed
- Dialogue completed
- Required dialogue completed
- Mission objective completed

---

# 19. TUTORIAL SYSTEM

Tutorials must not rely on loops or repeated state transitions.

When fixing a tutorial:

Track explicitly:

- Current tutorial step
- Completed step
- Required action
- Next step
- Completion condition

If a tutorial gets stuck in a loop, identify the state transition causing the loop rather than adding arbitrary flags.

---

# 20. UI

UI should reflect authoritative game state.

Do not make UI responsible for deciding gameplay progression.

Examples:

BAD:

```text
UI says mission complete → unlock portal
```

BETTER:

```text
MissionSystem → mission complete
UI reflects mission complete
Portal checks MissionSystem
```

The same principle applies to:

- GPS
- Mission markers
- Objective text
- Dialogue UI
- Hatsu UI
- Combat UI

---

# 21. HARDCODING

Avoid unnecessary hardcoded gameplay values.

Prefer:

- Existing configuration
- Data resources
- Dictionaries
- Mission data
- Existing constants
- Existing managers

However, do not create an elaborate configuration framework for a simple value.

Use the simplest architecture consistent with the existing project.

---

# 22. ERROR HANDLING

Do not hide errors.

Avoid using defensive code that silently ignores broken references just to prevent crashes.

Bad:

```gdscript
if target == null:
    return
```

when a missing target represents an actual broken mission state.

Instead, determine whether the missing target is:
- Expected
- Optional
- Invalid
- A real bug

For unexpected states, prefer useful diagnostics/logging consistent with the project.

---

# 23. DEBUGGING

When debugging:

Prefer identifying the actual state transition that causes the problem.

Use temporary logging when necessary.

Example:

```gdscript
print("Mission objective changed: ", objective_id)
```

Remove unnecessary debug spam after the issue is resolved unless the logging is intentionally part of the project's debugging architecture.

---

# 24. PERFORMANCE

Do not optimize prematurely.

However, avoid obviously expensive patterns such as:

- Searching the entire scene tree every frame
- Repeated filesystem operations during gameplay
- Repeated creation/destruction of large objects
- Unnecessary polling when signals/events already exist

For GPS, mission, combat and NPC systems, prefer event-driven updates when the architecture supports them.

---

# 25. CODE QUALITY

Follow the existing project's conventions.

Prefer:

- Clear names
- Small functions
- Single responsibility
- Existing types
- Existing architecture
- Minimal duplication

Avoid:

- Giant functions
- Duplicate managers
- Duplicate systems
- Unnecessary abstractions
- Premature optimization
- Massive refactors

Readable code is more important than clever code.

---

# 26. SCENE SAFETY

Before modifying a `.tscn`:

Check whether the scene is referenced by:

- Other scenes
- Scripts
- Instantiation
- Mission data
- NPC data
- Save data
- UI
- World maps

Do not casually rename or remove nodes that may be referenced elsewhere.

---

# 27. ASSET SAFETY

Do not replace or regenerate assets unless explicitly requested.

When modifying pixel-art assets:

- Preserve the project's established visual style.
- Preserve character proportions.
- Preserve sprite scale.
- Preserve animation compatibility.
- Do not introduce significantly more detail than the existing style.
- Do not change the visual direction of the project without explicit instruction.

Hunter Online uses a deliberately stylized pixel-art aesthetic.

## NEW CONTENT REQUIRES NEW SPRITES (PixelLab MCP)

Not replacing existing art does NOT mean shipping new content without art.

Whenever you add a **new enemy** or a **new scenario/map** (or a new NPC/prop),
you MUST generate its sprites/tiles with the **PixelLab MCP**
(`https://api.pixellab.ai/mcp`, docs: `https://api.pixellab.ai/mcp/docs`),
following the game's Hunter x Hunter pixel-art standard. Do NOT leave a new
enemy/NPC reusing `player.png` or a placeholder as the final asset.

Rules for generated assets:

- Follow the Style Lock in `docs/bibles/PIXEL_ART_STYLE_BIBLE.md` (and
  `.agent/docs/bibles/16_PIXEL_ART_STYLE_BIBLE.md`): 48x48 frames, chibi
  ~2.5-head proportion, 20-22px body height, feet at Y=42, flat shading,
  reduced palette (≈11-14 colors/frame). Style anchor: `assets/sprites/characters/player.png`.
- Characters/enemies: 8-direction idle sheet `assets/sprites/characters/<id>_8dir.png`
  plus walk sheet `<id>_walk_8x8.png` (enemies use the `enemy_<id>_...` prefix so
  `EnemySystem._vincular_textura_inimigo()` binds them; NPCs use `npc_<name>_...`).
- Map objects/landmarks: single high-top-down prop in `assets/sprites/objects/`.
- Scenarios/tilesets: use PixelLab `create_topdown_tileset`; keep tiles in
  `assets/sprites/tilesets/pixellab/`.
- Validate every character/enemy sheet with `tools/validate_sprite_style.gd`
  before wiring it in, and register the asset in `docs/systems/ASSET_REGISTRY.md`
  (asset name, PixelLab ID, description, size, directions, map, project path).
- The base flow and tools live in `docs/systems/PIXELLAB_MCP.md`. The MCP needs a
  local `.cursor/mcp.json` with a Bearer token (gitignored — never commit it). If
  the MCP is unavailable, use the REST fallback in `scripts/tools/pixellab_*`; if
  neither is available, state that the sprite step is pending rather than shipping
  a placeholder as final.

---

# 28. ANIME FIDELITY

Hunter Online is inspired by Hunter x Hunter.

When implementing story, characters, Nen or Hatsu mechanics:

Prioritize:
1. Strategic gameplay
2. Internal consistency
3. Anime-inspired logic
4. Existing Hunter Online design
5. Balance

Do not introduce mechanics that fundamentally contradict established Nen logic without explicit design approval.

---

# 29. DO NOT GUESS

If a behavior depends on existing project code:

SEARCH THE PROJECT.

Do not invent:
- Class names
- Function names
- Signals
- Node paths
- Data structures
- Save keys
- Mission IDs
- NPC IDs
- Resource formats

Use the actual implementation.

---

# 30. WHEN INFORMATION IS UNCLEAR

Do not stop the entire task unnecessarily.

Use this priority:

1. Inspect the project.
2. Infer from existing architecture.
3. Make the smallest safe assumption.
4. Implement if the requirement is sufficiently clear.
5. Ask the user only when the ambiguity materially affects the result.

Never ask for information that can be discovered by searching the project.

---

# 31. TASK SIZE

Prefer small, atomic tasks.

GOOD:

- Fix Mission GPS target resolution.
- Fix portal mission validation.
- Fix Elena tutorial progression.
- Fix enemy respawn for mission instances.
- Fix Wing interaction in Celestial Arena.

BAD:

- "Rewrite the entire mission system."

For large tasks, divide them into smaller implementation stages.

---

# 32. MULTI-FILE CHANGES

Changing multiple files is acceptable when necessary.

Before editing, identify the dependency chain.

Example:

```text
MissionSystem
    ↓
MissionObjective
    ↓
ObjectiveTarget
    ↓
GPS
```

Modify only the required parts.

Do not change unrelated systems simply because they are nearby in the architecture.

---

# 33. TESTING PRIORITY

For every bug fix, test the actual user-visible scenario.

Example:

If fixing:

"Portal can be entered before killing 3 enemies"

Do not only test:

```text
mission.is_complete() == true
```

Also test:

1. Enter mission.
2. Attempt portal immediately.
3. Portal blocks progression.
4. Kill required enemies.
5. Objective updates.
6. Objective becomes complete.
7. Portal allows progression.

Test the real gameplay flow whenever possible.

---

# 34. REGRESSION SAFETY

After fixing a system, verify the closest related behavior.

Examples:

### Mission GPS
Also verify:
- Objective changes
- NPC target
- Enemy target
- Location target

### Mission completion
Also verify:
- Rewards
- Stage progression
- Save state

### Hatsu
Also verify:
- Creation
- Storage
- Equipping
- Usage
- Mastery

### Dialogue
Also verify:
- NPC interaction
- Mission progression

---

# 35. RESPONSE FORMAT

After completing a task, use this concise format:

## Completed

### Root cause
Short explanation.

### Changes
- File — change
- File — change

### Validation
- Parser/syntax checked
- Relevant flow tested
- Regression checked

### Notes
Only mention remaining issues or limitations.

Do not dump entire files into the response unless explicitly requested.

---

# 36. MOST IMPORTANT RULES

If there is a conflict between convenience and project safety:

1. Preserve existing functionality.
2. Preserve save compatibility.
3. Reuse existing architecture.
4. Keep scope narrow.
5. Avoid duplicate systems.
6. Validate real gameplay behavior.
7. Do not guess existing project structures.
8. Make the smallest change that correctly solves the problem.

# END