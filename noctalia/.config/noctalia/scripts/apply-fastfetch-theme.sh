#!/usr/bin/env bash
# Regenerate Fastfetch config from Noctalia's active palette.
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
COLORS_FILE="$CONFIG_HOME/noctalia/colors.json"
SETTINGS_FILE="$STATE_HOME/noctalia/settings.toml"
PALETTES_DIR="$CONFIG_HOME/noctalia/palettes"
COLORSCHEMES_DIR="$CONFIG_HOME/noctalia/colorschemes"
COMMUNITY_DIR="$CACHE_HOME/noctalia/community-palettes"
TEMPLATE="$CONFIG_HOME/fastfetch/config.jsonc.template"
OUTPUT="$CONFIG_HOME/fastfetch/config.jsonc"
PROCESSOR="$CONFIG_HOME/quickshell/noctalia-shell/Scripts/python/src/theming/template-processor.py"
MODE="${1:-}"

if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
  if command -v noctalia >/dev/null 2>&1; then
    MODE="$(noctalia msg theme-mode-get 2>/dev/null || echo dark)"
  else
    MODE="dark"
  fi
fi
[[ "$MODE" == "light" ]] || MODE="dark"

if [[ ! -f "$PROCESSOR" || ! -f "$TEMPLATE" ]]; then
  exit 0
fi

SCHEME_FILE="$(python3 - "$SETTINGS_FILE" "$COLORS_FILE" "$PALETTES_DIR" "$COLORSCHEMES_DIR" "$COMMUNITY_DIR" <<'PY'
import json
import pathlib
import sys

settings_path, colors_path, palettes_dir, colorschemes_dir, community_dir = map(pathlib.Path, sys.argv[1:6])


def parse_theme_settings(path: pathlib.Path) -> dict[str, str]:
    theme: dict[str, str] = {}
    if not path.is_file():
        return theme
    in_theme = False
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped == "[theme]":
            in_theme = True
            continue
        if in_theme and stripped.startswith("["):
            break
        if in_theme and "=" in line:
            key, _, value = line.partition("=")
            value = value.strip().strip('"')
            if key.strip() and value:
                theme[key.strip()] = value
    return theme


theme = parse_theme_settings(settings_path)
source = theme.get("source", "builtin")
candidates: list[pathlib.Path] = []

if source == "custom" and theme.get("custom_palette"):
    name = theme["custom_palette"]
    candidates.append(palettes_dir / f"{name}.json")
    candidates.append(colorschemes_dir / name / f"{name}.json")
elif source == "community" and theme.get("community_palette"):
    candidates.append(community_dir / f"{theme['community_palette']}.json")
elif theme.get("builtin"):
    name = theme["builtin"]
    candidates.append(colorschemes_dir / name / f"{name}.json")

candidates.append(pathlib.Path.home() / ".cache/noctalia/predefined-scheme.json")
candidates.append(colors_path)

for path in candidates:
    if path.is_file():
        print(path)
        break
PY
)"

[[ -n "$SCHEME_FILE" && -f "$SCHEME_FILE" ]] || exit 0

TMP_TOML="$(mktemp)"
cleanup() {
  rm -f "$TMP_TOML"
}
trap cleanup EXIT

cat >"$TMP_TOML" <<EOF
[templates.fastfetch]
input_path = "$TEMPLATE"
output_path = "$OUTPUT"
EOF

python3 "$PROCESSOR" --scheme "$SCHEME_FILE" --config "$TMP_TOML" --default-mode "$MODE" >/dev/null 2>&1 || true
