#!/usr/bin/env bash
# Smoke: master registry + game announce + client query (localhost)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
GODOT="${GODOT_BIN:-$(command -v godot)}"
PORT_REG=17790
PASS_FLAG="/tmp/hunter_registry_smoke_pass.flag"
rm -f "$PASS_FLAG"
ANN_PID=""
REG_PID=""

cleanup() {
  if [[ -n "${ANN_PID}" ]]; then kill "$ANN_PID" 2>/dev/null || true; fi
  if [[ -n "${REG_PID}" ]]; then kill "$REG_PID" 2>/dev/null || true; fi
}
trap cleanup EXIT

echo "[registry-smoke] starting master registry on $PORT_REG..."
"$GODOT" --headless --path "$ROOT" "res://server/HunterServer.tscn" -- --master-registry "$PORT_REG" \
  > /tmp/hunter_registry_smoke_reg.log 2>&1 &
REG_PID=$!

sleep 1.2
if ! kill -0 "$REG_PID" 2>/dev/null; then
  echo "[registry-smoke] registry died early" >&2
  cat /tmp/hunter_registry_smoke_reg.log >&2 || true
  exit 1
fi

echo "[registry-smoke] starting announcing game server..."
"$GODOT" --headless --path "$ROOT" "res://server/HunterServer.tscn" -- \
  --port 7793 --no-lan-discovery --master-announce --master-host 127.0.0.1 --master-port "$PORT_REG" \
  --name "RegistrySmokeServer" \
  > /tmp/hunter_registry_smoke_ann.log 2>&1 &
ANN_PID=$!

sleep 1.5
if ! kill -0 "$ANN_PID" 2>/dev/null; then
  echo "[registry-smoke] announcer died early" >&2
  cat /tmp/hunter_registry_smoke_ann.log >&2 || true
  exit 1
fi

echo "[registry-smoke] querying registry..."
set +e
"$GODOT" --headless --path "$ROOT" -s "res://scratch/test_registry_query_smoke.gd" -- \
  --registry-host 127.0.0.1 --registry-port "$PORT_REG" --pass-file "$PASS_FLAG" \
  > /tmp/hunter_registry_smoke_query.log 2>&1
Q_RC=$?
set -e

if [[ $Q_RC -ne 0 || ! -f "$PASS_FLAG" ]]; then
  echo "[registry-smoke] FAILED (query_rc=$Q_RC)" >&2
  tail -50 /tmp/hunter_registry_smoke_query.log >&2 || true
  exit 1
fi

echo "[registry-smoke] PASS — announce+query on UDP $PORT_REG ok"
