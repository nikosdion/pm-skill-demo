#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="pm-skill-demo"

# ---------------------------------------------------------------------------
# Verify the manifest is present so we link the right directory.
# ---------------------------------------------------------------------------
if [ ! -f "$SCRIPT_DIR/qwen-extension.json" ]; then
  echo "qwen-extension.json not found in $SCRIPT_DIR" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Idempotent install: skip if this repo is already linked. Linking twice
# overwrites the previous link in current Qwen Code, but checking first gives
# clearer output and avoids triggering an interactive trust prompt on every
# run. Match on the absolute path because the display name is human-readable
# ("Project Management Skills for Joomla") and does not contain the internal id.
# ---------------------------------------------------------------------------
if qwen extensions list 2>/dev/null | grep -Fq "$SCRIPT_DIR"; then
  echo "$PLUGIN_NAME is already linked for Qwen Code."
  echo "Restart Qwen Code to pick up any changes."
  exit 0
fi

qwen extensions link "$SCRIPT_DIR"

echo "Linked $PLUGIN_NAME for Qwen Code. Restart Qwen Code to load it."
