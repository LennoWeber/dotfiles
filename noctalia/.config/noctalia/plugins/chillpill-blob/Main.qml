/*
 * Main.qml – Noctalia Plugin Entry Point for ChillPill Blob Bar.
 *
 * Creates a transparent PanelWindow on each screen using Wayland Layer Shell.
 * The window sits at the Top layer with no exclusive zone (floating over content).
 * The BlobBar component is centered horizontally at the top of each screen.
 *
 * This file is loaded by Noctalia's PluginService when the plugin is enabled.
 */

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

Item {
    id: root

    // Injected by PluginService
    required property var pluginApi

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: blobWindow

            required property var modelData
            screen: modelData

            // Anchor to full width at top of screen
            anchors {
                top: true
                left: true
                right: true
            }

            // Layer shell configuration
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "chillpill-blob"

            // Don't reserve screen space – float over desktop content
            exclusiveZone: 0

            // Transparent window background
            color: "transparent"

            // Window height: enough for blob + wobble padding
            height: 64

            // The blob bar itself, centered at top
            BlobBar {
                id: blobBar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 6
            }
        }
    }
}
