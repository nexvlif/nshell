pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real cpu: 0
    property real mem: 0
    property real disk: 0
    property bool ready: false
    property var prev: null

    function refresh(): void {
        cpuProc.running = true;
        memProc.running = true;
        diskProc.running = true;
    }

    function parseCpu(t: string): void {
        const parts = t.trim().split(/\s+/).slice(1).map(Number);
        if (parts.length < 8 || parts.some(isNaN))
            return;
        const idle = parts[3] + parts[4];
        let total = 0;
        for (const v of parts)
            total += v;
        if (root.prev) {
            const dt = total - root.prev.total;
            const di = idle - root.prev.idle;
            if (dt > 0)
                root.cpu = Math.max(0, Math.min(1, 1 - di / dt));
        }
        root.prev = {
            total: total,
            idle: idle
        };
        root.ready = true;
    }

    function parseMem(t: string): void {
        let total = 0, avail = 0;
        for (const line of t.split("\n")) {
            const m = line.match(/^(MemTotal|MemAvailable):\s+(\d+)/);
            if (m) {
                if (m[1] === "MemTotal")
                    total = parseInt(m[2], 10);
                else
                    avail = parseInt(m[2], 10);
            }
        }
        if (total > 0)
            root.mem = Math.max(0, Math.min(1, 1 - avail / total));
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: root.parseCpu(text)
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "grep -E '^(MemTotal|MemAvailable):' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: root.parseMem(text)
        }
    }

    Process {
        id: diskProc
        command: ["sh", "-c", "df / | tail -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const p of text.trim().split(/\s+/)) {
                    if (p.endsWith("%")) {
                        const v = parseInt(p.slice(0, -1), 10);
                        if (!isNaN(v))
                            root.disk = Math.max(0, Math.min(1, v / 100));
                        break;
                    }
                }
            }
        }
    }
}
