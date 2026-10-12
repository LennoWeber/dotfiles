#!/usr/bin/env bash
# Interaktiver Test: Speaker-Mute-LED-Befehle nacheinander ausprobieren.
# Auf die Lautsprecher-Mute-Taste schauen und Enter drücken.

set -euo pipefail

DEVICE=/dev/snd/hwC1D0

try_cmd() {
  local label="$1"
  shift
  echo
  echo ">>> $label"
  echo "    $*"
  read -r -p "Enter zum Ausführen..."
  sudo hda-verb "$@"
  read -r -p "Hat sich die SPEAKER-Mute-LED geändert? (j/n) " ans
  if [[ "$ans" =~ ^[jJ] ]]; then
    echo "TREFFER: $label"
    echo "Befehl: hda-verb $*"
    exit 0
  fi
}

echo "Speaker-LED-Test für $DEVICE"
echo "Mic-LED zuerst ausschalten..."
sudo hda-verb "$DEVICE" 0x01 0x715 0x20 2>/dev/null || true

try_cmd "Coef 0x0b ON (X360)" "$DEVICE" 0x20 0x500 0x0b
try_cmd "Coef 0x0b value 0x08" "$DEVICE" 0x20 0x400 0x08
try_cmd "Coef 0x0b OFF 0x04" "$DEVICE" 0x20 0x500 0x0b
try_cmd "Coef 0x0b value 0x04" "$DEVICE" 0x20 0x400 0x04
try_cmd "Verb 0x717 0x01" "$DEVICE" 0x01 0x717 0x01
try_cmd "Verb 0x717 0x20" "$DEVICE" 0x01 0x717 0x20
try_cmd "Verb 0x715 0x02" "$DEVICE" 0x01 0x715 0x02
try_cmd "Verb 0x715 0x04" "$DEVICE" 0x01 0x715 0x04
try_cmd "Verb 0x715 0x08" "$DEVICE" 0x01 0x715 0x08
try_cmd "GPIO 0x10" "$DEVICE" 0x01 0x716 0x10
try_cmd "GPIO 0x10 data" "$DEVICE" 0x01 0x717 0x10
try_cmd "GPIO 0x10 set" "$DEVICE" 0x01 0x715 0x10

echo
echo "Kein Treffer in dieser Runde. Kernel-Quirk für 103c:8a31 fehlt vermutlich."
