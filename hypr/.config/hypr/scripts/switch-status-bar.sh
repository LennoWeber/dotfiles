#!/usr/bin/env bash

set -euo pipefail

wait_for_noctalia() {
    local i
    for i in $(seq 1 80); do
        if pgrep -u "$(id -u)" -x noctalia >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
    done
    return 1
}

noctalia_ipc() {
    if ! command -v noctalia >/dev/null 2>&1; then
        return 1
    fi
    noctalia msg "$@" >/dev/null 2>&1
}

start_waybar() {
    if pgrep -x waybar >/dev/null 2>&1; then
        return 0
    fi
    if command -v uwsm-app >/dev/null 2>&1; then
        uwsm-app -- waybar >/dev/null 2>&1 &
    else
        waybar >/dev/null 2>&1 &
    fi
    local i
    for i in $(seq 1 40); do
        if pgrep -x waybar >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.05
    done
    return 1
}

apply_hybrid_bar() {
    wait_for_noctalia || true
    noctalia_ipc bar-hide || true
    pkill -x nm-applet >/dev/null 2>&1 || true
    start_waybar
}

apply_hybrid_bar
