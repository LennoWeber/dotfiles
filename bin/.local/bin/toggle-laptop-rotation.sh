#!/usr/bin/env bash
# Toggle Laptop Screen (eDP-1) rotation between normal and 180° (upside down)

LAPTOP_MONITOR="eDP-1"

# Get current transform value for the laptop monitor
CURRENT_TRANSFORM=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$LAPTOP_MONITOR\") | .transform")

# Fallback if jq is not available
if [ -z "$CURRENT_TRANSFORM" ] || [ "$CURRENT_TRANSFORM" = "null" ]; then
    CURRENT_TRANSFORM=$(hyprctl monitors | grep -A 10 "$LAPTOP_MONITOR" | grep "transform:" | awk '{print $2}')
fi

# Toggle between 0 (normal) and 2 (180° upside down)
if [ "$CURRENT_TRANSFORM" = "0" ] || [ -z "$CURRENT_TRANSFORM" ]; then
    # Rotate to 180° (upside down)
    hyprctl keyword monitor "$LAPTOP_MONITOR,transform,2"
    notify-send "Laptop Screen" "Rotated 180° (upside down)" -t 2000 2>/dev/null || true
else
    # Rotate back to normal
    hyprctl keyword monitor "$LAPTOP_MONITOR,transform,0"
    notify-send "Laptop Screen" "Rotated to normal" -t 2000 2>/dev/null || true
fi
