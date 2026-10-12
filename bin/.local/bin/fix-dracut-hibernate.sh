#!/usr/bin/env bash
# Nur Initramfs neu bauen — entfernt KEINE Kernel
set -euo pipefail

build_initrd() {
    local kver=$1
    local outfile="/boot/initramfs-${kver}.img"
    echo "    -> ${kver} -> ${outfile}"
    dracut -f "$outfile" "$kver"
    echo "       OK ($(stat -c '%y' "$outfile" | cut -d. -f1))"
}

echo "==> Installierte Boot-Kernel (werden NICHT entfernt):"
ls /boot/vmlinuz-* | grep -v rescue

echo "==> Initramfs neu bauen"
CURRENT=$(uname -r)
build_initrd "$CURRENT"

for moddir in /lib/modules/*/; do
    kver=$(basename "$moddir")
    [[ "$kver" == "$CURRENT" ]] && continue
    [[ -f "/boot/vmlinuz-${kver}" ]] && build_initrd "$kver"
done

echo "==> systemd neu laden"
systemctl daemon-reload

echo
echo "Fertig. Nächste Schritte:"
echo "  sudo grubby --info=DEFAULT | grep args"
echo "  sudo reboot"
echo "  sudo systemctl hibernate"
