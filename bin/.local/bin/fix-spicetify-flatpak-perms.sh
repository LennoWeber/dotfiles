#!/usr/bin/env bash
# Spicetify needs write access to Flatpak Spotify's app files.
# Re-run after every `flatpak update com.spotify.Client`.

set -euo pipefail

SPOTIFY_DIR="/var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify"
APPS_DIR="${SPOTIFY_DIR}/Apps"

if [[ ! -d "$SPOTIFY_DIR" ]]; then
  echo "Spotify-Flatpak-Pfad nicht gefunden: $SPOTIFY_DIR" >&2
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

chmod a+wr "$SPOTIFY_DIR"
chmod a+wr -R "$APPS_DIR"

# Ensure user-owned extracted dirs remain accessible after partial spicetify runs
if [[ -d "$APPS_DIR/login" ]]; then
  chmod -R u+rwX "$APPS_DIR/login" 2>/dev/null || true
fi
if [[ -d "$APPS_DIR/xpui" ]]; then
  chmod -R u+rwX "$APPS_DIR/xpui" 2>/dev/null || true
fi

echo "Berechtigungen gesetzt:"
ls -ld "$SPOTIFY_DIR" "$APPS_DIR"
if spa_count="$(find "$APPS_DIR" -maxdepth 1 -name '*.spa' 2>/dev/null | wc -l)"; then
  echo "SPA-Dateien in Apps/: $spa_count"
  find "$APPS_DIR" -maxdepth 1 -name '*.spa' -printf '  %f\n' 2>/dev/null || true
fi
