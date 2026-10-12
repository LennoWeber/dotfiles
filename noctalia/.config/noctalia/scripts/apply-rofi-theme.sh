#!/usr/bin/env bash
# Regenerate Rofi colors from Noctalia's active palette (exact m* values).
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TEMPLATE="$CONFIG_HOME/noctalia/templates/rofi.rasi"
OUTPUT="$CONFIG_HOME/rofi/themes/noctalia.rasi"
ROFI_CONFIG="$CONFIG_HOME/rofi/config.rasi"
RESOLVER="$CONFIG_HOME/noctalia/scripts/resolve-noctalia-colors.py"
MODE="${1:-}"

if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
  if command -v noctalia >/dev/null 2>&1; then
    MODE="$(noctalia msg theme-mode-get 2>/dev/null || echo dark)"
  else
    MODE="dark"
  fi
fi
[[ "$MODE" == "light" ]] || MODE="dark"

[[ -f "$TEMPLATE" && -f "$RESOLVER" ]] || exit 0

python3 - "$MODE" "$TEMPLATE" "$OUTPUT" "$RESOLVER" <<'PY'
import json
import pathlib
import subprocess
import sys

mode, template_path, output_path, resolver = sys.argv[1:5]

raw = subprocess.check_output(["python3", resolver, mode], text=True)
palette = json.loads(raw)


def hex_color(key: str, fallback: str = "#000000") -> str:
    value = palette.get(key, fallback)
    if not isinstance(value, str):
        return fallback
    value = value.strip()
    if not value.startswith("#"):
        value = f"#{value}"
    return value.lower()


def with_alpha(hex_color: str, alpha: str) -> str:
    value = hex_color.lstrip("#")
    if len(value) != 6:
        return hex_color
    return f"#{value}{alpha}"


terminal = palette.get("terminal") or {}
background = terminal.get("background") or palette.get("mSurface", "#000000")

tokens = {
    "fg0": with_alpha(hex_color("mOnSurface"), "ff"),
    "cyan": with_alpha(hex_color("mSecondary"), "ff"),
    "red": with_alpha(hex_color("mError"), "ff"),
    "blue": with_alpha(hex_color("mPrimary"), "ff"),
    "window-border": with_alpha(hex_color("mPrimary"), "ff"),
    "window-bg": with_alpha(background, "eb"),
    "mainbox-bg": with_alpha(hex_color("mSurfaceVariant"), "ff"),
    "inputbar-bg": with_alpha(hex_color("mHover"), "ff"),
    "inputbar-border": with_alpha(hex_color("mOutline"), "cc"),
    "list-bg": with_alpha(hex_color("mSurfaceVariant"), "ff"),
    "element-bg": with_alpha(hex_color("mSurfaceVariant"), "ff"),
    "select-bg": with_alpha(hex_color("mPrimary"), "38"),
    "message-border": with_alpha(hex_color("mOutline"), "cc"),
    "message-bg": with_alpha(background, "e6"),
}

content = pathlib.Path(template_path).read_text(encoding="utf-8")
for key, value in tokens.items():
    content = content.replace(f"{{{{{key}}}}}", value)

pathlib.Path(output_path).parent.mkdir(parents=True, exist_ok=True)
pathlib.Path(output_path).write_text(content, encoding="utf-8")
PY

if [[ -f "$ROFI_CONFIG" ]]; then
  if grep -q '^@import "themes/noctalia.rasi"' "$ROFI_CONFIG"; then
    :
  elif grep -q '^@theme ' "$ROFI_CONFIG"; then
    sed -i 's|^@theme .*|@import "themes/noctalia.rasi"|' "$ROFI_CONFIG"
  elif grep -q '^@import ' "$ROFI_CONFIG"; then
    sed -i 's|^@import .*|@import "themes/noctalia.rasi"|' "$ROFI_CONFIG"
  else
    printf '\n@import "themes/noctalia.rasi"\n' >>"$ROFI_CONFIG"
  fi
fi
