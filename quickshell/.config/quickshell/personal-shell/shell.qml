import Quickshell

Scope{
    Bar {}
}


















/*    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 15

            Text {
                anchors.centerIn:parent
                text: root.time
                color: "black"
            }
        }
    }
    Process {
        id: dateProc
        command: ["date"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.text = this.text
        }
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
*/
