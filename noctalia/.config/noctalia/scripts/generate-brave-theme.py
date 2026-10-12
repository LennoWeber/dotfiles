#!/usr/bin/env python3
"""Generate Brave extension colors from the active Noctalia palette."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

HOME = Path.home()
SETTINGS = HOME / ".local/state/noctalia/settings.toml"
PALETTES = HOME / ".config/noctalia/palettes"
COLORSCHEMES = HOME / ".config/noctalia/colorschemes"
COMMUNITY = HOME / ".cache/noctalia/community-palettes"
FALLBACK = HOME / ".config/noctalia/colors.json"
OUT = HOME / ".config/noctalia/brave-extension/colors.json"


def parse_theme_settings() -> dict[str, str]:
    theme: dict[str, str] = {}
    if not SETTINGS.exists():
        return theme
    in_theme = False
    for line in SETTINGS.read_text().splitlines():
        if line.strip() == "[theme]":
            in_theme = True
            continue
        if in_theme and line.startswith("[") and not line.startswith("[theme."):
            break
        if in_theme:
            key, _, value = line.partition("=")
            value = value.strip().strip('"')
            if key and value:
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


def load_palette(mode: str) -> dict:
    theme = parse_theme_settings()
    source = theme.get("source", "builtin")
    candidates: list[Path] = []

    if source == "custom" and theme.get("custom_palette"):
        candidates.append(PALETTES / f"{theme['custom_palette']}.json")
    elif source == "community" and theme.get("community_palette"):
        candidates.append(COMMUNITY / f"{theme['community_palette']}.json")
    elif theme.get("builtin"):
        name = theme["builtin"]
        candidates.append(COLORSCHEMES / name / f"{name}.json")

    candidates.append(FALLBACK)

    for path in candidates:
        if not path.exists():
            continue
        data = json.loads(path.read_text())
        if mode in data and isinstance(data[mode], dict):
            return data[mode]
        if "mSurface" in data:
            return data
    return {}


def pick(palette: dict, key: str, fallback: str) -> str:
    value = palette.get(key)
    if isinstance(value, str) and value.startswith("#") and len(value) == 7:
        return value
    return fallback


def main() -> None:
    mode = theme_mode()
    palette = load_palette(mode)
    payload = {
        "mode": mode,
        "surface": pick(palette, "mSurface", "#111417"),
        "surface_variant": pick(palette, "mSurfaceVariant", "#1a1f24"),
        "surface_high": pick(palette, "mHover", "#252c34"),
        "primary": pick(palette, "mPrimary", "#9aa6b2"),
        "secondary": pick(palette, "mSecondary", "#7f8c99"),
        "tertiary": pick(palette, "mTertiary", "#6f9c93"),
        "on_surface": pick(palette, "mOnSurface", "#dce1e7"),
        "on_surface_variant": pick(palette, "mOnSurfaceVariant", "#99a3b0"),
        "outline": pick(palette, "mOutline", "#2f3944"),
        "error": pick(palette, "mError", "#e07a7a"),
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(payload, indent=2) + "\n")

    content_css = OUT.parent / "content.css"
    content_css.write_text(
        "\n".join(
            [
                ":root {",
                f"  color-scheme: {mode};",
                f"  --noctalia-surface: {payload['surface']};",
                f"  --noctalia-surface-variant: {payload['surface_variant']};",
                f"  --noctalia-primary: {payload['primary']};",
                f"  --noctalia-on-surface: {payload['on_surface']};",
                f"  --noctalia-outline: {payload['outline']};",
                "}",
                "",
                "::selection {",
                f"  background-color: {payload['primary']}55;",
                f"  color: {payload['on_surface']};",
                "}",
                "",
                "* {",
                f"  scrollbar-color: {payload['outline']} {payload['surface_variant']};",
                "}",
                "",
            ]
        )
    )


if __name__ == "__main__":
    main()
