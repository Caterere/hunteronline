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
