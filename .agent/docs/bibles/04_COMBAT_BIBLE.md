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
