#!/usr/bin/env bash
set -euo pipefail

DEVICE=/dev/snd/hwC1D0

noctalia msg mic-mute
sleep 0.3

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
  led_on=1
elif pactl get-source-mute @DEFAULT_SOURCE@ | grep -qiE 'ja|yes'; then
  led_on=1
else
  led_on=0
fi

if [ "$led_on" = 1 ]; then
  sudo hda-verb "$DEVICE" 0x01 0x715 0x01
else
  sudo hda-verb "$DEVICE" 0x01 0x717 0x01
fi

