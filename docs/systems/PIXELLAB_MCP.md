# PixelLab — status no projeto

## Autoridade documental

Antes de gerar arte, ler nesta ordem:

1. [`docs/bibles/ART_PIPELINE_CANON.md`](../bibles/ART_PIPELINE_CANON.md) — união / anti-conflito
2. Personagens → [`docs/bibles/PIXEL_ART_STYLE_BIBLE.md`](../bibles/PIXEL_ART_STYLE_BIBLE.md)
3. Mundo / pipeline → [`docs/bibles/PIXEL_ART_PRODUCTION_BIBLE.md`](../bibles/PIXEL_ART_PRODUCTION_BIBLE.md)
4. Prompts → [`docs/guides/PIXELLAB_PROMPT_LIBRARY.md`](../guides/PIXELLAB_PROMPT_LIBRARY.md)
5. Catálogo → [`ASSET_REGISTRY.md`](ASSET_REGISTRY.md)

## Integração Cursor (MCP)

Config oficial (docs PixelLab):

```json
{
  "mcpServers": {
    "pixellab": {
      "url": "https://api.pixellab.ai/mcp",
      "transport": "http",
      "headers": {
        "Authorization": "Bearer YOUR_API_TOKEN"
      }
    }
  }
}
```

- **Projeto:** `.cursor/mcp.json` (gitignored — contém token)
- **Template:** `.cursor/mcp.json.example` (sem segredo, pode commitar)
- Depois de criar/alterar: **Cursor Settings → Tools & MCP → refresh/enable `pixellab`**, ou reiniciar o Cursor

Tools típicas: `create_character`, `animate_character`, `create_topdown_tileset`, `get_character`, etc. Jobs são async (2–5 min).

## Quando gerar (obrigatório)

Sempre que um **inimigo novo**, **NPC novo**, **prop/landmark novo** ou **cenário/mapa novo** for adicionado, gere a arte via PixelLab MCP seguindo o Style Lock (`docs/bibles/PIXEL_ART_STYLE_BIBLE.md`) e o padrão Hunter x Hunter. Não finalize conteúdo novo reutilizando `player.png` ou placeholder.

Convenções de saída:

| Conteúdo | Tool | Formato / naming | Pasta |
|---|---|---|---|
| Inimigo | `create_character` + `animate_character` | `enemy_<id>_8dir.png` (idle 8 dir, folha 384x48) + `enemy_<id>_walk_8x8.png` | `assets/sprites/characters/` |
| NPC | `create_character` + `animate_character` | `npc_<nome>_8dir.png` (+ `_walk_8x8.png` se andar) | `assets/sprites/characters/` |
| Prop / Landmark | `create_character` (high top-down) | `<nome>.png` (1 direção) | `assets/sprites/objects/` |
| Cenário / Tileset | `create_topdown_tileset` | conforme registro | `assets/sprites/tilesets/pixellab/` |

Padrão obrigatório: frame **48x48**, altura do boneco **20–22px**, pés em **Y=42**, proporção chibi ~2.5 cabeças, sombreamento plano, paleta reduzida (≈11–14 cores/frame). Âncora de estilo: `assets/sprites/characters/player.png`.

Depois de gerar: valide personagens/inimigos com `tools/validate_sprite_style.gd`, faça o bind (`EnemySystem` liga automaticamente `enemy_<id>_8dir.png` pelo id) e **registre em `docs/systems/ASSET_REGISTRY.md`** (asset, PixelLab ID, descrição, tamanho, direções, mapa, caminho no projeto).

Se o MCP estiver offline (sem token em `.cursor/mcp.json`), use o fallback REST `scripts/tools/pixellab_*`; se nada estiver disponível, sinalize que a etapa de sprite ficou pendente em vez de shipar placeholder como final.

## Camadas

| Camada | Onde | Status |
|---|---|---|
| MCP HTTP | `https://api.pixellab.ai/mcp` | `.cursor/mcp.json` + `.gemini` / `.claude` |
| Clients REST | `scripts/tools/pixellab_*.{py,js}` | Fallback se MCP offline |
| Assets | `assets/sprites/tilesets/pixellab/` | Ver `ASSET_REGISTRY.md` |

## Segurança & token (.env)

**Nenhum token deve entrar no git.** Os arquivos de config do MCP são gerados
localmente a partir de um único segredo e todos estão no `.gitignore`:

- `.cursor/mcp.json`, `.gemini/settings.json`, `.claude/settings.json` — gerados, gitignored.
- Templates versionados (sem segredo): `*.example` + `.env.example`.

Fluxo local:

```bash
cp .env.example .env          # e edite PIXELLAB_API_TOKEN
bash scripts/tools/setup_mcp_local.sh
# Cursor: Settings -> Tools & MCP -> refresh/enable 'pixellab'
```

Os scripts JS (`scripts/tools/pixellab_*.js`, `scratch/pixellab_client.js`) leem o
token de `process.env.PIXELLAB_API_TOKEN` (carregue o `.env` antes de rodar).

> [!WARNING]
> Um token já foi commitado no passado (histórico do git nos commits
> `d432ecf`/`becef2b`). Deixar de rastrear **não apaga o histórico**. Antes de
> tornar o repositório público, **rotacione o token** ou **reescreva o histórico**
> (git filter-repo / BFG) para removê-lo dos commits antigos.
