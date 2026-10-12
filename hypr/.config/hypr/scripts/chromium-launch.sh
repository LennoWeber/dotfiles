#!/usr/bin/env sh

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
profile_dir="${CHROMIUM_USER_DATA_DIR:-$HOME/.config/chromium}"

"$script_dir/chromium-clear-stale-lock.sh" "$profile_dir" chromium

chromium_bin=""
for candidate in /usr/bin/chromium /usr/bin/chromium-browser; do
  if [ -x "$candidate" ]; then
    chromium_bin="$candidate"
    break
  fi
done

if [ -z "$chromium_bin" ]; then
  echo "chromium-launch: chromium nicht gefunden" >&2
  exit 127
fi

exec "$chromium_bin" "$@"
