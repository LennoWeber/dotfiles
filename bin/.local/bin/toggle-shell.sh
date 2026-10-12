#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.config/hypr/active-shell"
HYPR_DIR="$HOME/.config/hypr"
KITTY_DIR="$HOME/.config/kitty"
GHOSTTY_CFG="$HOME/.config/ghostty/config"
ALACRITTY_CFG="$HOME/.config/alacritty/alacritty.toml"
DMS_COLORS="$HOME/.cache/DankMaterialShell/dms-colors.json"
FASTFETCH_CFG="$HOME/.config/fastfetch/config.jsonc"
FASTFETCH_TPL="$HOME/.config/fastfetch/config.jsonc.template"

is_hyprland() { [[ "${XDG_CURRENT_DESKTOP:-}" == "Hyprland" ]] || pgrep -x Hyprland >/dev/null 2>&1; }

current=$(cat "$STATE_FILE" 2>/dev/null || echo "noctalia")

switch_terminal_theme() {
    local target="$1"

    if [[ "$target" == "dms" ]]; then
        ln -sf dank-theme.conf "$KITTY_DIR/active-shell-theme.conf"
        sed -i 's/^theme = .*/theme = dankcolors/' "$GHOSTTY_CFG"
        sed -i 's|"~/.config/alacritty/themes/noctalia.toml"|"~/.config/alacritty/dank-theme.toml"|' "$ALACRITTY_CFG"
    else
        ln -sf current-theme.conf "$KITTY_DIR/active-shell-theme.conf"
        sed -i 's/^theme = .*/theme = noctalia/' "$GHOSTTY_CFG"
        sed -i 's|"~/.config/alacritty/dank-theme.toml"|"~/.config/alacritty/themes/noctalia.toml"|' "$ALACRITTY_CFG"
    fi

    pkill -SIGUSR1 kitty 2>/dev/null || true
}

generate_fastfetch_from_dms() {
    [[ -f "$DMS_COLORS" && -f "$FASTFETCH_TPL" ]] || return 0

    python3 -c "
import json, re, sys
with open('$DMS_COLORS') as f:
    raw = json.load(f)
colors = raw.get('colors', {}).get('dark', {})
mapping = {
    'colors.primary.default.hex': colors.get('primary', ''),
    'colors.secondary.default.hex': colors.get('secondary', ''),
    'colors.tertiary.default.hex': colors.get('tertiary', ''),
    'colors.outline.default.hex': colors.get('outline', ''),
    'colors.surface_dim.default.hex': colors.get('surface_dim', ''),
    'colors.on_surface.default.hex': colors.get('on_surface', ''),
}
with open('$FASTFETCH_TPL') as f:
    tpl = f.read()
for key, val in mapping.items():
    tpl = tpl.replace('{{' + key + '}}', val)
with open('$FASTFETCH_CFG', 'w') as f:
    f.write(tpl)
" 2>/dev/null
}

if [[ "$current" == "noctalia" ]]; then
    pkill -f "qs.*noctalia-shell" 2>/dev/null || true
    sleep 0.3

    echo "dms" > "$STATE_FILE"

    if is_hyprland; then
        ln -sf shell-binds-dms.conf "$HYPR_DIR/shell-binds.conf"
    fi

    dms run -d &
    disown

    sleep 3
    is_hyprland && hyprctl reload
    switch_terminal_theme dms
    generate_fastfetch_from_dms
else
    dms kill 2>/dev/null || pkill -f "qs.*dms" 2>/dev/null || true
    sleep 0.3

    echo "noctalia" > "$STATE_FILE"

    if is_hyprland; then
        ln -sf shell-binds-noctalia.conf "$HYPR_DIR/shell-binds.conf"
    fi

    qs -c noctalia-shell -d &
    disown

    sleep 3
    is_hyprland && hyprctl reload
    wp=$(qs -c noctalia-shell ipc call wallpaper get all 2>/dev/null || echo "")
    if [[ -n "$wp" ]]; then
        qs -c noctalia-shell ipc call wallpaper set "$wp" all 2>/dev/null &
        disown
    fi
    switch_terminal_theme noctalia
fi
