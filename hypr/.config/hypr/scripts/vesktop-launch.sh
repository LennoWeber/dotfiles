#!/usr/bin/env bash
# Vesktop on Hyprland/Wayland: Chromium's DMA-BUF screen capture often fails
# with xdg-desktop-portal-hyprland ("Out of buffers", format renegotiation).
exec /usr/bin/vesktop \
  --ozone-platform=wayland \
  --disable-gpu-memory-buffer-video-frames \
  "$@"
