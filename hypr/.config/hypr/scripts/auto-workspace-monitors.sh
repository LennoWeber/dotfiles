#!/usr/bin/env bash
set -euo pipefail

# Zielverhalten:
# - Kein externer Monitor aktiv: eDP-1 bekommt Workspaces 1–10
# - Externer Monitor aktiv: externer bekommt 1–5, eDP-1 bekommt 6–10
#
# Hinweis: Workspaces sind in Hyprland global eindeutig. Wir "initialisieren"
# beide Monitore, indem wir Workspaces beim (Un)Plug umverteilen.

HYPRCTL="${HYPRCTL:-hyprctl}"
INTERNAL_MONITOR="${INTERNAL_MONITOR:-eDP-1}"
MODE="${1:-}"

lock_or_exit() {
  local runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  mkdir -p "$runtime" 2>/dev/null || true
  local lockfile="$runtime/auto-workspace-monitors.lock"
  exec 9>"$lockfile"
  if ! flock -n 9; then
    exit 0
  fi
}

log() {
  printf '[auto-workspace-monitors] %s\n' "$*" >&2
}

has_hypr() {
  command -v "$HYPRCTL" >/dev/null 2>&1
}

json_monitors() {
  "$HYPRCTL" monitors -j 2>/dev/null
}

json_workspaces() {
  "$HYPRCTL" workspaces -j 2>/dev/null
}

pick_external_monitor() {
  # Wähle den ersten aktiven Monitor, der nicht INTERNAL_MONITOR ist.
  # Gibt leeren String zurück, wenn keiner vorhanden ist.
  json_monitors | jq -r --arg internal "$INTERNAL_MONITOR" '
    map(select(.name != $internal) | select(.disabled == false) | select(.active == true or .focused == true or .dpmsStatus == true)) |
    (.[0].name // "")
  ' 2>/dev/null || true
}

workspace_on_monitor() {
  local ws="$1"
  json_workspaces | jq -r --argjson ws "$ws" '
    map(select(.id == $ws) | .monitor) | (.[0] // "")
  ' 2>/dev/null || true
}

move_ws_to_monitor_if_needed() {
  local ws="$1"
  local target_monitor="$2"
  local current
  current="$(workspace_on_monitor "$ws")"
  if [[ -n "$current" && "$current" == "$target_monitor" ]]; then
    return 0
  fi
  log "move workspace $ws -> $target_monitor (was: ${current:-unknown})"
  "$HYPRCTL" dispatch moveworkspacetomonitor "$ws" "$target_monitor" >/dev/null 2>&1 || true
}

apply_layout() {
  if ! has_hypr; then
    log "hyprctl nicht gefunden; abbrechen"
    return 0
  fi

local external
external="$(pick_external_monitor)"

if [[ -z "$external" ]]; then
  log "kein externer Monitor -> $INTERNAL_MONITOR: 1-10"
  for ws in {1..10}; do
    move_ws_to_monitor_if_needed "$ws" "$INTERNAL_MONITOR"
  done
  xrandr --output "$INTERNAL_MONITOR" --primary 2>/dev/null || true
  return 0
fi

log "externer Monitor '$external' aktiv -> $external: 1-5, $INTERNAL_MONITOR: 6-10"
for ws in {1..5}; do
  move_ws_to_monitor_if_needed "$ws" "$external"
done
for ws in {6..10}; do
  move_ws_to_monitor_if_needed "$ws" "$INTERNAL_MONITOR"
done
xrandr --output "$external" --primary 2>/dev/null || true
}

event_socket() {
  local runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  local sig="${HYPRLAND_INSTANCE_SIGNATURE:-}"
  if [[ -z "$sig" ]]; then
    return 1
  fi
  printf '%s/hypr/%s/.socket2.sock' "$runtime" "$sig"
}

listen_events() {
  local sock
  sock="$(event_socket)" || return 1
  [[ -S "$sock" ]] || return 1

  log "höre auf Events via $sock"
  # Initial anwenden
  apply_layout

  # monitoradded/monitorremoved/configreloaded reichen
  socat -u "UNIX-CONNECT:$sock" - 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      monitoradded*|monitorremoved*|monitoraddedv2*|monitorremovedv2*)
        sleep 0.2
        apply_layout
        ;;
      configreloaded*)
        sleep 0.2
        apply_layout
        ;;
    esac
  done
}

poll_fallback() {
  log "kein Event-Socket; nutze Polling"
  while true; do
    apply_layout
    sleep 2
  done
}

main() {
  lock_or_exit

  if [[ "$MODE" == "--once" ]]; then
    apply_layout
    return 0
  fi

  if ! listen_events; then
    poll_fallback
  fi
}

main

