#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.config/hypr/active-shell"
current=$(cat "$STATE_FILE" 2>/dev/null || echo "noctalia")

if [[ "$current" == "dms" ]]; then
    dms run -d
else
    qs -c noctalia-shell -d
fi
