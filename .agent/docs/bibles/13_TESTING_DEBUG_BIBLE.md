# BIBLE DE TESTES E DEBUG

## Bug Workflow
REPRODUCE → ISOLATE → IDENTIFY ROOT CAUSE → FIX → REGRESSION TEST → DOCUMENT.

## Do Not
- hide errors;
- add arbitrary delays as a permanent fix;
- duplicate calls until something works;
- disable systems to avoid symptoms;
- declare success because the editor stopped showing an error.

## Test Levels
### Unit/System
Validate individual formulas and state transitions.

### Integration
Validate interactions between systems.

### Gameplay
Perform the actual player flow.

### Regression
Verify existing functionality after changes.

## Mandatory Regression Areas
When relevant, test:
- character creation;
- save/load;
- mission progression;
- portal gates;
- NPC interaction;
- dialogue;
- enemy spawn;
- combat;
- Nen;
- Hatsu;
- UI.

## Debugging
Prefer temporary diagnostic logging that can be removed or disabled after the root cause is known.

Logs should identify:
- system;
- event;
- entity;
- state;
- relevant IDs;
- expected vs actual value.

## Completion Standard
A fix is complete only when the original bug is resolved and the surrounding workflow still works.
