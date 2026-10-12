/*
 * BlobBar – Main container component for the ChillPill blob bar.
 *
 * Instantiates the BlobAnimEngine, overlays BlobShape (background)
 * with BlobBarContent (widgets), and adds a hover glow effect.
 * The pill width automatically adapts to content size.
 */

import QtQuick
import qs.Commons

Item {
    id: blobBar

    // Size driven by content, with horizontal padding
    width: contentRow.implicitWidth + 48
    height: 44

    // Update engine dimensions reactively
    onWidthChanged: engine.pillWidth = width
    onHeightChanged: engine.pillHeight = height

    // Smooth width transition when widgets appear/disappear
    Behavior on width {
        NumberAnimation { duration: Style.animationNormal; easing.type: Easing.OutCubic }
    }

    // === Animation Engine ===
    BlobAnimEngine {
        id: engine
    }

    // === Background Blob Shape ===
    BlobShape {
        id: blobBg
        engine: engine
        anchors.fill: parent
        // Extra space around the blob for wobble overflow
        anchors.margins: -10
        width: parent.width + 20
        height: parent.height + 20
    }

    // === Widget Content ===
    BlobBarContent {
        id: contentRow
        anchors.centerIn: parent
    }

    // === Hover Glow Effect ===
    // Subtle border glow using Color.mPrimary on hover
    Rectangle {
        id: hoverGlow
        anchors.fill: parent
        anchors.margins: -8
        radius: height / 2
        color: "transparent"
        border.color: Qt.alpha(Color.mPrimary, hoverArea.containsMouse ? 0.15 : 0)
        border.width: Style.borderS

        Behavior on border.color {
            ColorAnimation { duration: Style.animationFast }
        }
    }

    // Hover detection
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
