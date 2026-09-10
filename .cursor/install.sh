#!/usr/bin/env bash
# ============================================================
# Hunter Online — Cloud Agent install script
# ------------------------------------------------------------
# Idempotent bootstrap for a headless Godot 4.6 dev environment:
#   1. Install the pinned Godot 4.6 engine (headless-capable).
#   2. Import the project so .godot/ resources are generated.
# Runs after the repository is checked out. Safe to run repeatedly.
# ============================================================
set -euo pipefail

GODOT_VERSION="4.6-stable"
GODOT_BIN_NAME="Godot_v${GODOT_VERSION}_linux.x86_64"
GODOT_ZIP_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/${GODOT_BIN_NAME}.zip"
INSTALL_DIR="${HOME}/.local/bin"
GODOT_BIN="${INSTALL_DIR}/godot"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "${INSTALL_DIR}"

install_godot() {
	echo "[install] Downloading Godot ${GODOT_VERSION} ..."
	local tmp
	tmp="$(mktemp -d)"
	curl -fL --retry 4 --retry-delay 4 -o "${tmp}/godot.zip" "${GODOT_ZIP_URL}"
	unzip -o -q "${tmp}/godot.zip" -d "${tmp}"
	mv "${tmp}/${GODOT_BIN_NAME}" "${GODOT_BIN}"
	chmod +x "${GODOT_BIN}"
	rm -rf "${tmp}"
}

# Install Godot only when the pinned version is not already present.
if [[ -x "${GODOT_BIN}" ]] && "${GODOT_BIN}" --headless --version 2>/dev/null | grep -q "^4.6"; then
	echo "[install] Godot 4.6 already present: $("${GODOT_BIN}" --headless --version)"
else
	install_godot
	echo "[install] Installed Godot: $("${GODOT_BIN}" --headless --version)"
fi

# Ensure ~/.local/bin is on PATH for interactive shells.
if ! grep -qs 'HOME/.local/bin' "${HOME}/.bashrc" 2>/dev/null; then
	echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
fi

# Import the project assets/resources (generates .godot/, which is gitignored).
echo "[install] Importing Godot project resources ..."
"${GODOT_BIN}" --headless --path "${PROJECT_DIR}" --import

echo "[install] Done. Run the dedicated server with:"
echo "  godot --headless --path . res://server/HunterServer.tscn"
