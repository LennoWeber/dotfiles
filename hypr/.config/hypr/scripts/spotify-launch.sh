#!/usr/bin/env bash
# Spotify (Flatpak) zuverlässig beim Hyprland-Start: Session bereit, keine Doppelinstanz.

set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
profile_dir="${SPOTIFY_USER_DATA_DIR:-$HOME/.var/app/com.spotify.Client/cache/spotify}"

if pgrep -x spotify >/dev/null 2>&1; then
  exit 0
fi

for _ in $(seq 1 50); do
  if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors >/dev/null 2>&1; then
    break
  fi
  sleep 0.2
done

"$script_dir/chromium-clear-stale-lock.sh" "$profile_dir" spotify

# Wayland/D-Bus kurz stabilisieren lassen, bevor Electron startet.
sleep 1

nohup flatpak run --branch=stable --arch=x86_64 com.spotify.Client >/dev/null 2>&1 &
