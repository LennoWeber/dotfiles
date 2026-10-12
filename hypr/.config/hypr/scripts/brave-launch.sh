#!/usr/bin/env sh

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
profile_dir="${BRAVE_USER_DATA_DIR:-$HOME/.config/BraveSoftware/Brave-Browser}"

"$script_dir/chromium-clear-stale-lock.sh" "$profile_dir" brave

brave_bin=""
for candidate in /usr/bin/brave-browser /usr/bin/brave; do
  if [ -x "$candidate" ]; then
    brave_bin="$candidate"
    break
  fi
done

if [ -z "$brave_bin" ]; then
  echo "brave-launch: brave-browser nicht gefunden" >&2
  exit 127
fi

exec "$brave_bin" "$@"
