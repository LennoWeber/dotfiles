#!/usr/bin/env bash
# Keep default apps pinned in nwg-dock and ensure launchable .desktop stubs exist.
set -euo pipefail

PINNED_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/nwg-dock-pinned"
APPS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

python3 - "$PINNED_FILE" "$APPS_DIR" <<'PY'
import os
import re
import sys
from pathlib import Path

pinned_file, apps_dir = map(Path, sys.argv[1:3])
apps_dir.mkdir(parents=True, exist_ok=True)
pinned_file.parent.mkdir(parents=True, exist_ok=True)

MARKER = "X-Dock-Pinned"
CURSOR_ICON = Path.home() / ".local/share/icons/cursor-dock.png"

PINNED = [
    {"class": "kitty", "source": "kitty.desktop"},
    {"class": "zen", "source": "zen-browser.desktop"},
    {"class": "cursor", "source": "cursor.desktop"},
    {"class": "Code", "source": "code.desktop"},
    {"class": "ONLYOFFICE", "source": "onlyoffice-desktopeditors.desktop"},
    {"class": "im.riot.Riot", "source": "/var/lib/flatpak/exports/share/applications/im.riot.Riot.desktop"},
    {"class": "spotify", "source": "/var/lib/flatpak/exports/share/applications/com.spotify.Client.desktop"},
]

desktop_dirs: list[Path] = []
xdg_data_home = os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))
for entry in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":"):
    if entry:
        desktop_dirs.append(Path(entry) / "applications")
desktop_dirs.append(Path(xdg_data_home) / "applications")


def read_desktop(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("["):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def find_source(name: str) -> Path | None:
    direct = Path(name)
    if direct.is_file():
        return direct
    for directory in desktop_dirs:
        path = directory / name
        if path.is_file():
            data = read_desktop(path)
            exec_line = main_exec(data)
            if exec_line:
                return path
    return None


def main_exec(data: dict[str, str]) -> str:
    for key in ("Exec", "TryExec"):
        value = data.get(key, "")
        if value and value not in {"true", "false"}:
            exec_line = value
            cut = exec_line.find(" %")
            if cut != -1:
                exec_line = exec_line[:cut]
            exec_line = exec_line.strip()
            exec_line = re.sub(r"\s@@\S+$", "", exec_line)
            flatpak = re.search(
                r"(/usr/bin/flatpak run)\s+(?:--\S+\s+)*([A-Za-z0-9._-]+\.[A-Za-z0-9._-]+)",
                exec_line,
            )
            if flatpak:
                return f"{flatpak.group(1)} {flatpak.group(2)}"
            return exec_line
    return ""


def resolve_icon(wm_class: str, data: dict[str, str]) -> str:
    if wm_class == "cursor" and CURSOR_ICON.is_file():
        return str(CURSOR_ICON)
    return data.get("Icon", wm_class)


def write_stub(wm_class: str, source: Path, data: dict[str, str]) -> None:
    exec_line = main_exec(data)
    if not exec_line:
        raise SystemExit(f"No Exec found for pinned app '{wm_class}' ({source})")

    icon = resolve_icon(wm_class, data)
    name = data.get("Name", wm_class)
    stub = apps_dir / f"{wm_class}.desktop"
    body = (
        "[Desktop Entry]\n"
        "Type=Application\n"
        f"Name={name}\n"
        f"Icon={icon}\n"
        f"StartupWMClass={wm_class}\n"
        "StartupNotify=false\n"
        f"Exec={exec_line}\n"
        f"{MARKER}=pinned\n"
    )
    stub.write_text(body, encoding="utf-8")


classes: list[str] = []
for entry in PINNED:
    wm_class = entry["class"]
    source = find_source(entry["source"])
    if source is None:
        raise SystemExit(f"Missing desktop file for pinned app '{wm_class}': {entry['source']}")
    write_stub(wm_class, source, read_desktop(source))
    classes.append(wm_class)

pinned_file.write_text("\n".join(classes) + "\n", encoding="utf-8")
print(f"dock-pins: {len(classes)} app(s) pinned -> {pinned_file}")
PY

THEME_SCRIPT="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/scripts/apply-nwg-dock-theme.sh"
if [[ -x "$THEME_SCRIPT" ]]; then
    "$THEME_SCRIPT" --css-only || true
fi
