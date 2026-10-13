pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool available: false
    property bool powered: false
    property string connectedName: ""

    readonly property string icon: "bluetooth"

    function poll(): void {
        if (!showProc.running)
            showProc.running = true;
        if (!devProc.running)
            devProc.running = true;
    }

    function setPowered(on: bool): void {
        root.powered = on;
        Quickshell.execDetached(["bluetoothctl", "power", on ? "on" : "off"]);
        refreshTimer.restart();
    }

    Component.onCompleted: poll()

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.poll()
    }
    Timer {
        id: refreshTimer
        interval: 2000
        repeat: false
        onTriggered: root.poll()
    }

    Process {
        id: showProc
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.indexOf("No default controller") >= 0) {
                    root.available = false;
                    root.powered = false;
                    return;
                }
                root.available = true;
                root.powered = text.indexOf("Powered: yes") >= 0;
            }
        }
    }

    Process {
        id: devProc
        command: ["sh", "-c", "bluetoothctl devices Connected | head -n 1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim();
                if (line.indexOf("Device ") === 0) {
                    const parts = line.split(" ");
                    root.connectedName = parts.slice(2).join(" ");
                } else {
                    root.connectedName = "";
                }
            }
        }
    }
}
