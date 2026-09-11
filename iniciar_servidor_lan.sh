#!/usr/bin/env bash
# Hunter Online — Dedicated LAN / VPS server launcher (Linux / macOS)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

echo "============================================================"
echo "        INICIANDO HUNTER MMORPG DEDICATED SERVER"
echo "============================================================"
echo "[LAN / Radmin VPN / futuro VPS]"
echo "Porta padrao: 7777 (ENet UDP)"
echo "Discovery LAN: 7778 (UDP Broadcast)"
echo
echo "Outros PCs na mesma rede: conecte no IP deste host:7777"
echo "Firewall: UDP 7777 (obrigatorio). UDP 7778 so e util na LAN."
echo

GODOT_BIN="${GODOT_BIN:-}"
if [[ -z "$GODOT_BIN" ]]; then
  if command -v godot >/dev/null 2>&1; then
    GODOT_BIN="$(command -v godot)"
  elif command -v godot4 >/dev/null 2>&1; then
    GODOT_BIN="$(command -v godot4)"
  elif [[ -x "$HOME/.local/bin/godot" ]]; then
    GODOT_BIN="$HOME/.local/bin/godot"
  fi
fi

if [[ -z "${GODOT_BIN}" || ! -x "${GODOT_BIN}" ]]; then
  echo "[ERRO] Godot 4.6 nao encontrado. Exporte GODOT_BIN=/caminho/para/godot" >&2
  exit 1
fi

echo "Usando: $GODOT_BIN"
exec "$GODOT_BIN" --headless --path "$ROOT" "res://server/HunterServer.tscn" "$@"
