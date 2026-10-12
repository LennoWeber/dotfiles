#!/usr/bin/env bash
# Clears Spotify startup blockers and stale Chromium/GPU caches.
# Safe to run when Spotify exits immediately or shows a blank window.

set -euo pipefail

FLATPAK_CACHE="$HOME/.var/app/com.spotify.Client/cache"
SPOTIFY_CACHE="$FLATPAK_CACHE/spotify"

if pgrep -f '/app/extra/share/spotify/spotify' >/dev/null 2>&1 || pgrep -x spotify >/dev/null 2>&1; then
  echo "Spotify läuft noch — bitte zuerst beenden." >&2
  exit 1
fi

removed=0

singleton_files=(
  "$SPOTIFY_CACHE/SingletonCookie"
  "$SPOTIFY_CACHE/SingletonLock"
  "$SPOTIFY_CACHE/SingletonSocket"
)

for path in "${singleton_files[@]}"; do
  if [[ -e "$path" || -L "$path" ]]; then
    rm -f "$path"
    echo "Singleton entfernt: $path"
    removed=$((removed + 1))
  fi
done

paths=(
  "$SPOTIFY_CACHE/Default/Cache"
  "$SPOTIFY_CACHE/Default/Code Cache"
  "$SPOTIFY_CACHE/Default/GPUCache"
  "$SPOTIFY_CACHE/Default/DawnWebGPUCache"
  "$SPOTIFY_CACHE/Default/DawnGraphiteCache"
  "$SPOTIFY_CACHE/GrShaderCache"
  "$SPOTIFY_CACHE/GraphiteDawnCache"
  "$SPOTIFY_CACHE/ShaderCache"
  "$SPOTIFY_CACHE/BrowserMetrics"
  "$SPOTIFY_CACHE/DeferredBrowserMetrics"
  "$FLATPAK_CACHE/mesa_shader_cache"
  "$FLATPAK_CACHE/radv_builtin_shaders"
)

for path in "${paths[@]}"; do
  if [[ -e "$path" ]]; then
    rm -rf "$path"
    echo "Gelöscht: $path"
    removed=$((removed + 1))
  fi
done

if [[ "$removed" -eq 0 ]]; then
  echo "Keine Startup-Caches oder Singleton-Locks gefunden."
else
  echo "Startup bereinigt ($removed Einträge)."
fi
