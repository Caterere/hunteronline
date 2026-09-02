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
