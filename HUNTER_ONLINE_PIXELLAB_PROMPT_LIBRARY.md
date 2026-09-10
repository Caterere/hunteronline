# HUNTER ONLINE --- PIXELLAB PROMPT LIBRARY

**Companion to:** `HUNTER_ONLINE_PIXELART_PRODUCTION_BIBLE.md`

Este arquivo contém prompts prontos para o agente usar com PixelLab.

A regra é: **não usar um prompt genérico para tudo**. Cada categoria
possui objetivos, densidade, escala e validação próprios.

------------------------------------------------------------------------

# 0. COMO USAR ESTE ARQUIVO

Antes de qualquer geração:

1.  Ler `HUNTER_ONLINE_PIXELART_PRODUCTION_BIBLE.md`.
2.  Procurar se o asset já existe.
3.  Reutilizar ou criar variante antes de gerar do zero.
4.  Escolher a chamada PixelLab adequada.
5.  Usar os prompts abaixo como base.
6.  Substituir os placeholders:
    -   `[REGION]`
    -   `[MATERIAL]`
    -   `[COLOR_FAMILY]`
    -   `[OBJECT]`
    -   `[CHARACTER]`
    -   `[LANDMARK]`
    -   `[ACTION]`
7.  Gerar.
8.  Comparar com os assets aprovados.
9.  Testar na escala real do Godot.
10. Só depois registrar como aprovado.

------------------------------------------------------------------------

# 1. MATRIZ DE CHAMADAS PIXELLAB

  -----------------------------------------------------------------------
  Necessidade                         Chamada recomendada
  ----------------------------------- -----------------------------------
  Terreno conectado                   `create-tileset`

  Grupo de tiles individuais          `create-tiles-pro`

  Objeto simples de mapa              `map-objects`

  Prop reutilizável/persistente       `create-1-direction-object`

  Prop que precisa virar              `create-8-direction-object`

  Personagem reutilizável             `create-character-v3`

  Animação descrita por texto         `animate-with-text-v3`

  Rotações de personagem              `generate-8-rotations-v3`

  Alterar parte de asset existente    `edit-images-v2`

  Inpainting controlado               `inpaint-v3`

  Imagem/concept para pixel art       `image-to-pixelart`

  Imagem ambiental completa           `generate-image-v2` /
                                      `create-image-pixen`
  -----------------------------------------------------------------------

A documentação atual do PixelLab recomenda `create-character-v3` para
personagens persistentes, `animate-with-text-v3` para animação e
`create-tileset` para tilesets conectados; também diferencia objetos
reutilizáveis de map objects simples. citeturn1search0

**Importante:** antes de alimentar uma referência de usuário em uma
ferramenta de referência, a documentação atual recomenda passar por
`unzoom`, pois arte pixelada previamente ampliada pode confundir o
modelo. citeturn1search0

------------------------------------------------------------------------

# 2. BLOCO GLOBAL --- STYLE LOCK

Este bloco deve ser incorporado mentalmente a praticamente todos os
prompts.

``` text
HUNTER ONLINE VISUAL STYLE LOCK

Create production-ready 2D top-down pixel art for Hunter Online.

The project has two complementary visual levels:

CHARACTERS:
small, readable, low-to-medium detail, 48x48 character frames,
simple silhouettes, simplified faces, grouped pixels, limited palette.

WORLD:
richer environmental detail, varied terrain, layered vegetation,
rocks, ground details, props, transitions, landmarks and readable
environmental storytelling.

The world may be substantially richer than the characters.

STYLE:
- crisp pixel clusters
- hard pixel edges
- no anti-aliasing
- no smooth vector edges
- no photographic textures
- no realistic rendering
- no soft gradients
- no painterly brushwork
- controlled palette
- coherent light direction
- readable silhouettes
- game-ready asset design
- consistent top-down RPG perspective

Do not turn the result into high-resolution pixel illustration.

Do not create generic fantasy asset art.

The result must look like it belongs to the same game as the existing
Hunter Online assets.
```

------------------------------------------------------------------------

# 3. BLOCO DE PERSONAGEM

Para personagens, usar `player(3).png` como **character/style anchor**
quando a ferramenta aceitar referência.

``` text
CHARACTER STYLE ANCHOR

Use the provided Hunter Online player sprite as the primary visual
reference for character pixel density, scale, silhouette complexity,
face simplicity, hair treatment, clothing simplification, shading
and overall sprite language.

The reference defines the visual language, NOT the identity of the
new character.

Create a NEW character identity.

Preserve:
- small RPG character scale
- 48x48 frame target
- consistent feet/baseline
- consistent pivot
- simple face
- grouped pixel clusters
- limited palette
- simple hair masses
- simple clothing masses
- readable silhouette

Do not copy the original character's hair, face or outfit unless
explicitly requested.

Do not add realistic anatomy or excessive micro-detail.
```

------------------------------------------------------------------------

# 4. PERSONAGEM --- NPC COMUM

### Chamada

`create-character-v3`

### Prompt

``` text
Create a common civilian NPC for Hunter Online.

Role:
[ROLE]

Visual identity:
[SHORT_DESCRIPTION]

The NPC must feel like an ordinary inhabitant of the Hunter Online
world, not a hero or boss.

Use the existing Hunter Online player sprite as the character style
anchor.

Target:
48x48 game sprite scale,
small readable silhouette,
simple face,
simple hair,
simple clothing,
limited palette,
grouped pixels,
clean hard edges.

Give the NPC one or two visual identifiers only:
[IDENTIFIER_1]
[IDENTIFIER_2]

Avoid excessive accessories and micro-details.

The character must be readable immediately at gameplay scale.
```

------------------------------------------------------------------------

# 5. PERSONAGEM --- HUNTER

``` text
Create a Hunter Association field hunter for Hunter Online.

Role:
[HUNTER_ROLE]

Personality:
[PERSONALITY]

Equipment:
[EQUIPMENT]

Use the Hunter Online player sprite as the character style anchor.

Create a distinct silhouette and outfit, but preserve the same
48x48-scale character language.

The hunter should look more specialized than a civilian while still
remaining a small, readable RPG sprite.

Use clothing shape, hair silhouette and one distinctive accessory
to communicate identity.

Do not solve identity through excessive detail.

No realistic anatomy.
No high-resolution pixel illustration.
No gradients.
No anti-aliasing.
```

------------------------------------------------------------------------

# 6. PERSONAGEM --- NPC IMPORTANTE

``` text
Create a major Hunter Online NPC.

Character:
[NAME_OR_ROLE]

Personality:
[PERSONALITY]

Story function:
[STORY_FUNCTION]

Signature visual:
[SIGNATURE]

The character must be recognizable from silhouette alone.

Use:
- distinctive hair silhouette
- distinctive clothing silhouette
- one strong accessory
- controlled color identity
- readable posture

Preserve the Hunter Online 48x48 sprite language.

This is an important NPC, so it may have slightly richer visual
identity than a generic NPC, but it must still belong to the same
character system.

Do not make the character look like a different game's art style.
```

------------------------------------------------------------------------

# 7. PERSONAGEM --- BOSS

``` text
Create a Hunter Online boss character.

Boss concept:
[BOSS_CONCEPT]

Combat identity:
[COMBAT_IDENTITY]

Signature:
[SIGNATURE]

The boss must have a strong silhouette and immediately readable
combat identity.

Increase visual presence through:
- silhouette
- posture
- weapon
- clothing shape
- controlled palette
- signature feature

Do NOT simply add hundreds of tiny pixels.

The boss should remain compatible with the Hunter Online character
language.

If a larger-than-normal boss scale is required by gameplay, preserve
the same pixel-art construction logic rather than increasing
rendering smoothness.
```

------------------------------------------------------------------------

# 8. PERSONAGEM --- ENEMY FAMILY

``` text
Create a reusable enemy family for Hunter Online.

Enemy family:
[FAMILY]

Base creature:
[CREATURE]

Combat role:
[ROLE]

Create a strong and simple silhouette.

The family must have a recognizable visual language.

Generate variants through controlled changes:
- color
- markings
- accessories
- body proportions where appropriate
- small silhouette changes

Do not make every variant a completely different creature.

The result must support repeated use across the world without looking
like identical recolors.
```

------------------------------------------------------------------------

# 9. ANIMAÇÃO --- IDLE

### Chamada

`animate-with-text-v3`

``` text
Animate the provided Hunter Online character with a subtle idle loop.

Motion:
- tiny breathing motion
- slight body movement
- very small hair/clothing movement
- preserve feet position
- preserve character identity
- preserve pixel density

The animation should be subtle.

Do not redraw the character with additional detail.

Do not change clothing, face, palette or proportions.

Keep the animation readable at gameplay scale.
```

------------------------------------------------------------------------

# 10. ANIMAÇÃO --- WALK

``` text
Animate the provided Hunter Online character walking.

Create a clean readable RPG walking cycle.

Requirements:
- believable alternating leg movement
- corresponding arm movement
- slight body bob
- preserve baseline
- preserve character proportions
- preserve pixel density
- preserve face and clothing design

Do not add detail between frames.

Do not introduce blur or smooth interpolation.

The animation must look like a real pixel-art game animation.
```

------------------------------------------------------------------------

# 11. ANIMAÇÃO --- ATTACK

``` text
Animate the provided Hunter Online character performing a basic
physical attack.

Attack:
[ATTACK_TYPE]

Motion:
- preparation
- decisive attack motion
- short recovery

Prioritize readable silhouette and anticipation.

Do not create excessive smear frames.

Use strong pixel clusters to communicate speed.

Preserve the original character's scale, clothing, face and palette.

The attack must remain readable at normal gameplay zoom.
```

------------------------------------------------------------------------

# 12. ANIMAÇÃO --- DASH

``` text
Animate the provided Hunter Online character performing a short
directional dash.

The motion should communicate:
- rapid acceleration
- strong body lean
- clear directional intent
- short duration
- clean recovery

Use minimal pixel-based motion accents.

Do not add huge visual effects.

The character must remain recognizable throughout the animation.
```

------------------------------------------------------------------------

# 13. ANIMAÇÃO --- HIT

``` text
Animate the provided Hunter Online character receiving a hit.

Create a short readable hit reaction.

Use:
- small body recoil
- clear directional reaction
- brief pose change

Do not distort the character excessively.

Preserve character identity and pixel density.
```

------------------------------------------------------------------------

# 14. 8 DIREÇÕES

### Chamada

`generate-8-rotations-v3`

``` text
Generate the eight directional views of this Hunter Online character.

Perspective:
low top-down RPG view.

Preserve:
- exact character identity
- hair silhouette
- outfit
- color palette
- approximate character scale
- pixel density
- visual simplicity

Directions must remain consistent.

Do not redesign the character between directions.

Do not introduce new accessories.

Do not increase detail in side or rear views.
```

A documentação atual indica `generate-8-rotations-v3` como a opção
recomendada para gerar oito direções a partir de um frame de referência.
citeturn1search0

------------------------------------------------------------------------

# 15. TERRAIN --- GRASS

### Chamada

`create-tileset`

``` text
Create a connected top-down terrain tileset for Hunter Online.

Terrain:
natural temperate grassland.

Primary material:
soft green grass.

Target visual quality:
rich environmental pixel art with controlled pixel clusters.

The terrain should contain subtle natural variation:
- slightly different grass patches
- sparse small grass tufts
- occasional tiny flowers
- subtle darker soil hints
- tiny irregular ground marks
- restrained natural texture

The terrain must NOT look like a flat repeated green texture.

Create a game-ready connected tileset where terrain edges connect
cleanly.

Keep the visual language consistent with Hunter Online:
crisp pixels, hard edges, limited palette, readable shapes.

Do not use photographic texture.
Do not use smooth gradients.
Do not create excessive micro-detail.
```

`create-tileset` é apropriado para Wang tiles conectados em mapas
top-down. citeturn1search0

------------------------------------------------------------------------

# 16. TERRAIN --- DIRT

``` text
Create a connected top-down dirt terrain tileset for Hunter Online.

Material:
compact natural earth.

Visual characteristics:
- warm brown earth
- darker compacted patches
- tiny stones
- occasional cracks
- sparse grass intrusion
- irregular worn areas
- natural edge variation

The terrain should support paths and worn areas.

Avoid perfectly repeated texture patterns.

Edges must connect naturally with neighboring terrain.

Pixel art must remain crisp and game-ready.
```

------------------------------------------------------------------------

# 17. TERRAIN --- STONE

``` text
Create a connected top-down stone terrain tileset for Hunter Online.

Material:
weathered natural stone.

Include:
- subtle cracks
- different stone values
- small embedded rocks
- moss hints
- irregular seams
- worn edges

The material should feel hand-crafted rather than procedural.

Use a controlled palette.

Keep edges crisp and pixelated.

No realistic photographic stone texture.
```

------------------------------------------------------------------------

# 18. TERRAIN --- WATER

``` text
Create a connected top-down water tileset for Hunter Online.

Water style:
calm natural freshwater.

Include:
- subtle pixel wave patterns
- shallow/deep variation
- small ripples
- restrained highlights
- natural shoreline interaction

The water must remain readable as a game tile.

Do not use realistic reflections.

Do not use smooth gradients.

Create clean terrain connections around the shoreline.
```

------------------------------------------------------------------------

# 19. TRANSITION --- GRASS TO DIRT

### Chamada

`create-tileset` ou grupo de tiles específico

``` text
Create a seamless top-down pixel-art terrain transition between
natural grass and worn dirt for Hunter Online.

The boundary must be irregular and organic.

Use:
- grass intrusion into dirt
- dirt intrusion into grass
- small stones
- sparse grass tufts
- darker soil patches
- broken edge patterns

Do NOT create a straight horizontal boundary.

The transition must support natural paths and irregular terrain.

Preserve the same pixel density and palette family as the existing
Hunter Online world.
```

------------------------------------------------------------------------

# 20. TRANSITION --- WATER TO GRASS

``` text
Create a seamless top-down pixel-art shoreline transition between
freshwater and grass for Hunter Online.

Include:
- irregular shoreline
- small stones
- tiny grass clusters
- shallow water
- subtle wet-ground pixels
- occasional shoreline plants

Avoid a perfectly geometric coast.

The edge should look hand-placed and natural.

Maintain clean tile connectivity.
```

------------------------------------------------------------------------

# 21. TILE VARIANTS --- GRASS

### Chamada

`create-tiles-pro`

``` text
Create a coherent family of grass terrain tile variants for
Hunter Online.

Generate visually related variants that prevent repetitive tiling.

Variants may include:
- clean grass
- slightly darker grass
- sparse grass detail
- small flower patch
- small worn patch
- small rock detail
- subtle soil exposure

All variants must share:
- same lighting
- same palette family
- same pixel density
- same material definition
- same perspective

Do not make the variants look like different art styles.
```

------------------------------------------------------------------------

# 22. TREE FAMILY

### Chamada

`create-1-direction-object` ou `map-objects`

``` text
Create a top-down temperate forest tree for Hunter Online.

Tree type:
[TREE_TYPE]

The tree must be significantly richer than the small player sprite,
because environmental assets carry more visual detail in this game.

Include:
- readable trunk
- layered foliage masses
- multiple green tones
- small branch hints
- subtle shadow
- irregular foliage silhouette
- a few natural pixel details

Avoid individual realistic leaves.

The tree should look hand-crafted in pixel art.

Create a strong silhouette that remains readable at gameplay scale.
```

------------------------------------------------------------------------

# 23. TREE VARIANT

``` text
Create a variant of the approved Hunter Online tree.

Preserve:
- same species family
- same scale
- same lighting
- same pixel density
- same palette family

Change:
- foliage silhouette
- branch arrangement
- small shadow shape
- small color distribution

The new tree must look like another tree from the same forest,
not a new art style.
```

------------------------------------------------------------------------

# 24. BUSH FAMILY

``` text
Create a family of small and medium top-down forest bushes for
Hunter Online.

Use layered pixel clusters.

Variants:
- round bush
- irregular bush
- flowering bush
- dark bush
- dense bush

Keep:
- same palette family
- same light direction
- same environmental detail level

Avoid perfectly symmetrical bushes.
```

------------------------------------------------------------------------

# 25. ROCK FAMILY

``` text
Create a family of natural top-down rocks for Hunter Online.

Rock sizes:
small, medium and large.

Material:
weathered gray-brown stone.

Include:
- irregular silhouette
- 2-4 main value groups
- small cracks
- moss hints on selected variants
- tiny attached stones
- simple cast shadow

The rock must read clearly without becoming realistic.

Create multiple silhouettes to prevent repetition.
```

------------------------------------------------------------------------

# 26. ROCK CLUSTER

``` text
Create a natural top-down rock cluster for Hunter Online.

Composition:
3-7 rocks with varied sizes.

Avoid:
- evenly spaced rocks
- identical rocks
- perfect circles
- symmetrical arrangements

Use overlapping silhouettes and natural spacing.

The cluster should work as a reusable environmental decoration.
```

------------------------------------------------------------------------

# 27. GROUND DETAILS

``` text
Create a reusable collection of small top-down ground details for
Hunter Online.

Include:
- tiny stones
- grass tufts
- leaves
- branches
- small cracks
- dirt patches
- tiny flowers
- small debris

Each detail must be simple enough to remain readable at gameplay
scale.

The collection should add richness without visually dominating the map.
```

------------------------------------------------------------------------

# 28. FLOWERS

``` text
Create a family of small wildflowers for Hunter Online.

Variants:
- white flower
- yellow flower
- red flower
- blue/purple flower
- mixed tiny flower patch

Flowers should be small decorative accents.

Do not create botanical realism.

Use clear pixel clusters and simple shapes.
```

------------------------------------------------------------------------

# 29. PATH / ROAD

``` text
Create a top-down worn natural road/path tileset for Hunter Online.

Material:
packed earth mixed with sparse grass.

The path should show:
- compacted center
- irregular edges
- small stones
- occasional grass intrusion
- tiny worn patches
- subtle variation

Do not create a perfectly straight road texture.

The tiles must support curved and branching paths.
```

------------------------------------------------------------------------

# 30. WOODEN FENCE

### Chamada

`create-1-direction-object`

``` text
Create a reusable wooden fence prop for Hunter Online.

Style:
old but maintained RPG-world wooden fence.

Include:
- wooden posts
- horizontal boards
- subtle cracks
- darker joints
- small variation
- simple ground shadow

Readable silhouette.

No excessive micro-detail.
```

------------------------------------------------------------------------

# 31. SIGNPOST

``` text
Create a top-down wooden signpost for Hunter Online.

Purpose:
town/path navigation.

Include:
- wooden post
- readable sign board
- slightly worn edges
- small metal/wood details
- ground contact shadow

The sign must have a clean empty area where Godot can later place
text or UI.

Do not bake illegible fake text into the pixel art.
```

------------------------------------------------------------------------

# 32. BARREL / CRATE SET

``` text
Create a reusable set of wooden RPG storage props for Hunter Online.

Include:
- barrel
- small crate
- large crate
- stacked crates
- damaged crate

Use one coherent wood material and lighting direction.

Small imperfections are desirable.

Avoid excessive texture detail.
```

------------------------------------------------------------------------

# 33. CAMPFIRE

``` text
Create a top-down campfire prop for Hunter Online.

Include:
- irregular stones
- wood logs
- central flame
- small warm light impression
- subtle ash/ground detail

The base object must work as a static map prop.

Keep the pixel art readable and compact.

Do not create a huge magical flame.
```

------------------------------------------------------------------------

# 34. CHEST

``` text
Create a reusable top-down treasure chest for Hunter Online.

Style:
adventure RPG wooden chest.

Include:
- wooden body
- darker metal reinforcement
- lock
- small shadow
- readable lid shape

The silhouette must be instantly recognizable.

Create enough material definition without over-rendering.
```

------------------------------------------------------------------------

# 35. WELL

``` text
Create a town well landmark prop for Hunter Online.

Include:
- circular stone structure
- wooden support
- roof
- rope/bucket
- moss/wear
- ground shadow

The well should have enough detail to function as a small town landmark.

Do not make it visually noisy.
```

------------------------------------------------------------------------

# 36. TRAINING DUMMY

``` text
Create a Hunter Association training dummy for Hunter Online.

Include:
- wooden support
- straw/cloth body
- target markings
- visible wear
- damaged sections
- ground shadow

The object should immediately communicate:
training area.

Keep it consistent with the world pixel art.
```

------------------------------------------------------------------------

# 37. HUNTER ASSOCIATION BUILDING

### Chamada

`generate-image-v2` for concept, then break into assets/tiles

``` text
Design a Hunter Association building for the original Hunter Online
world.

This is NOT a copy of any existing anime building.

Architecture:
formal hunter organization headquarters.

Visual elements:
- strong entrance
- stone and wood construction
- banners
- signs
- training area
- windows
- lamps
- stairs
- decorative stonework

The building should function as a recognizable world landmark.

Pixel art target:
rich environmental pixel art,
layered materials,
controlled palette,
crisp pixels,
clear silhouette.

Create a game asset concept that can later be decomposed into
reusable tiles and props.
```

------------------------------------------------------------------------

# 38. TOWN HOUSE

``` text
Create a modular top-down RPG town house for Hunter Online.

Architecture:
[HOUSE_STYLE]

Include:
- roof with layered tiles
- walls
- windows
- door
- small foundation
- small decorative plants
- optional chimney
- subtle wear

The house should feel inhabited.

Avoid creating a flat rectangular building.
```

------------------------------------------------------------------------

# 39. SHOP

``` text
Create a small top-down RPG shop building for Hunter Online.

Shop type:
[SHOP_TYPE]

Include:
- recognizable entrance
- sign
- display elements
- windows
- awning
- small exterior props

The shop should communicate its function without requiring UI.
```

------------------------------------------------------------------------

# 40. MARKET STALL

``` text
Create a top-down market stall for Hunter Online.

Include:
- wooden structure
- cloth canopy
- displayed goods
- crates
- baskets
- small sign
- ground shadow

Use a clear silhouette.

The stall should add life to town streets.
```

------------------------------------------------------------------------

# 41. BRIDGE

``` text
Create a reusable top-down wooden/stone bridge for Hunter Online.

Environment:
[ENVIRONMENT]

The bridge must integrate with terrain and water.

Include:
- structural supports
- railings where appropriate
- slight wear
- coherent shadows
- irregular natural details

Design it as a modular map asset rather than a standalone illustration.
```

------------------------------------------------------------------------

# 42. ENVIRONMENTAL STORY PROP

``` text
Create an environmental storytelling prop for Hunter Online.

Story:
[SHORT_STORY]

The prop should visually imply the story without text.

Examples:
- broken tree
- abandoned camp
- damaged cart
- destroyed training dummy
- bloodstained ground
- broken weapon
- discarded equipment

Use restrained details.

The player should be able to wonder:
"What happened here?"
```

------------------------------------------------------------------------

# 43. DUNGEON TILESET

``` text
Create a connected top-down dungeon tileset for Hunter Online.

Dungeon theme:
[DUNGEON_THEME]

Include:
- floor
- wall
- edge
- corners
- cracks
- moss/damage
- transition tiles
- decorative floor details
- door/entrance integration

The dungeon should have stronger visual identity than generic stone rooms.

Use environmental storytelling through damage, age and structure.

Do not make every tile noisy.
```

------------------------------------------------------------------------

# 44. CAVE TILESET

``` text
Create a connected top-down cave tileset for Hunter Online.

Include:
- rock floor
- rock walls
- irregular edges
- stalagmites
- small stones
- cracks
- moss
- dark recesses

Use layered rock silhouettes.

The cave must feel natural and irregular.

Avoid perfectly repeated wall patterns.
```

------------------------------------------------------------------------

# 45. DUNGEON PROP SET

``` text
Create a reusable dungeon prop set for Hunter Online.

Include:
- broken barrel
- torch
- chains
- rubble
- crate
- broken weapon
- old sign
- bone/debris where appropriate
- small stone pile

Keep the same dungeon material language.

Do not over-render.
```

------------------------------------------------------------------------

# 46. WATERFALL

``` text
Create a top-down/low-top-down waterfall environmental landmark
for Hunter Online.

Include:
- water source
- falling water
- rock edges
- foam
- wet stone
- vegetation
- small mist impression

The effect must be readable as a landmark.

Use pixel clusters, not smooth gradients.
```

------------------------------------------------------------------------

# 47. TREE STUMP / DEAD TREE

``` text
Create a family of forest tree remnants for Hunter Online.

Include:
- stump
- dead stump
- fallen log
- broken branch
- hollow log

Use natural irregular silhouettes.

Some variants may have moss, mushrooms or small plants.

These assets should help prevent the forest from feeling generated
from only healthy trees.
```

------------------------------------------------------------------------

# 48. NIGHT VARIANT

``` text
Create a night-state visual variant of the approved [ASSET].

Preserve the exact identity and silhouette.

Do not simply make everything black.

Use:
- cooler shadow values
- reduced saturation
- selective highlights
- moonlight direction
- controlled ambient darkness

The asset must remain readable at gameplay scale.
```

------------------------------------------------------------------------

# 49. RAIN VARIANT

``` text
Create a rainy-world variant for [REGION/ASSET].

Preserve the underlying asset identity.

Add environmental cues:
- wet ground
- subtle puddles
- darker soil
- small reflective pixels
- vegetation weighted by rain
- subdued lighting

Do not use glossy photorealistic reflections.
```

------------------------------------------------------------------------

# 50. COMBAT FX --- PUNCH

### Chamada

`generate-image-v2` / image or animation workflow

``` text
Create a small pixel-art combat impact effect for Hunter Online.

Effect:
physical punch impact.

Visual language:
- compact
- readable
- few frames
- hard pixel edges
- strong silhouette
- limited palette
- short visual duration

Use a small impact burst, directional pixel fragments and a compact
shock shape.

Do not create a giant explosion.
Do not use smooth glow.
```

------------------------------------------------------------------------

# 51. COMBAT FX --- SLASH

``` text
Create a pixel-art melee slash effect for Hunter Online.

Attack:
[WEAPON]

Create:
- directional arc
- small bright impact point
- a few pixel fragments
- compact motion shape

The effect should communicate attack direction immediately.

Keep it visually compatible with the small characters.
```

------------------------------------------------------------------------

# 52. COMBAT FX --- DASH

``` text
Create a compact pixel-art dash trail for Hunter Online.

The effect should communicate speed without becoming a permanent
trail.

Use:
- directional streaks
- small dust pixels
- short-lived motion accents

Keep the character readable.

Do not create anime-style giant energy trails.
```

------------------------------------------------------------------------

# 53. COMBAT FX --- NEN AURA

``` text
Create a restrained Nen aura effect for Hunter Online.

Concept:
controlled supernatural aura around a small RPG character.

Use:
- compact pixel clusters
- subtle aura outline
- small upward energy fragments
- controlled glow impression
- limited palette

The aura should remain subordinate to the character.

Do not create a giant Dragon Ball-style aura.
Do not cover the character.
```

------------------------------------------------------------------------

# 54. COMBAT FX --- HATSU PROJECTILE

``` text
Create a Hatsu projectile effect for Hunter Online.

Hatsu concept:
[HATSU_CONCEPT]

The projectile must have:
- strong readable silhouette
- distinct elemental/color identity
- pixel-cluster construction
- compact scale
- clear direction
- simple animation potential

It must look supernatural without becoming a smooth vector effect.
```

------------------------------------------------------------------------

# 55. COMBAT FX --- HATSU EXPLOSION

``` text
Create a compact Hatsu explosion effect for Hunter Online.

Explosion identity:
[HATSU_IDENTITY]

Use multiple readable pixel layers:
- core
- energy body
- small fragments
- dissipating outer pixels

Keep the effect temporary and compact.

Avoid photorealistic fire.
Avoid giant screen-filling effects unless explicitly requested.
```

------------------------------------------------------------------------

# 56. HEALING FX

``` text
Create a small pixel-art healing effect for Hunter Online.

Visual language:
positive, controlled Nen energy.

Include:
- small upward particles
- compact circular energy
- gentle light impression
- readable effect around the character

Do not obscure the character.
Do not use smooth gradients.
```

------------------------------------------------------------------------

# 57. HIT FX

``` text
Create a compact pixel-art hit feedback effect for Hunter Online.

Use:
- directional impact
- a few pixel fragments
- small flash
- short-lived motion

The effect must be readable in less than a second.

Do not create excessive particles.
```

------------------------------------------------------------------------

# 58. DEATH FX

``` text
Create a restrained pixel-art defeat/death effect for Hunter Online.

Depending on enemy type:
[DEATH_STYLE]

Use:
- readable final pose
- small particles or dissipating pixels
- optional dust
- controlled timing

Avoid giant explosions unless specifically required by the enemy.
```

------------------------------------------------------------------------

# 59. UI / ICON SUPPORT ASSETS

``` text
Create a Hunter Online pixel-art inventory icon.

Item:
[ITEM]

The icon must remain readable at small UI scale.

Use:
- strong silhouette
- limited palette
- high contrast
- few meaningful details

Do not create tiny unreadable decoration.

The icon must communicate the item immediately.
```

------------------------------------------------------------------------

# 60. MAP BACKGROUND / CONCEPT REFERENCE

### Chamada

`generate-image-v2`

Use esta chamada para conceito visual, não como final map texture.

``` text
Create a visual concept for a top-down Hunter Online RPG region.

Region:
[REGION]

Purpose:
[GAMEPLAY_PURPOSE]

The image should communicate:
- terrain structure
- paths
- landmarks
- vegetation density
- architecture
- environmental storytelling
- color palette
- visual hierarchy

This is a DESIGN REFERENCE for later tileset and asset generation.

Do not create a final screenshot.
Do not include UI.
Do not include characters unless necessary for scale.
Do not copy an existing game.
```

------------------------------------------------------------------------

# 61. EDIT --- CORREÇÃO DE ASSET

### Chamada

`edit-images-v2`

``` text
Edit the provided Hunter Online pixel-art asset.

Keep everything unchanged except:

[CHANGE]

Preserve:
- silhouette
- pixel density
- palette family
- lighting direction
- scale
- pixel edges
- material language

Do not redesign the asset.

This is a controlled correction, not a new generation.
```

------------------------------------------------------------------------

# 62. EDIT --- REMOVER EXCESSO DE DETALHE

``` text
Simplify the provided Hunter Online pixel-art asset.

Remove:
- excessive micro-details
- unnecessary texture noise
- overly fine highlights
- unnecessary color variations
- smooth-looking details

Preserve:
- main silhouette
- material identity
- original composition
- approved palette family

The result must look cleaner and more like a game sprite/tileset,
not like a detailed pixel illustration.
```

------------------------------------------------------------------------

# 63. EDIT --- AUMENTAR RIQUEZA DO TILE

``` text
Refine the provided Hunter Online world tile.

Increase environmental richness through:
- a few additional pixel clusters
- subtle material variation
- small ground details
- controlled shading
- small natural imperfections

Do NOT increase resolution.
Do NOT add gradients.
Do NOT add photographic texture.
Do NOT change the material identity.

The goal is richer environmental detail, not higher-resolution art.
```

------------------------------------------------------------------------

# 64. MAP OBJECT --- ÁRVORE

### Chamada

`map-objects`

``` text
Create a transparent top-down map object:

A natural temperate forest tree.

The tree must have:
- irregular foliage silhouette
- layered green masses
- visible trunk
- subtle branch structure
- compact ground shadow
- a few small pixel details

It must be easy to place repeatedly in a Godot tile-based world.

Create a reusable asset, not a scene illustration.
```

------------------------------------------------------------------------

# 65. MAP OBJECT --- PEDRA

``` text
Create a transparent top-down map object:

A natural weathered forest rock.

Include:
- irregular silhouette
- 2-4 major value groups
- tiny cracks
- subtle moss
- compact ground shadow

The rock should be reusable and easy to scatter across the map.
```

------------------------------------------------------------------------

# 66. MAP OBJECT --- BUSH

``` text
Create a transparent top-down map object:

A dense forest bush.

Use layered pixel clusters and an irregular silhouette.

Create enough internal variation to avoid looking like a flat blob,
but do not draw individual leaves.

Include a small natural ground shadow.
```

------------------------------------------------------------------------

# 67. MAP OBJECT --- FLOWER PATCH

``` text
Create a transparent top-down map object:

A small wildflower patch.

Include:
- 5-15 tiny flowers
- grass clusters
- irregular arrangement
- small leaves
- compact ground shadow

The patch should be readable but subtle.
```

------------------------------------------------------------------------

# 68. OBJECT --- 8 DIRECTIONS

### Chamada

`create-8-direction-object`

Usar quando um objeto precisa realmente mudar de orientação.

``` text
Create a reusable eight-direction top-down object for Hunter Online.

Object:
[OBJECT]

The object must remain visually consistent across all directions.

Preserve:
- material identity
- silhouette
- scale
- lighting
- pixel density

Do not redesign the object between directions.
```

------------------------------------------------------------------------

# 69. PERSISTENT OBJECT

### Chamada

`create-1-direction-object`

``` text
Create a persistent reusable Hunter Online world object.

Object:
[OBJECT]

Purpose:
[GAMEPLAY_PURPOSE]

The object may later receive:
- interaction
- animation
- state changes
- damage state

Design it as a clean reusable game object with a strong silhouette
and coherent pixel-art construction.
```

------------------------------------------------------------------------

# 70. OBJECT STATE --- DAMAGED

### Chamada

`create-character-state` / object state workflow conforme o asset

``` text
Create a damaged state of the approved Hunter Online object.

Original:
[OBJECT]

Damage:
[DAMAGE]

Preserve:
- exact identity
- same scale
- same palette family
- same lighting
- same perspective

Only change the requested state.

Do not redesign the object.
```

------------------------------------------------------------------------

# 71. OBJECT STATE --- DESTROYED

``` text
Create a destroyed state of the approved Hunter Online object.

Object:
[OBJECT]

Destroyed condition:
[DESCRIPTION]

The destroyed version must clearly derive from the original.

Preserve recognizable materials and major silhouette fragments.

Use environmental storytelling rather than excessive debris.
```

------------------------------------------------------------------------

# 72. NPC PORTRAIT

``` text
Create a Hunter Online dialogue portrait for:

[CHARACTER]

The portrait must be visually derived from the approved in-game
character.

Preserve:
- hair identity
- face identity
- clothing identity
- palette

The portrait can be more expressive than the 48x48 gameplay sprite,
but it must clearly represent the same character.

Do not redesign the character.
```

------------------------------------------------------------------------

# 73. TILESET --- CITY STREET

``` text
Create a connected top-down city street tileset for Hunter Online.

Environment:
busy but readable Hunter Association-era city.

Include:
- stone/packed street
- sidewalks
- irregular edges
- drainage details
- small cracks
- subtle dirt
- occasional weeds
- transition zones

The street should feel used and inhabited.

Avoid perfectly clean modern pavement.
```

------------------------------------------------------------------------

# 74. TILESET --- RESIDENTIAL

``` text
Create a connected top-down residential neighborhood tileset for
Hunter Online.

Include:
- roads
- sidewalks
- grass
- dirt edges
- house foundations
- fences
- small garden areas

Create visual variation without visual chaos.

The neighborhood should feel lived in.
```

------------------------------------------------------------------------

# 75. TILESET --- TRAINING AREA

``` text
Create a top-down Hunter training-ground environment tileset.

Include:
- worn dirt
- grass edges
- impact marks
- broken stones
- training areas
- simple wooden structures
- target zones
- small debris

The environment should communicate:
this place is actively used for combat training.

Do not depend entirely on props; terrain itself should tell the story.
```

------------------------------------------------------------------------

# 76. TILESET --- FOREST

``` text
Create a connected top-down forest terrain system for Hunter Online.

Primary terrain:
temperate forest.

The forest should have:
- rich grass
- dirt paths
- irregular terrain transitions
- multiple foliage zones
- rock integration
- tree placement support
- ground details
- occasional clearings

The result must support exploration and environmental storytelling.

Do not make every tile equally detailed.
Use visual density variation.
```

------------------------------------------------------------------------

# 77. TILESET --- RIVER

``` text
Create a connected top-down river terrain system for Hunter Online.

Include:
- deep water
- shallow water
- shoreline
- rocks
- grass intrusion
- small plants
- foam
- riverbank transitions

The river should feel naturally irregular.

Create clean tile connectivity for curves and branching.
```

------------------------------------------------------------------------

# 78. TILESET --- DUNGEON ENTRANCE

``` text
Create a top-down dungeon entrance environment for Hunter Online.

Dungeon:
[DUNGEON]

Include:
- terrain transition
- entrance structure
- rocks/walls
- vegetation or debris
- clear landmark silhouette

The entrance must communicate:
"This is a significant location."

It should work as a gameplay landmark rather than merely a decorative
picture.
```

------------------------------------------------------------------------

# 79. LANDMARK --- UNIQUE LOCATION

``` text
Create a unique Hunter Online environmental landmark.

Location:
[LOCATION]

Narrative purpose:
[NARRATIVE_PURPOSE]

Gameplay purpose:
[GAMEPLAY_PURPOSE]

The landmark must have:
- memorable silhouette
- distinctive palette
- layered construction
- surrounding micro-details
- clear interaction with terrain
- visual storytelling

It must be recognizable even without a UI marker.
```

------------------------------------------------------------------------

# 80. REGION VISUAL KIT

Para criar uma região completa, não chamar uma geração gigantesca.

Usar:

``` text
1x terrain base
1x terrain transition kit
1x path kit
1x water kit if needed
3-5 tree variants
3-5 bush variants
4-8 rock variants
10-20 ground details
8-15 props
2-5 structures
1-3 landmarks
NPC set
enemy set
weather set
FX set
```

A quantidade final deve ser adaptada à região.

------------------------------------------------------------------------

# 81. REGRA DE VARIANTE

Quando o mapa estiver repetitivo, NÃO pedir:

> "make the map more detailed"

Primeiro identificar a repetição.

Depois pedir:

``` text
Create additional variants for:
[ASSET_FAMILY]

Preserve the same style, palette, lighting and material.

The purpose is to break visible repetition while maintaining
coherence.
```

------------------------------------------------------------------------

# 82. REGRA DE MAPA VAZIO

Quando o mapa estiver vazio, NÃO gerar um mapa novo.

Adicionar, em ordem:

1.  terrain variation;
2.  transitions;
3.  vegetation;
4.  rocks;
5.  ground details;
6.  props;
7.  landmarks;
8.  NPCs;
9.  interactive objects;
10. secrets.

------------------------------------------------------------------------

# 83. REGRA DE MAPA POLUÍDO

Quando o mapa estiver poluído:

``` text
Reduce environmental clutter in the provided Hunter Online map.

Preserve important:
- paths
- landmarks
- gameplay areas
- interactive objects

Remove redundant:
- rocks
- flowers
- bushes
- tiny decorative clusters

Create clearer visual hierarchy and breathing space.

Do not remove the world's identity.
```

------------------------------------------------------------------------

# 84. REGRA DE "PARECE OUTRO JOGO"

Se um asset não combinar:

``` text
Recalibrate this asset to the existing Hunter Online visual language.

Do NOT redesign its function.

Match:
- pixel density
- palette complexity
- shading complexity
- outline language
- perspective
- environmental detail level

The goal is integration with the existing game, not a more impressive
standalone asset.
```

------------------------------------------------------------------------

# 85. REGRA DE "PERSONAGEM DETALHADO DEMAIS"

``` text
Simplify this character to match the Hunter Online player sprite.

Reduce:
- hair micro-details
- face details
- clothing texture
- tiny highlights
- color count
- internal linework

Preserve:
- identity
- silhouette
- outfit
- proportions

Target:
small readable 48x48 RPG sprite.

Do not turn it into a detailed pixel illustration.
```

------------------------------------------------------------------------

# 86. REGRA DE "MUNDO SIMPLES DEMAIS"

``` text
Increase the environmental detail density of this Hunter Online
world asset without increasing resolution.

Add controlled:
- terrain variation
- small vegetation
- rocks
- ground marks
- material variation
- subtle shadows
- natural imperfections

Keep the same core material and style.

The goal is:
more environmental richness,
NOT more pixels per object.
```

------------------------------------------------------------------------

# 87. REGRA DE REFERÊNCIA

Quando uma imagem de referência for utilizada:

``` text
REFERENCE ROLE:

The reference defines:
[STYLE / IDENTITY / MATERIAL / COMPOSITION]

Do NOT copy unrelated content.

Preserve only the requested properties.

The final result must remain original to Hunter Online.
```

------------------------------------------------------------------------

# 88. PROMPT COMBINADO --- NOVA REGIÃO

``` text
Create a complete visual asset plan for a new Hunter Online region.

Region:
[REGION]

Theme:
[THEME]

Gameplay:
[GAMEPLAY]

Narrative:
[NARRATIVE]

Visual identity:
[VISUAL_IDENTITY]

Generate the assets as a coherent production family:

TERRAIN
- primary terrain
- secondary terrain
- transitions

NATURE
- trees
- bushes
- flowers
- rocks
- ground details

INFRASTRUCTURE
- roads
- fences
- structures
- bridges

PROPS
- interactive props
- decorative props

LANDMARKS
- major landmark
- minor landmarks

CHARACTERS
- common NPCs
- important NPCs
- enemies

EFFECTS
- environmental effects
- combat effects

All assets must share:
- pixel density
- lighting
- palette logic
- top-down perspective
- Hunter Online visual language

Do not generate the whole region as one final image.
This is an asset-family specification for later Godot composition.
```

------------------------------------------------------------------------

# 89. AGENT PROMPT --- AUDIT ANTES DE PIXELLAB

Este é um dos prompts mais importantes para o Antigravity.

``` text
Before calling PixelLab, audit the requested visual asset.

Determine:

1. Does an equivalent approved asset already exist?
2. Can an existing asset be reused?
3. Can a variant solve the problem?
4. Is a new asset actually necessary?
5. Which PixelLab operation is appropriate?
6. What reference should be supplied?
7. What dimensions are appropriate?
8. Does this asset belong to an existing family?
9. Which catalog entry will be created?
10. How will it integrate into Godot?

Do not generate anything until these questions are answered internally.

Prefer reuse and controlled variants over unnecessary generation.
```

------------------------------------------------------------------------

# 90. AGENT PROMPT --- PIXELLAB EXECUTION

``` text
Execute the requested Hunter Online visual asset through PixelLab.

Before generation:
- read HUNTER_ONLINE_PIXELART_PRODUCTION_BIBLE.md
- inspect existing approved assets
- select the correct PixelLab operation
- use the appropriate style/character/material reference
- preserve dimensions and perspective

After generation:
- validate visual consistency
- validate scale
- validate transparency/background
- validate pixel density
- validate material
- validate integration with existing asset family

If the result is inconsistent, do NOT blindly accept it.

Refine or regenerate with a more precise prompt.

Only register the asset as APPROVED after validation.
```

------------------------------------------------------------------------

# 91. AGENT PROMPT --- ASSET REGISTRATION

``` text
After approving a new PixelLab asset, register it in the existing
Hunter Online asset catalog.

Record:
- asset name
- category
- region
- PixelLab operation
- reference used
- dimensions
- variants
- collision requirements
- animation requirements
- Godot integration path
- status

Do not create a duplicate catalog system.

Update the project's existing documentation when appropriate.
```

------------------------------------------------------------------------

# 92. AGENT PROMPT --- BATCH GENERATION

Não gerar centenas de assets de uma vez.

``` text
Generate this PixelLab asset family in controlled batches.

Family:
[ASSET_FAMILY]

Batch 1:
Create only 3-5 representative assets.

Validate:
- style
- scale
- palette
- density
- material
- integration

Only after Batch 1 is approved:
generate the remaining variants.

Do not spend credits generating an entire family before the style is
validated.
```

Isso também reduz desperdício de créditos.

------------------------------------------------------------------------

# 93. AGENT PROMPT --- STYLE CALIBRATION BATCH

Antes de uma grande produção:

``` text
Create a calibration batch for Hunter Online.

Generate:

1 grass tile
1 dirt tile
1 tree
1 bush
1 rock
1 prop
1 NPC

Use the official Hunter Online references.

Do NOT generate a full set yet.

The purpose is to verify:
- world detail level
- pixel density
- palette
- lighting
- perspective
- character/world relationship

Stop after the calibration batch.

Do not continue to mass production until the visual direction is approved.
```

------------------------------------------------------------------------

# 94. PRIMEIRO BATCH RECOMENDADO PARA HUNTER ONLINE

A primeira chamada real do novo pipeline deve ser pequena.

``` text
1. Grass tileset
2. Dirt tileset
3. Grass/Dirt transition
4. Tree A
5. Tree B
6. Bush A
7. Rock A
8. Rock B
9. Ground detail set
10. One NPC
```

Depois montar uma pequena área no Godot.

Se estiver bom:

``` text
→ continuar produção
```

Se estiver ruim:

``` text
→ recalibrar prompt
```

Isso evita gastar muitos créditos em uma direção errada.

------------------------------------------------------------------------

# 95. REGRA DE CUSTO

PixelLab gera trabalhos que podem levar de segundos a minutos e muitas
operações retornam job IDs para processamento assíncrono.
citeturn1search0

Por isso:

-   calibrar primeiro;
-   gerar em batches;
-   reutilizar;
-   criar variantes;
-   não regenerar assets aprovados;
-   evitar geração de mapa gigante;
-   evitar prompts vagos.

------------------------------------------------------------------------

# 96. PIPELINE RECOMENDADO

``` text
ART BIBLE
   ↓
AUDIT
   ↓
STYLE CALIBRATION
   ↓
3-5 ASSETS
   ↓
GODOT TEST
   ↓
APPROVE
   ↓
BATCH GENERATION
   ↓
ASSET CATALOG
   ↓
MAP COMPOSITION
   ↓
POLISH
```

------------------------------------------------------------------------

# 97. ORDEM DE PRODUÇÃO DO MUNDO

Para o primeiro grande upgrade visual:

``` text
PHASE 1
Terrain
↓
Transitions
↓
Paths

PHASE 2
Trees
↓
Bushes
↓
Rocks
↓
Ground Details

PHASE 3
Props
↓
Fences
↓
Signs
↓
Buildings

PHASE 4
Landmarks
↓
NPCs
↓
Enemies

PHASE 5
Combat FX
↓
Weather
↓
Night

PHASE 6
Map Polish
↓
Environmental Storytelling
↓
Secrets
```

------------------------------------------------------------------------

# 98. REGRA FINAL

Não perguntar:

> "Como deixar esse asset mais bonito?"

Perguntar:

> "O que está faltando para esse asset cumprir sua função visual no
> universo do Hunter Online?"

Essa pergunta deve orientar todo o pipeline.

------------------------------------------------------------------------

# 99. CHECKLIST FINAL DE CADA CHAMADA

``` text
[ ] operação PixelLab correta
[ ] referência correta
[ ] estilo correto
[ ] perspectiva correta
[ ] escala correta
[ ] densidade correta
[ ] palette correta
[ ] material correto
[ ] função clara
[ ] variante/família definida
[ ] sem detalhes desnecessários
[ ] sem artefatos
[ ] testado no Godot
[ ] registrado no catálogo
```

------------------------------------------------------------------------

# 100. FONTES PIXELLAB

Documentação oficial atual:

https://api.pixellab.ai/v2/docs

A documentação atual lista as operações de criação de imagem,
personagens, objetos, animações, rotações, tilesets, tiles e map
objects. citeturn1search0

Para integração assistida por agentes, a documentação também fornece
`llms.txt` para que agentes como Cursor/Claude Code/ChatGPT possam
consultar a API disponível. citeturn1search0
