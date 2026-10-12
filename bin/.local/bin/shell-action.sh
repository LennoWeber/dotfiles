#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.config/hypr/active-shell"
shell=$(cat "$STATE_FILE" 2>/dev/null || echo "noctalia")
action="${1:-}"

case "$shell" in
  dms)
    case "$action" in
      launcher)        dms ipc call spotlight toggle ;;
      session-menu)    dms ipc call powermenu toggle ;;
      lock-screen)     dms ipc call lock lock ;;
      dark-mode)       dms ipc call theme toggle ;;
      notifications)   dms ipc call notifications toggle ;;
      control-center)  dms ipc call control-center toggle ;;
      settings)        dms ipc call settings toggle ;;
      wallpaper)       dms ipc call dankdash wallpaper ;;
      volume-up)       dms ipc call audio increment 5 ;;
      volume-down)     dms ipc call audio decrement 5 ;;
      volume-mute)     dms ipc call audio mute ;;
      mic-mute)        dms ipc call audio micmute ;;
      brightness-up)   dms ipc call brightness increment 5 "" ;;
      brightness-down) dms ipc call brightness decrement 5 "" ;;
    esac
    ;;
  hacker)
    case "$action" in
      launcher)        ~/.config/hypr/scripts/hacker-qs.sh ipc call launcher toggle ;;
      session-menu)    ~/.config/hypr/scripts/hacker-qs.sh ipc call sessionMenu toggle ;;
      lock-screen)     ~/.config/hypr/scripts/hacker-qs.sh ipc call lockScreen lock ;;
      dark-mode)       ~/.config/hypr/scripts/hacker-qs.sh ipc call darkMode toggle ;;
      notifications)   ~/.config/hypr/scripts/hacker-qs.sh ipc call notifications toggleHistory ;;
      control-center)  ~/.config/hypr/scripts/hacker-qs.sh ipc call controlCenter toggle ;;
      settings)        ~/.config/hypr/scripts/hacker-qs.sh ipc call settings toggle ;;
      wallpaper)       ~/.config/hypr/scripts/hacker-qs.sh ipc call wallpaper toggle ;;
      volume-up)       ~/.config/hypr/scripts/hacker-qs.sh ipc call volume increase ;;
      volume-down)     ~/.config/hypr/scripts/hacker-qs.sh ipc call volume decrease ;;
      volume-mute)     ~/.config/hypr/scripts/hacker-qs.sh ipc call volume muteOutput ;;
      mic-mute)        ~/.config/hypr/scripts/hacker-qs.sh ipc call volume muteInput ;;
      brightness-up)   ~/.config/hypr/scripts/hacker-qs.sh ipc call brightness increase ;;
      brightness-down) ~/.config/hypr/scripts/hacker-qs.sh ipc call brightness decrease ;;
    esac
    ;;
  *)
    case "$action" in
      launcher)        qs -c noctalia-shell ipc call launcher toggle ;;
      session-menu)    qs -c noctalia-shell ipc call sessionMenu toggle ;;
      lock-screen)     qs -c noctalia-shell ipc call lockScreen lock ;;
      dark-mode)       qs -c noctalia-shell ipc call darkMode toggle ;;
      notifications)   qs -c noctalia-shell ipc call notifications toggleHistory ;;
      control-center)  qs -c noctalia-shell ipc call controlCenter toggle ;;
      settings)        qs -c noctalia-shell ipc call settings toggle ;;
      wallpaper)       qs -c noctalia-shell ipc call wallpaper toggle ;;
      volume-up)       qs -c noctalia-shell ipc call volume increase ;;
      volume-down)     qs -c noctalia-shell ipc call volume decrease ;;
      volume-mute)     qs -c noctalia-shell ipc call volume muteOutput ;;
      mic-mute)        qs -c noctalia-shell ipc call volume muteInput ;;
      brightness-up)   qs -c noctalia-shell ipc call brightness increase ;;
      brightness-down) qs -c noctalia-shell ipc call brightness decrease ;;
    esac
    ;;
esac
