import Quickshell
import QtQuick

Text {
    color: "White"
    font.pixelSize: 14
    text: Qt.formatDateTime(clock.date, "ddd dd.MM. yyyy  HH:mm:ss")

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
