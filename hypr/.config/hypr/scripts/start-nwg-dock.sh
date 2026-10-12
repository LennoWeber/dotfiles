#!/usr/bin/env bash
# Dash-to-Dock style: vertical dock on the left, always visible.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOCK_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nwg-dock-hyprland"

pkill -f '[n]wg-dock-hyprland' 2>/dev/null || true
sleep 0.15

"${SCRIPT_DIR}/sync-dock-icons.sh" --all
"${SCRIPT_DIR}/sync-dock-pins.sh"

cd "$DOCK_DIR"

exec nwg-dock-hyprland \
  -r \
  -x \
  -p left \
  -i 22 \
  -mr 0 -ml 0 -mt 0 -mb 0 \
  -a center \
  -c "noctalia msg panel-toggle launcher" \
  -lp end \
  -w 10 \
  -l overlay \
  -s style.css
