# BIBLE DE PROGRESSÃO DO PERSONAGEM

## Attributes
Baseline physical attributes:
- Strength: 1–50 baseline design range.
- Defense
- Speed
- HP
- Aura
- Level

## Nen Progression
Nen progression is separate from ordinary character progression conceptually, even if stored in the same save structure.
Progression does NOT use an arbitrary "Nen Level" counter. Instead, it is governed by:
- Character Level & Potential IV.
- Nen XP (accumulated mastery through aura use and training).
- Nen Skill Points (`nen_skill_points`), awarded on level-ups and special achievements.
- Unlocks in the visual Nen Skill Tree (`NenSkillTree`), applying `StatModifier` passive and contextual bonuses.

## Potential / IV
Characters receive randomized potential in a baseline range of 60–100.

Potential affects XP gain from approximately 60% to 100%.

Potential affects:
- character XP;
- Nen XP.

Potential should not secretly modify unrelated stats unless explicitly designed.

## XP
XP should use an exponential/progressive curve so later levels require substantially more effort.

The exact formula belongs in balance data and must be changeable without rewriting progression code.

## Training
Training and rest are primary progression mechanisms for Nen and physical development.

The baseline design does not depend on consumable aura potions as the main recovery mechanism.

## Builds
The progression system must allow different builds rather than forcing every player toward one optimal stat distribution.
