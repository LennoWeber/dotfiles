/*
 * BlobClock – Minimal clock widget for the blob bar.
 * Uses Noctalia fonts (Settings.data.ui.fontDefault) and colors (Color.mOnSurface).
 */

import QtQuick
import qs.Commons

Item {
    id: clockWidget
    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight

    property string timeString: ""

    Text {
        id: clockText
        text: clockWidget.timeString
        color: Color.mOnSurface
        font.pixelSize: Style.fontSizeL * Settings.data.ui.fontDefaultScale
        font.weight: Font.Medium
        font.family: Settings.data.ui.fontDefault
        font.letterSpacing: 0.5

        Behavior on color {
            ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            clockWidget.timeString = now.getHours().toString().padStart(2, '0')
                                   + ":" + now.getMinutes().toString().padStart(2, '0');
        }
    }
}
