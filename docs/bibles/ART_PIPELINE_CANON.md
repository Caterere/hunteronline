# HUNTER ONLINE — ART PIPELINE CANON (UNIÃO)

**Status:** Source-of-truth index for all pixel-art / PixelLab rules  
**Purpose:** Unir as regras novas (Production Bible + Prompt Library) com as bibles
anteriores **sem conflito** e sem documentação duplicada.

------------------------------------------------------------------------

## 1. HIERARQUIA DE AUTORIDADE (obrigatória)

Quando houver dúvida ou sobreposição, seguir nesta ordem:

1. Pedido explícito do usuário na tarefa atual
2. **Este índice** (`docs/bibles/ART_PIPELINE_CANON.md`)
3. Documento SSOT do tema (tabela abaixo)
4. Código / assets já aprovados no repo
5. Documentos legados / guides históricos (somente contexto)

**Nunca** inventar um terceiro estilo. Se dois docs parecerem divergir, este
índice decide qual mandado vale.

------------------------------------------------------------------------

## 2. MAPA SSOT — O QUE CADA DOC MANDA

| Tema | SSOT (autoridade) | Docs de apoio (não contradizer o SSOT) |
|---|---|---|
| **Style lock de personagem** (48×48, escala, rosto, paleta, gate) | [`PIXEL_ART_STYLE_BIBLE.md`](PIXEL_ART_STYLE_BIBLE.md) | Production Bible §§5–12, 41–42, 49; Prompt Library §§2–14 |
| **Hierarquia visual mundo vs personagem** (mundo rico, char simples) | [`PIXEL_ART_PRODUCTION_BIBLE.md`](PIXEL_ART_PRODUCTION_BIBLE.md) | Prompt Library §2; VISUAL_BIBLE (render/Y-sort) |
| **Pipeline de produção / fases / quality gates de mapa** | [`PIXEL_ART_PRODUCTION_BIBLE.md`](PIXEL_ART_PRODUCTION_BIBLE.md) | Prompt Library §§94–97; World Production Guide (legado) |
| **Prompts e chamadas PixelLab por categoria** | [`../guides/PIXELLAB_PROMPT_LIBRARY.md`](../guides/PIXELLAB_PROMPT_LIBRARY.md) | PIXELLAB_MCP.md; scripts em `scripts/tools/pixellab_*.py` |
| **Registro de assets gerados** | [`../systems/ASSET_REGISTRY.md`](../systems/ASSET_REGISTRY.md) | Production Bible §74 |
| **Render, Y-sort, game feel visual, resolução** | [`VISUAL_BIBLE.md`](VISUAL_BIBLE.md) | Production Bible §§37, 76–78 |
| **Integração MCP / tokens / tools** | [`../systems/PIXELLAB_MCP.md`](../systems/PIXELLAB_MCP.md) | Prompt Library §1, §100 |

Cópias na raiz do repo (`HUNTER_ONLINE_PIXELART_PRODUCTION_BIBLE.md`,
`HUNTER_ONLINE_PIXELLAB_PROMPT_LIBRARY.md`) são **stubs de ponte** para os
caminhos canônicos acima — editar sempre o arquivo em `docs/`.

------------------------------------------------------------------------

## 3. UNIÃO DAS REGRAS (o que fica válido)

### 3.1 Personagens — herda Style Lock antigo (inalterado)

Mantém-se tudo definido em `PIXEL_ART_STYLE_BIBLE.md`:

- Frame **48×48**; personagem ~**20–22 px**; pés em **Y≈42**
- Olhos 1×2 sem esclera; sem nariz/boca no idle
- Flat/basic shading; ≤14 cores/frame; ≤22 na folha
- Âncora: `assets/sprites/characters/player.png` / `assets/reference/player(3).png`
- Rejeitar 68×68 / high detail / photographic

A Production Bible **não substitui** esses números — ela só reforça que o
personagem fica **simples** relativo ao mundo.

### 3.2 Mundo — herda Production Bible nova + referência visual

Mantém-se a hierarquia da Production Bible:

- Terreno / vegetação / landmarks = **média–alta** riqueza
- Props = média
- Personagens = baixa–média (Style Lock)

Referência oficial de densidade ambiental:

`assets/reference/world_detail_grass_dirt_trees_ref.png`

(Use como nível de acabamento — **não** copiar UI, logo, personagens ou layout.)

### 3.3 PixelLab — herda Prompt Library

- Escolher a chamada correta (tileset / map-object / character-v3…)
- Batches pequenos (§94 → calibrar → expandir)
- Reutilizar antes de regenerar
- Registrar IDs em `ASSET_REGISTRY.md`

### 3.4 Render / engine — herda VISUAL_BIBLE

- 640×360 nativo, pixel-snap, Y-sort, camadas de efeito
- Não misturar com decisões de densidade de tile/prop

------------------------------------------------------------------------

## 4. CONFLITOS RESOLVIDOS (explícitos)

| Conflito aparente | Decisão canônica |
|---|---|
| VISUAL_BIBLE: “player com maior densidade que o fundo” vs Production: “mundo mais rico que o char” | **Silhueta/contraste/legibilidade** do player vencem no combate; **riqueza de tile/prop** do mundo vence na exploração. Não é detalhe facial no player. |
| Style Bible “simplicidade = qualidade” vs Production “mundo detalhado” | Simplicidade aplica-se a **personagens**. Mundo usa detalhe **controlado** (variantes, transições, composição) — não micro-noise. |
| World Production Guide (guides/) vs Production Bible | Production Bible é SSOT de pipeline visual. O guide antigo fica como histórico/contexto; em conflito, preferir Production Bible. |
| `.agent/docs/bibles/16_PIXEL_ART_STYLE_BIBLE.md` vs `docs/bibles/PIXEL_ART_STYLE_BIBLE.md` | Preferir **`docs/bibles/`**. A cópia `.agent/` deve espelhar ou apontar para docs. |

------------------------------------------------------------------------

## 5. FASES DE PRODUÇÃO (ordem oficial)

Da Prompt Library §97 + Production Bible §47 — **não pular**:

``` text
PHASE 1  Terrain + transitions + paths     [calibração §94 — feito]
PHASE 2  Trees + bushes + rocks + details  [densidade Estrada/Floresta — feito]
PHASE 3  Props + fences + signs + crates   [feito — WorldPropsKit]
PHASE 4  Landmarks + NPCs + enemies        [feito — WorldLandmarkKit]
PHASE 5  Combat FX + weather + night       [próximo]
PHASE 6  Map polish + storytelling + secrets
```

Kits de integração Godot:

| Kit | Fase | Mapas |
|---|---|---|
| `CalibrationArtKit` | 1 / demo | Estrada |
| `WorldDensityKit` | 2 | Estrada + Floresta |
| `WorldPropsKit` | 3 | Estrada + Floresta |
| `WorldLandmarkKit` | 4 | Estrada + Floresta |

------------------------------------------------------------------------

## 6. REGRAS PARA AGENTES (checklist curto)

Antes de gerar arte:

1. Ler este índice
2. Abrir o SSOT do tema (tabela §2)
3. Procurar asset existente / variante
4. Usar Prompt Library da categoria certa
5. Validar Style Lock se for personagem
6. Integrar no Godot na escala real
7. Registrar em `ASSET_REGISTRY.md`
8. Não criar documento novo para a mesma regra — atualizar o SSOT

------------------------------------------------------------------------

## 7. ARQUIVOS CANÔNICOS (paths)

``` text
docs/bibles/ART_PIPELINE_CANON.md              ← este arquivo
docs/bibles/PIXEL_ART_STYLE_BIBLE.md           ← personagens
docs/bibles/PIXEL_ART_PRODUCTION_BIBLE.md      ← mundo + pipeline
docs/bibles/VISUAL_BIBLE.md                    ← render / feel
docs/guides/PIXELLAB_PROMPT_LIBRARY.md         ← prompts operacionais
docs/systems/ASSET_REGISTRY.md                 ← catálogo
docs/systems/PIXELLAB_MCP.md                   ← MCP
assets/reference/player(3).png                 ← âncora personagem
assets/reference/world_detail_grass_dirt_trees_ref.png  ← âncora mundo
```

Stubs na raiz (não editar conteúdo longo neles):

``` text
HUNTER_ONLINE_PIXELART_PRODUCTION_BIBLE.md  → docs/bibles/PIXEL_ART_PRODUCTION_BIBLE.md
HUNTER_ONLINE_PIXELLAB_PROMPT_LIBRARY.md    → docs/guides/PIXELLAB_PROMPT_LIBRARY.md
```
