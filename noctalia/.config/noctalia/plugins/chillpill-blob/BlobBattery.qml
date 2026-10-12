/*
 * BlobBattery – Battery status widget for the blob bar.
 * Reads battery data from /sys/class/power_supply/BAT*.
 * Uses Noctalia Color.mPrimary for accent and Color.mError for low battery.
 */

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons

RowLayout {
    id: batteryWidget
    spacing: Style.marginXS

    property int percent: 100
    property bool charging: false
    property bool hasBattery: true

    visible: hasBattery

    // Battery icon (Nerd Font)
    Text {
        text: batteryWidget.charging ? "󱐋" :
              batteryWidget.percent > 80 ? "󰁹" :
              batteryWidget.percent > 60 ? "󰂁" :
              batteryWidget.percent > 40 ? "󰁿" :
              batteryWidget.percent > 20 ? "󰁽" : "󰁻"
        color: batteryWidget.percent <= 20 && !batteryWidget.charging ? Color.mError : Color.mPrimary
        font.pixelSize: Style.fontSizeXL * Settings.data.ui.fontDefaultScale
        font.family: "Symbols Nerd Font"
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
        }
    }

    // Percentage text
    Text {
        text: batteryWidget.percent + "%"
        color: Color.mOnSurface
        font.pixelSize: Style.fontSizeM * Settings.data.ui.fontDefaultScale
        font.weight: Font.Medium
        font.family: Settings.data.ui.fontDefault
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
        }
    }

    // Poll battery status every 10 seconds
    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryReader.running = true
    }

    Process {
        id: batteryReader
        command: ["sh", "-c", "cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1); stat=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1); [ -z \"$cap\" ] && echo 'NOBAT' || echo \"$cap $stat\""]
        stdout: SplitParser {
            onRead: function(data) {
                var trimmed = data.trim();
                if (trimmed === "NOBAT") {
                    batteryWidget.hasBattery = false;
                    return;
                }
                var parts = trimmed.split(" ");
                if (parts.length >= 1) {
                    var cap = parseInt(parts[0]);
                    if (!isNaN(cap)) batteryWidget.percent = cap;
                }
                if (parts.length >= 2) {
                    batteryWidget.charging = parts[1] === "Charging";
                }
            }
        }
    }
}
