#!/usr/bin/env bash
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_COLORS_FILE="$CONFIG_HOME/noctalia/colors.json"
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
command -v jq >/dev/null 2>&1 || exit 0

normalize_hex() {
    local value="${1:-}"
    value="${value#\#}"
    value="${value,,}"
    printf '#%s' "$value"
}

json_color() {
    local key="$1"
    local fallback="$2"
    local value
    value="$(jq -r --arg key "$key" '.[$key] // empty' <<<"$COLORS_JSON" 2>/dev/null || true)"
    if [[ -z "$value" || "$value" == "null" ]]; then
        value="$fallback"
    fi
    normalize_hex "$value"
}

terminal_color() {
    local key="$1"
    local fallback_key="$2"
    local fallback="$3"
    local value
    value="$(jq -r --arg key "$key" '.terminal[$key] // empty' <<<"$COLORS_JSON" 2>/dev/null || true)"
    if [[ -z "$value" || "$value" == "null" ]]; then
        value="$(jq -r --arg key "$fallback_key" '.[$key] // empty' <<<"$COLORS_JSON" 2>/dev/null || true)"
    fi
    if [[ -z "$value" || "$value" == "null" ]]; then
        value="$fallback"
    fi
    normalize_hex "$value"
}

ansi_color() {
    local group="$1"   # "normal" or "bright"
    local name="$2"    # e.g. "black", "red", ...
    local fallback="$3"
    local value
    value="$(jq -r --arg g "$group" --arg n "$name" '.terminal[$g][$n] // empty' <<<"$COLORS_JSON" 2>/dev/null || true)"
    if [[ -z "$value" || "$value" == "null" ]]; then
        value="$fallback"
    fi
    normalize_hex "$value"
}

m_surface="$(terminal_color background mSurface "#111417")"
m_on_surface="$(terminal_color foreground mOnSurface "#dce1e7")"
m_primary="$(terminal_color cursor mPrimary "#9aa6b2")"
m_secondary="$(json_color "mSecondary" "#7f8c99")"
m_hover="$(terminal_color selectionBg mHover "#252c34")"
m_on_hover="$(terminal_color selectionFg mOnHover "#e8edf3")"
m_on_primary="$(terminal_color cursorText mOnPrimary "#0d1117")"
m_on_surface_variant="$(json_color "mOnSurfaceVariant" "#99a3b0")"
m_surface_variant="$(json_color "mSurfaceVariant" "#1a1f24")"

# ANSI palette: check if terminal.normal exists in the colorscheme
has_ansi="$(jq -r '.terminal.normal // empty' <<<"$COLORS_JSON" 2>/dev/null || true)"
if [[ -n "$has_ansi" && "$has_ansi" != "null" ]]; then
    c0="$(ansi_color  normal black   "#1c2228")"
    c1="$(ansi_color  normal red     "#e07a7a")"
    c2="$(ansi_color  normal green   "#86a88f")"
    c3="$(ansi_color  normal yellow  "#b0a581")"
    c4="$(ansi_color  normal blue    "#8f9db0")"
    c5="$(ansi_color  normal magenta "#9a93b2")"
    c6="$(ansi_color  normal cyan    "#6f9c93")"
    c7="$(ansi_color  normal white   "#d6dde5")"
    c8="$(ansi_color  bright black   "#3b4754")"
    c9="$(ansi_color  bright red     "#eca2a2")"
    c10="$(ansi_color bright green   "#9bbda4")"
    c11="$(ansi_color bright yellow  "#c3b895")"
    c12="$(ansi_color bright blue    "#a7b5c7")"
    c13="$(ansi_color bright magenta "#b0a8c5")"
    c14="$(ansi_color bright cyan    "#8cb8b0")"
    c15="$(ansi_color bright white   "#f4f7fb")"
    SYNC_ANSI=true
else
    SYNC_ANSI=false
fi

strip_hash() {
    local value="$1"
    printf '%s' "${value#\#}"
}

update_ghostty() {
    local file="$CONFIG_HOME/ghostty/themes/noctalia"
    [[ -f "$file" ]] || return 0

    local sed_args=(
        -e "s|^background = .*|background = ${m_surface}|"
        -e "s|^foreground = .*|foreground = ${m_on_surface}|"
        -e "s|^cursor-color = .*|cursor-color = ${m_primary}|"
        -e "s|^cursor-text = .*|cursor-text = ${m_on_primary}|"
        -e "s|^selection-background = .*|selection-background = ${m_hover}|"
        -e "s|^selection-foreground = .*|selection-foreground = ${m_on_hover}|"
    )
    if [[ "$SYNC_ANSI" == true ]]; then
        sed_args+=(
            -e "s|^palette = 0=.*|palette = 0=${c0}|"
            -e "s|^palette = 1=.*|palette = 1=${c1}|"
            -e "s|^palette = 2=.*|palette = 2=${c2}|"
            -e "s|^palette = 3=.*|palette = 3=${c3}|"
            -e "s|^palette = 4=.*|palette = 4=${c4}|"
            -e "s|^palette = 5=.*|palette = 5=${c5}|"
            -e "s|^palette = 6=.*|palette = 6=${c6}|"
            -e "s|^palette = 7=.*|palette = 7=${c7}|"
            -e "s|^palette = 8=.*|palette = 8=${c8}|"
            -e "s|^palette = 9=.*|palette = 9=${c9}|"
            -e "s|^palette = 10=.*|palette = 10=${c10}|"
            -e "s|^palette = 11=.*|palette = 11=${c11}|"
            -e "s|^palette = 12=.*|palette = 12=${c12}|"
            -e "s|^palette = 13=.*|palette = 13=${c13}|"
            -e "s|^palette = 14=.*|palette = 14=${c14}|"
            -e "s|^palette = 15=.*|palette = 15=${c15}|"
        )
    fi
    sed -i -E "${sed_args[@]}" "$file"
}

update_kitty_file() {
    local file="$1"
    [[ -f "$file" ]] || return 0

    local sed_args=(
        -e "s|^background .*|background ${m_surface}|"
        -e "s|^foreground .*|foreground ${m_on_surface}|"
        -e "s|^selection_background .*|selection_background ${m_hover}|"
        -e "s|^selection_foreground .*|selection_foreground ${m_on_hover}|"
        -e "s|^cursor .*|cursor ${m_primary}|"
        -e "s|^cursor_text_color .*|cursor_text_color ${m_on_primary}|"
        -e "s|^active_border_color .*|active_border_color ${m_primary}|"
        -e "s|^inactive_border_color .*|inactive_border_color ${m_secondary}|"
        -e "s|^active_tab_foreground .*|active_tab_foreground   ${m_on_primary}|"
        -e "s|^active_tab_background .*|active_tab_background   ${m_primary}|"
        -e "s|^inactive_tab_foreground .*|inactive_tab_foreground ${m_on_surface_variant}|"
        -e "s|^inactive_tab_background .*|inactive_tab_background ${m_surface_variant}|"
        -e "s|^cursor_trail_color .*|cursor_trail_color      ${m_on_surface_variant}|"
    )
    if [[ "$SYNC_ANSI" == true ]]; then
        sed_args+=(
            -e "s|^color0 .*|color0 ${c0}|"
            -e "s|^color1 .*|color1 ${c1}|"
            -e "s|^color2 .*|color2 ${c2}|"
            -e "s|^color3 .*|color3 ${c3}|"
            -e "s|^color4 .*|color4 ${c4}|"
            -e "s|^color5 .*|color5 ${c5}|"
            -e "s|^color6 .*|color6 ${c6}|"
            -e "s|^color7 .*|color7 ${c7}|"
            -e "s|^color8 .*|color8 ${c8}|"
            -e "s|^color9 .*|color9 ${c9}|"
            -e "s|^color10 .*|color10 ${c10}|"
            -e "s|^color11 .*|color11 ${c11}|"
            -e "s|^color12 .*|color12 ${c12}|"
            -e "s|^color13 .*|color13 ${c13}|"
            -e "s|^color14 .*|color14 ${c14}|"
            -e "s|^color15 .*|color15 ${c15}|"
        )
    fi
    sed -i -E "${sed_args[@]}" "$file"
}

update_alacritty() {
    local file="$CONFIG_HOME/alacritty/themes/noctalia.toml"
    [[ -f "$file" ]] || return 0

    local tmp
    tmp="$(mktemp)"

    awk \
        -v pbg="$m_surface" \
        -v pfg="$m_on_surface" \
        -v ccur="$m_primary" \
        -v ctext="$m_on_primary" \
        -v sbg="$m_hover" \
        -v sfg="$m_on_hover" \
        '
        BEGIN { section = ""; quote = sprintf("%c", 39) }
        /^\[/ { section = $0 }
        {
            if (section == "[colors.primary]" && $0 ~ /^background = /) {
                $0 = "background = " quote pbg quote
            } else if (section == "[colors.primary]" && $0 ~ /^foreground = /) {
                $0 = "foreground = " quote pfg quote
            } else if (section == "[colors.cursor]" && $0 ~ /^cursor = /) {
                $0 = "cursor = " quote ccur quote
            } else if (section == "[colors.cursor]" && $0 ~ /^text = /) {
                $0 = "text = " quote ctext quote
            } else if (section == "[colors.selection]" && $0 ~ /^background = /) {
                $0 = "background = " quote sbg quote
            } else if (section == "[colors.selection]" && $0 ~ /^text = /) {
                $0 = "text = " quote sfg quote
            }
            print
        }
        ' "$file" > "$tmp"

    mv "$tmp" "$file"
}

update_foot() {
    local file="$CONFIG_HOME/foot/themes/noctalia"
    [[ -f "$file" ]] || return 0

    local surface_nohash on_surface_nohash hover_nohash on_hover_nohash primary_nohash on_primary_nohash
    surface_nohash="$(strip_hash "$m_surface")"
    on_surface_nohash="$(strip_hash "$m_on_surface")"
    hover_nohash="$(strip_hash "$m_hover")"
    on_hover_nohash="$(strip_hash "$m_on_hover")"
    primary_nohash="$(strip_hash "$m_primary")"
    on_primary_nohash="$(strip_hash "$m_on_primary")"

    local sed_args=(
        -e "s|^foreground=.*|foreground=${on_surface_nohash}|"
        -e "s|^background=.*|background=${surface_nohash}|"
        -e "s|^selection-foreground=.*|selection-foreground=${on_hover_nohash}|"
        -e "s|^selection-background=.*|selection-background=${hover_nohash}|"
        -e "s|^cursor=.*|cursor=${on_primary_nohash} ${primary_nohash}|"
    )
    if [[ "$SYNC_ANSI" == true ]]; then
        sed_args+=(
            -e "s|^regular0=.*|regular0=$(strip_hash "$c0")|"
            -e "s|^regular1=.*|regular1=$(strip_hash "$c1")|"
            -e "s|^regular2=.*|regular2=$(strip_hash "$c2")|"
            -e "s|^regular3=.*|regular3=$(strip_hash "$c3")|"
            -e "s|^regular4=.*|regular4=$(strip_hash "$c4")|"
            -e "s|^regular5=.*|regular5=$(strip_hash "$c5")|"
            -e "s|^regular6=.*|regular6=$(strip_hash "$c6")|"
            -e "s|^regular7=.*|regular7=$(strip_hash "$c7")|"
            -e "s|^bright0=.*|bright0=$(strip_hash "$c8")|"
            -e "s|^bright1=.*|bright1=$(strip_hash "$c9")|"
            -e "s|^bright2=.*|bright2=$(strip_hash "$c10")|"
            -e "s|^bright3=.*|bright3=$(strip_hash "$c11")|"
            -e "s|^bright4=.*|bright4=$(strip_hash "$c12")|"
            -e "s|^bright5=.*|bright5=$(strip_hash "$c13")|"
            -e "s|^bright6=.*|bright6=$(strip_hash "$c14")|"
            -e "s|^bright7=.*|bright7=$(strip_hash "$c15")|"
        )
    fi
    sed -i -E "${sed_args[@]}" "$file"
}

update_ghostty
update_kitty_file "$CONFIG_HOME/kitty/current-theme.conf"
update_kitty_file "$CONFIG_HOME/kitty/themes/noctalia.conf"
update_alacritty
update_foot
