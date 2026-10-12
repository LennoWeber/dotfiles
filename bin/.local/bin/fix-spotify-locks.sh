#!/usr/bin/env bash
# Quick fix when Spotify exits immediately with no window.
set -euo pipefail
exec "$HOME/.local/bin/clear-spotify-startup-cache.sh"
