pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool wifiEnabled: true
    property bool connected: false
    property string ssid: ""
    property int signal: 0

    readonly property string icon: {
        if (!wifiEnabled || !connected)
            return "wifi_off";
        return signal >= 60 ? "wifi_2" : "wifi_1";
    }

    function poll(): void {
        proc.running = true;
    }

    function setWifiEnabled(on: bool): void {
        root.wifiEnabled = on;
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        repollTimer.restart();
    }

    Component.onCompleted: poll()

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: root.poll()
    }
    Timer {
        id: repollTimer
        interval: 2000
        repeat: false
        onTriggered: root.poll()
    }

    Process {
        id: proc
        command: ["sh", "-c", "nmcli -t -f WIFI general; nmcli -t -f IN-USE,SIGNAL,SSID device wifi list --rescan no | grep '^\\*:' || echo 'none'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length > 0)
                    root.wifiEnabled = lines[0].indexOf("enabled") === 0;
                if (lines.length > 1 && lines[1] !== "none") {
                    const parts = lines[1].split(":");
                    root.connected = true;
                    root.signal = parseInt(parts[1], 10) || 0;
                    root.ssid = parts.slice(2).join(":");
                } else {
                    root.connected = false;
                    root.signal = 0;
                    root.ssid = "";
                }
            }
        }
    }
}
