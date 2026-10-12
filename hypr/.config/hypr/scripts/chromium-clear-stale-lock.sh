#!/usr/bin/env sh
# Entfernt veraltete Chromium/Brave-Singleton-Sperren (SingletonLock/Cookie/Socket).
# Typisch nach Absturz oder wenn sich der Hostname ändert (z. B. Telekom dip0.t-ipconnect.de).

profile_dir="${1:?Profilverzeichnis fehlt}"
process_name="${2:-}"

if [ ! -d "$profile_dir" ]; then
  exit 0
fi

if [ -n "$process_name" ]; then
  if pgrep -x "$process_name" >/dev/null 2>&1 \
    || pgrep -f "$profile_dir" >/dev/null 2>&1; then
    exit 0
  fi
fi

lock="$profile_dir/SingletonLock"
if [ ! -e "$lock" ] && [ ! -L "$lock" ]; then
  exit 0
fi

target=$(readlink "$lock" 2>/dev/null || true)
stale=0

if [ -z "$target" ]; then
  stale=1
else
  case "$target" in
    *-*)
      pid="${target##*-}"
      lock_host="${target%-*}"
      if ! kill -0 "$pid" 2>/dev/null; then
        stale=1
      elif [ "$(hostname)" != "$lock_host" ] && [ "$(hostname -f 2>/dev/null)" != "$lock_host" ]; then
        stale=1
      fi
      ;;
    *)
      stale=1
      ;;
  esac
fi

if [ "$stale" -eq 0 ]; then
  exit 0
fi

socket_target=$(readlink "$profile_dir/SingletonSocket" 2>/dev/null || true)

rm -f \
  "$profile_dir/SingletonLock" \
  "$profile_dir/SingletonCookie" \
  "$profile_dir/SingletonSocket"

if [ -n "$target" ]; then
  rm -f "$profile_dir/$target"
fi

if [ -n "$socket_target" ]; then
  rm -f "$socket_target" 2>/dev/null || true
fi
