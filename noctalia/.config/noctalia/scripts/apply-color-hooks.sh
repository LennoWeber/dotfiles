#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INPUT="${1:-}"
STATUS=0

# First, dynamically update ~/.config/noctalia/colors.json so all scripts use the correct theme colors
# "$SCRIPT_DIR/update-noctalia-colors.py" || STATUS=$?

# Terminal palette sync is handled by Noctalia's own template system (theming.dynamic.toml)
# "$SCRIPT_DIR/sync-terminal-palette.sh" "$INPUT" || STATUS=$?

# Starship palette dynamic injection (adapts to wallpaper, custom, or predefined palette with contrast awareness)
"$SCRIPT_DIR/apply-starship-palette.sh" "$INPUT" || STATUS=$?

# Fastfetch dynamic theming (rhel_old logo untouched, text colors dynamically themed)
"$SCRIPT_DIR/apply-fastfetch-theme.sh" "$INPUT" || STATUS=$?

if pgrep -x nvim >/dev/null 2>&1; then
    pkill -SIGUSR1 -x nvim 2>/dev/null || STATUS=$?
fi

"$SCRIPT_DIR/apply-brave-theme.sh" || STATUS=$?

# Fuzzel theming is handled by Noctalia's built-in template system (TemplateRegistry)
# "$SCRIPT_DIR/apply-fuzzel-theme.sh" "$INPUT" || STATUS=$?

"$SCRIPT_DIR/apply-rofi-theme.sh" "$INPUT" || STATUS=$?

"$SCRIPT_DIR/apply-zen-flatpak-theme.sh" || STATUS=$?

"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/sync-dock-icons.sh" --all || STATUS=$?

exit "$STATUS"
