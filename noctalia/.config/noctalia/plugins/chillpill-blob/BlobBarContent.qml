/*
 * BlobBarContent – Widget layout inside the blob bar.
 * Arranges all status widgets in a horizontal row with themed separator dots.
 */

import QtQuick
import QtQuick.Layouts
import qs.Commons

RowLayout {
    id: content
    spacing: Style.marginL

    BlobBattery {}

    // Themed separator dot
    Rectangle {
        width: 3; height: 3; radius: 1.5
        color: Qt.alpha(Color.mOutline, 0.4)
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
        }
    }

    BlobWorkspaces {}

    Rectangle {
        width: 3; height: 3; radius: 1.5
        color: Qt.alpha(Color.mOutline, 0.4)
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
        }
    }

    BlobClock {}

    Rectangle {
        width: 3; height: 3; radius: 1.5
        color: Qt.alpha(Color.mOutline, 0.4)
        Layout.alignment: Qt.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
        }
    }

    BlobNetwork {}
}
