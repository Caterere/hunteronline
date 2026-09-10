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

## Camadas

| Camada | Onde | Status |
|---|---|---|
| MCP HTTP | `https://api.pixellab.ai/mcp` | `.cursor/mcp.json` + `.gemini` / `.claude` |
| Clients REST | `scripts/tools/pixellab_*.{py,js}` | Fallback se MCP offline |
| Assets | `assets/sprites/tilesets/pixellab/` | Ver `ASSET_REGISTRY.md` |

## Segurança

Não commitar `.cursor/mcp.json` com Bearer token. Use o example + token local. Se o token vazou em chat/repo, rotacione em https://api.pixellab.ai/mcp
