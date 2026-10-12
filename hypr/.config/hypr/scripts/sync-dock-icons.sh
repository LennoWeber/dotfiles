#!/usr/bin/env bash
# Map Hyprland window classes to .desktop stubs so nwg-dock can resolve icons.
# Usage:
#   sync-dock-icons.sh          # running windows only
#   sync-dock-icons.sh --all    # every StartupWMClass on the system

set -euo pipefail

MODE="${1:-running}"
TARGET_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
MARKER="X-Dock-Icon-Sync"

mkdir -p "$TARGET_DIR"

python3 - "$MODE" "$TARGET_DIR" "$MARKER" <<'PY'
import json
import os
import re
import subprocess
import sys
from pathlib import Path

mode, target_dir, marker = sys.argv[1:4]
target = Path(target_dir)

desktop_dirs = []
for var in ("XDG_DATA_HOME", "XDG_DATA_DIRS"):
    raw = os.environ.get(var, "")
    if var == "XDG_DATA_HOME" and raw:
        desktop_dirs.append(str(Path(raw) / "applications"))
    elif raw:
        desktop_dirs.extend(str(Path(p) / "applications") for p in raw.split(":") if p)

if str(target) not in desktop_dirs:
    desktop_dirs.append(str(target))

icon_theme = os.environ.get("GTK_ICON_THEME", "Papirus-Dark")
icon_roots = [
    Path("/usr/share/icons"),
    Path.home() / ".local/share/icons",
    Path("/usr/share/pixmaps"),
]
CURSOR_ICON_CACHE = Path.home() / ".local/share/icons/cursor-dock.png"
CURSOR_ICON_RELATIVE = "usr/share/icons/hicolor/256x256/apps/cursor.png"
EXEC_OVERRIDES = {
    "vesktop": str(Path.home() / ".config/hypr/scripts/vesktop-launch.sh"),
}


def is_valid_image(path: Path) -> bool:
    if not path.is_file():
        return False
    try:
        header = path.read_bytes()[:16]
    except OSError:
        return False
    if header.startswith(b"\x89PNG\r\n\x1a\n"):
        return True
    if header.startswith(b"GIF87a") or header.startswith(b"GIF89a"):
        return True
    if header.startswith(b"\xff\xd8\xff"):
        return True
    if header.lstrip().startswith(b"<") and b"svg" in header.lower():
        return True
    return False


def resolve_cursor_icon() -> str:
    if is_valid_image(CURSOR_ICON_CACHE):
        return str(CURSOR_ICON_CACHE)

    mount_candidates = sorted(Path("/tmp").glob(".mount_Cursor*/" + CURSOR_ICON_RELATIVE))
    for candidate in mount_candidates:
        if is_valid_image(candidate):
            CURSOR_ICON_CACHE.parent.mkdir(parents=True, exist_ok=True)
            CURSOR_ICON_CACHE.write_bytes(candidate.read_bytes())
            return str(CURSOR_ICON_CACHE)

    for appimage in sorted((Path.home() / "Downloads").glob("Cursor*.AppImage")):
        alt = appimage.parent / f".cursor-icon-{appimage.stem}.png"
        if is_valid_image(alt):
            return str(alt)

    return str(CURSOR_ICON_CACHE)


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


def icon_exists(icon: str) -> bool:
    if not icon:
        return False
    if icon.startswith("/"):
        return is_valid_image(Path(icon))
    for root in icon_roots:
        if not root.exists():
            continue
        for pattern in (
            f"{icon_theme}/scalable/apps/{icon}.svg",
            f"{icon_theme}/scalable/apps/{icon}.png",
            f"{icon_theme}/48x48/apps/{icon}.svg",
            f"{icon_theme}/48x48/apps/{icon}.png",
            f"{icon_theme}/64x64/apps/{icon}.svg",
            f"{icon_theme}/64x64/apps/{icon}.png",
            f"hicolor/scalable/apps/{icon}.svg",
            f"hicolor/256x256/apps/{icon}.png",
            f"{icon}.png",
            f"{icon}.svg",
        ):
            if (root / pattern).exists():
                return True
    return False


def pick_icon(data: dict[str, str]) -> str:
    icon = data.get("Icon", "")
    if icon_exists(icon):
        return icon
    name = data.get("Name", "")
    for candidate in (
        data.get("StartupWMClass", ""),
        name.lower().replace(" ", "-"),
        Path(data.get("_source", "")).stem,
    ):
        if candidate and icon_exists(candidate):
            return candidate
    return icon or name or "application-x-executable"


def safe_class_name(value: str) -> str | None:
    value = value.strip()
    if not value or "/" in value or "\0" in value:
        return None
    return value


def stub_path(class_name: str) -> Path:
    return target / f"{class_name}.desktop"


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


def write_stub(class_name: str, source: Path, data: dict[str, str], force: bool = False) -> bool:
    path = stub_path(class_name)
    if path.exists() and not force:
        existing = read_desktop(path)
        if existing.get("X-Dock-Pinned"):
            return False
        if existing.get(marker) != "generated" and existing.get("Icon"):
            return False
    exec_line = EXEC_OVERRIDES.get(class_name) or main_exec(data)
    if not exec_line:
        return False
    icon = pick_icon({**data, "_source": str(source)})
    name = data.get("Name", class_name)
    body = (
        "[Desktop Entry]\n"
        f"Type=Application\n"
        f"Name={name}\n"
        f"Icon={icon}\n"
        f"StartupWMClass={class_name}\n"
        "StartupNotify=false\n"
        f"Exec={exec_line}\n"
        f"{marker}=generated\n"
    )
    path.write_text(body, encoding="utf-8")
    return True


def load_all_desktops() -> list[tuple[Path, dict[str, str]]]:
    entries: list[tuple[Path, dict[str, str]]] = []
    seen: set[Path] = set()
    for directory in desktop_dirs:
        root = Path(directory)
        if not root.is_dir():
            continue
        for path in root.glob("*.desktop"):
            resolved = path.resolve()
            if resolved in seen:
                continue
            seen.add(resolved)
            data = read_desktop(path)
            if data.get("Type") not in (None, "Application", "Link"):
                continue
            entries.append((path, data))
    return entries


def index_by_wmclass(entries: list[tuple[Path, dict[str, str]]]) -> dict[str, tuple[Path, dict[str, str]]]:
    mapping: dict[str, tuple[Path, dict[str, str]]] = {}
    for path, data in entries:
        wm = data.get("StartupWMClass")
        if wm:
            mapping.setdefault(wm, (path, data))
            mapping.setdefault(wm.lower(), (path, data))
    return mapping


def is_generated_stub(path: Path, data: dict[str, str]) -> bool:
    return path.parent == target and data.get(marker) == "generated"


def pick_source(path: Path, data: dict[str, str]) -> tuple[Path, dict[str, str]] | None:
    if is_generated_stub(path, data) and not main_exec(data):
        return None
    return path, data


def find_match(class_name: str, entries: list[tuple[Path, dict[str, str]]], by_wm: dict[str, tuple[Path, dict[str, str]]]) -> tuple[Path, dict[str, str]] | None:
    if class_name in by_wm:
        picked = pick_source(*by_wm[class_name])
        if picked:
            return picked
    lower = class_name.lower()
    if lower in by_wm:
        picked = pick_source(*by_wm[lower])
        if picked:
            return picked

    direct = Path(class_name)
    if direct.suffix == ".desktop" and direct.exists():
        picked = pick_source(direct, read_desktop(direct))
        if picked:
            return picked

    for directory in desktop_dirs:
        for candidate in (f"{class_name}.desktop", f"{lower}.desktop"):
            path = Path(directory) / candidate
            if path.exists():
                picked = pick_source(path, read_desktop(path))
                if picked:
                    return picked

    prefix = class_name.split("-")[0].split(".")[0].split(" ")[0]
    for path, data in entries:
        stem = path.stem
        if prefix and prefix.lower() in stem.lower():
            picked = pick_source(path, data)
            if picked:
                return picked
        if class_name.lower() in stem.lower():
            picked = pick_source(path, data)
            if picked:
                return picked

    for path, data in entries:
        wm = data.get("StartupWMClass", "")
        if wm and (wm == class_name or wm.lower() == lower):
            picked = pick_source(path, data)
            if picked:
                return picked

    return None


def running_classes() -> set[str]:
    try:
        raw = subprocess.check_output(["hyprctl", "clients", "-j"], text=True)
        clients = json.loads(raw)
    except Exception:
        return set()
    classes: set[str] = set()
    for client in clients:
        for key in ("class", "initialClass"):
            value = safe_class_name(str(client.get(key, "")))
            if value:
                classes.add(value)
    return classes


KNOWN_OVERRIDES = {
    "dev.noctalia.Noctalia.Settings": {
        "Name": "Noctalia Settings",
        "Icon": "/usr/share/noctalia/assets/noctalia.svg",
        "StartupWMClass": "dev.noctalia.Noctalia.Settings",
    },
    "cursor": {
        "Name": "Cursor",
        "Icon": resolve_cursor_icon(),
        "StartupWMClass": "cursor",
    },
    "Cursor": {
        "Name": "Cursor",
        "Icon": resolve_cursor_icon(),
        "StartupWMClass": "Cursor",
    },
}


entries = load_all_desktops()
by_wm = index_by_wmclass(entries)

classes: set[str] = set()
if mode == "--all":
    for _, data in entries:
        wm = safe_class_name(data.get("StartupWMClass", ""))
        if wm:
            classes.add(wm)
    classes.update(running_classes())
else:
    classes = running_classes()

created = 0
for class_name in sorted(classes):
    if class_name in KNOWN_OVERRIDES:
        if write_stub(class_name, target / "override.desktop", KNOWN_OVERRIDES[class_name], force=True):
            created += 1
        continue

    match = find_match(class_name, entries, by_wm)
    if match:
        source, data = match
        if write_stub(class_name, source, data):
            created += 1
    elif icon_exists(class_name):
        if write_stub(class_name, target / "fallback.desktop", {
            "Name": class_name,
            "Icon": class_name,
            "StartupWMClass": class_name,
        }):
            created += 1

print(f"dock-icons: {created} stub(s) updated in {target}")
PY
