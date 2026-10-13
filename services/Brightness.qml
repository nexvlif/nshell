pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real value: 0.5
    property bool ready: false
    property string device: ""
    property int maxVal: 1
    property string sysPath: ""

    function setValue(v: real): void {
        const pct = Math.round(Math.max(0, Math.min(1, v)) * 100);
        root.value = pct / 100;
        Quickshell.execDetached(["brightnessctl", "set", pct + "%"]);
    }
    function increment(step = 0.05): void {
        setValue(value + step);
    }
    function decrement(step = 0.05): void {
        setValue(value - step);
    }

    function applyRaw(t: string): void {
        const v = parseInt(t.trim(), 10);
        if (!isNaN(v) && root.maxVal > 0) {
            root.value = Math.max(0, Math.min(1, v / root.maxVal));
            root.ready = true;
        }
    }

    Component.onCompleted: detectProc.running = true

    Process {
        id: detectProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                if (parts.length >= 5) {
                    root.device = parts[0];
                    root.maxVal = parseInt(parts[4], 10) || 1;
                    root.sysPath = "/sys/class/backlight/" + root.device + "/brightness";
                    root.applyRaw(parts[2]);
                }
            }
        }
    }

    FileView {
        id: sysView
        path: root.sysPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.applyRaw(text())
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (root.sysPath !== "")
                sysView.reload();
        }
    }
}
