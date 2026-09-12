# BIBLE 16 — PIXEL ART STYLE LOCK & SPRITE GENERATION BIBLE
## Hunter Online — Single Source of Truth para PERSONAGENS 2D

> **Escopo SSOT:** style lock de **personagens / NPCs / enemies humanoides** (96×96).
> **Mundo / tiles / props / pipeline:** ver
> [`PIXEL_ART_PRODUCTION_BIBLE.md`](PIXEL_ART_PRODUCTION_BIBLE.md) +
> [`ART_PIPELINE_CANON.md`](ART_PIPELINE_CANON.md).
> **Prompts PixelLab:** [`../guides/PIXELLAB_PROMPT_LIBRARY.md`](../guides/PIXELLAB_PROMPT_LIBRARY.md).
> **Roteiro de regeneração:** [`../roadmap/CHARACTER_QUALITY_REGEN_ROADMAP.md`](../roadmap/CHARACTER_QUALITY_REGEN_ROADMAP.md).
>
> **Upgrade 2026-09 (Quality Pack):** o cast nomeado usa as refs em
> [`assets/reference/cast_quality_pack/`](../../assets/reference/cast_quality_pack/)
> como **SSOT visual**. Frame continua **96×96**; o corpo encaixa em **~60–68 px**
> (pés Y≈84) para caber o chibi das refs sem esmagar cabelo/outfit. Mundo pode
> continuar mais rico que o char.

---

### 1. PRINCÍPIO SUPREMO: RECONHECIMENTO + CONSISTÊNCIA

**SSOT visual do cast (prioridade máxima):**
```
assets/reference/cast_quality_pack/
  grid_24_cast.png          # Gon→Gotoh (L→R, cima→baixo)
  south_refs/<id>_south_ref.png
  netero_heart_uniform_ref.jpg / chrollo_troupe_coat_ref.png / <nome>_ref.png
```

Âncora técnica de canvas/padding:
```
res://assets/sprites/characters/player.png
```

Toda regeneração de personagem nomeado **DEVE** partir da south_ref correspondente
(`create_character` `mode=v3` + `reference_image_base64`). Prompt textual só guia
rotação/animação — **não** reinventa o design.

> [!IMPORTANT]
> **FIDELIDADE À REF = IDENTIDADE #1.**  
> O PNG de referência (grade ou standalone) define cabelo, outfit e proporção.
> Cabelo continua o sinal mais forte (Gon spikes + tips verdes, Killua prata, etc.).
> Proibido: reinventar silhueta via prompt; misturar o Chrollo de terno da grade com
> o casaco da trupe (casaco = canônico); Netero sem uniforme heart / topknot.

---

### 1.1 FIDELIDADE DE CABELO (SSOT HxH)

Ao gerar/regenerar qualquer personagem nomeado, o prompt **deve começar pelo cabelo**
(forma, direção dos spikes, cor, o que NÃO é). Budget extra de pixels do Style Lock v2
existe sobretudo para caber essas silhuetas.

| Personagem | Silhueta de cabelo obrigatória | Anti-padrões |
| :--- | :--- | :--- |
| **Gon** | Preto com leve tint verde-escuro nas bordas; **spikes altos e VERTICAIS** (porco-espinho para cima), crowning jagged; laterais mais curtos | Bola radial redonda; bob; spikes só laterais |
| **Killua** | Prata/branco-lavanda gelado **para cima e para trás**, comprimentos irregulares; franja irregular na testa | Coroa curta uniforme; azul forte demais |
| **Kurapika** | Loiro dourado curto em camadas, fios laterais mais longos emoldurando o rosto | Spike; bowl cut preto |
| **Leorio** | Castanho escuro curto, topo um pouco volumoso/bagunçado | Spikes gelados; careca |
| **Hisoka** | Magenta/rosa-choque **varrido para trás** em agulhas longas e pontudas; **sem pontas amarelas** | Coroa com tips amarelas; cabelo curto |
| **Netero** | Careca + **topknot** branco + sobrancelhas/barba/bigode brancos (uniforme heart) | Sem topknot; kimono roxo como idle padrão |
| **Chrollo** | Cabelo preto slicked + cruz roxa na testa; **casaco trupe** (gola pelepura) | Terno preto da grade como look padrão |
| **Wing** | Escuro bagunçado / desalinhado | Corte militar limpo |
| **Elena** | Castanho em coque baixo limpo | Solto longo |
| **Satotz** | Cabelo oculto sob bowler | Spikes visíveis |

**Fit geométrico (Quality Pack):** alvo **~64 px de altura**, largura até **~48 px**
(pés Y≈84). Não esmagar cabelo/capa das refs da grade (~65 px nativos).

---

### 2. MÉTRICAS CANÔNICAS (Style Lock v2 — 96×96 + Quality Pack)

| Métrica | Valor Canônico | Limite Aceitável | Reprovado |
| :--- | :--- | :--- | :--- |
| **Canvas do Frame** | **96×96 pixels** | **96×96** fixos | 48×48 legado / 128×128 gameplay |
| **Altura do Personagem (Idle/Walk)** | **60 a 66 pixels** | **68 px** (cabelo/capa) | <48 px (pobre) ou >74 px |
| **Largura do Personagem (Idle/Walk)** | **28 a 40 pixels** | **52 px** (capa/arma/cabelo) | >56 px |
| **Ocupação de Área no Frame** | **~22% a 38%** | **< 45%** | >55% |
| **Baseline dos Pés (Solo)** | **Y = 84** | **Y = 82 a 86** | colado na borda inferior |
| **Top Padding** | **12 a 24 px livres** | **≥ 10 px** | <8 px |
| **Bottom Padding** | **10 a 12 px** (Y=86..95) | **≥ 8 px** | <4 px |
| **Padding Lateral** | **22 a 34 px** por lado | **≥ 16 px** | <12 px |
| **Cores Únicas por Frame** | **12 a 28 cores** | **36 cores** | >48 cores |
| **Cores Totais na Spritesheet** | **18 a 40 cores** | **56 cores** | >64 cores |
| **Proporção Corporal** | **Chibi (~2.5–3 cabeças)** | **2.2 a 3.2 cabeças** | 4+ cabeças realistas |

#### Folha 8 direções
- Idle/walk direcional: **768×96** (8 frames × 96)
- Ordem: S, SE, E, NE, N, NW, W, SW

#### Legado 48×48
- Sprites `*_8dir.png` em 384×48 são **legado pré-Quality Pass**.
- Novos commits de personagem **devem** sair em 96×96.
- Validação: `tools/validate_sprite_style.gd` usa as métricas v2.

---

### 3. ANATOMIA PIXEL A PIXEL (escala dobrada)

#### 3.1. Cabeça e Rosto
- **Altura da Cabeça:** 22 a 26 px (cabelo incluso) — ~55–60% da altura do boneco.
- **Rosto (pele):** 10 a 12 px alt × 14 a 16 px larg.
- **Olhos:** blocos **2×3 ou 2×4 px** escuros (`#21110d` / `#000000`), separados por **5–7 px** de pele.
- **PROIBIÇÕES NO ROSTO:**
  - ❌ Esclera branca / brilho de pupila
  - ❌ Nariz desenhado no idle
  - ❌ Boca detalhada no idle (exceto expressões de animação pontual)
  - ❌ Blush / sobrancelha realista

#### 3.2. Cabelo
- Massas sólidas com **2–3 tons** (base + sombra + contorno pontual).
- Silhueta deve ser o **principal ID** do personagem (Gon spikes, Killua gel, etc.).
- ❌ Fios individuais, gradiente especular, mechas microscópicas.

#### 3.3. Tronco e Roupas
- Tronco visível: ~8 a 12 px alt × 14 a 20 px larg.
- Pernas/botas: ~8 a 12 px alt.
- Mãos: blocos ~3×3 / 4×4 px.
- Acessórios icônicos **permitidos e desejados** (bastão, alfinete, chapéu, capa curta)
  desde que caibam no bbox.
- ❌ Dobrinhas densas, costuras micro, botões 1px espalhados.

#### 3.4. Sombra de Solo
- Elipse sob os pés em **Y=82–84**.
- Cor `#0c0e19` ~50% alpha.
- Largura ~22–28 px; altura 3–4 px.

---

### 4. PALETA MESTRA

Arquivo: `res://assets/sprites/characters/master_palette.png`

A paleta mestre de 15 cores base permanece como âncora de **família cromática**.
No lock v2, personagens nomeados podem usar **tons extras de identidade**
(ex.: verde Gon, azul Killua, vermelho Hisoka) desde que o total por frame
respeite o teto de cores da tabela acima.

---

### 5. O QUE MUDA / O QUE NÃO MUDA ENTRE PERSONAGENS

- **Muda:** cor/silhueta de cabelo, outfit, acessório, proporção leve de ombros.
- **Nunca muda:** frame 96×96, pés Y≈84, chibi das refs Quality Pack, outline nítido,
  alpha binário no corpo, fidelidade à south_ref.

---

### 6. INTEGRAÇÃO PIXELLAB MCP

#### 6.1 Pipeline Quality Pack (obrigatório para cast nomeado)

1. South ref em `assets/reference/cast_quality_pack/south_refs/<id>_south_ref.png`
2. Fit ~64 px / pés Y≈84 (`pixellab_regen_cast_from_quality_refs.py`)
3. `create_character` `mode=v3` + `reference_image_base64` = south fitted, `size: 96`
4. `animate_character`: `breathing-idle`, `walk`, `taking-punch` (hit) — 8 dirs
5. Habilidades futuras: templates/`action_description` por Hatsu (fora do MVP)

```json
{
  "name": "npc_gon",
  "description": "Preserve EXACT pixel identity from reference south sprite while rotating 8 directions; chibi RPG, 96x96 transparent frame, feet near bottom",
  "mode": "v3",
  "size": 96,
  "reference_image_base64": "<fitted south png>"
}
```

> [!WARNING]
> - **NÃO** regenerar cast nomeado só com `create_image_pixen` sem a south_ref.
> - **NÃO** usar `size: 48` para personagens novos de gameplay.
> - Se o corpo ficar <48 px ou >74 px após fit, ajustar fit — não inventar novo design.
> - Não usar `v3` + referência do **player** para NPCs únicos (clona identidade).

#### 6.2 Quantização
- `reduce_colors` / quantização local sem dithering se estourar paleta.
- Alpha binário no corpo.

---

### 7. CHECKLIST DE ACEITAÇÃO (GATE)

- [ ] Frame **96×96** (folha 8dir = 768×96)
- [ ] Altura idle **60–68 px**; largura **28–52 px**
- [ ] Pés em **Y=82–86**
- [ ] Top padding ≥ 10 px; laterais ≥ 16 px
- [ ] Fidelidade visual à south_ref (cabelo + outfit)
- [ ] Animações mínimas: idle / walk / hit (8 dirs quando aplicável)
- [ ] ≤36 cores/frame; ≤56 na folha
- [ ] Sem anti-aliasing suave no corpo
- [ ] `tools/validate_sprite_style.gd` aprovado

---

### 8. AUDITORIA

```bash
godot --headless -s tools/validate_sprite_style.gd -- "res://assets/sprites/characters/<sprite>.png"
```
