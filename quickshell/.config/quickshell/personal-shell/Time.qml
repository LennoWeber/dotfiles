pragma Singleton

import Quickshell
import QtQuick

Item {
    readonly property string time:
        Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy")

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
