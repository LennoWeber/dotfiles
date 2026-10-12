#!/usr/bin/env bash
# Repairs broken Spotify Flatpak + reapplies Spicetify safely.
#
# Root cause this fixes:
# - Spicetify unpacks login.spa/xpui.spa but failed to repack (permission denied)
# - Broken SingletonLock/SingletonSocket after reboot (Spotify exits silently)
# - Stale Chromium/GPU caches on Wayland
#
# Re-run after: flatpak update com.spotify.Client

set -euo pipefail

SPOTIFY_DIR="/var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify"
APPS_DIR="${SPOTIFY_DIR}/Apps"
FIX_PERMS="$HOME/.local/bin/fix-spicetify-flatpak-perms.sh"
CLEAR_CACHE="$HOME/.local/bin/clear-spotify-startup-cache.sh"

usage() {
  cat <<'EOF'
Usage: spotify-repair.sh [OPTION]

  --spotify-only   Reinstall Flatpak Spotify, skip Spicetify
  --spicetify-only Fix permissions and reapply Spicetify (Spotify must be intact)
  --cache-only     Clear startup/GPU caches only
  (default)        Full repair: reinstall + permissions + spicetify + cache

EOF
}

spotify_only=false
spicetify_only=false
cache_only=false

for arg in "$@"; do
  case "$arg" in
    --spotify-only) spotify_only=true ;;
    --spicetify-only) spicetify_only=true ;;
    --cache-only) cache_only=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unbekannte Option: $arg" >&2; usage; exit 1 ;;
  esac
done

if pgrep -f '/app/extra/share/spotify/spotify' >/dev/null 2>&1 || pgrep -x spotify >/dev/null 2>&1; then
  echo "Beende Spotify …"
  pkill -f '/app/extra/share/spotify/spotify' 2>/dev/null || pkill -x spotify 2>/dev/null || true
  sleep 1
fi

"$CLEAR_CACHE" || true

if [[ "$cache_only" == true ]]; then
  echo "Fertig. Test: flatpak run com.spotify.Client"
  exit 0
fi

spa_ok() {
  [[ -f "$APPS_DIR/login.spa" && -f "$APPS_DIR/xpui.spa" ]]
}

if [[ "$spicetify_only" != true ]]; then
  if ! spa_ok; then
    echo "Kaputte Spotify-Installation erkannt (login.spa/xpui.spa fehlen)."
    echo "Flatpak neu installieren …"
    flatpak install --reinstall -y flathub com.spotify.Client
  else
    echo "Spotify .spa-Dateien vorhanden — kein Reinstall nötig."
  fi
fi

if [[ "$spotify_only" == true ]]; then
  "$CLEAR_CACHE" || true
  echo "Fertig. Test: flatpak run com.spotify.Client"
  exit 0
fi

if [[ ! -x "$FIX_PERMS" ]]; then
  echo "Fehlt: $FIX_PERMS" >&2
  exit 1
fi

echo "Spicetify-Berechtigungen setzen (sudo) …"
"$FIX_PERMS"

if ! spa_ok; then
  echo "Spotify-Dateien immer noch kaputt — Reinstall erneut versuchen." >&2
  exit 1
fi

echo "Spicetify anwenden …"
spicetify restore || true
spicetify backup apply
spicetify apply

"$CLEAR_CACHE" || true

echo
echo "Reparatur abgeschlossen."
echo "Test: flatpak run com.spotify.Client"
echo
echo "Nach jedem 'flatpak update com.spotify.Client':"
echo "  spotify-repair.sh --spicetify-only"
