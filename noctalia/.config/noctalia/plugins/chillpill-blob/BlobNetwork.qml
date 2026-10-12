/*
 * BlobNetwork – Network status widget for the blob bar.
 * Uses nmcli to detect active connection type and name.
 * Color.mTertiary for online status, Color.mOnSurfaceVariant for offline.
 */

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons

RowLayout {
    id: networkWidget
    spacing: Style.marginXS

    property string netStatus: "offline"
    property string netName: ""

    // Network icon (Nerd Font)
    Text {
        text: networkWidget.netStatus === "wifi" ? "󰤨" :
              networkWidget.netStatus === "ethernet" ? "󰈀" : "󰤭"
        color: networkWidget.netStatus !== "offline" ? Color.mTertiary : Color.mOnSurfaceVariant
        font.pixelSize: Style.fontSizeXL * Settings.data.ui.fontDefaultScale
        font.family: "Symbols Nerd Font"
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
        }
    }

    // Connection name
    Text {
        visible: networkWidget.netName !== ""
        text: networkWidget.netName
        color: Color.mOnSurface
        font.pixelSize: Style.fontSizeM * Settings.data.ui.fontDefaultScale
        font.weight: Font.Medium
        font.family: Settings.data.ui.fontDefault
        elide: Text.ElideRight
        Layout.maximumWidth: 80
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
        }
    }

    // Poll network status every 5 seconds
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netReader.running = true
    }

    Process {
        id: netReader
        command: ["sh", "-c", "nmcli -t -f TYPE,NAME connection show --active 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: function(data) {
                var trimmed = data.trim();
                if (trimmed === "") {
                    networkWidget.netStatus = "offline";
                    networkWidget.netName = "";
                    return;
                }
                // nmcli output format: TYPE:NAME (colon-separated)
                var colonIdx = trimmed.indexOf(":");
                if (colonIdx >= 0) {
                    var type = trimmed.substring(0, colonIdx).toLowerCase();
                    networkWidget.netName = trimmed.substring(colonIdx + 1);
                    if (type.indexOf("wireless") >= 0 || type.indexOf("wifi") >= 0 || type === "802-11-wireless") {
                        networkWidget.netStatus = "wifi";
                    } else if (type.indexOf("ethernet") >= 0 || type === "802-3-ethernet") {
                        networkWidget.netStatus = "ethernet";
                    } else {
                        networkWidget.netStatus = "online";
                    }
                } else {
                    networkWidget.netStatus = "offline";
                    networkWidget.netName = "";
                }
            }
        }
    }
}
