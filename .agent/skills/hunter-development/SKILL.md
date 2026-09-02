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
