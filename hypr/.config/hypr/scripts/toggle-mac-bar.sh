#!/usr/bin/env bash
# Toggles L-Shell between classic solid white menu_bar and modern menu_bar_glass

STATE_FILE="$HOME/.local/state/l-shell/settings.toml"
SHELL_CMD="/home/lenno/.local/bin/shell-switch msg"

if grep -q 'mode = "menu_bar_glass"' "$STATE_FILE" 2>/dev/null; then
    $SHELL_CMD layout-mode-set menu_bar
else
    $SHELL_CMD layout-mode-set menu_bar_glass
fi
