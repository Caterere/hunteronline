# BIBLE DE MUNDO E SPAWN

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
