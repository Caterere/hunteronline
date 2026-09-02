# BIBLE DE HATSU

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
