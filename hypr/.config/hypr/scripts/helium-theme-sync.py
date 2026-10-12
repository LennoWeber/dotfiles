#!/usr/bin/env python3
import json
import os
import re
from pathlib import Path


def hex_to_rgb255(hex_color: str):
    s = hex_color.strip()
    if s.startswith("#"):
        s = s[1:]
    if len(s) == 3:
        s = "".join(ch * 2 for ch in s)
    if len(s) != 6 or not re.fullmatch(r"[0-9a-fA-F]{6}", s):
        raise ValueError(f"invalid hex color: {hex_color!r}")
    return [int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16)]


def read_matugen_colors():
    p = Path.home() / ".local/state/quickshell/user/generated/colors.json"
    data = json.loads(p.read_text(encoding="utf-8"))
    return {k: hex_to_rgb255(v) for k, v in data.items() if isinstance(v, str)}


def build_manifest(colors):
    # Gruvbox-ish: dark surfaces with warm text and green/yellow accents.
    bg = colors.get("surface_container_lowest") or colors.get("background") or colors.get("surface") or [40, 40, 40]
    surface = colors.get("surface") or bg
    surface_hi = colors.get("surface_container_high") or colors.get("surface_container") or surface
    surface_mid = colors.get("surface_container") or surface_hi
    text = colors.get("on_surface") or colors.get("on_background") or [235, 219, 178]
    outline = colors.get("outline") or [146, 131, 116]
    text_variant = colors.get("on_surface_variant") or outline
    primary = colors.get("primary") or [184, 187, 38]
    secondary = colors.get("secondary") or [250, 189, 47]
    tertiary = colors.get("tertiary") or secondary

    return {
        "manifest_version": 2,
        "name": "Noctalia (Matugen) – Helium Theme",
        "version": "1.0.0",
        "description": "Auto-generated theme from Noctalia/Matugen colors.",
        "theme": {
            "colors": {
                "frame": bg,
                "frame_inactive": bg,
                "toolbar": surface,
                "toolbar_text": text,
                "tab_text": text,
                "tab_background": surface_hi,
                "tab_background_text": text_variant,
                "tab_line": primary,
                "bookmark_bar": surface_mid,
                "bookmark_text": text,
                "button_background": [0, 0, 0, 0],
                "omnibox_background": bg,
                "omnibox_text": text,
                "omnibox_border": outline,
                "omnibox_results_bg": surface_mid,
                "omnibox_results_text": text,
                "omnibox_results_url": tertiary,
                "ntp_background": bg,
                "ntp_text": text,
                "ntp_link": primary,
                "ntp_header": surface,
                "ntp_section": surface_mid,
                "ntp_section_text": text_variant,
                "ntp_section_link": secondary,
            },
        },
    }


def main():
    theme_dir = Path.home() / ".config/helium/noctalia-theme"
    theme_dir.mkdir(parents=True, exist_ok=True)
    manifest_path = theme_dir / "manifest.json"

    colors = read_matugen_colors()
    manifest = build_manifest(colors)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()

