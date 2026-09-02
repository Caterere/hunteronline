# SAVE DATA BIBLE

## Principle
Anything that represents meaningful player progression must be persisted when intended to survive closing the game.

## Character Data
Conceptual persistent data includes:
- character identity;
- appearance;
- level;
- XP;
- potential;
- physical attributes;
- HP state where appropriate;
- aura state where appropriate;
- Nen progression;
- Nen affinity;
- Hatsu definitions;
- Hatsu slots;
- inventory;
- currencies/credits;
- quests;
- story progression;
- unlocks.

## Lifecycle
Required flow:
Create Character → Save → Exit → Relaunch → Load → Continue.

## Load Validation
Loading must validate:
- file existence;
- schema version;
- required fields;
- missing optional fields;
- corrupted values.

## Versioning
Save data should have a schema version so future updates can migrate old characters.

## Atomicity
Saving should minimize the chance of leaving a partially written character.

## Regression Test
Every major save-system change must test:
1. fresh character;
2. save;
3. restart;
4. load;
5. verify progression;
6. modify;
7. save again;
8. reload.
