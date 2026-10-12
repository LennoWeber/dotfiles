#!/usr/bin/env bash
# Hibernate/Sleep-Fix rückgängig machen — Laptop schläft nicht mehr automatisch ein
set -euo pipefail

echo "==> systemd-logind: Deckel und Idle ignorieren (kein Sleep/Hibernate)"
install -d /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/50-hp-sleep.conf <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
IdleAction=ignore
EOF

echo "==> systemd-sleep Override entfernen"
rm -f /etc/systemd/sleep.conf.d/50-hp-sleep.conf
rmdir /etc/systemd/sleep.conf.d 2>/dev/null || true

echo "==> Sleep-Hook entfernen"
rm -f /etc/systemd/system-sleep/hp-wakeup-fix.sh

echo "==> GRUB: resume-Parameter entfernen"
grubby --update-kernel=ALL \
    --remove-args="resume=UUID=5df59aa3-e774-45b4-bdb3-652b9cf42152 resume_offset=78914816" \
    2>/dev/null || true

echo "==> dracut resume-Modul entfernen"
rm -f /etc/dracut.conf.d/resume.conf

echo "==> fstab: Swap-Eintrag auf Standard zurücksetzen"
if grep -q '^/swapfile none swap defaults,pri=10 0 0$' /etc/fstab; then
    sed -i 's|^/swapfile none swap defaults,pri=10 0 0$|/swapfile none swap defaults 0 0|' /etc/fstab
fi

echo "==> Initramfs ohne resume neu bauen"
for kver in $(ls /boot/vmlinuz-* 2>/dev/null | sed 's|.*/vmlinuz-||' | grep -v rescue); do
    echo "    -> ${kver}"
    dracut -f "/boot/initramfs-${kver}.img" "$kver"
done

echo "==> systemd neu laden"
systemctl daemon-reload

echo
echo "Fertig. Noch manuell:"
echo "  killall hypridle; hypridle &    # hypridle-Konfig neu laden"
echo "  sudo reboot                     # GRUB-Änderungen aktivieren"
echo
echo "Der Laptop geht jetzt NICHT mehr automatisch in Standby/Hibernate."
echo "Deckel zu = ignoriert. Nur Bildschirm sperren/aus nach hypridle-Timeout."
