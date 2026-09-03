# BIBLE DE UI/UX

## Principles
UI should communicate state without requiring the player to inspect hidden systems.

## Required Feedback
Important actions should communicate:
- success;
- failure;
- unavailable requirement;
- cooldown;
- insufficient aura;
- mission progress;
- objective completion.

## Dialogue
Dialogue boxes must remain inside intended screen bounds and adapt to text length.

## Mission UI
Display:
- current objective;
- progress;
- optional objectives;
- completion state.

## Combat UI & Player HUD
Display clearly:
- Character Name & Level (`Nv. X`).
- Nen Affinity / Stance (`◈ Nen: Intensificação`).
- Available Skill Points badge (`⚡ X SP`).
- HP, Aura and XP gauges with current/max values and percentages.
- Active Nen technique badge (Ten, Ren, Zetsu, Gyo, Ko, Ken, En, Ryu).
- Dynamic tactical condition pills (Bloodied, First Strike, Surrounded, etc.).
- Banned from UI: obsolete labels like "Nen Level" or "NEN NV.".

## Skill Tree UI
The Skill Tree must be presented as an authentic video game 2D node graph:
- 2D layout organized across canonical pillars (Defense, Offense, Stances, Control, Stealth/Regen).
- Dynamic connection lines between prerequisite nodes and child techniques.
- Node states: Locked (🔒), Available to unlock (⚡), Mastered (⭐).
- Dedicated inspector drawer showing stats, tags, combat conditions and clear action buttons.
- Instantaneous initialization without artificial loading screens.

## GPS
Navigation should clearly indicate the active objective and update when objective state changes.

## Interaction
Interact prompts should only appear when interaction conditions are satisfied.

## Accessibility
Avoid communicating critical gameplay information through color alone.
