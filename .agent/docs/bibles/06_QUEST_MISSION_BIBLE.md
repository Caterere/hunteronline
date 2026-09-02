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
