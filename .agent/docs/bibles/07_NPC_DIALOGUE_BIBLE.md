# NPC & DIALOGUE BIBLE

## NPC Principles
NPCs should have:
- identity;
- role;
- location;
- interaction rules;
- dialogue state;
- quest relationships;
- progression requirements where needed.

## Interaction
Use the existing interaction architecture when possible, including InteractionComponent and the project's NPC interaction conventions.

## Dialogue
Dialogue should be state-aware.

An NPC may show different dialogue depending on:
- quest state;
- player progression;
- saga;
- previous choices;
- Hatsu/Nen progression;
- mission completion.

## Tutorial NPCs
Tutorial NPCs must not create infinite dialogue loops.

A tutorial step should transition exactly when its completion condition is satisfied.

## NPC Quest Integration
Dialogue options that start or advance quests must call the canonical quest system rather than maintaining a duplicate quest state.

## Availability
NPC interactions may be gated by story progression, but the reason should be explicit and debuggable.
