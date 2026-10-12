#!/usr/bin/env bash
# Process Noctalia matugen templates for nwg-dock, sync assets, optionally restart dock.
set -euo pipefail

RESTART_DOCK=1
if [[ "${1:-}" == "--css-only" ]]; then
  RESTART_DOCK=0
  shift
fi

COLORS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/colors.json"
SETTINGS_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/settings.toml"
TEMPLATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/templates"
PALETTES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/palettes"
COLORSCHEMES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/colorschemes"
COMMUNITY_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/community-palettes"
CSS_OUT="${XDG_CONFIG_HOME:-$HOME/.config}/nwg-dock-hyprland/style.css"
IMAGES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nwg-dock-hyprland/images"
STOCK_IMAGES="/usr/share/nwg-dock-hyprland/images"
START_SCRIPT="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/start-nwg-dock.sh"

THEMED_IMAGES=(
  grid.svg
  task-single-vertical.svg
  task-multiple-vertical.svg
  task-empty-vertical.svg
)

mkdir -p "$IMAGES_DIR" "$(dirname "$CSS_OUT")"

python3 - "$COLORS_FILE" "$SETTINGS_FILE" "$TEMPLATE_DIR" "$PALETTES_DIR" "$COLORSCHEMES_DIR" "$COMMUNITY_DIR" "$CSS_OUT" "$IMAGES_DIR" <<'PY'
import json
import pathlib
import subprocess
import sys

(
    colors_path,
    settings_path,
    template_dir,
    palettes_dir,
    colorschemes_dir,
    community_dir,
    css_out,
    images_dir,
) = map(pathlib.Path, sys.argv[1:9])


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


def theme_mode() -> str:
    try:
        mode = subprocess.check_output(
            ["noctalia", "msg", "theme-mode-get"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        mode = "dark"
    return "light" if mode == "light" else "dark"


def load_active_colors() -> dict:
    mode = theme_mode()
    theme = parse_theme_settings(settings_path)
    source = theme.get("source", "builtin")
    candidates: list[pathlib.Path] = []

    if source == "custom" and theme.get("custom_palette"):
        candidates.append(palettes_dir / f"{theme['custom_palette']}.json")
        candidates.append(colorschemes_dir / theme["custom_palette"] / f"{theme['custom_palette']}.json")
    elif source == "community" and theme.get("community_palette"):
        candidates.append(community_dir / f"{theme['community_palette']}.json")
    elif theme.get("builtin"):
        name = theme["builtin"]
        candidates.append(colorschemes_dir / name / f"{name}.json")

    candidates.append(colors_path)

    for path in candidates:
        if not path.is_file():
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        if mode in data and isinstance(data[mode], dict):
            return data[mode]
        if "mSurface" in data:
            return data
    return {}


colors = load_active_colors()
if not colors:
    sys.exit(0)


def hex_to_rgba(hex_color: str, alpha: float) -> str:
    value = hex_color.lstrip("#")
    if len(value) != 6:
        return hex_color
    r, g, b = (int(value[i : i + 2], 16) for i in (0, 2, 4))
    return f"rgba({r}, {g}, {b}, {alpha})"


surface = colors.get("mSurface", "#111417")

token_map = {
    "{{colors.surface.default.hex}}": surface,
    "{{colors.surface.default.rgba_70}}": hex_to_rgba(surface, 0.7),
    "{{colors.surface_container.default.hex}}": colors.get("mSurfaceVariant", "#1a1f24"),
    "{{colors.primary.default.hex}}": colors.get("mPrimary", "#9aa6b2"),
    "{{colors.secondary.default.hex}}": colors.get("mSecondary", "#7f8c99"),
    "{{colors.tertiary.default.hex}}": colors.get("mTertiary", "#6f9c93"),
    "{{colors.on_surface.default.hex}}": colors.get("mOnSurface", "#dce1e7"),
    "{{colors.on_surface_variant.default.hex}}": colors.get("mOnSurfaceVariant", "#99a3b0"),
    "{{colors.outline.default.hex}}": colors.get("mOutline", "#2f3944"),
    "{{colors.error.default.hex}}": colors.get("mError", "#e07a7a"),
}


def apply_tokens(text: str) -> str:
    for token, value in token_map.items():
        text = text.replace(token, value)
    return text


pinned_path = pathlib.Path.home() / ".cache/nwg-dock-pinned"
pinned_count = 0
if pinned_path.is_file():
    pinned_count = sum(
        1
        for line in pinned_path.read_text(encoding="utf-8").splitlines()
        if line.strip() and line.strip() != "dock-separator"
    )

outline = colors.get("mOutline", "#2f3944")
outline_value = outline.lstrip("#")
if len(outline_value) == 6:
    or_, og, ob = (int(outline_value[i : i + 2], 16) for i in (0, 2, 4))
    separator_css = (
        f"#box > box > box > box:nth-child({pinned_count}) {{\n"
        f"  border-bottom: 1px solid rgba({or_}, {og}, {ob}, 0.55);\n"
        f"  margin-bottom: 5px;\n"
        f"  padding-bottom: 5px;\n"
        f"}}\n"
        if pinned_count > 0
        else ""
    )
else:
    separator_css = ""


def write_template(src: pathlib.Path, dst: pathlib.Path) -> None:
    content = apply_tokens(src.read_text(encoding="utf-8"))
    content = content.replace("{{dock.separator_css}}", separator_css)
    if dst.suffix == ".css":
        content = "/* Generated by Noctalia's Template Processor */\n\n" + content
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(content, encoding="utf-8")


write_template(template_dir / "nwg-dock.css", css_out)

for name in (
    "grid.svg",
    "task-single-vertical.svg",
    "task-multiple-vertical.svg",
    "task-empty-vertical.svg",
):
    write_template(template_dir / "nwg-dock" / name, images_dir / name)
PY

if [ -d "$STOCK_IMAGES" ]; then
  for img in "$STOCK_IMAGES"/*; do
    name="$(basename "$img")"
    for themed in "${THEMED_IMAGES[@]}"; do
      [ "$name" = "$themed" ] && continue 2
    done
    [ -f "$IMAGES_DIR/$name" ] || cp "$img" "$IMAGES_DIR/$name"
  done
fi

# Dock restart disabled — nwg-dock-hyprland is no longer used.
