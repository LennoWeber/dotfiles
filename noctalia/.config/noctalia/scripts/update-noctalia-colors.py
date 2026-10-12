#!/usr/bin/env python3
import json
import pathlib
import subprocess
import sys

HOME = pathlib.Path.home()
SETTINGS = HOME / ".local/state/noctalia/settings.toml"
PALETTES = HOME / ".config/noctalia/palettes"
COLORSCHEMES = HOME / ".config/noctalia/colorschemes"
COMMUNITY = HOME / ".cache/noctalia/community-palettes"
TEMPLATE = HOME / ".config/quickshell/noctalia-shell/Assets/Templates/noctalia.json"
OUT = HOME / ".config/noctalia/colors.json"
PROCESSOR = HOME / ".config/quickshell/noctalia-shell/Scripts/python/src/theming/template-processor.py"


def parse_theme_settings() -> dict[str, str]:
    theme: dict[str, str] = {}
    if not SETTINGS.exists():
        return theme
    in_theme = False
    for line in SETTINGS.read_text(encoding="utf-8").splitlines():
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


def main():
    theme = parse_theme_settings()
    source = theme.get("source", "builtin")
    mode = theme_mode()

    input_source = ""
    is_scheme = False

    if source == "wallpaper":
        try:
            input_source = subprocess.check_output(
                ["noctalia", "msg", "wallpaper-get"],
                text=True,
                stderr=subprocess.DEVNULL,
            ).strip()
        except Exception:
            input_source = ""
    elif source == "custom" and theme.get("custom_palette"):
        input_source = str(PALETTES / f"{theme['custom_palette']}.json")
        is_scheme = True
    elif source == "community" and theme.get("community_palette"):
        input_source = str(COMMUNITY / f"{theme['community_palette']}.json")
        is_scheme = True
    elif theme.get("builtin"):
        name = theme["builtin"]
        input_source = str(COLORSCHEMES / name / f"{name}.json")
        is_scheme = True

    if not input_source or not pathlib.Path(input_source).exists():
        print(f"Error: Resolved input source '{input_source}' does not exist.", file=sys.stderr)
        sys.exit(1)

    # We will generate a temp TOML config for template-processor.py
    import tempfile
    with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
        config_path = f.name
        f.write(f"[templates.noctalia]\ninput_path = \"{TEMPLATE}\"\noutput_path = \"{OUT}\"\n")

    cmd = ["python3", str(PROCESSOR)]
    if is_scheme:
        cmd += ["--scheme", input_source]
    else:
        cmd += [input_source]
        
    cmd += ["--config", config_path, "--default-mode", mode]

    try:
        subprocess.run(cmd, check=True)
    finally:
        pathlib.Path(config_path).unlink(missing_ok=True)


if __name__ == "__main__":
    main()
