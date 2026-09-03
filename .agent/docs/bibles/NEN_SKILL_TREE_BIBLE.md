# Nen Skill Tree Bible

## Current responsibility

`NenSkillTree` owns the unlocked nodes, prerequisites, Nen-point investment and Ryu path selection. `PlayerData` remains the source of player progression and owns the resulting active modifiers.

## Modifier integration

Every passive stat effect created by the Nen Skill Tree uses `StatModifier`. The tree must not define a second modifier representation or mutate base player attributes directly. Recalculation is performed through the existing `PlayerData` modifier pipeline.

## Current nodes

The current tree contains progression for Ten, Zetsu, Ren, Gyo, Ko, Ryu and a reserved Shu node. Contextual behavioral nodes (`first_strike`, `bloodied`, `surrounded`, `isolated_target`, `hunters_mark`) and cross-technique synergies (`ken_mastery`, `in_mastery`, `en_expansion`) are fully integrated as modular extensions using canonical `GameplayCondition`, `GameplayTags` and `StatModifier`.

## Contextual effects and synergies

Behavioral effects (First Strike, Bloodied, Surrounded, Isolated Target, Hunter's Mark) are expressed using reusable `GameplayCondition` resources and canonical gameplay tags:
- `first_strike`: evaluated via `NO_DAMAGE_FOR_SECONDS` (4.0s).
- `bloodied`: evaluated via `PLAYER_HP_BELOW` (0.35).
- `surrounded`: evaluated via `ENEMIES_NEARBY_AT_LEAST` (3 enemies).
- `isolated_target`: evaluated via `SINGLE_TARGET` (1 enemy).
- `hunters_mark`: evaluated via `TARGET_MARKED`.
- `en_expansion`: evaluated via `PLAYER_IN_EN`.

Cross-technique synergies (`ken_mastery`, `in_mastery`) combine prerequisites across fundamental techniques (Ten + Ren, Zetsu + Gyo) without duplicating `HatsuManager` elemental tag synergies. Contextual modifiers are dynamically managed via `atualizar_modificadores_contextuais()` using `PlayerData.adicionar_modificador` with source `"nen_skill_tree_contextual"`.

## Canonical Lifecycle & Ownership

`NenSkillTree` is instantiated and owned permanently by `PlayerData` as a child node on initialization (`PlayerData.skill_tree`), and is immediately registered in group `"nen_skill_tree"`. It synchronizes with `PlayerData.nen_skill_points`, `PlayerData.nen_skill_tree_progress`, and `PlayerData.nen_ryu_caminho`, restoring all invested node levels and recalculating stat modifiers upon startup or save loading.

## Visual Tree Architecture & UI

The Nen Skill Tree UI (`NenSkillTreeUI.gd`) is built as a complete 2D RPG/MMORPG skill graph:
- **Zero-loading guarantee**: UI obtains `skill_tree` directly from `PlayerData.skill_tree` with 0ms loading time.
- **Dynamic 2D Graph Canvas**: Draws anti-aliased connection lines (`_draw`) between prerequisites and dependent techniques. Line styles reflect connectivity (locked, ready to unlock, mastered).
- **5 Pillars of Mastery**:
  1. *Defense*: Ten I–V, Ken Mastery, Bloodied.
  2. *Offense*: Ren I–V, Ko I–V, First Strike, Isolated Target.
  3. *Equilibrium & Stances*: Shu I, Ryu Balanced, Ryu Offensive, Ryu Defensive.
  4. *Control & Perception*: Gyo I–V, En Expansion, Surrounded, Hunter's Mark.
  5. *Stealth & Recovery*: Zetsu I–III, In Mastery.
- **Node States**: Locked (🔒, muted border), Available to Unlock (⚡, pulsing green border), Mastered (⭐, gold aura fill).
- **Lateral Inspector**: Displays canonical technique lore, category badge, exact stat modifiers, combat conditions, tags, and action buttons (`[ ⚡ DESBLOQUEAR (-1 SP) ]` or `[ ⭐ TÉCNICA DOMINADA ]`).
- **Archetype Filters**: Quick tabs for full tree, defense, offense, control, stances, synergies, and tactical nodes.

## Persistence

Node levels, skill points and the selected Ryu path are persisted through `PlayerData` and `SaveManager` (`nen_skill_points`, `nen_skill_tree_progress`, `nen_ryu_caminho`). Older saves default missing nodes to 0 and restore invested progression without data loss.

## Validation

All tree behaviors and visual UI components are verified by `scratch/test_skill_tree_contextual_suite.gd` and `scratch/test_nen_ui_and_hud_redesign_suite.gd`, testing prerequisites, point consumption, True/False condition evaluations, modifier lifecycle, Ryu exclusivity, CombatEngine context integration, SaveManager round-trips, and zero-loading UI instantiation.
