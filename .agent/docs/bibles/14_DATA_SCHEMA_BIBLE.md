# DATA SCHEMA BIBLE

## Purpose
This document defines conceptual canonical data rather than forcing every field into a single implementation.

## Player
Conceptual:
- id
- name
- appearance
- level
- xp
- potential
- attributes
- Nen data
- Hatsu data
- inventory
- currency
- quest state
- story state
- schema_version

## Attributes
Baseline:
- vida
- vida_max
- forca
- defesa
- velocidade
- aura
- aura_max
- nivel

## Nen
Conceptual:
- affinity/type
- technique progression
- aura control
- Nen XP

## Hatsu
Conceptual:
- id
- name
- category
- components
- cost
- cooldown
- restrictions
- level
- slot
- unlocked
- normalized gameplay tags
- serializable gameplay conditions

## Quest
Conceptual:
- quest_id
- current_step
- objectives
- objective_progress
- status
- prerequisites
- rewards
- repeatable
- timestamps when needed

## Migration
Any schema change must consider existing saves.

Never delete or rename a persistent field without a migration/compatibility strategy.
