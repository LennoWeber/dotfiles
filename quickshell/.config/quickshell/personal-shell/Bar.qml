import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Services.UPower

Scope {
    Variants {
        model: Quickshell.screens

        Item {
            id: screenRoot
            required property var modelData

            property bool bluetoothPopupOpen: false
            property bool wifiPopupOpen: false

            property bool wifiEnabled: true
            property string wifiStatus: "wifi"
            property var wifiNetworks: []
            readonly property var battery: UPower.displayDevice

            function closePopups() {
                bluetoothPopupOpen = false;
                wifiPopupOpen = false;
            }

            function refreshWifi() {
                wifiProcess.running = false;
                wifiProcess.running = true;
            }

            PanelWindow {
                screen: modelData

                anchors {
                    top: true
                    left: true
                    right: true
                }

                implicitHeight: 15
                color: "black"

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4

                    ClockWidget {
                        anchors.centerIn: parent
                    }

                    Row {
                        id: rightModules
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Text {
                            id: batteryText
                            color: "white"
                            font.pixelSize: 14
                            text: {
                                if (!screenRoot.battery || !screenRoot.battery.ready || !screenRoot.battery.isPresent) {
                                    return "󰂑 --%";
                                }

                                const percent = Math.round(screenRoot.battery.percentage);
                                return (UPower.onBattery ? "󰁹 " : "󰂄 ") + percent + "%";
                            }
                        }

                        Text {
                            id: wifiText
                            color: "white"
                            font.pixelSize: 14
                            text: "󰖩 " + screenRoot.wifiStatus

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    screenRoot.bluetoothPopupOpen = false;
                                    screenRoot.wifiPopupOpen = !screenRoot.wifiPopupOpen;
                                    if (screenRoot.wifiPopupOpen) {
                                        screenRoot.refreshWifi();
                                    }
                                }
                            }
                        }

                        Text {
                            id: bluetoothText
                            readonly property var adapter: Bluetooth.defaultAdapter
                            readonly property var connectedDevices: {
                                if (!adapter || !adapter.devices) {
                                    return [];
                                }

                                return adapter.devices.values.filter(device => device && device.connected);
                            }
                            text: {
                                if (!adapter) {
                                    return "󰂲 bluetooth unavailable";
                                }

                                if (!adapter.enabled) {
                                    return "󰂲 bluetooth off";
                                }

                                if (connectedDevices.length > 0) {
                                    return "󰂯 " + (connectedDevices[0].name || connectedDevices[0].deviceName || "bluetooth");
                                }

                                return "󰂯 bluetooth";
                            }
                            color: "white"
                            font.pixelSize: 14

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    screenRoot.wifiPopupOpen = false;
                                    screenRoot.bluetoothPopupOpen = !screenRoot.bluetoothPopupOpen;
                                }
                            }
                        }
                    }
                }
            }

            PanelWindow {
                screen: modelData
                visible: wifiPopupOpen || bluetoothPopupOpen
                color: "transparent"

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: screenRoot.closePopups()
                }

                Rectangle {
                    id: wifiPopup
                    visible: screenRoot.wifiPopupOpen
                    x: Math.max(0, Math.min(parent.width - width, (parent.width - 4 - rightModules.width) + wifiText.x))
                    y: 15
                    width: 320
                    height: Math.min(parent.height - y, Math.min(240, wifiPopupContent.implicitHeight + 8))
                    color: "black"
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                    }

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 4
                        clip: true
                        contentWidth: width
                        contentHeight: wifiPopupContent.implicitHeight

                        Column {
                            id: wifiPopupContent
                            width: parent.width
                            spacing: 4

                            Rectangle {
                                width: parent.width
                                height: wifiHeader.implicitHeight + 4
                                color: "transparent"

                                Text {
                                    id: wifiHeader
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "wifi"
                                    color: "white"
                                    font.pixelSize: 14
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#224466"
                            }

                            Rectangle {
                                width: parent.width
                                height: wifiToggleText.implicitHeight + 4
                                color: wifiToggleArea.containsMouse ? "#1d3557" : "transparent"

                                Text {
                                    id: wifiToggleText
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: screenRoot.wifiEnabled ? "disable wifi" : "enable wifi"
                                    color: "white"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: wifiToggleArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        wifiToggleProcess.command = ["nmcli", "radio", "wifi", screenRoot.wifiEnabled ? "off" : "on"];
                                        wifiToggleProcess.running = false;
                                        wifiToggleProcess.running = true;
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: wifiScanText.implicitHeight + 4
                                color: wifiScanArea.containsMouse ? "#1d3557" : "transparent"

                                Text {
                                    id: wifiScanText
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "refresh wifi"
                                    color: "white"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: wifiScanArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: screenRoot.refreshWifi()
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#224466"
                            }

                            Repeater {
                                model: screenRoot.wifiNetworks

                                delegate: Rectangle {
                                    required property var modelData
                                    width: parent ? parent.width : 0
                                    height: networkText.implicitHeight + 4
                                    color: networkArea.containsMouse ? "#1d3557" : "transparent"

                                    Text {
                                        id: networkText
                                        anchors.left: parent.left
                                        anchors.leftMargin: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.active ? modelData.ssid + " disconnect" : modelData.ssid + " connect"
                                        color: "white"
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: networkArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (modelData.active) {
                                                wifiConnectProcess.command = ["nmcli", "connection", "down", "id", modelData.ssid];
                                            } else {
                                                wifiConnectProcess.command = ["sh", "-c", "nmcli connection up id \"$1\" || nmcli device wifi connect \"$1\"", "_", modelData.ssid];
                                            }
                                            wifiConnectProcess.running = false;
                                            wifiConnectProcess.running = true;
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                visible: screenRoot.wifiNetworks.length === 0
                                width: parent.width
                                height: wifiEmptyText.implicitHeight + 4
                                color: "transparent"

                                Text {
                                    id: wifiEmptyText
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "no wifi networks"
                                    color: "white"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: bluetoothPopup
                    visible: screenRoot.bluetoothPopupOpen
                    x: Math.max(0, Math.min(parent.width - width, (parent.width - 4 - rightModules.width) + bluetoothText.x))
                    y: 15
                    width: 360
                    height: Math.min(parent.height - y, Math.min(240, bluetoothPopupContent.implicitHeight + 8))
                    color: "black"
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                    }

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 4
                        clip: true
                        contentWidth: width
                        contentHeight: bluetoothPopupContent.implicitHeight

                        Column {
                            id: bluetoothPopupContent
                            width: parent.width
                            spacing: 4

                            Rectangle {
                                width: parent.width
                                height: bluetoothHeader.implicitHeight + 4
                                color: "transparent"

                                Text {
                                    id: bluetoothHeader
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "bluetooth"
                                    color: "white"
                                    font.pixelSize: 14
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#224466"
                            }

                            Rectangle {
                                width: parent.width
                                height: btToggleText.implicitHeight + 4
                                color: btToggleArea.containsMouse ? "#1d3557" : "transparent"

                                Text {
                                    id: btToggleText
                                    readonly property var adapter: Bluetooth.defaultAdapter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: adapter && adapter.enabled ? "disable bluetooth" : "enable bluetooth"
                                    color: "white"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: btToggleArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: !!Bluetooth.defaultAdapter
                                    onClicked: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: btScanText.implicitHeight + 4
                                color: btScanArea.containsMouse ? "#1d3557" : "transparent"

                                Text {
                                    id: btScanText
                                    readonly property var adapter: Bluetooth.defaultAdapter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: adapter && adapter.discovering ? "scan stop" : "scan start"
                                    color: "white"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: btScanArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: !!Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
                                    onClicked: Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#224466"
                            }

                            Repeater {
                                model: {
                                    const adapter = Bluetooth.defaultAdapter;
                                    if (!adapter || !adapter.enabled || !adapter.devices) {
                                        return [];
                                    }

                                    const devices = adapter.devices.values.filter(device => device && !device.blocked);
                                    devices.sort(function(a, b) {
                                        return (b.connected ? 1 : 0) - (a.connected ? 1 : 0);
                                    });
                                    return devices;
                                }

                                delegate: Rectangle {
                                    required property var modelData
                                    width: parent ? parent.width : 0
                                    height: btDeviceText.implicitHeight + 4
                                    color: btDeviceArea.containsMouse ? "#1d3557" : "transparent"

                                    Text {
                                        id: btDeviceText
                                        anchors.left: parent.left
                                        anchors.leftMargin: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: {
                                            const name = modelData.name || modelData.deviceName || modelData.address || "unknown";
                                            if (modelData.connected) {
                                                return name + " disconnect";
                                            }
                                            if (modelData.paired || modelData.trusted) {
                                                return name + " connect";
                                            }
                                            return name + " pair";
                                        }
                                        color: "white"
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: btDeviceArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (modelData.connected) {
                                                modelData.disconnect();
                                            } else if (!modelData.paired && !modelData.trusted) {
                                                modelData.pair();
                                            } else {
                                                modelData.trusted = true;
                                                modelData.connect();
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#224466"
                            }

                            Rectangle {
                                width: parent.width
                                height: btManagerText.implicitHeight + 4
                                color: btManagerArea.containsMouse ? "#1d3557" : "transparent"

                                Text {
                                    id: btManagerText
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "blueman manager"
                                    color: "white"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: btManagerArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Quickshell.execDetached(["blueman-manager"])
                                }
                            }
                        }
                    }
                }
            }

            Process {
                id: wifiProcess
                command: ["sh", "-c", "nmcli -t -f RADIO wifi; printf '\\n---\\n'; nmcli -t -f ACTIVE,SSID dev wifi list --rescan no | head -n 20"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        const parts = text.split("\n---\n");
                        const radio = (parts[0] || "").trim();
                        const listPart = parts[1] || "";
                        const lines = listPart.split("\n");
                        const networks = [];
                        let activeName = "";

                        if (radio === "disabled") {
                            screenRoot.wifiEnabled = false;
                            screenRoot.wifiStatus = "wifi off";
                        } else {
                            screenRoot.wifiEnabled = true;
                            screenRoot.wifiStatus = "wifi";
                        }

                        for (let i = 0; i < lines.length; i++) {
                            const line = lines[i].trim();
                            if (!line) {
                                continue;
                            }

                            const firstColon = line.indexOf(":");
                            if (firstColon === -1) {
                                continue;
                            }

                            const active = line.slice(0, firstColon) === "yes";
                            const ssid = line.slice(firstColon + 1).trim();

                            if (!ssid) {
                                continue;
                            }

                            networks.push({
                                active: active,
                                ssid: ssid
                            });

                            if (active) {
                                activeName = ssid;
                            }
                        }

                        if (radio !== "disabled" && activeName) {
                            screenRoot.wifiStatus = activeName;
                        }

                        screenRoot.wifiNetworks = networks;
                    }
                }
            }

            Process {
                id: wifiToggleProcess
                command: ["true"]
                running: false
                stdout: StdioCollector {
                    onStreamFinished: refreshTimer.restart()
                }
                stderr: StdioCollector {
                    onStreamFinished: refreshTimer.restart()
                }
            }

            Process {
                id: wifiConnectProcess
                command: ["true"]
                running: false
                stdout: StdioCollector {
                    onStreamFinished: refreshTimer.restart()
                }
                stderr: StdioCollector {
                    onStreamFinished: refreshTimer.restart()
                }
            }

            Timer {
                id: refreshTimer
                interval: 1500
                repeat: false
                onTriggered: screenRoot.refreshWifi()
            }

            Timer {
                interval: 15000
                running: true
                repeat: true
                onTriggered: {
                    if (!screenRoot.wifiPopupOpen) {
                        screenRoot.refreshWifi();
                    }
                }
            }
        }
    }
}
