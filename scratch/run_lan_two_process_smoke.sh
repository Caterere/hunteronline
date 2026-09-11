#!/usr/bin/env bash
# Smoke: dedicated server + client handshake on localhost (simula 2 máquinas na LAN).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
GODOT="${GODOT_BIN:-$(command -v godot || true)}"
if [[ -z "${GODOT}" ]]; then
  echo "godot not found" >&2
  exit 1
fi

PORT="${LAN_SMOKE_PORT:-7791}"
SERVER_LOG="/tmp/hunter_lan_server_${PORT}.log"
CLIENT_LOG="/tmp/hunter_lan_client_${PORT}.log"
PASS_MARKER="/tmp/hunter_lan_smoke_pass_${PORT}.flag"
rm -f "$SERVER_LOG" "$CLIENT_LOG" "$PASS_MARKER"

echo "[lan-smoke] starting dedicated server on $PORT..."
"$GODOT" --headless --path "$ROOT" "res://server/HunterServer.tscn" \
  -- --port "$PORT" --discovery-port "$((PORT + 1))" --name "LAN Smoke" \
  --no-lan-discovery >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!

cleanup() {
  kill "$SERVER_PID" 2>/dev/null || true
  wait "$SERVER_PID" 2>/dev/null || true
}
trap cleanup EXIT

# Wait for listen banner
for i in $(seq 1 40); do
  if grep -q "Waiting for hunter connections" "$SERVER_LOG" 2>/dev/null; then
    break
  fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "[lan-smoke] server died early" >&2
    cat "$SERVER_LOG" >&2 || true
    exit 1
  fi
  sleep 0.25
done

if ! grep -q "Waiting for hunter connections" "$SERVER_LOG"; then
  echo "[lan-smoke] server did not become ready" >&2
  cat "$SERVER_LOG" >&2 || true
  exit 1
fi

echo "[lan-smoke] starting client handshake runner..."
"$GODOT" --headless --path "$ROOT" "res://scratch/test_lan_client_handshake_suite.tscn" \
  -- --lan-smoke-host 127.0.0.1 --lan-smoke-port "$PORT" --lan-smoke-pass-file "$PASS_MARKER" \
  >"$CLIENT_LOG" 2>&1
CLIENT_RC=$?

echo "----- SERVER LOG (tail) -----"
tail -n 40 "$SERVER_LOG" || true
echo "----- CLIENT LOG (tail) -----"
tail -n 60 "$CLIENT_LOG" || true

if [[ $CLIENT_RC -ne 0 || ! -f "$PASS_MARKER" ]]; then
  echo "[lan-smoke] FAILED (client_rc=$CLIENT_RC)" >&2
  exit 1
fi

echo "[lan-smoke] PASS — handshake localhost:$PORT ok"
exit 0
