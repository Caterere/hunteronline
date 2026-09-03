# Documentação completa

Reunião dos documentos Markdown presentes no projeto. Identificadores de código, nomes próprios e tags permanecem no formato técnico original.

## Índice

- .agent/docs/bibles/00_BIBLE_INDEX.md
- .agent/docs/bibles/01_GAME_DESIGN_BIBLE.md
- .agent/docs/bibles/02_NEN_BIBLE.md
- .agent/docs/bibles/03_HATSU_BIBLE.md
- .agent/docs/bibles/04_COMBAT_BIBLE.md
- .agent/docs/bibles/05_CHARACTER_PROGRESSION_BIBLE.md
- .agent/docs/bibles/06_QUEST_MISSION_BIBLE.md
- .agent/docs/bibles/07_NPC_DIALOGUE_BIBLE.md
- .agent/docs/bibles/08_WORLD_SPAWN_BIBLE.md
- .agent/docs/bibles/09_SAVE_DATA_BIBLE.md
- .agent/docs/bibles/10_UI_UX_BIBLE.md
- .agent/docs/bibles/11_CONTENT_DESIGN_BIBLE.md
- .agent/docs/bibles/12_ARCHITECTURE_BIBLE.md
- .agent/docs/bibles/13_TESTING_DEBUG_BIBLE.md
- .agent/docs/bibles/14_DATA_SCHEMA_BIBLE.md
- .agent/docs/bibles/15_GAMEPLAY_FOUNDATION_BIBLE.md
- .agent/docs/lore/HUNTER_CANON_LORE_ENCYCLOPEDIA.md
- .agent/skills/hunter-development/SKILL.md
- NEN_SKILL_TREE_BIBLE.md
- TASKS_FUTURAS.md

---

## .agent/docs/bibles/00_BIBLE_INDEX.md

# HUNTER ONLINE — ÍNDICE DAS BIBLES

## Objetivo
Estas Bibles definem O QUE é o MMORPG Hunter e como seus sistemas devem funcionar. Elas complementam `.agent/skills/hunter-development/SKILL.md`, que define COMO o agente deve desenvolver o projeto.

## Source of Truth
Priority:
1. Explicit user requirements for the current task
2. This Bible set
3. Existing project architecture and implementation
4. Agent assumptions

If code conflicts with the Bibles, do not silently rewrite the project. Analyze the conflict and report it.

## Bibles
- 01_GAME_DESIGN_BIBLE.md — global game rules and philosophy
- 02_NEN_BIBLE.md — Nen fundamentals and techniques
- 03_HATSU_BIBLE.md — Hatsu creation, categories and custom abilities
- 04_COMBAT_BIBLE.md — combat, damage, defense, aura and Ryu
- 05_CHARACTER_PROGRESSION_BIBLE.md — attributes, level, potential and progression
- 06_QUEST_MISSION_BIBLE.md — quests, objectives, stages and progression gates
- 07_NPC_DIALOGUE_BIBLE.md — NPCs, interactions and dialogue
- 08_WORLD_SPAWN_BIBLE.md — maps, portals, spawning and encounter rules
- 09_SAVE_DATA_BIBLE.md — persistence and character lifecycle
- 10_UI_UX_BIBLE.md — interfaces and player feedback
- 11_CONTENT_DESIGN_BIBLE.md — enemies, bosses, rewards and content scaling
- 12_ARCHITECTURE_BIBLE.md — system responsibilities and integration rules
- 13_TESTING_DEBUG_BIBLE.md — validation, regression and QA standards
- 14_DATA_SCHEMA_BIBLE.md — canonical data structures and persistence concepts
- NEN_SKILL_TREE_BIBLE.md (raiz do repositório) — responsabilidade atual da Skill Tree de Nen, integração de modificadores e regras de expansão
- 15_GAMEPLAY_FOUNDATION_BIBLE.md — condições, tags e integração de modificadores reutilizáveis
- TASKS_FUTURAS.md (raiz do repositório) — roadmap, dependências, critérios e status de execução


---

## .agent/docs/bibles/01_GAME_DESIGN_BIBLE.md

# BIBLE DE DESIGN DO JOGO

## Identity
A 2D MMORPG/RPG inspired by Hunter x Hunter, built around strategy, Nen, Hatsu customization, exploration, progression and meaningful player choices.

## Core Pillars
1. Strategy over raw button-mashing.
2. Nen is a core gameplay system, not a cosmetic layer.
3. Hatsu should support different builds.
4. Player progression must feel persistent.
5. World progression must respect mission requirements.
6. Systems should interact rather than exist as isolated minigames.
7. Content should remain extensible.

## World Structure
The game may use semi-open regions connected by missions, portals, towns, hubs, instances and story progression.

## Story
The player can coexist with the Hunter x Hunter-inspired storyline and major saga structure while having their own progression and missions.

Planned broad progression includes Hunter Exam, Heaven's Arena, Yorknew, Greed Island, Chimera Ant and later content such as the Black Whale/Dark Continent direction.

## Design Rule
Anime-inspired content should preserve the strategic philosophy of Nen while gameplay numbers may be adapted for balance.


---

## .agent/docs/bibles/02_NEN_BIBLE.md

# BIBLE DE NEN

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


---

## .agent/docs/bibles/03_HATSU_BIBLE.md

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


---

## .agent/docs/bibles/04_COMBAT_BIBLE.md

# BIBLE DE COMBATE

## Combat Philosophy
Combat should reward positioning, timing, Nen management, build knowledge and tactical decisions.

## Core Resources
Player combat uses:
- HP
- Max HP
- Aura
- Max Aura
- Strength
- Defense
- Speed
- Level
- Hatsu

## Baseline Attributes
Current project data convention includes:
`vida`, `vida_max`, `forca`, `defesa`, `velocidade`, `aura`, `aura_max`, `nivel`.

Do not rename existing fields casually. If schema evolution is necessary, provide migration/compatibility handling.

## Damage
Damage should be calculated through a centralized combat system rather than scattered formulas.

Generic conceptual model:
Final Damage = Base Power × scaling factors × offensive modifiers × defensive mitigation.

Exact coefficients belong to balance data, not hardcoded across multiple scripts.

## Aura
Aura-intensive attacks should consume aura.
A player should not be able to execute abilities that require more aura than available unless the ability explicitly supports an overdraw mechanic.

## Cooldowns
Cooldowns belong to the ability state/system and must not be reset accidentally by scene changes, repeated signals or UI interactions.

## Death
Death must produce a deterministic state transition and cleanly notify relevant systems such as missions, spawning and UI.

## Enemy Combat
Enemies should use the same conceptual combat rules where practical. Special bosses may have controlled exceptions.


---

## .agent/docs/bibles/05_CHARACTER_PROGRESSION_BIBLE.md

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


---

## .agent/docs/bibles/06_QUEST_MISSION_BIBLE.md

# BIBLE DE QUESTS E MISSÕES

## Mission Principle
A mission is a state machine with explicit objectives and completion conditions.

## Objective Types
Supported conceptual objectives:
- kill
- collect
- talk
- escort
- protect
- reach location
- survive
- interact
- use ability
- defeat boss
- complete prerequisite
- conditional objective

## Progression Gate
A portal, NPC, cutscene or next stage must not advance the mission unless its required objectives are satisfied.

Example:
If the mission requires killing 3 swamp creatures, entering the next portal must not complete the stage before `3/3`.

## Multi-Step Missions
Saga missions may contain many stages. The project target can support missions with approximately 20 meaningful steps when appropriate.

Each step should have:
- objective;
- state;
- completion condition;
- failure condition when applicable;
- reward;
- next-step transition.

## Repeatable Missions
Repeatable side missions should explicitly define:
- reset conditions;
- reward;
- cooldown if any;
- spawn behavior;
- objective tracking.

## Mission Enemy Spawning
Mission targets and non-target enemies must be distinguished.

Killing a non-objective enemy must not permanently remove it from the world unless the design explicitly says so.

Mission spawns should be owned by a mission/encounter lifecycle and cleanly reset when appropriate.

## GPS
Navigation markers must derive from actual objective state rather than hardcoded coordinates whenever possible.

## Persistence
Mission state must survive save/load when the mission is persistent.

## Completion
Mission completion must be validated server-authoritatively at the system level, even in a single-player prototype.


---

## .agent/docs/bibles/07_NPC_DIALOGUE_BIBLE.md

# BIBLE DE NPCs E DIÁLOGOS

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


---

## .agent/docs/bibles/08_WORLD_SPAWN_BIBLE.md

# BIBLE DE MUNDO E SPAWN

## Spawn Principles
Spawning must be deterministic from game state and encounter rules.

## Enemy Categories
At minimum distinguish:
- ambient enemies;
- mission objectives;
- elite enemies;
- bosses;
- event encounters.

## Respawn
Ambient enemies can respawn according to world rules.
Mission enemies should follow mission lifecycle rules.
Bosses should follow encounter reset rules.

## Scene Changes
Leaving and re-entering a mission area must not accidentally duplicate enemies or permanently delete required enemies.

## Portal Rules
Portals can have:
- unconditional access;
- quest-gated access;
- level-gated access;
- story-gated access;
- objective-gated access.

Objective-gated portals must query the canonical mission state.

## Arena / Encounter
Special arenas should explicitly initialize their required combatants and verify that all expected entities spawned successfully.

## GPS
Targets should expose a stable objective reference or location source to navigation rather than relying on manually duplicated coordinates.


---

## .agent/docs/bibles/09_SAVE_DATA_BIBLE.md

# BIBLE DE SAVE E DADOS

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


---

## .agent/docs/bibles/10_UI_UX_BIBLE.md

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

## Combat UI
Display relevant:
- HP;
- aura;
- cooldowns;
- active Nen technique;
- important status effects.

## GPS
Navigation should clearly indicate the active objective and update when objective state changes.

## Interaction
Interact prompts should only appear when interaction conditions are satisfied.

## Accessibility
Avoid communicating critical gameplay information through color alone.


---

## .agent/docs/bibles/11_CONTENT_DESIGN_BIBLE.md

# BIBLE DE DESIGN DE CONTEÚDO

## Enemies
Every enemy should define:
- identity;
- level;
- HP;
- aura if applicable;
- attack;
- defense;
- speed;
- behavior;
- rewards;
- spawn category;
- weaknesses/resistances where appropriate.

## Bosses
Bosses should introduce mechanics, not merely inflated HP.

## Rewards
Rewards should correspond to difficulty and progression.

Possible rewards:
- XP;
- Nen XP;
- money;
- items;
- unlocks;
- Hatsu components;
- story progression.

## Difficulty
Difficulty should scale through a combination of:
- enemy stats;
- AI behavior;
- mechanics;
- encounter composition;
- objective complexity;
- resource pressure.

Avoid relying solely on HP inflation.

## Mission Length
Main saga missions can be designed as long multi-stage sequences, while side missions can be shorter and repeatable.

## Content Consistency
New content must use canonical systems for:
- damage;
- rewards;
- quests;
- spawning;
- persistence;
- dialogue.


---

## .agent/docs/bibles/12_ARCHITECTURE_BIBLE.md

# BIBLE DE ARQUITETURA

## Principle
The project is a collection of interconnected systems. Each system must have a clear responsibility.

## Core Systems
Known conceptual systems include:
- GameManager
- DataManager
- EventBus
- TimeManager
- PlayerData
- NenSystem
- HunterCombatSystem
- quest/mission systems
- NPC/interaction systems
- dialogue systems
- save/load systems
- UI systems

## Responsibilities
### GameManager
Coordinates high-level game state and lifecycle.

### DataManager
Owns or coordinates persistent/game data access according to the existing project implementation.

### EventBus
Provides decoupled communication for global events. Do not turn it into a dumping ground for arbitrary state.

### PlayerData
Represents canonical player progression data.

### Combat System
Owns combat calculations and combat state.

### Nen System
Owns Nen techniques, aura behavior and related rules.

### Gameplay Foundation Resources
`GameplayTags` normalizes and queries extensible gameplay labels. `GameplayCondition` is a serializable, context-driven Resource shared by Hatsu now and by Skill Tree, quests, enemies, bosses and events as they adopt it. These resources do not own player, combat or world state.

`StatModifier` remains the single modifier representation consumed by `PlayerData`; feature systems must reuse it instead of defining private modifier classes.

### Quest System
Owns objective state, progression and completion.

### NPC System
Owns NPC behavior and interactions.

## Dependency Rule
Prefer:
Data → Systems → Presentation

UI should request/display canonical state instead of becoming the owner of gameplay state.

## Duplication Rule
Before adding a system, search the repository for equivalent responsibility.

## Refactoring
Refactor incrementally. Do not perform broad rewrites during unrelated feature work.


---

## .agent/docs/bibles/13_TESTING_DEBUG_BIBLE.md

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


---

## .agent/docs/bibles/14_DATA_SCHEMA_BIBLE.md

# BIBLE DE SCHEMA DE DADOS

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


---

## .agent/docs/bibles/15_GAMEPLAY_FOUNDATION_BIBLE.md

# Bible da Base de Gameplay

## Objetivo

Fornecer condições, tags e modificadores reutilizáveis para expressar regras de gameplay sem IDs de Hatsu fixos, lógica de combate duplicada ou cópias privadas de estado.

## Responsabilidades

### GameplayTags

Normaliza rótulos e responde consultas de tags. Não determina resultados de combate nem mantém um registro fechado. As tags continuam sendo strings extensíveis em `snake_case`, como `projectile`, `offensive`, `long_range`, `single_target`, `weapon` e `aura`.

### GameplayCondition

Armazena uma exigência declarativa e avalia um dicionário de contexto. Não consulta nós da cena, altera estado nem emite UI. O contexto pode incluir `player_hp_percent`, `seconds_since_damage`, `target_marked`, `nearby_enemy_count`, `target_hp_percent`, `player_in_en`, `player_stealth`, `active_hatsu_ids`, `unlocked_skill_ids`, `target_states`, `target_weak_point_revealed` e `hatsu_tags`.

`evaluate()` retorna `{ met, type, actual }`; o sistema consumidor decide o efeito, feedback e transição de estado.

### StatModifier

`StatModifier` é a única representação de modificadores usada pelo `PlayerData`. Sistemas de funcionalidade criam a instância e informam sua origem; `PlayerData` recalcula os atributos.

## Integrações atuais

`HatsuData` persiste tags normalizadas e suas `gameplay_conditions` opcionais. Na ativação, combina os contextos do jogador e do alvo e recusa o uso quando uma condição não é atendida. `NenSkillTree` cria `StatModifier` diretamente.

## Regras de expansão

Adicione um tipo de condição somente quando ele puder ser reutilizado por mais de um domínio. Consultas de mundo, seleção de alvo, temporizadores e efeitos permanecem no sistema dono; o resultado é passado no contexto. Skill Tree, inimigos, bosses, quests, eventos e HUD devem consumir essas interfaces.

## Validação

Teste normalização/consulta de tags, casos verdadeiro e falso de cada condição, round-trip de serialização do Hatsu, recusa de ativação e aplicação/remoção de modificadores da Skill Tree. Teste save/load quando campos persistentes mudarem.


---

## .agent/docs/lore/HUNTER_CANON_LORE_ENCYCLOPEDIA.md

# HUNTER X HUNTER — CANON LORE & HATSU ENCYCLOPEDIA (COMPÊNDIO GERAL)

Este compêndio reúne a decomposição de habilidades e mecânicas canônicas de Hunter x Hunter, estruturadas diretamente para o consumo do agente de IA e integração com a arquitetura do jogo (`CombatEngine`, `PlayerData`, `NenSystem`, `GameplayTags`, `GameplayCondition`, `StatModifier` e `SaveManager`). Identificadores marcados como **[PLANEJADA]** são referências de design e ainda não estão implementados em `GameplayCondition`.

---

## 1. REGRAS DE CONVERSÃO CANÔNICA PARA SISTEMA DE JOGO

Ao implementar qualquer habilidade descrita neste documento:
1. **Afinidade & Eficiência**: Respeite o hexágono de afinidade. Componentes fora da afinidade primária sofrem penalidade de eficácia (80%, 60%, 40%) e custo aumentado de aura.
2. **Tags Canônicas (`GameplayTags`)**: Use identificadores normalizados em `snake_case` (ex: `offensive`, `projectile`, `melee`, `control`, `utility`, `buff`, `debuff`, `summon`, `binding`, `tether`, `counter`, `transmutation`, `emission`, `enhancement`, `conjuration`, `manipulation`, `specialization`).
3. **Condições (`GameplayCondition`)**: Habilidades complexas ou com Juramentos/Limitações exigem verificação de contexto. `target_marked` e `player_hp_percent` são suportadas; `target_in_en`, `aura_threshold`, `charge_time`, `target_faction` e `vow_active` são **[PLANEJADAS]**.
4. **Modificadores Passivos/Buffs (`StatModifier`)**: Nenhum buff deve alterar diretamente os atributos base de `PlayerData`. Crie instâncias de `StatModifier` com tipos e valores adequados.
5. **Custo e Limite de Liberação**: Habilidades de grande impacto consomem aura respeitando o AOP (Actual Output Power / teto instantâneo de liberação de aura).

---

## 2. PROTAGONISTAS & PERSONAGENS PRINCIPAIS

### 2.1 Gon Freecss
- **Afinidade Primária**: Reforço (100%)
- **Habilidades / Hatsu**:
  - **Jajanken: Rock (Guu)**
    - *Afinidade*: Reforço (100%)
    - *Tags*: `["offensive", "melee", "charge", "high_risk", "ko", "enhancement"]`
    - *Mecânica*: Concentra uma quantidade extrema de AOP no punho via Ko. Requer tempo de carregamento estático enquanto entoa o lema ("First comes rock...").
    - *GameplayCondition [PLANEJADA]*: `player_charging`, `target_in_melee_range`.
    - *Risco/Compensação*: Durante a canalização, a defesa do corpo cai severamente (vulnerabilidade a contra-ataques). Dano massivo no impacto.
  - **Jajanken: Scissors (Chii)**
    - *Afinidade*: Transmutação (80% de eficiência)
    - *Tags*: `["offensive", "melee", "slashing", "transmutation"]`
    - *Mecânica*: Transmuta a aura estendida pelos dedos indicador e médio em lâminas afiadas.
    - *Efeito*: Dano cortante em cone frontal de curto alcance; menor dano de impacto bruto que o Rock, mas com chance de sangramento/crítico.
  - **Jajanken: Paper (Paa)**
    - *Afinidade*: Emissão (80% de eficiência)
    - *Tags*: `["offensive", "projectile", "ranged", "emission"]`
    - *Mecânica*: Projeta uma esfera esférica de aura concentrada contra o alvo.
    - *Efeito*: Ataque à distância de velocidade média. Causa dano contundente moderado.

### 2.2 Killua Zoldyck
- **Afinidade Primária**: Transmutação (100%)
- **Habilidades / Hatsu**:
  - **Lightning Palm (Izutsushi)**
    - *Afinidade*: Transmutação (100%) + Emissão (60%)
    - *Tags*: `["offensive", "melee", "stun", "electric", "transmutation"]`
    - *Mecânica*: Descarrega alta voltagem pelas palmas das mãos ao tocar o alvo.
    - *Efeito*: Causa dano elétrico moderado e aplica breve atordoamento (`stun`) ou paralisia muscular.
  - **Thunderbolt (Narukami)**
    - *Afinidade*: Transmutação (100%) + Emissão (60%)
    - *Tags*: `["offensive", "ranged", "projectile", "electric", "burst"]`
    - *Mecânica*: Dispara um raio concentrado de eletricidade a partir do ar ou à distância.
    - *Efeito*: Dano perfurante elétrico rápido e atordoamento prolongado.
  - **Godspeed: Speed of Lightning (Kanmuru: Denkou Sekka)**
    - *Afinidade*: Transmutação (100%) + Reforço (80%)
    - *Tags*: `["buff", "transformation", "speed", "mobility"]`
    - *Mecânica*: Transmuta aura em impulsos elétricos que percorrem os nervos, controlando o corpo conscientemente em velocidade sobre-humana.
    - *Efeito*: Adiciona `StatModifier` extremo de velocidade de movimento e esquiva passiva. Drena aura continuamente e requer recarga periódica de eletricidade.
  - **Godspeed: Whirlwind (Kanmuru: Shippu Jinrai)**
    - *Afinidade*: Transmutação (100%) + Manipulação (40%)
    - *Tags*: `["buff", "counter", "reflex", "defensive"]`
    - *Mecânica*: O corpo reage diretamente aos estímulos de aura do inimigo sem passar pelo processamento cerebral.
    - *Efeito*: Esquiva ou contra-ataque automático contra o primeiro golpe que entrar no raio de detecção.

### 2.3 Kurapika
- **Afinidade Primária**: Conjuração (100%) / Especialização (100% sob Scarlet Eyes)
- **Habilidades / Hatsu**:
  - **Emperor Time (Olhos Escarlates)**
    - *Afinidade*: Especialização (100%)
    - *Tags*: `["buff", "specialization", "high_risk", "emperor_time"]`
    - *Mecânica*: Permite usar 100% de eficiência e maestria máxima em todas as categorias de Nen.
    - *Condição & Risco*: Cada segundo ativo drena 1 hora do tempo de vida do usuário. No jogo, gera debuff cumulativo de fadiga e dreno contínuo de HP/Aura.
  - **Holy Chain (Polegar)**
    - *Afinidade*: Conjuração (100%) + Reforço (100% via Emperor Time, senão 60%)
    - *Tags*: `["heal", "support", "recovery", "enhancement"]`
    - *Mecânica*: Corrente com terminação em cruz que acelera drasticamente a regeneração celular natural.
    - *Efeito*: Cura rápida de HP próprio ou de aliados.
  - **Chain Jail (Dedo Médio)**
    - *Afinidade*: Conjuração (100%) + Manipulação (60% / 100% via Emperor Time)
    - *Tags*: `["control", "single_target", "binding", "vow_restricted"]`
    - *Juramento Absoluto*: SÓ PODE SER USADA CONTRA MEMBROS DO PHANTOM TROUPE (Genei Ryodan).
    - *GameplayCondition [PLANEJADA]*: `target_has_tag: phantom_troupe`. Se violada, ativa `kill_player`.
    - *Efeito*: Prende o alvo indefensavelmente e força-o ao estado de Zetsu absoluto (aura cai para 0).
  - **Dowsing Chain (Dedo Anelar)**
    - *Afinidade*: Conjuração (100%)
    - *Tags*: `["utility", "detection", "ranged", "guidance"]`
    - *Mecânica*: Corrente com pêndulo metálico sensível à mentira, presenças ocultas e rastreamento.
    - *Efeito*: Revela inimigos camuflados/em In e aumenta a precisão de projéteis.
  - **Judgement Chain (Dedo Mindinho)**
    - *Afinidade*: Conjuração (100%) + Emissão (100% via Emperor Time) + Manipulação (100% via Emperor Time)
    - *Tags*: `["curse", "execution", "rule_based"]`
    - *Mecânica*: Insere uma lâmina de corrente no coração do alvo e impõe uma ou mais regras/condições.
    - *Efeito*: Se o alvo violar a regra estipulada, a lâmina esmaga seu coração causando morte instantânea.
  - **Steal Chain & Stealth Dolphin (Dedo Indicador)**
    - *Afinidade*: Conjuração (100%) + Especialização
    - *Tags*: `["utility", "ability_theft", "drain", "synergy"]`
    - *Mecânica*: Corrente com seringa que drena a aura do alvo e extrai temporariamente seu Hatsu.
    - *Efeito*: O alvo entra em Zetsu temporário. O Stealth Dolphin materializado analisa a habilidade e permite usá-la uma única vez ou transferi-la para um aliado.

### 2.4 Leorio Paradinight
- **Afinidade Primária**: Emissão (100%)
- **Habilidades / Hatsu**:
  - **Remote Punch (Soco Remoto)**
    - *Afinidade*: Emissão (100%) + Transmutação/Reforço
    - *Tags*: `["offensive", "ranged", "surprise", "portal_strike"]`
    - *Mecânica*: Golpela uma superfície com o punho, transmitindo a aura pelo solo ou parede para que ela emerja através de um portal de aura diretamente sob o queixo ou corpo do inimigo distante.
    - *Efeito*: Dano de concussão à distância que ignora obstáculos físicos diretos entre o atacante e o alvo.
  - **Ultrasound Echo (Varredura Ultrassônica)**
    - *Afinidade*: Emissão (100%)
    - *Tags*: `["utility", "detection", "sonar"]`
    - *Mecânica*: Emite pulsos microscópicos de aura semelhantes a ultrassom através de superfícies para mapear tumores, anomalias ou inimigos ocultos em paredes.
    - *Efeito*: Revela contornos de salas adjacentes e alvos em stealth no mini-mapa.

---

## 3. TRUPE FANTASMA (GENEI RYODAN)

### 3.1 Chrollo Lucilfer
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Skill Hunter: Bandit's Secret**
    - *Afinidade*: Especialização (100%)
    - *Tags*: `["ability_theft", "utility", "specialization", "grimoire"]`
    - *Mecânica*: Rouba habilidades de Nen alheias e as armazena em um grimório conjurado.
    - *Condições Estritas de Roubo*:
      1. Ver a habilidade em ação com os próprios olhos.
      2. Fazer perguntas sobre a habilidade e obter resposta do usuário.
      3. A mão da vítima deve tocar a impressão digital na capa do livro.
      4. As etapas anteriores devem ocorrer dentro do prazo de 1 hora.
    - *Efeito no Jogo*: Permite equipar e invocar Hatsu roubados de chefes/NPCs específicos, consumindo aura mantendo o livro aberto em uma das mãos.
  - **Double Face (Marcador de Página)**
    - *Mecânica*: Um marcador que permite manter ativada uma habilidade mesmo com o livro fechado, ou usar duas habilidades roubadas simultaneamente.
  - **Indoor Fish (Peixes do Quarto)**
    - *Afinidade*: Conjuração (100%) + Manipulação
    - *Tags*: `["offensive", "summon", "drain", "room_bound"]`
    - *Condição*: Só sobrevive em recintos totalmente selados e fechados hermeticamente.
    - *Efeito*: Peixes esqueléticos que devoram a carne do inimigo sem causar dor ou perda de sangue. Quando o quarto é aberto, o dano acumulado manifesta-se instantaneamente, resultando na morte do alvo.
  - **Fun Fun Cloth (Pano de Encolhimento - Roubada de Owl)**
    - *Afinidade*: Conjuração (100%) + Manipulação
    - *Tags*: `["control", "capture", "utility"]`
    - *Efeito*: Tecido conjurado que encolhe tudo o que envolve, permitindo capturar inimigos inteiros ou armazenar itens volumosos.
  - **Sun and Moon (Sol e Lua - Roubada dos Anciãos de Meteor City)**
    - *Tags*: `["offensive", "mark", "explosive", "delayed_burst"]`
    - *Mecânica*: Aplica uma marca solar (mão esquerda) e uma marca lunar (mão direita). Quando as marcas se tocam, detonam uma explosão violenta proporcional ao tempo de contato.

### 3.2 Hisoka Morow
- **Afinidade Primária**: Transmutação (100%)
- **Habilidades / Hatsu**:
  - **Bungee Gum (Goma Elástica)**
    - *Afinidade*: Transmutação (100%)
    - *Tags*: `["utility", "control", "tether", "mobility", "projectile"]`
    - *Mecânica*: Concede à aura propriedades combinadas de chiclete (adesão total) e borracha (elasticidade extrema).
    - *Efeito*: Puxa inimigos, rebate projéteis balísticos, arremessa o próprio usuário em alta velocidade ou prende os membros do adversário ao solo.
  - **Texture Surprise (Textura Surpresa)**
    - *Afinidade*: Conjuração (100%) + Transmutação
    - *Tags*: `["utility", "illusion", "camouflage", "deception"]`
    - *Mecânica*: Aplica uma fina camada de aura sobre qualquer superfície plana reproduzindo fielmente texturas visuais e táteis (pele falsa, ferimentos maquiados, cartas falsas).
    - *Efeito*: Engana a interface de percepção do inimigo até que este utilize Gyo para detectar a aura subjacente.

### 3.3 Uvogin
- **Afinidade Primária**: Reforço (100%)
- **Habilidades / Hatsu**:
  - **Big Bang Impact (Impacto Big Bang)**
    - *Afinidade*: Reforço (100%)
    - *Tags*: `["offensive", "melee", "aoe", "burst", "ko"]`
    - *Mecânica*: Concentra toda a reserva de AOP no punho direito e golpeia com a força equivalente a um míssil antitanque.
    - *Efeito*: Dano físico maciço com onda de choque em área que destrói o terreno e atordoa alvos adjacentes.
  - **Superhuman Roar (Rugido Sônico)**
    - *Afinidade*: Reforço (100%) + Emissão
    - *Tags*: `["offensive", "aoe", "debuff", "disruption"]`
    - *Mecânica*: Amplifica as cordas vocais com aura, gerando uma onda sônica ensurdecedora em cone frontal.
    - *Efeito*: Rompe tímpanos, causa confusão/desorientação e anula canalizações mágicas.

### 3.4 Feitan Portor
- **Afinidade Primária**: Transmutação (100%) + Conjuração
- **Habilidades / Hatsu**:
  - **Pain Packer (Embalador de Dor)**
    - *Afinidade*: Conjuração (100%)
    - *Tags*: `["armor", "counter", "revenge_gauge", "defensive"]`
    - *Mecânica*: Conjura uma armadura protetora pesada em resposta à raiva e aos ferimentos recebidos em batalha.
    - *GameplayCondition [PLANEJADA]*: `damage_received_threshold`.
  - **Rising Sun (Sol Nascente)**
    - *Afinidade*: Transmutação (100%) + Emissão
    - *Tags*: `["offensive", "aoe", "fire", "heat", "burst"]`
    - *Mecânica*: Transmuta toda a dor acumulada em uma esfera de calor extremo e fogo incandescente que incinera uma vasta área circular.
    - *Escalonamento*: O dano é diretamente proporcional à perda de HP sofrida por Feitan na luta.

### 3.5 Machi Komacine
- **Afinidade Primária**: Transmutação (100%)
- **Habilidades / Hatsu**:
  - **Nen Stitches (Pontos de Nen)**
    - *Afinidade*: Transmutação (100%)
    - *Tags*: `["heal", "support", "surgery", "utility"]`
    - *Mecânica*: Fios de aura finos e incrivelmente resistentes usados para reconectar músculos, ossos e membros decepados com precisão cirúrgica quase instantânea.
  - **Nen Threads (Fios Invisíveis de Nen)**
    - *Tags*: `["control", "trap", "tether", "stealth"]`
    - *Mecânica*: Fios de aura estendidos em In para criar armadilhas, estrangular alvos ou manipular corpos humanos como marionetes.

### 3.6 Nobunaga Hazama
- **Afinidade Primária**: Reforço (100%)
- **Habilidades / Hatsu**:
  - **Iai / En Domain Cut**
    - *Afinidade*: Reforço (100%) + Emissão
    - *Tags*: `["counter", "melee", "reaction", "precision", "en"]`
    - *Mecânica*: Mantém uma esfera de En de raio circular estrito de 4 metros (alcance de sua katana).
    - *GameplayCondition [PLANEJADA]*: `target_enters_en_zone`.
    - *Efeito*: Qualquer inimigo ou projétil que atravesse o limite do En recebe um contra-ataque de desembainhar instantâneo com acerto crítico garantido.

### 3.7 Shizuku Murasaki
- **Afinidade Primária**: Conjuração (100%)
- **Habilidades / Hatsu**:
  - **Blinky (Deme-chan - Aspirador Conjurado)**
    - *Afinidade*: Conjuração (100%)
    - *Tags*: `["utility", "drain", "cleanse", "lethal"]`
    - *Regra Canônica*: Não pode aspirar criaturas vivas nem objetos feitos puramente de Nen, mas aspira qualquer objeto inanimado infinito e sem restrição de volume.
    - *Efeito de Combate*: Pode aspirar todo o sangue derramado através de feridas abertas de um inimigo, causando sangramento contínuo letal por anemia súbita.

### 3.8 Franklin Bordeau
- **Afinidade Primária**: Emissão (100%)
- **Habilidades / Hatsu**:
  - **Double Machine Gun (Metralhadora Dupla)**
    - *Afinidade*: Emissão (100%)
    - *Tags*: `["offensive", "ranged", "rapid_fire", "projectile"]`
    - *Limitação Autoimposta*: Cortou as pontas dos próprios dedos para fortalecer a convicção do disparo.
    - *Efeito*: Dispara rajadas ininterruptas e ultra-rápidas de projéteis densos de aura a partir das pontas dos dedos modificadas.

### 3.9 Shalnark
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Black Voice (Voz Negra)**
    - *Afinidade*: Manipulação (100%)
    - *Tags*: `["control", "puppet", "single_target"]`
    - *Mecânica*: Insere uma antena com terminação de morcego no corpo do alvo e controla seus movimentos remotamente através de um celular customizado.
    - *Efeito*: O alvo perde o controle de suas ações e executa comandos cegamente até que a antena seja fisicamente removida.
  - **Autopilot (Piloto Automático)**
    - *Afinidade*: Manipulação (100%) + Reforço (60%)
    - *Tags*: `["buff", "transformation", "berserk", "high_risk"]`
    - *Mecânica*: Espeta a antena em seu próprio corpo e programa o celular para atingir um objetivo específico.
    - *Efeito*: A aura explode em níveis titânicos e o corpo combate automaticamente com atributos maximizados. Ao encerrar o efeito, o usuário sofre fadiga muscular extrema e amnésia dos eventos.

### 3.10 Phinks Magcub
- **Afinidade Primária**: Reforço (100%)
- **Habilidades / Hatsu**:
  - **Ripper Cyclotron (Ciclótron Despedaçador)**
    - *Afinidade*: Reforço (100%)
    - *Tags*: `["offensive", "melee", "charge", "escalating"]`
    - *Mecânica*: Gira o braço direito em círculos como uma manivela. Cada volta completa acumula aura proporcional no punho.
    - *Efeito*: O poder de dano escala exponencialmente por volta acumulada, descarregando um golpe de impacto devastador ao socar o adversário.

### 3.11 Bonolenov Ndongo
- **Afinidade Primária**: Conjuração (100%) + Emissão
- **Habilidades / Hatsu**:
  - **Battle Cantabile: Prologue & Jupiter**
    - *Tags*: `["offensive", "ranged", "sound", "crush"]`
    - *Mecânica*: O ar passa pelos orifícios esculpidos em seu corpo durante danças tribais, gerando melodias que materializam armas ou uma réplica em miniatura esmagadora do planeta Júpiter arremessada contra o inimigo.

### 3.12 Pakunoda
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Memory Extraction & Memory Bomb**
    - *Tags*: `["utility", "mind_reading", "information", "ranged"]`
    - *Mecânica*: Ao tocar alguém e fazer uma pergunta, lê memórias puras e sem filtros mentais. Converte essas memórias em balas de revólver que, ao atingirem aliados, transmitem as lembranças instantaneamente sem dano.

### 3.13 Kortopi
- **Afinidade Primária**: Conjuração (100%)
- **Habilidades / Hatsu**:
  - **Gallery Fake (Galeria Falsa)**
    - *Tags*: `["utility", "cloning", "tracking", "conjuration"]`
    - *Mecânica*: Toca um objeto com a mão esquerda e materializa uma cópia física exata e idêntica com a mão direita.
    - *Regras*: As cópias duram exatamente 24 horas e funcionam como receptores de En (Kortopi sabe a localização exata de cada cópia).

---

## 4. FAMÍLIA ZOLDYCK

### 4.1 Zeno Zoldyck
- **Afinidade Primária**: Transmutação (100%) + Emissão (80%)
- **Habilidades / Hatsu**:
  - **Dragon Head (Cabeça de Dragão)**
    - *Afinidade*: Transmutação (100%)
    - *Tags*: `["offensive", "utility", "tether", "weapon"]`
    - *Mecânica*: Transmuta a aura em forma de cabeça de dragão chinesa que se estende de suas mãos para agarrar, morder ou transportar combatentes.
  - **Dragon Lance (Lança do Dragão)**
    - *Afinidade*: Transmutação (100%) + Emissão (80%)
    - *Tags*: `["offensive", "ranged", "piercing", "laser"]`
    - *Mecânica*: Dispara a cabeça de dragão como um feixe contínuo e perfurante de longo alcance sob controle manual direto.
  - **Dragon Dive (Chuva de Dragões)**
    - *Afinidade*: Transmutação (100%) + Emissão (80%)
    - *Tags*: `["offensive", "aoe", "bombardment", "ranged"]`
    - *Mecânica*: Desmembra um dragão gigante de aura em milhares de fragmentos perfurantes que despencam do céu como chuva de meteoros sobre uma vasta área.

### 4.2 Silva Zoldyck
- **Afinidade Primária**: Transmutação (100%) + Emissão (80%)
- **Habilidades / Hatsu**:
  - **Explosive Orbs (Orbes Explosivos de Aura)**
    - *Afinidade*: Transmutação (100%) + Emissão (80%)
    - *Tags*: `["offensive", "ranged", "aoe", "explosive"]`
    - *Mecânica*: Concentra duas esferas densas de aura crepitante, uma em cada palma, arremessando-as para criar uma detonação monumental combinada.

### 4.3 Illumi Zoldyck
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Needle People (Agulhas de Controle Mental)**
    - *Afinidade*: Manipulação (100%)
    - *Tags*: `["control", "puppet", "minion", "debuff"]`
    - *Mecânica*: Cravando agulhas imbuidas de Nen na cabeça de alvos humanos, priva-os de raciocínio transformando-os em zumbis obedientes que lutam até a morte.
  - **Body Alteration (Alteração Facial)**
    - *Tags*: `["utility", "disguise", "stealth"]`
    - *Mecânica*: Reorganiza ossos e cartilagens faciais usando agulhas para se disfarçar com perfeição.

### 4.4 Kalluto Zoldyck
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Paper Manipulation: Snake Bite & Surveillance**
    - *Tags*: `["offensive", "ranged", "scrying", "slashing"]`
    - *Mecânica*: Controla pequenos recortes de papel confete imbuídos de Shu como projéteis cortantes mortais ou dispositivos de escuta remota.

---

## 5. ASSOCIAÇÃO HUNTER & EXAMINADORES

### 5.1 Isaac Netero
- **Afinidade Primária**: Reforço (100%) + Emissão/Manipulação
- **Habilidades / Hatsu**:
  - **100-Type Guanyin Bodhisattva (Bodhisattva Guanyin de 100 Tipos)**
    - *Afinidade*: Conjuração/Emissão + Manipulação + Reforço
    - *Tags*: `["offensive", "summon", "melee", "divine", "god_speed"]`
    - *Mecânica*: Ora com as mãos juntas antes de cada movimento. A velocidade dessa oração e do subsequente golpe da estátua ultrapassa a barreira do som e a capacidade de reação biológica.
  - **First Hand, Third Hand, Ninety-Ninth Hand**
    - *Variações*: Golpes verticais de palma, palmas cruzadas esmagadoras e tempestades de centenas de golpes contínuos e impiedosos.
  - **Zero Hand (Mão Zero)**
    - *Afinidade*: Emissão (80%) + Reforço (100%)
    - *Tags*: `["offensive", "ultimate", "burnout", "last_resort"]`
    - *Mecânica*: A estátua surge pelas costas do inimigo e o imobiliza; Netero canaliza todo o remanescente absoluto de sua aura (MOP residual) através de sua boca em uma labareda de pura energia destrutiva. O usuário envelhece e esgota completamente suas forças.

### 5.2 Biscuit Krueger
- **Afinidade Primária**: Transmutação (100%)
- **Habilidades / Hatsu**:
  - **Magical Esthetician (Cookie-chan)**
    - *Afinidade*: Conjuração (100%) + Transmutação (100%) + Manipulação
    - *Tags*: `["support", "heal", "stamina_recovery", "utility"]`
    - *Mecânica*: Concura uma massagista de aura que secreta loções transmutadas para curar lesões e restaurar completamente a vitalidade muscular de 8 horas de sono em apenas 30 minutos.
  - **Body Reversion (Forma Muscular Verdadeira)**
    - *Tags*: `["buff", "enhancement", "physical_might"]`
    - *Mecânica*: Rompe a restrição cosmética de garotinha, revelando sua estatura titânica e musculatura hipertrofiada, concedendo aumentos monumentais em Força e Defesa física.

### 5.3 Morel Mackernasey
- **Afinidade Primária**: Manipulação (100%) + Emissão
- **Habilidades / Hatsu**:
  - **Deep Purple (Fumaça de Nen)**
    - *Afinidade*: Manipulação (100%) + Emissão (80%) + Transmutação (40%)
    - *Tags*: `["summon", "utility", "clone", "crowd_control"]`
    - *Mecânica*: Sopra fumaça através de seu cachimbo gigante e molda soldados autônomos, cordas de contenção impenetráveis ou duplicatas idênticas de pessoas.
  - **Smoky Jail (Prisão de Fumaça)**
    - *Tags*: `["binding", "cage", "barrier", "impenetrable"]`
    - *Mecânica*: Cria um domo selado de fumaça sólida indestrutível que isola o usuário e o oponente do restante do mundo.

### 5.4 Knov
- **Afinidade Primária**: Conjuração (100%) + Emissão (40%)
- **Habilidades / Hatsu**:
  - **Hide and Seek (4-Dimensional Mansion)**
    - *Afinidade*: Conjuração (100%) + Emissão
    - *Tags*: `["utility", "teleport", "dimension", "inventory"]`
    - *Mecânica*: Desenha portais no chão que conectam a uma mansão quadridimensional de 21 salas separadas, permitindo evacuação, armazenamento ou transporte furtivo de exércitos.
  - **Scream (Grito Espacial)**
    - *Afinidade*: Conjuração + Emissão
    - *Tags*: `["offensive", "lethal", "spatial_cut", "execution"]`
    - *Mecânica*: Abre um portal espacial entre as duas mãos envolvendo a cabeça/corpo do alvo e fecha o portal subitamente, enviando a parte decepada para outra dimensão e ignorando defesas físicas.

### 5.5 Knuckle Bine
- **Afinidade Primária**: Emissão (100%)
- **Habilidades / Hatsu**:
  - **A.P.R. (Hakoware - Falência de Aura)**
    - *Afinidade*: Emissão (100%) + Manipulação
    - *Tags*: `["debuff", "aura_debt", "invulnerable_pet", "tactical"]`
    - *Mecânica*: Ao desferir um golpe, empresta aura ao oponente sem causar dano físico. Uma criatura indestrutível (Toritaten) passa a acompanhar o alvo cobrando 10% de juros compostos a cada 10 segundos.
    - *Penalidade*: Se a dívida de aura ultrapassar a reserva total de Nen do alvo, A.P.R. transforma-se em I.R.S. e força o adversário ao estado de **Zetsu por 30 dias**.

### 5.6 Shoot McMahon
- **Afinidade Primária**: Manipulação (100%) + Conjuração
- **Habilidades / Hatsu**:
  - **Hotel Rafflesia (Jaula Escura & Mãos Flutuantes)**
    - *Afinidade*: Manipulação (100%) + Conjuração
    - *Tags*: `["control", "seal", "ranged", "disarm"]`
    - *Mecânica*: Controla três mãos levitantes desincorporadas. Cada golpe bem-sucedido arranca uma parte do corpo do oponente e a sela dentro de uma pequena gaiola suspensa.

### 5.7 Palm Siberia
- **Afinidade Primária**: Reforço (100%) / Quimera
- **Habilidades / Hatsu**:
  - **Black Widow (Viúva Negra)**
    - *Afinidade*: Reforço (100%) + Manipulação
    - *Tags*: `["armor", "melee", "enhancement", "spikes"]`
    - *Mecânica*: Envolve seu corpo inteiro em cabelos armados com Ko e Ten, formando uma armadura viva e afiada para combate corpo a corpo brutal.
  - **Merman Clairvoyance (Clarividência da Sereia)**
    - *Tags*: `["utility", "tracking", "vision"]`
    - *Mecânica*: Alimentando uma esfera de cristal com seu sangue, pode observar a localização de qualquer pessoa que já tenha visto com os próprios olhos.

---

## 6. FORMIGAS QUIMERA (CHIMERA ANTS)

### 6.1 Meruem (O Rei)
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Aura Synthesis (Síntese de Aura)**
    - *Afinidade*: Especialização (100%)
    - *Tags*: `["passive", "absorption", "stat_growth", "evolution"]`
    - *Mecânica*: Ao devorar usuários de Nen, assimila completamente sua aura e desenvolve novas capacidades baseadas nas afinidades e habilidades da vítima.
  - **Photon En & Rage Blast (Pós-Rosa)**
    - *Afinidade*: Emissão + Transmutação + Especialização
    - *Tags*: `["offensive", "en", "ranged", "detection", "annihilation"]`
    - *Mecânica*: Transmuta seu En em partículas microscópicas de fótons de luz que mapeiam instantaneamente qualquer presença, emoção ou intenção, além de disparar canhões concentrados de pura aura capazes de pulverizar montanhas.

### 6.2 Neferpitou
- **Afinidade Primária**: Especialização (100%) + Manipulação
- **Habilidades / Hatsu**:
  - **Terpsichora (Dança da Marionete Titânica)**
    - *Afinidade*: Manipulação (100%) + Especialização
    - *Tags*: `["buff", "combat_puppet", "berserk", "post_mortem"]`
    - *Mecânica*: Conjura uma bailarina monstruosa de cordas que manipula o próprio corpo de Pitou além de seus limites biológicos normais, atacando em frações de décimos de segundo. Funciona mesmo após a morte biológica via Nen Pós-Morte.
  - **Doctor Blythe (Doutor Blythe)**
    - *Afinidade*: Especialização (100%) + Conjuração
    - *Tags*: `["heal", "surgery", "anchor", "utility"]`
    - *Mecânica*: Cirurgiã gigante que reconecta tecidos, órgãos e remove toxinas.
    - *Restrição*: Fica fixa no espaço geográfico onde foi conjurada e consome toda a aura defensiva de Pitou, deixando-a vulnerável enquanto opera.
  - **Puppeteering Army (Exército de Marionetes)**
    - *Tags*: `["control", "summon", "mass_manipulation"]`
    - *Mecânica*: Controla soldados e cadáveres em larga escala a quilômetros de distância usando fios invisíveis de aura.

### 6.3 Shaiapouf (Pouf)
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Beelzebub (Rei das Moscas)**
    - *Afinidade*: Manipulação (100%) + Especialização
    - *Tags*: `["utility", "cloning", "evasion", "invulnerable"]`
    - *Mecânica*: Divide seu corpo em milhões de clones microscópicos do tamanho de células. Imune a dano físico contundente normal enquanto o núcleo principal estiver protegido.
  - **Spiritual Message (Escamas Hipnóticas)**
    - *Tags*: `["debuff", "aoe", "mind_reading", "hypnosis"]`
    - *Mecânica*: Espalha escamas brilhantes através de suas asas de borboleta que induzem hipnose em massas de pessoas e leem com precisão absoluta as emoções psicológicas do alvo.

### 6.4 Menthuthuyoupi (Youpi)
- **Afinidade Primária**: Reforço (100%) + Transmutação
- **Habilidades / Hatsu**:
  - **Metamorfose e Fúria Célular**
    - *Afinidade*: Reforço (100%) + Transmutação (80%)
    - *Tags*: `["transformation", "tentacles", "melee", "adaptation"]`
    - *Mecânica*: Altera sua anatomia instantaneamente criando tentáculos, olhos extras, asas carnosas e lâminas orgânicas densas.
  - **Rage Incarnate & Rage Cannon (Canhão de Fúria)**
    - *Afinidade*: Reforço (100%) + Emissão (80%)
    - *Tags*: `["offensive", "aoe", "explosive", "burst"]`
    - *Mecânica*: Converte sua fúria desmedida em uma explosão cataclísmica de aura vulcânica ao redor de si mesmo ou canalizada em formato de canhão centauro.

### 6.5 Ikalgo
- **Afinidade Primária**: Manipulação (100%)
- **Habilidades / Hatsu**:
  - **Living Dead Dolls (Parasitismo Cadavérico)**
    - *Tags*: `["utility", "puppet", "infiltration"]`
    - *Mecânica*: Entra no cadáver de uma criatura falecida e assume o controle completo de sua voz, memória motora e habilidades corporais.
  - **Flea Bullets (Balas de Pulga)**
    - *Tags*: `["offensive", "ranged", "sniper", "bleed"]`
    - *Mecânica*: Transforma seus tentáculos em um rifle de precisão que dispara pulgas parasitas gigantes que impedem a coagulação sanguínea do alvo.

### 6.6 Meleoron
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Perfect Plan (Plano Perfeito / Furtividade Absoluta)**
    - *Afinidade*: Especialização (100%)
    - *Tags*: `["stealth", "invisibility", "invulnerable_presence"]`
    - *Mecânica*: Enquanto prende a respiração, torna-se totalmente invisível e indetectável por visão, audição, olfato, tato, En ou sexto sentido.
  - **God's Accomplice (Cúmplice de Deus)**
    - *Mecânica*: Estende os efeitos do Perfect Plan a qualquer companheiro que estiver em contato físico direto consigo.

---

## 7. GREED ISLAND & ANTAGONISTAS SECUNDÁRIOS

### 7.1 Genthru (The Bomber)
- **Afinidade Primária**: Conjuração (100%) + Transmutação
- **Habilidades / Hatsu**:
  - **Little Flower (Pequena Flor)**
    - *Afinidade*: Transmutação (80%) + Reforço (60%)
    - *Tags*: `["offensive", "melee", "explosive", "high_risk"]`
    - *Mecânica*: Faz explodir a aura em contato com as mãos. Para não ter as próprias mãos dilaceradas, precisa proteger suas palmas com uma concentração maior de aura via Gyo (ex: 80% defensivo nas mãos, 20% explosivo).
  - **Countdown (Contagem Regressiva)**
    - *Afinidade*: Conjuração (100%) + Emissão + Manipulação
    - *Tags*: `["curse", "timed_bomb", "co-op", "vow_restricted"]`
    - *Condições Estritas*:
      1. Tocar o alvo na área do tórax.
      2. Dizer a palavra secreta "Bomber".
      3. Explicar detalhadamente o funcionamento de sua habilidade ao alvo.
    - *Efeito*: Um contador numérico cardíaco é acoplado ao peito da vítima, detonando com força devastadora ao chegar a zero.

### 7.2 Razor (Mestre de Greed Island)
- **Afinidade Primária**: Emissão (100%)
- **Habilidades / Hatsu**:
  - **14 Devils (14 Demônios de Aura)**
    - *Afinidade*: Emissão (100%) + Manipulação (80%)
    - *Tags*: `["summon", "minion", "sports_rules", "coordinated"]`
    - *Mecânica*: Emite e sustenta 14 feras humanóides autônomas de aura que podem se combinar ou executar ações táticas sincronizadas.
  - **Spike Cannon (Disparo de Aura Esférico)**
    - *Afinidade*: Emissão (100%) + Reforço (80%)
    - *Tags*: `["offensive", "projectile", "heavy_impact"]`
    - *Mecânica*: Corta ou arremessa uma bola com velocidade supersônica carregada de aura pura, destruindo navios e quebrando membros de mestres de Nen.

---

## 8. SUCESSÃO DE KARKINO & DARK CONTINENT

### 8.1 Halkenburg Hui Guo Rou
- **Afinidade Primária**: Reforço / Emissão
- **Habilidades / Hatsu**:
  - **GNB Arrow (Arco e Flecha de Vontade Coletiva)**
    - *Tags*: `["offensive", "armor_piercing", "possession", "resonance"]`
    - *Mecânica*: Une a determinação e lealdade de seus súditos em uma flecha de aura colossal. O disparo perfura qualquer barreira de Nen e substitui a consciência do alvo pela de um de seus seguidores.

### 8.2 Camilla Hui Guo Rou
- **Afinidade Primária**: Especialização (100%)
- **Habilidades / Hatsu**:
  - **Cat's Name (Gato de Um Milhão de Vidas)**
    - *Afinidade*: Especialização (100%) + Nen Pós-Morte
    - *Tags*: `["counter", "revive", "lethal", "post_mortem"]`
    - *Condição*: Camilla deve morrer assassinada por um atacante.
    - *Efeito*: Invoca uma gata gigante de aura pós-morte que esmaga o assassino até extrair toda a sua energia vital, usando essa energia para ressuscitar Camilla imediatamente sem sequelas.

---

## 9. GLOSSÁRIO DE INTEGRAÇÃO COM GODOT

Ao converter qualquer uma dessas entradas para scripts GDScript ou arquivos de recursos `.tres` (`HatsuData`):
- O campo `category` recebe a string canônica em inglês minúsculo: `"enhancement"`, `"transmutation"`, `"emission"`, `"conjuration"`, `"manipulation"`, `"specialization"`.
- As tags no array `tags` devem ser filtradas por `GameplayTags.normalize(tag)`.
- Requisitos situacionais implementados utilizam instâncias de `GameplayCondition` alimentadas pelo dicionário de contexto da cena de combate. Os identificadores acima marcados como **[PLANEJADA]** devem ser adicionados em uma fase futura antes de serem usados em runtime.


---

## .agent/skills/hunter-development/SKILL.md

---
name: hunter-development
description: Desenvolver, diagnosticar ou revisar o projeto Hunter Online em Godot, preservando os sistemas canônicos e aplicando as Bibles relevantes para Nen, Hatsu, combate, Skill Tree, quests, mundo, UI e persistência.
---

# Skill de Desenvolvimento do Hunter Online

Use esta skill para alterações e revisões do projeto Godot. Desenvolva em incrementos pequenos e compatíveis, mantendo um RPG estratégico, persistente e expansível.

## Fonte de verdade

1. Pedido atual do usuário.
2. Bible relevante em `.agent/docs/bibles/`, começando pelo `00_BIBLE_INDEX.md`, e `NEN_SKILL_TREE_BIBLE.md` na raiz.
3. Implementação, cenas e recursos existentes.
4. Decisões razoáveis de implementação.

Quando uma Bible divergir do código, investigue e comunique o conflito antes de uma reescrita ampla.

## Investigação obrigatória

Antes de alterar código ou cenas:

1. Leia scripts, cenas, recursos, sinais, grupos, autoloads e chamadas relacionadas.
2. Leia somente as Bibles que governam a tarefa; em trabalho entre sistemas, inclua Arquitetura, Schema e Testes.
3. Identifique o dono canônico de cada estado e regra. Reutilize-o, sem criar estado ou sistemas paralelos.
4. Faça a menor alteração que atende ao pedido.

## Donos canônicos

- `PlayerData`: progressão, dados persistentes e pipeline de `StatModifier`.
- `CombatEngine`: cálculo compartilhado de dano e mitigação.
- `NenSystem`: aura, técnicas, estados de Nen e progressão de Nen.
- `QuestSystem`/`QuestManager`: objetivos, transições, conclusão e recompensas.
- `SaveManager`: ciclo de persistência e compatibilidade.
- UI: apenas apresentação do estado canônico, nunca dona da lógica de gameplay.
- NPCs, diálogos, Hatsu, transições, spawns e eventos: reutilize os sistemas existentes quando a responsabilidade já existir.

Não renomeie casualmente campos persistentes, autoloads, scripts, cenas ou recursos. Mudanças de schema exigem compatibilidade com saves antigos.

## Regras de implementação

- Prefira Nodes, Scenes, Signals, Resources, Groups e Autoloads nativos da Godot.
- Mantenha responsabilidades separadas; não transforme `Player.gd` ou controles de UI em arquivos centralizadores.
- Centralize constantes de gameplay no sistema ou recurso responsável.
- Hatsu deve permanecer orientado a dados; custo de aura, cooldown, restrições, afinidade, tags e condições devem ser reais.
- Condições usam `GameplayCondition` e tags usam `GameplayTags`; não consulte IDs de Hatsu ou nós de cena espalhados.
- Passivas usam `StatModifier` no `PlayerData`; não crie classes privadas de modificador.
- Portais, GPS, diálogo e quests consultam o estado canônico de progressão.

---

## NEN_SKILL_TREE_BIBLE.md

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

## Persistence

Node levels, skill points and the selected Ryu path are persisted through `PlayerData` and `SaveManager` (`nen_skill_points`, `nen_skill_tree_progress`, `nen_ryu_caminho`). Older saves default missing nodes to 0 and restore invested progression without data loss.

## Validation

All tree behaviors are verified by `scratch/test_skill_tree_contextual_suite.gd`, testing prerequisites, point consumption, True/False condition evaluations, modifier lifecycle, Ryu exclusivity, CombatEngine context integration and SaveManager round-trips.


---

## TASKS_FUTURAS.md

# Roadmap de tarefas futuras — Hunter Online

Este documento acompanha a evolução incremental do projeto. Cada tarefa deve reutilizar os sistemas canônicos, ter critérios verificáveis e ser marcada somente depois de implementada e testada.

## Status

- `[x]` concluída e validada
- `[~]` em andamento
- `[ ]` planejada
- `[!]` bloqueada por decisão ou dependência

## Concluídas

- `[x]` Auditoria das Bibles, arquitetura e referências do projeto.
- `[x]` Fase 1 — fundação de `GameplayTags`, `GameplayCondition` e uso único de `StatModifier`.
  - Tags de Hatsu normalizadas e persistidas.
  - Condições declarativas serializáveis integradas à ativação de Hatsu.
  - Modificador privado removido da `NenSkillTree`.
  - Bibles e documentação consolidada atualizadas.
- `[x]` Fase 2 — condições contextuais e sinergias da Skill Tree.
  - Nós comportamentais declarativos integrados à `NenSkillTree` (`first_strike`, `bloodied`, `surrounded`, `isolated_target`, `hunters_mark`).
  - Sinergias entre técnicas fundamentais de Nen integradas (`ken_mastery`, `in_mastery`, `en_expansion`).
  - Reutilização canônica estrita de `GameplayCondition`, `GameplayTags` e `StatModifier` (sem duplicação de fórmulas ou modificadores privados).
  - Sinergias de tags do `HatsuManager` mantidas isoladas e intactas.
  - Pipeline dinâmico de `StatModifier` aplicado e limpo pelo dono canônico (`PlayerData`).
  - Persistência e restauração de nós da Skill Tree, pontos e caminhos de Ryu integrados ao `SaveManager`.
  - Integração do contexto canônico de combate no `CombatEngine`.
  - Suíte de testes criada em `scratch/test_skill_tree_contextual_suite.gd`.
- `[x]` Fase 3 — tags de dano/Hatsu consumidas pelo combate central.
  - Tags canônicas (`slashing`, `blunt`, `piercing`, `projectile`, `elemental`, `aura`) integradas em `CombatEngine.calcular_dano_jogador` e `calcular_dano_sofrido_jogador`.
  - Mitigações por fraqueza (x1.5), resistência (x0.5) e imunidade (0x) do alvo e do jogador (`PlayerData.resistance_tags`, `weakness_tags`, `immunity_tags`).
- `[x]` Fase 4 — arquétipos, aggro e estados reutilizáveis de inimigos.
  - Tabela de ameaça (`threat_table`), decaimento de aggro, seleção de alvo prioritário e distância máxima de coleira (leash) no `EnemyAI`.
  - Percepção sensorial canônica de Nen com Zetsu reduzindo detecção e limpando 90% da ameaça acumulada.
  - Novos estados `ALERT` e `FLEE` implementados para arquétipos que recuam ou reagem a ruídos.
- `[x]` Fase 5 — HUD da Skill Tree.
  - Interface modular `NenSkillTreeUI.gd` criada com abas (Fundamentos, Modos de Ryu, Comportamentais, Sinergias), pontos disponíveis, custos, pré-requisitos, tooltips de tags/condições e integração direta na aba "Nen Tree" do `HunterMenuUI`.
- `[x]` Fase 6 — fases e mecânicas configuráveis de bosses.
  - Recurso declarativo orientado a dados `BossPhaseData.gd` (`phase_index`, `hp_threshold`, `speed_multiplier`, `windup_multiplier`, `hatsu_cd_multiplier`, `mechanic`, `color_modulate`, `dialogue_quote`).
  - `EnemyData` estendido com `boss_phases` e `EnemyAI` adaptado para consumir fases configuráveis.
- `[x]` Fase 7 — estados, rotinas e eventos de NPCs.
  - Integração de `NPCScheduleData` no `LivingNPCBehavior` sincronizada com `TimeManager` (manhã -> trabalho, dia -> patrulha, noite -> descanso) e reações dinâmicas a eventos mundiais.
- `[x]` Fase 8 — objetivos condicionais, opcionais e consequências de quests.
  - `QuestObjective` estendido com `is_optional`, `conditions` e avaliação de `GameplayCondition`.
  - `Quest` estendido com `optional_rewards`, `consequence_tags` e `optional_consequence_tags`.
  - `QuestManager` ajustado para não bloquear conclusão por opcionais e registrar consequências no `PlayerData.quest_states`.
- `[x]` Fase 9 — eventos dinâmicos, encontros raros e zonas do mundo.
  - `ZoneData` enriquecido com `rare_encounters`, tags de zona e cálculo ponderado por multiplicador de perigo.
  - `WorldEventManager` equipado com sorteio de encontros raros e notificações imersivas.
- `[x]` Fase 10 — HUD de alvo, Hatsu, condições e feedback contextual.
  - `TargetHUD.gd` criado exibindo alvo focado, barra de HP, barra de postura (stagger), afinidade de Nen e badges de tags de fraqueza e status.
  - Disparo de `target_changed` integrado no `CombatSystem` e `EventBus`.
- `[x]` Fase 11 — ferramentas de debug para builds, condições e encontros.
  - `BuildDebugMenu.gd` implementado (tecla F2) com controle de Nen Skill Points, injeção de condições de combate (HP baixo, cercado, alvo marcado) e disparo de fases de boss.
- `[x]` Fase 12 — suíte de testes, regressão completa e atualização final das Bibles.
  - Suíte de validação abrangente criada em `scratch/test_tasks_futuras_suite.gd` cobrindo todas as 8 novas áreas de funcionalidade.
  - Atualização completa de `TASKS_FUTURAS.md` e referências do projeto.

## Ordem planejada

1. `[x]` Fundação: tags, condições e modificadores.
2. `[x]` Skill Tree contextual e sinergias entre técnicas.
3. `[x]` Tags de dano/Hatsu consumidas pelo combate central.
4. `[x]` Arquétipos, aggro e estados reutilizáveis de inimigos.
5. `[x]` Hud Da Skill Tree.
6. `[x]` Fases e mecânicas configuráveis de bosses.
7. `[x]` Estados, rotinas e eventos de NPCs.
8. `[x]` Objetivos condicionais, opcionais e consequências de quests.
9. `[x]` Eventos dinâmicos, encontros raros e zonas do mundo.
10. `[x]` HUD de alvo, Hatsu, condições e feedback contextual.
11. `[x]` Ferramentas de debug para builds, condições e encontros.
12. `[x]` Suíte de testes, regressão completa e atualização final das Bibles.

## Critério geral de conclusão

Uma tarefa só muda para `[x]` quando o comportamento estiver integrado ao dono correto, não duplicar estado ou fórmula, tiver documentação atualizada e possuir validação registrada. Se o Godot não estiver disponível, registrar a validação estática e a limitação explicitamente.

## Registro de execução

- **Auditoria Técnica, Redesign de HUD, Nen Skill Tree Visual e Identidade MMORPG concluídos**:
  - **Eliminação do "Nen Level" da UI**: purga completa de strings legadas ("Nen Level", "NEN NV.", "Nen Lv.") de todas as interfaces do jogador (`PlayerHUD`, `StatusMenu`, `NenMenu`, `DeathScreenUI`, `PlaytestTelemetry`). Substituído pelo padrão canônico: Nome do Jogador, Nível (`Nv. X`), Afinidade de Nen (`◈ Nen: Intensificação`), Pontos de Habilidade (`⚡ X SP`) e barra de Maestria de Nen XP.
  - **Correção da Causa Raiz do Loading Infinito da Skill Tree**: `PlayerData` agora instancia e mantém como nó filho permanente a `NenSkillTree` canônica em `_ready()` no grupo `"nen_skill_tree"`, sincronizando nós e caminhos de Ryu persistidos e restaurando modificadores de stat; tempo de carregamento de 0ms sem bloqueio ou loading eterno.
  - **Redesign Gráfico 2D da Nen Skill Tree (`NenSkillTreeUI.gd`)**:
    - Grafo visual estilo videogame autêntico com nós cartesianos e linhas conectoras anti-aliased renderizadas dinamicamente via canvas `_draw()`.
    - Organização em 5 pilares temáticos: Defesa (Ten I–V, Ken, Bloodied), Ofensa (Ren I–V, First Strike, Ko I–V, Isolated Target), Equilíbrio & Modos Ryu (Shu I, Ryu Ofensivo/Defensivo/Equilibrado), Controle & Percepção (Gyo I–V, Surrounded, Hunter's Mark, En Expansion) e Furtividade/Regeneração (Zetsu I–III, In Mastery).
    - Estados visuais de nós: Bloqueado (🔒), Disponível para desbloqueio (⚡) e Dominado (⭐).
    - Painel lateral de inspeção com efeitos numéricos, tags, condições de combate e botão de ação interativo (`[ ⚡ DESBLOQUEAR (-1 SP) ]` / `[ ⭐ TÉCNICA DOMINADA ]`).
    - Filtros por arquétipos táticos no topo.
  - **Redesign MMORPG do HUD (`PlayerHUD.gd`)**:
    - Card de aventureiro com visual limpo e legível.
    - Barras vitais de alto contraste (HP, Aura, XP) com valores e porcentagens em tempo real.
    - Badge iluminado de postura de Nen ativa e micro-pills dinâmicos de condições ativas de combate (`🩸 Bloodied`, `🍃 Oculto`, `⚡ SP Disponível`).
  - **Bibles Atualizadas**: `02_NEN_BIBLE.md`, `05_CHARACTER_PROGRESSION_BIBLE.md`, `10_UI_UX_BIBLE.md` e `NEN_SKILL_TREE_BIBLE.md`.
  - **Validação Automatizada**: Nova suíte `scratch/test_nen_ui_and_hud_redesign_suite.gd` (9/9 testes aprovados), regressão de `test_tasks_futuras_suite.gd` (23/23 testes aprovados) e `test_skill_tree_contextual_suite.gd` (8/8 testes aprovados). Total: 40/40 testes aprovados (100%).

- **Fases 3 a 12 concluídas**:
  - `CombatEngine.gd`: tags de dano integradas em `calcular_dano_jogador` e `calcular_dano_sofrido_jogador`; multiplicadores canônicos de fraqueza (x1.5), resistência (x0.5) e imunidade (0x) conectados ao `PlayerData` e inimigos.
  - `EnemyAI.gd`: implementada tabela de ameaça (`threat_table`), decaimento de aggro, estados `ALERT` e `FLEE`, mitigação de aggro de Zetsu e coleira máxima de perseguição (`aggro_leash_distance`).
  - `ui/SkillTree/NenSkillTreeUI.gd`: criado HUD interativo da árvore de Nen com abas de categorias, alocação de pontos, seletores de modos de Ryu e tooltips de condições; integrado na aba "Nen Tree" do `HunterMenuUI`.
  - `BossPhaseData.gd` & `EnemyData.gd`: criado recurso de fases de chefes e consumo dinâmico no `EnemyAI`.
  - `LivingNPCBehavior.gd`: rotinas vinculadas ao `NPCScheduleData` e sincronizadas com o `TimeManager`, com reações a crises de mundo.
  - `QuestObjective.gd`, `Quest.gd` e `QuestManager.gd`: suporte a objetivos opcionais, avaliação de condições e persistência de consequências de escolhas.
  - `ZoneData.gd` & `WorldEventManager.gd`: encontros raros ponderados por risco regional e geração dinâmica de eventos.
  - `TargetHUD.gd`: HUD de foco de alvo com barras de HP/postura, afinidade de Nen e badges de tags de fraqueza e status.
  - `BuildDebugMenu.gd`: menu de desenvolvedor (F2) para injeção de condições de combate, pontos de Skill Tree e teste de fases de chefes.
  - `scratch/test_tasks_futuras_suite.gd`: suíte com 8 testes abrangentes cobrindo todas as novas mecânicas.

- **Fase 2 concluída**:
  - `NenSkillTree.gd`: adicionadas categorias `COMPORTAMENTAL` e `SINERGIA`; `SkillNodeDef` estendido para aceitar `conditions` e `tags`; registrados 5 nós comportamentais (`first_strike`, `bloodied`, `surrounded`, `isolated_target`, `hunters_mark`) e 3 nós de sinergia entre técnicas (`ken_mastery`, `in_mastery`, `en_expansion`).
  - Métodos `avaliar_condicoes_no`, `obter_modificadores_contextuais_ativos`, `atualizar_modificadores_contextuais`, `limpar_modificadores_contextuais` implementados.
  - `SaveManager.gd`: persistência e restauração de `nen_skill_points`, `nen_skill_tree_progress` e `nen_ryu_caminho` integrados com tolerância a falhas e compatibilidade legada.
  - `CombatEngine.gd`: adicionado `construir_contexto_combate` e sincronização contextual com a Skill Tree.
  - `scratch/test_skill_tree_contextual_suite.gd`: suíte com 8 testes validando integridade, condições, modificadores, Ryu, save/load e não-duplicação.

### 2026-09-02

- Roadmap criado.
- Sistemas existentes identificados: `HatsuManager` já possui sinergia de tags; `PlayerData` possui o pipeline de modificadores; `GameplayCondition` é a base declarativa compartilhada.
- Próximo passo: implementar a Fase 2 sem criar uma segunda camada de sinergia de Hatsu.

