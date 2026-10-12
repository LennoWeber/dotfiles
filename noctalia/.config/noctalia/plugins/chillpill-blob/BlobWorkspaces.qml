/*
 * BlobWorkspaces – Workspace indicator dots for the blob bar.
 * Active workspace shown as an expanded pill in Color.mPrimary,
 * inactive workspaces as small dots in Color.mOnSurfaceVariant.
 * Uses hyprctl IPC for Hyprland workspace data.
 */

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons

RowLayout {
    id: wsWidget
    spacing: Style.marginXS

    property int activeWs: 1
    property int wsCount: 5

    Repeater {
        model: wsWidget.wsCount

        Rectangle {
            required property int index
            property bool isActive: (index + 1) === wsWidget.activeWs

            width: isActive ? 18 : 6
            height: 6
            radius: 3
            color: isActive ? Color.mPrimary : Qt.alpha(Color.mOnSurfaceVariant, 0.35)
            Layout.alignment: Qt.AlignVCenter

            Behavior on width {
                NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation { duration: Style.animationFast }
            }
        }
    }

    // Poll active workspace every 250ms for responsive feedback
    Timer {
        interval: 250
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wsReader.running = true
    }

    Process {
        id: wsReader
        command: ["sh", "-c", "hyprctl activeworkspace -j 2>/dev/null | grep -o '\"id\":[0-9]*' | head -1 | cut -d: -f2"]
        stdout: SplitParser {
            onRead: function(data) {
                var id = parseInt(data.trim());
                if (!isNaN(id) && id > 0) {
                    wsWidget.activeWs = id;
                }
            }
        }
    }
}
