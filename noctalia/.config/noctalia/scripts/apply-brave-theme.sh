#!/usr/bin/env bash
# Updates Noctalia colors for the local Brave extension (pywalfox-style, for Chromium).

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/brave-extension"

python3 "$SCRIPT_DIR/generate-brave-theme.py"
touch "$EXT_DIR/colors.json"

if pgrep -f '[b]rave.*Brave-Browser' >/dev/null 2>&1; then
  echo "Brave-Theme: Farben aktualisiert."
else
  echo "Brave-Theme: Farben geschrieben."
fi
