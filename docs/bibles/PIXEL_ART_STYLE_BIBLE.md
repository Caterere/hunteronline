# BIBLE 16 — PIXEL ART STYLE LOCK & SPRITE GENERATION BIBLE
## Hunter Online — Single Source of Truth para PERSONAGENS 2D

> **Escopo SSOT:** style lock de **personagens / NPCs / enemies humanoides** (96×96).
> **Mundo / tiles / props / pipeline:** ver
> [`PIXEL_ART_PRODUCTION_BIBLE.md`](PIXEL_ART_PRODUCTION_BIBLE.md) +
> [`ART_PIPELINE_CANON.md`](ART_PIPELINE_CANON.md).
> **Prompts PixelLab:** [`../guides/PIXELLAB_PROMPT_LIBRARY.md`](../guides/PIXELLAB_PROMPT_LIBRARY.md).
> **Roteiro de regeneração:** [`../roadmap/CHARACTER_QUALITY_REGEN_ROADMAP.md`](../roadmap/CHARACTER_QUALITY_REGEN_ROADMAP.md).
>
> **Upgrade 2026-09 (Quality Pass):** o budget de pixels do **corpo do personagem**
> foi **dobrado** vs o lock antigo (20–22 → 40–44 px) para melhorar reconhecimento
> de silhueta/identidade. Mantém-se **chibi ~2.5 cabeças**, tamanho uniforme entre
> cast, e mundo continua podendo ser mais rico que o char.

---

### 1. PRINCÍPIO SUPREMO: RECONHECIMENTO + CONSISTÊNCIA

O arquivo canônico do projeto é:
```
res://assets/sprites/characters/player.png (style lock também em `assets/reference/player(3).png`)
```
Toda geração (PixelLab MCP, REST, procedural ou manual) **DEVE** seguir a **linguagem
de pixels** desta referência — agora na escala 96×96 / corpo ~40–44 px.

> [!IMPORTANT]
> **RECONHECIMENTO = QUALIDADE.**
> O personagem precisa ser identificável à escala de jogo (quem é, facção, silhueta).
> Continua proibido: anatomia realista, esclera branca, micro-fios, shading fotográfico.
> Detalhe extra só é válido se **aumentar legibilidade de identidade** (cabelo, outfit,
> acessório marcante) sem quebrar o chibi uniforme.

---

### 2. MÉTRICAS CANÔNICAS (Style Lock v2 — 96×96)

| Métrica | Valor Canônico | Limite Aceitável | Reprovado |
| :--- | :--- | :--- | :--- |
| **Canvas do Frame** | **96×96 pixels** | **96×96** fixos | 48×48 legado / 128×128 gameplay / 68×68 |
| **Altura do Personagem (Idle/Walk)** | **40 a 44 pixels** | **48 px** (chapéu/cabelo alto) | <36 px (pobre) ou >52 px (gigante) |
| **Largura do Personagem (Idle/Walk)** | **26 a 30 pixels** | **36 px** (capa/arma) | >40 px |
| **Ocupação de Área no Frame** | **~18% a 28%** | **< 35%** | >50% |
| **Baseline dos Pés (Solo)** | **Y = 84** | **Y = 82 a 86** | colado na borda inferior |
| **Top Padding** | **36 a 44 px livres** | **≥ 28 px** | <20 px |
| **Bottom Padding** | **10 a 12 px** (Y=86..95) | **≥ 8 px** | <4 px |
| **Padding Lateral** | **30 a 36 px** por lado | **≥ 24 px** | <16 px |
| **Cores Únicas por Frame** | **12 a 20 cores** | **24 cores** | >32 cores |
| **Cores Totais na Spritesheet** | **18 a 28 cores** | **36 cores** | >48 cores |
| **Proporção Corporal** | **Chibi (~2.5 cabeças)** | **2.2 a 2.7 cabeças** | 4+ cabeças realistas |

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
- **Nunca muda:** frame 96×96, altura-alvo ~40–44, pés Y≈84, chibi ~2.5 cabeças,
  olhos sem esclera, outline 1px nítido, alpha binário no corpo.

---

### 6. INTEGRAÇÃO PIXELLAB MCP

#### 6.1 Pipeline híbrido (obrigatório para NPCs únicos)

1. `create_image_pixen` — identidade south em **96×96**, `detail: medium detail`
2. Fit geométrico ~40–44 px / pés Y≈84 (`pixellab_regen_cast_v96_stylelock.py`)
3. `create_character` `mode=v3` + `reference_image_base64` = south fitted, `size: 96`

```json
{
  "name": "NomeDoPersonagem",
  "description": "retro 16-bit rpg sprite, chibi 2.5 heads, readable identity silhouette, about 42 pixels tall character centered in 96x96 transparent frame, chunky shapes, dark block eyes no sclera, flat/basic shading, single color black outline, game sprite",
  "mode": "v3",
  "size": 96,
  "detail": "medium detail",
  "outline": "single color black outline",
  "view": "low top-down"
}
```

> [!WARNING]
> - **NÃO** usar `size: 48` para personagens novos de gameplay.
> - **NÃO** usar high detail / shading fotográfico / proporção realistic.
> - Se o corpo ficar <36 px ou >52 px após fit, regenerar.
> - Não usar `v3` + referência do **player** para NPCs únicos (clona identidade).

#### 6.2 Quantização
- `reduce_colors` / quantização local sem dithering se estourar paleta.
- Alpha binário no corpo.

---

### 7. CHECKLIST DE ACEITAÇÃO (GATE)

- [ ] Frame **96×96** (folha 8dir = 768×96)
- [ ] Altura idle **40–48 px**; largura **24–36 px**
- [ ] Pés em **Y=82–86**
- [ ] Top padding ≥ 28 px; laterais ≥ 24 px
- [ ] Olhos em bloco escuro sem esclera
- [ ] Chibi ~2.5 cabeças; silhueta reconhecível do personagem
- [ ] ≤24 cores/frame; ≤36 na folha
- [ ] Sem anti-aliasing suave no corpo
- [ ] `tools/validate_sprite_style.gd` aprovado

---

### 8. AUDITORIA

```bash
godot --headless -s tools/validate_sprite_style.gd -- "res://assets/sprites/characters/<sprite>.png"
```
