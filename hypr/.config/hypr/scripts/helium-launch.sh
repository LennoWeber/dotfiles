#!/usr/bin/env sh

# Helium user profile: MUST stay stable across reboots and network changes.
# Previously this script used machine-id + hostname → different folders when
# the hostname changed (WLAN/Fritzbox/transient hostname), so settings looked "gone".
#
# Default: one fixed directory on this machine.
# Optional: same NFS home on two PCs → set per host, e.g. in hypr env.conf:
#   env = HELIUM_USER_DATA_DIR,/home/you/.config/Helium-fedora-laptop
#
helium_bin=""
user_data_dir="${HELIUM_USER_DATA_DIR:-$HOME/.config/Helium}"

for candidate in helium helium-browser-bin helium-browser; do
  if command -v "$candidate" >/dev/null 2>&1; then
    helium_bin="$candidate"
    break
  fi
done

if [ -z "$helium_bin" ]; then
  echo "helium launcher: no Helium binary found (checked: helium, helium-browser-bin, helium-browser)" >&2
  exit 127
fi

# Native GTK dialogs (Dateiauswahl etc.) nutzen GTK_THEME; ohne Export oft „fremdes“ Adwaita.
if command -v gsettings >/dev/null 2>&1; then
  gt="$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")"
  [ -n "$gt" ] && export GTK_THEME="$gt"
fi
export GTK_THEME="${GTK_THEME:-Breeze-Dark}"

# Keep Helium UI themed with current Noctalia/Matugen colors.
if command -v python3 >/dev/null 2>&1; then
  python3 "$HOME/.config/hypr/scripts/helium-theme-sync.py" >/dev/null 2>&1 || true
fi

exec "$helium_bin" \
  --gtk-version=4 \
  --load-extension="$HOME/.config/helium/noctalia-theme" \
  --user-data-dir="$user_data_dir" \
  "$@"
