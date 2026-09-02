# NEN BIBLE

## Core Concept
Nen is the manipulation of aura. The player's Nen progression is central to combat and Hatsu.

## Techniques
### Ten
Maintains aura around the body. Defensive/basic aura control.

### Zetsu
Suppresses aura output. Useful for stealth, recovery and risk/reward situations.

### Ren
Increases aura output. Offensive pressure and aura-intensive actions.

### Gyo
Concentrates aura into a body part or sense, enabling enhanced perception and focused power.

### Shu
Extends aura into an object, empowering equipment or held objects.

### Ko
Concentrates an extreme amount of aura into one point, trading broad defense for focused power.

### En
Extends aura into an area for detection and awareness.

### Ryu
Dynamically redistributes aura between body regions according to tactical needs.

## Ryu Modes
The project supports:
- Offensive Ryu: favors attack/damage.
- Defensive Ryu: favors defense/survivability.
- Balanced Ryu: distributes benefits between offense and defense.

## Aura
Aura is a finite combat resource.
Relevant systems must respect `aura` and `aura_max`.

Suggested baseline from the project design:
- Outside combat: regeneration around 5% of maximum aura per second.
- In combat: regeneration around 3% of maximum aura per second.

These values are tunable balance values, not immutable engine constants.

## Nen Types
The six canonical affinities should remain represented:
- Enhancement
- Transmutation
- Conjuration
- Specialization
- Manipulation
- Emission

Affinity should influence Hatsu design and efficiency without preventing creative builds.

## Training
Nen techniques should be acquired/improved through training, progression, quests and/or controlled challenges rather than arbitrary instant unlocks.
