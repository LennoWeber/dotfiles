#!/usr/bin/env bash

set -u

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

NOCTALIA_PATH="/etc/xdg/quickshell/noctalia-shell"
PERSONAL_PATH="$XDG_CONFIG_HOME/quickshell/personal-shell"
NOCTALIA_QML="$NOCTALIA_PATH/shell.qml"
PERSONAL_QML="$PERSONAL_PATH/shell.qml"
LOG_FILE="$XDG_CACHE_HOME/quickshell-switch.log"

log() {
    mkdir -p "$(dirname "$LOG_FILE")" >/dev/null 2>&1 || true
    printf '[%s] %s\n' "$(date '+%F %T')" "$*" >>"$LOG_FILE" 2>/dev/null || true
}

notify_qs() {
    if command -v notify-send >/dev/null 2>&1; then
        (timeout 1s notify-send "$@" >/dev/null 2>&1 &) || true
    fi
}

pick_shell() {
    local options
    options=$(printf "Noctalia\nPersoenliches Projekt\n")

    if command -v wofi >/dev/null 2>&1; then
        printf "%s\n" "$options" | wofi --dmenu --prompt "Quickshell> "
        return
    fi

    if command -v rofi >/dev/null 2>&1; then
        printf "%s\n" "$options" | rofi -dmenu -p "Quickshell"
        return
    fi

    if command -v fuzzel >/dev/null 2>&1; then
        printf "%s\n" "$options" | fuzzel -d -p "Quickshell> " -w 40 -l 2 --no-run-if-empty
        return
    fi

    return 1
}

normalize_selection() {
    printf "%s" "$1" | sed 's/\r$//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

tag_from_arg() {
    case "${1:-}" in
        noctalia|Noctalia)
            printf "noctalia"
            return 0
            ;;
        personal|personal-shell|Persoenliches\ Projekt)
            printf "personal"
            return 0
            ;;
        menu|"")
            return 1
            ;;
        *)
            return 2
            ;;
    esac
}

path_for_tag() {
    case "$1" in
        noctalia) printf "%s" "$NOCTALIA_PATH" ;;
        personal) printf "%s" "$PERSONAL_PATH" ;;
        *) return 1 ;;
    esac
}

qml_for_tag() {
    case "$1" in
        noctalia) printf "%s" "$NOCTALIA_QML" ;;
        personal) printf "%s" "$PERSONAL_QML" ;;
        *) return 1 ;;
    esac
}

pattern_for_tag() {
    case "$1" in
        noctalia)
            printf "%s" "qs -p $NOCTALIA_PATH -d"
            ;;
        personal)
            printf "%s" "qs -p $PERSONAL_PATH -d"
            ;;
        *)
            return 1
            ;;
    esac
}

pid_list_for_tag() {
    local tag="$1"
    local pattern
    pattern="$(pattern_for_tag "$tag" || true)"
    if [ -z "$pattern" ]; then
        return 1
    fi
    pgrep -u "$(id -u)" -f "$pattern" || true
}

has_running_instance() {
    local tag="$1"
    [ -n "$(pid_list_for_tag "$tag")" ]
}

active_tag() {
    if has_running_instance "personal"; then
        printf "personal"
        return 0
    fi

    if has_running_instance "noctalia"; then
        printf "noctalia"
        return 0
    fi

    return 1
}

toggle_tag() {
    local active
    active="$(active_tag || true)"
    if [ "$active" = "personal" ]; then
        printf "noctalia"
    else
        printf "personal"
    fi
}

kill_current_shells() {
    local i
    pkill -x qs >/dev/null 2>&1 || true
    for i in $(seq 1 40); do
        if ! pgrep -u "$(id -u)" -x qs >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.05
    done
    return 1
}

target_tag=""
if arg_tag="$(tag_from_arg "${1:-menu}")"; then
    target_tag="$arg_tag"
else
    status=$?
    if [ "$status" -eq 2 ]; then
        log "Invalid switch argument: '${1:-}'"
        exit 1
    fi

    selection_raw="$(pick_shell || true)"
    selection="$(normalize_selection "$selection_raw")"
    case "$selection" in
        "Noctalia")
            target_tag="noctalia"
            ;;
        "Persoenliches Projekt")
            target_tag="personal"
            ;;
        *)
            target_tag="$(toggle_tag)"
            log "No valid menu selection. raw='$selection_raw' normalized='$selection'. Fallback toggle -> $target_tag"
            ;;
    esac
fi

if [ -z "$target_tag" ]; then
    log "No target tag could be resolved."
    exit 1
fi

target_path="$(path_for_tag "$target_tag" || true)"
if [ -z "$target_path" ]; then
    log "No target path for tag '$target_tag'"
    exit 1
fi

log "Switch requested -> $target_tag ($target_path)"
kill_current_shells || log "Could not fully stop existing qs processes"
sleep 0.2

tmp_start_log="$(mktemp "${XDG_CACHE_HOME:-$HOME/.cache}/quickshell-start.XXXXXX.log")"
if timeout 8s qs -p "$target_path" -d >"$tmp_start_log" 2>&1; then
    start_exit=0
else
    start_exit=$?
fi
start_output="$(cat "$tmp_start_log" 2>/dev/null || true)"
rm -f "$tmp_start_log" >/dev/null 2>&1 || true

if [ -n "$start_output" ]; then
    log "qs start output ($target_tag): $start_output"
fi

if [ "$start_exit" -eq 0 ]; then
    sleep 0.2
    if has_running_instance "$target_tag"; then
        log "Switch successful -> $target_tag"
        notify_qs "Quickshell" "Aktiv: $target_tag" -t 1500
    else
        if printf "%s" "$start_output" | rg -q "Failed to load configuration|ERROR"; then
            log "Switch failed (configuration/runtime error) -> $target_tag"
            notify_qs "Quickshell" "Startfehler: $target_tag (siehe ~/.cache/quickshell-switch.log)" -t 3000
            exit 1
        fi
        log "Start command ran, but target instance not visible -> $target_tag"
        notify_qs "Quickshell" "Unklarer Status: $target_tag" -t 2000
    fi
else
    log "Switch failed -> $target_tag (exit=$start_exit)"
    notify_qs "Quickshell" "Start fehlgeschlagen: $target_tag" -t 2500
    exit 1
fi
