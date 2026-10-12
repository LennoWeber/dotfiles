#!/usr/bin/env bash
# Einmalig mit: sudo bash ~/.local/bin/setup-hp-sleep-fix.sh
set -euo pipefail

RESUME_UUID="5df59aa3-e774-45b4-bdb3-652b9cf42152"
RESUME_OFFSET="78914816"

echo "==> fstab: Swap-Priorität unter zram setzen"
if grep -q '^/swapfile none swap defaults 0 0$' /etc/fstab; then
    sed -i 's|^/swapfile none swap defaults 0 0$|/swapfile none swap defaults,pri=10 0 0|' /etc/fstab
elif ! grep -q '^/swapfile ' /etc/fstab; then
    echo '/swapfile none swap defaults,pri=10 0 0' >> /etc/fstab
fi

echo "==> systemd-logind: Hibernate erlauben, Deckel -> Hibernate"
install -d /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/50-hp-sleep.conf <<'EOF'
[Login]
HandleLidSwitch=hibernate
HandleLidSwitchExternalPower=hibernate
HandleLidSwitchDocked=ignore
IdleAction=ignore
IdleActionSec=30min
AllowHibernation=yes
EOF

echo "==> systemd-sleep: Hibernate-Modus"
install -d /etc/systemd/sleep.conf.d
cat > /etc/systemd/sleep.conf.d/50-hp-sleep.conf <<'EOF'
[Sleep]
AllowHibernation=yes
AllowSuspend=yes
HibernateMode=platform
EOF

echo "==> Sleep-Hook: USB-Wakeup vor Sleep deaktivieren (HP s2idle-Fix)"
install -d /etc/systemd/system-sleep
cat > /etc/systemd/system-sleep/hp-wakeup-fix.sh <<'EOF'
#!/usr/bin/env bash
# XHC0/XHC1 verursachen auf HP ENVY x360 oft hängende s2idle-Zustände.
case "${1:-}" in
    pre)
        for dev in XHC0 XHC1 GP17; do
            if grep -q "^${dev}.*\*enabled" /proc/acpi/wakeup 2>/dev/null; then
                echo "$dev" > /proc/acpi/wakeup 2>/dev/null || true
            fi
        done
        ;;
esac
EOF
chmod +x /etc/systemd/system-sleep/hp-wakeup-fix.sh

echo "==> Kernel-Parameter für Hibernate (Btrfs-Swapfile)"
grubby --update-kernel=ALL \
    --args="resume=UUID=${RESUME_UUID} resume_offset=${RESUME_OFFSET}"

echo "==> dracut: resume-Modul"
install -d /etc/dracut.conf.d
cat > /etc/dracut.conf.d/resume.conf <<EOF
add_dracutmodules+=" resume "
resume="UUID=${RESUME_UUID}"
resume_offset="${RESUME_OFFSET}"
EOF

echo "==> Initramfs neu bauen"
for moddir in /lib/modules/*/; do
    kver=$(basename "$moddir")
    if [[ -f "/boot/vmlinuz-${kver}" ]]; then
        echo "    -> ${kver}"
        dracut -f --kver "$kver"
    else
        echo "    überspringe ${kver} (kaputtes Kernel-Paket, kein vmlinuz)"
    fi
done

echo "==> systemd neu laden"
systemctl daemon-reload

echo
echo "Fertig. Bitte neu starten, dann testen:"
echo "  sudo systemctl hibernate"
echo
echo "Optional: kaputtes Kernel-Paket entfernen (empfohlen):"
echo "  sudo dnf remove kernel-core-7.0.10-100.fc43.x86_64 kernel-7.0.10-100.fc43.x86_64"
echo
echo "Nach dem Test prüfen:"
echo "  cat /sys/power/mem_sleep          # zeigt [s2idle] — normal auf diesem HP"
echo "  swapon --show                     # zram Prio 100, /swapfile Prio 10"
