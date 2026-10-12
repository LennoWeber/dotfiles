#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DEFAULT_COLORS_FILE="$CONFIG_HOME/noctalia/colors.json"
STARSHIP_FILE="$CONFIG_HOME/starship.toml"
INPUT="${1:-}"

MODE=""
if [[ "$INPUT" == "dark" || "$INPUT" == "light" ]]; then
    MODE="$INPUT"
fi

COLORS_JSON=""
if COLORS_JSON="$("$SCRIPT_DIR/resolve-noctalia-colors.py" ${MODE:+"$MODE"})"; then
    :
elif [[ -n "$INPUT" && -f "$INPUT" ]]; then
    COLORS_JSON="$(jq -c '.' "$INPUT" 2>/dev/null || true)"
elif [[ -f "$DEFAULT_COLORS_FILE" ]]; then
    COLORS_JSON="$(jq -c '.' "$DEFAULT_COLORS_FILE" 2>/dev/null || true)"
fi

[[ -n "$COLORS_JSON" ]] || exit 0

python3 - "$COLORS_JSON" "$STARSHIP_FILE" <<'PY'
import json
import pathlib
import re
import sys

colors = json.loads(sys.argv[1])
starship_path = pathlib.Path(sys.argv[2])


def c(key, fallback):
    return colors.get(key, fallback)


def hex_to_rgb(h: str):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return [int(h[i:i+2], 16) / 255.0 for i in (0, 2, 4)]


def rgb_to_hex(r: float, g: float, b: float) -> str:
    return f"#{int(round(r * 255)):02x}{int(round(g * 255)):02x}{int(round(b * 255)):02x}"


def relative_luminance(h: str) -> float:
    r, g, b = hex_to_rgb(h)
    def to_linear(v):
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4
    return 0.2126 * to_linear(r) + 0.7152 * to_linear(g) + 0.0722 * to_linear(b)


def best_contrast_fg(bg_hex: str, preferred_fg: str, fallback_fg: str) -> str:
    bg_lum = relative_luminance(bg_hex)
    pref_lum = relative_luminance(preferred_fg)
    # Check contrast ratio
    ratio = (max(bg_lum, pref_lum) + 0.05) / (min(bg_lum, pref_lum) + 0.05)
    if ratio >= 3.5:
        return preferred_fg
    return "#000000" if bg_lum > 0.4 else "#ffffff"


def adjust_lightness(h: str, target_l: float) -> str:
    import colorsys
    r, g, b = hex_to_rgb(h)
    h_val, _, s_val = colorsys.rgb_to_hls(r, g, b)
    r2, g2, b2 = colorsys.hls_to_rgb(h_val, target_l, s_val)
    return rgb_to_hex(r2, g2, b2)


def surface_color() -> str:
    terminal = colors.get("terminal") or {}
    return terminal.get("background") or c("mSurface", "#010409")


# Semantic base colors
c_primary = c("mPrimary", "#58a6ff")
c_on_primary = best_contrast_fg(c_primary, c("mOnPrimary", "#000000"), "#000000")

c_secondary = c("mSecondary", "#d29922")
c_on_secondary = best_contrast_fg(c_secondary, c("mOnSecondary", "#000000"), "#000000")

c_tertiary = c("mTertiary", "#3fb950")
c_on_tertiary = best_contrast_fg(c_tertiary, c("mOnTertiary", "#000000"), "#000000")

c_error = c("mError", "#ff7b72")

# Containers for subsequent segments (subtle backgrounds)
c_surface = c("mSurfaceVariant", adjust_lightness(c_secondary, 0.12))
c_on_surface = best_contrast_fg(c_surface, c("mOnSurface", "#c9d1d9"), "#ffffff")

c_muted = adjust_lightness(c_primary, 0.09)
c_on_muted = best_contrast_fg(c_muted, c("mOnSurfaceVariant", "#8b949e"), "#ffffff")

c_deep = adjust_lightness(c_tertiary, 0.06)
c_on_deep = best_contrast_fg(c_deep, c("mOnSurface", "#c9d1d9"), "#ffffff")

palette = {
    # Powerline Semantic variables (used directly by starship.toml)
    "color_primary": c_primary,
    "color_on_primary": c_on_primary,
    "color_secondary": c_secondary,
    "color_on_secondary": c_on_secondary,
    "color_tertiary": c_tertiary,
    "color_on_tertiary": c_on_tertiary,
    "color_error": c_error,
    "color_surface": c_surface,
    "color_on_surface": c_on_surface,
    "color_muted": c_muted,
    "color_on_muted": c_on_muted,
    "color_deep": c_deep,
    "color_on_deep": c_on_deep,

    # Standard colors
    "blue": c_primary,
    "red": c_error,
    "green": c_tertiary,
    "yellow": c_secondary,
    "cyan": c("mHover", c_tertiary),
    "magenta": c_secondary,
    "white": c("mOnSurface", "#c9d1d9"),
    "black": surface_color(),

    # Catppuccin compatibility
    "rosewater": c_tertiary,
    "flamingo": c_secondary,
    "pink": c_primary,
    "mauve": c_primary,
    "maroon": c_error,
    "peach": c_secondary,
    "teal": c_tertiary,
    "sky": c("mHover", c_tertiary),
    "sapphire": c_primary,
    "lavender": c_secondary,
    "text": c("mOnSurface", "#c9d1d9"),
    "subtext1": c("mOnSurfaceVariant", "#8b949e"),
    "subtext0": c("mOutline", "#30363d"),
    "overlay2": c("mOutline", "#30363d"),
    "overlay1": c("mOnSurfaceVariant", "#8b949e"),
    "overlay0": c_surface,
    "surface2": c_surface,
    "surface1": surface_color(),
    "surface0": surface_color(),
    "base": surface_color(),
    "mantle": c_surface,
    "crust": c("mOnPrimary", "#010409"),

    # Gruvbox aliases
    "color_fg0": c("mOnSurface", "#c9d1d9"),
    "color_bg1": surface_color(),
    "color_bg3": c("mOutline", "#30363d"),
    "color_blue": c_primary,
    "color_aqua": c_tertiary,
    "color_green": c_tertiary,
    "color_orange": c_error,
    "color_purple": c_secondary,
    "color_red": c_error,
    "color_yellow": c_secondary,
}

marker_begin = "# >>> NOCTALIA STARSHIP PALETTE >>>"
marker_end = "# <<< NOCTALIA STARSHIP PALETTE <<<"

lines = [marker_begin, "[palettes.noctalia]"]
for key, value in palette.items():
    lines.append(f"{key} = \"{value}\"")
lines.append(marker_end)
block = "\n".join(lines)

if starship_path.exists():
    config = starship_path.read_text(encoding="utf-8")
else:
    config = ""

config = re.sub(
    r"\n?# >>> NOCTALIA STARSHIP PALETTE >>>\n.*?# <<< NOCTALIA STARSHIP PALETTE <<<\n?",
    "\n",
    config,
    flags=re.S,
)

if re.search(r"(?m)^palette\s*=", config):
    config = re.sub(r"(?m)^palette\s*=.*$", 'palette = "noctalia"', config, count=1)
else:
    config = 'palette = "noctalia"\n' + config.lstrip("\n")

config = config.rstrip() + "\n\n" + block + "\n"
starship_path.write_text(config, encoding="utf-8")
PY
