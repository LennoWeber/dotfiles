#!/bin/bash

# Toggle between transparent and opaque windows in Hyprland
# Transparent: active=0.9, inactive=0.8
# Opaque: active=1.0, inactive=1.0

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hyprland-opacity-toggle"

if [ -f "$STATE_FILE" ]; then
    # Currently opaque -> switch back to transparent
    hyprctl keyword decoration:active_opacity 0.9
    hyprctl keyword decoration:inactive_opacity 0.8
#    hyprctl keyword general:gaps_in 0
#    hyprctl keyword general:gaps_out 0
    rm "$STATE_FILE"
    # Optional: Send notification
    # notify-send "Opacity" "Windows transparent" -t 2000
else
    # Currently transparent -> switch to opaque
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0
#    hyprctl keyword general:gaps_in 5
#    hyprctl keyword general:gaps_out 5
    touch "$STATE_FILE"
    # Optional: Send notification
    # notify-send "Opacity" "Windows opaque" -t 2000
fi
