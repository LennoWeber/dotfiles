#!/usr/bin/env python3
"""Resolve Noctalia's active palette for the current (or given) theme mode."""

from __future__ import annotations

import json
import pathlib
import subprocess
import sys


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
    if len(sys.argv) > 1 and sys.argv[1] in {"dark", "light"}:
        return sys.argv[1]
    try:
        mode = subprocess.check_output(
            ["noctalia", "msg", "theme-mode-get"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        mode = "dark"
    return "light" if mode == "light" else "dark"


def load_active_palette(mode: str) -> dict:
    config_home = pathlib.Path(
        __import__("os").environ.get("XDG_CONFIG_HOME", pathlib.Path.home() / ".config")
    )
    cache_home = pathlib.Path(
        __import__("os").environ.get("XDG_CACHE_HOME", pathlib.Path.home() / ".cache")
    )
    state_home = pathlib.Path(
        __import__("os").environ.get("XDG_STATE_HOME", pathlib.Path.home() / ".local/state")
    )

    settings_path = state_home / "noctalia/settings.toml"
    colors_path = config_home / "noctalia/colors.json"
    palettes_dir = config_home / "noctalia/palettes"
    colorschemes_dir = config_home / "noctalia/colorschemes"
    community_dir = cache_home / "noctalia/community-palettes"

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

    candidates.append(cache_home / "noctalia/predefined-scheme.json")
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


def main() -> int:
    mode = theme_mode()
    palette = load_active_palette(mode)
    if not palette:
        return 1
    print(json.dumps(palette, ensure_ascii=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
