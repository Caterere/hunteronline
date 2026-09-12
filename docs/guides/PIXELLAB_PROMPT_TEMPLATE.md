# HUNTER ONLINE — PIXELLAB PROMPT TEMPLATE (copy-paste)

**Uso:** modelo fill-in para gerar **um asset por vez** no PixelLab.  
**SSOT de regras:** [`../bibles/ART_PIPELINE_CANON.md`](../bibles/ART_PIPELINE_CANON.md)  
**Catálogo completo de prompts:** [`PIXELLAB_PROMPT_LIBRARY.md`](PIXELLAB_PROMPT_LIBRARY.md)  
**Âncoras:**
- Personagem → `assets/reference/player(3).png` / `assets/sprites/characters/player.png`
- Mundo (densidade) → `assets/reference/world_detail_grass_dirt_trees_ref.png` + `gamestyle.png`

> Gere **individualmente** (1 personagem, 1 animação, 1 prop, 1 tileset).  
> Não peça “todas as animações de uma vez” — calibra melhor e gasta menos crédito.

------------------------------------------------------------------------

## COMO USAR (30 segundos)

1. Escolha a **seção** certa (personagem / animação / mundo / FX).
2. Copie o bloco inteiro.
3. Substitua só o que está entre `[COLCHETES]`.
4. Anexe a **referência** correta (tabela abaixo).
5. Cole no PixelLab / MCP e gere **um** resultado.
6. Compare com a âncora na escala de gameplay. Se driftar, use o bloco **RECALIBRATE**.

### Referências por tipo

| Tipo | Anexar no PixelLab | Papel |
|---|---|---|
| Novo personagem / NPC / enemy | `player(3).png` ou `player.png` | STYLE (não identidade) |
| Animação de personagem existente | o próprio sprite aprovado | IDENTITY + STYLE |
| 8 direções | frame south aprovado | IDENTITY |
| Tileset / prop / árvore / pedra | `world_detail_grass_dirt_trees_ref.png` ou `gamestyle.png` | DENSIDADE ambiental |
| Edição / correção | o asset a editar | IDENTITY |

------------------------------------------------------------------------

## A) STYLE LOCK GLOBAL (sempre incluir)

Cole este bloco no início de **quase todo** prompt:

```text
HUNTER ONLINE STYLE LOCK

Production-ready 2D top-down oblique pixel art for Hunter Online (Godot RPG).

VISUAL LANGUAGE:
- crisp hard pixel edges, no anti-aliasing, no soft gradients
- cell-shaded / flat block shading (base + 1 shadow, optional 1 highlight)
- thick dark outline on readable silhouettes
- controlled limited palette
- game sprite / tileset asset (not illustration, not photo, not concept art)
- consistent low top-down RPG perspective

HIERARCHY:
- CHARACTERS = small, simple, low detail, readable
- WORLD = richer environmental detail than characters
- FX = compact, short, readable, subordinate to characters

Must look like it belongs with existing Hunter Online assets.
Do not invent a new art style.
```

------------------------------------------------------------------------

## B) SETTINGS PIXELLAB — PERSONAGEM (create_character / v3)

Use estes valores fixos (não invente):

| Campo | Valor obrigatório |
|---|---|
| `size` | `48` |
| `detail` | `low detail` |
| `shading` | `flat shading` |
| `outline` | `single color black outline` |
| `view` | `low top-down` |
| `proportions` | chibi (~2.5 heads) |
| `n_directions` | `4` ou `8` (preferir 8 quando for gameplay) |

**Rejeitar se:** personagem >24px de altura, frame ≠48, olhos com branco, anti-alias, gradiente, “HD pixel”.

### Números do Style Lock (gate)

```text
Frame: 48x48 transparent
Character height idle/walk: 20–22 px (max 24 with hat)
Width: 13–15 px (max 18 with cape/weapon)
Feet baseline: Y ≈ 42
Top padding: ≥18 px empty
Colors/frame: ≤14 (prefer 7–11)
Eyes: 1x2 dark dots, NO sclera, NO nose, NO mouth in idle
Hair: solid masses (no individual strands)
Clothes: color blocks (no fabric wrinkles / micro buttons)
Contact shadow: small flat ellipse under feet
```

------------------------------------------------------------------------

## C) MODELO — NOVO PERSONAGEM / NPC / ENEMY

**Tool:** `create-character-v3` / `create_character`  
**Ref:** `player(3).png` = style only

```text
[COLE AQUI O STYLE LOCK GLOBAL — seção A]

CHARACTER STYLE ANCHOR
Use the attached Hunter Online player sprite as STYLE reference only:
pixel density, scale, face simplicity, hair masses, clothing masses, shading, outline.
Do NOT copy hair, face, outfit or identity unless requested.

Create a NEW character for Hunter Online.

Name/ID: [NOME_OU_ID]
Category: [NPC_COMUM | HUNTER | NPC_IMPORTANTE | ENEMY | BOSS]
Role: [FUNCAO]
Personality vibe: [1_FRASE]
Visual identity (what CHANGES from the anchor):
- hair silhouette/color: [CABELO]
- outfit silhouette/colors: [ROUPA]
- 1–2 identifiers only: [ID_1], [ID_2]
- palette accent: [COR_ACENTO]

Target:
48x48 frame, character ~20–22 px tall, feet near Y=42,
chibi ~2.5 heads, simple face (dot eyes, no sclera),
flat shading, limited palette, readable silhouette at gameplay zoom.

Avoid:
realistic anatomy, micro-detail, gradients, anti-aliasing,
high-res pixel illustration, too many accessories.
```

### Exemplo preenchido (NPC)

```text
Name/ID: npc_merchant_padokia
Category: NPC_COMUM
Role: traveling merchant
Personality vibe: cheerful, slightly greedy
Visual identity:
- hair silhouette/color: short black bowl cut
- outfit silhouette/colors: warm brown vest, cream shirt, dark pants
- identifiers: oversized backpack, small coin pouch
- palette accent: warm brown + cream
```

------------------------------------------------------------------------

## D) MODELO — 8 DIREÇÕES

**Tool:** `generate-8-rotations-v3`  
**Ref:** frame south aprovado do personagem

```text
[COLE STYLE LOCK GLOBAL]

Generate the eight directional views of this Hunter Online character.

Perspective: low top-down RPG view.

Preserve exactly:
- character identity, hair, outfit, palette
- 48x48 scale language, pixel density, simplicity
- feet/baseline consistency

Do not redesign between directions.
Do not add accessories.
Do not increase detail on side/rear views.
```

------------------------------------------------------------------------

## E) MODELO — ANIMAÇÕES (um ciclo por vez)

**Tool:** `animate-with-text-v3` / `animate_character`  
**Ref:** o personagem aprovado (não o player genérico)

### E1 — Template mestre de animação

```text
[COLE STYLE LOCK GLOBAL]

Animate the PROVIDED Hunter Online character.

Animation: [IDLE | WALK | RUN | ATTACK | DASH | HIT | DEATH | CAST]
Direction focus: [SOUTH | ou manter multi-dir se a tool permitir]
Frames target: [N] (keep short and readable)

HARD RULES:
- preserve exact identity, clothing, face, palette, proportions
- preserve pixel density (do not redraw with extra detail between frames)
- hard pixels only — no blur, no smooth interpolation, no morphing
- keep feet/baseline stable unless the action requires lift
- readable at gameplay zoom

Motion brief:
[DESCREVA_O_MOVIMENTO_EM_3_A_6_BULLETS]
```

### E2 — IDLE (pronto)

```text
[COLE STYLE LOCK GLOBAL]

Animate the provided Hunter Online character with a subtle idle loop.

Motion:
- tiny breathing bob (1–2 px)
- very slight hair/clothing settle
- preserve feet position and baseline
- preserve identity, palette, pixel density

Subtle only. No new details. No face redraw.
```

### E3 — WALK (pronto)

```text
[COLE STYLE LOCK GLOBAL]

Animate the provided Hunter Online character with a clean RPG walk cycle.

Motion:
- alternating legs
- matching arm swing
- slight body bob
- preserve baseline, proportions, clothing, face, palette
- no blur, no extra detail between frames

Must look like real pixel-art game animation, not interpolated video.
```

### E4 — RUN (pronto)

```text
[COLE STYLE LOCK GLOBAL]

Animate the provided Hunter Online character running.

Motion:
- faster leg cycle than walk
- stronger forward lean
- bigger arm swing
- short readable body bob
- preserve identity and pixel density

No smear blur. No extra accessories.
```

### E5 — ATTACK (pronto — preencha o tipo)

```text
[COLE STYLE LOCK GLOBAL]

Animate the provided Hunter Online character performing a basic attack.

Attack type: [PUNCH | KICK | DAGGER_SLASH | SWORD_SLASH | STAFF_SWING]
Weapon/effect language: compact hard pixels; optional small white motion arc for blade path (Hunter Online attack language).

Motion phases:
1) anticipation / preparation
2) decisive strike (readable silhouette)
3) short recovery

Rules:
- prioritize readable silhouette over fancy smears
- few frames, strong poses
- do not add huge FX
- preserve character scale, clothing, face, palette
```

### E6 — DASH (pronto)

```text
[COLE STYLE LOCK GLOBAL]

Animate the provided Hunter Online character performing a short directional dash.

Motion:
- rapid acceleration
- strong body lean
- clear directional intent
- short duration + clean recovery
- minimal pixel dust/streak accents only

Character must stay recognizable. No giant energy trails.
```

### E7 — HIT (pronto)

```text
[COLE STYLE LOCK GLOBAL]

Animate the provided Hunter Online character receiving a hit.

Motion:
- small directional recoil
- brief pose change
- short duration

Do not distort anatomy. Preserve identity and pixel density.
```

### E8 — DEATH / DEFEAT (pronto)

```text
[COLE STYLE LOCK GLOBAL]

Animate the provided Hunter Online character defeat/death.

Style: [COLLAPSE_FORWARD | KNOCKDOWN | DISSIPATE_PIXELS]
Motion: clear, short, readable final pose. Minimal particles.

No giant explosion unless enemy design requires it.
Preserve silhouette readability.
```

### E9 — CAST / NEN (pronto)

```text
[COLE STYLE LOCK GLOBAL]

Animate the provided Hunter Online character casting / channeling Nen.

Motion:
- compact cast pose
- restrained aura accents (pixel clusters, not Dragon Ball glow)
- aura subordinate to character — never covers the body
- short loop or cast-release depending on request: [LOOP | RELEASE]

Preserve identity. No smooth glow gradients.
```

### Ordem recomendada por personagem

```text
1) create character (south / style lock)
2) 8 directions
3) idle
4) walk
5) attack (tipo principal)
6) hit
7) dash (se combate)
8) death / cast (se necessário)
```

------------------------------------------------------------------------

## F) MODELO — MUNDO / TILE / PROP

**Tools:** `create-tileset` / `create-tiles-pro` / `map-objects` / `create-1-direction-object`  
**Ref:** `world_detail_grass_dirt_trees_ref.png` ou `gamestyle.png` (densidade, não copiar layout/UI)

```text
[COLE STYLE LOCK GLOBAL]

Create a production-ready Hunter Online top-down world asset.

Asset type: [TILESET | TRANSITION | TREE | BUSH | ROCK | PROP | LANDMARK]
Name: [NOME]
Region/material: [REGIAO_OU_MATERIAL]
Purpose: [GAMEPLAY_PURPOSE]

WORLD DETAIL TARGET:
richer than characters — layered terrain/vegetation, natural variation,
irregular edges, controlled ground details, coherent light, crisp pixels.

Include:
[LISTA_CURTA_DE_DETALHES_DESEJADOS]

Avoid:
photographic texture, smooth gradients, anti-aliasing,
perfectly repeated patterns, over-noisy micro-detail,
copying any reference UI/characters/layout.
```

------------------------------------------------------------------------

## G) MODELO — COMBAT FX

```text
[COLE STYLE LOCK GLOBAL]

Create a compact Hunter Online pixel-art combat FX.

FX: [PUNCH_IMPACT | SLASH_ARC | DASH_TRAIL | HIT_FLASH | NEN_AURA | HATSU_PROJECTILE | HEAL]
Scale: small — must fit around 48x48 characters
Language: hard pixel clusters, strong silhouette, short duration, limited palette

Avoid: giant explosions, soft glow, photoreal fire, screen-filling effects.
```

------------------------------------------------------------------------

## H) MODELO — EDIT / CORREÇÃO

**Tool:** `edit-images-v2` / `inpaint-v3`

```text
[COLE STYLE LOCK GLOBAL]

Edit the provided Hunter Online asset.

Change ONLY:
[MUDANCA_ESPECIFICA]

Preserve:
silhouette, pixel density, palette family, lighting, scale, hard edges.

This is a controlled correction, not a redesign.
```

### Recalibrate (quando “parece outro jogo”)

```text
Recalibrate this asset to Hunter Online visual language.

Match:
- pixel density and outline language
- shading complexity (flat/blocks)
- character scale rules if character (48x48, ~20–22px tall)
- world detail density if environment
- no AA, no gradients

Do not change gameplay function. Integration > standalone beauty.
```

### Simplify character (detalhe demais)

```text
Simplify this character to Hunter Online Style Lock.

Reduce hair micro-detail, face detail, clothing texture, tiny highlights, color count.
Preserve identity silhouette/outfit/proportions.
Target: readable 48x48 RPG sprite, not pixel illustration.
```

------------------------------------------------------------------------

## I) CHECKLIST RÁPIDO ANTES DE COLAR

```text
[ ] um asset / uma animação só
[ ] style lock colado
[ ] referência correta anexada
[ ] tool PixelLab correta
[ ] placeholders [COLCHETES] preenchidos
[ ] size 48 + low detail (se personagem)
[ ] depois: validar no Godot + Style Lock gate
[ ] registrar em docs/systems/ASSET_REGISTRY.md
```

------------------------------------------------------------------------

## J) ATALHO — prompt mínimo de 1 linha (emergência)

Só quando precisar de velocidade. Prefira os blocos completos.

**Personagem:**
```text
Hunter Online 48x48 low top-down chibi RPG sprite, ~20px tall, flat shading, black outline, dot eyes no sclera, limited palette, style-matched to attached player anchor, NEW identity: [DESC], no AA no gradients
```

**Animação:**
```text
Animate attached Hunter Online sprite: [ACTION], preserve identity/palette/pixel density, hard pixels no blur, readable RPG motion, subtle/short frames
```

**Mundo:**
```text
Hunter Online top-down connected pixel tileset/prop: [ASSET], rich env detail, hard pixels, limited palette, natural variation, no photo no gradients, match attached world density ref
```
