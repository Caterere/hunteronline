#!/usr/bin/env bash
# ============================================================
# Hunter Online — gerador de configs de MCP (PixelLab) LOCAIS
# ------------------------------------------------------------
# Gera, a partir de um único token, os arquivos de configuração do MCP
# que contêm segredo — todos gitignored:
#   - .cursor/mcp.json       (Cursor)
#   - .gemini/settings.json  (Gemini CLI)
#   - .claude/settings.json  (Claude CLI)
#
# Fonte do token (nesta ordem):
#   1. variável de ambiente PIXELLAB_API_TOKEN
#   2. arquivo .env na raiz do repositório (PIXELLAB_API_TOKEN=...)
#
# Uso:
#   cp .env.example .env      # e edite o token
#   bash scripts/tools/setup_mcp_local.sh
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [[ -z "${PIXELLAB_API_TOKEN:-}" && -f .env ]]; then
	set -a
	# shellcheck disable=SC1091
	. ./.env
	set +a
fi

TOKEN="${PIXELLAB_API_TOKEN:-}"
if [[ -z "$TOKEN" || "$TOKEN" == "YOUR_API_TOKEN" ]]; then
	echo "[setup_mcp_local] ERRO: defina PIXELLAB_API_TOKEN em .env ou no ambiente." >&2
	echo "                  cp .env.example .env  # e edite o token" >&2
	exit 1
fi

mkdir -p .cursor .gemini .claude

cat > .cursor/mcp.json <<EOF
{
  "mcpServers": {
    "pixellab": {
      "url": "https://api.pixellab.ai/mcp",
      "transport": "http",
      "headers": {
        "Authorization": "Bearer ${TOKEN}"
      }
    }
  }
}
EOF

cat > .gemini/settings.json <<EOF
{
  "mcpServers": {
    "pixellab": {
      "httpUrl": "https://api.pixellab.ai/mcp",
      "headers": {
        "Authorization": "Bearer ${TOKEN}"
      }
    }
  }
}
EOF

printf 'mcp add pixellab https://api.pixellab.ai/mcp -t http -H "Authorization: Bearer %s"\n' "$TOKEN" > .claude/settings.json

echo "[setup_mcp_local] OK — configs de MCP geradas (gitignored):"
echo "  - .cursor/mcp.json"
echo "  - .gemini/settings.json"
echo "  - .claude/settings.json"
echo "[setup_mcp_local] No Cursor: Settings -> Tools & MCP -> refresh/enable 'pixellab'."
