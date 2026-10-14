pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var items: []
    property bool available: true
    property bool watching: false
    property var thumbs: ({})
    property var pending: []
    readonly property string thumbDir: "/tmp/nshell-clip/"

    function refresh(): void {
        if (!listProc.running)
            listProc.running = true;
        if (!watchProc.running)
            watchProc.running = true;
    }

    function ensureWatching(): void {
        Quickshell.execDetached(["sh", "-c", "pgrep -f '[w]l-paste.*watch' >/dev/null || (wl-paste --watch cliphist store >/dev/null 2>&1 &)"]);
        watchTimer.restart();
    }

    function copy(id: int, mime: string): void {
        if (!isFinite(id))
            return;
        const cleanId = parseInt(id, 10);
        if (mime !== "" && /^[a-z]+\/[a-z0-9.+-]+$/.test(mime))
            Quickshell.execDetached(["sh", "-c", "cliphist decode " + cleanId + " | wl-copy -t '" + mime + "'"]);
        else
            Quickshell.execDetached(["sh", "-c", "cliphist decode " + cleanId + " | wl-copy"]);
    }

    function remove(id: int): void {
        Quickshell.execDetached(["cliphist", "delete", "" + id]);
        Quickshell.execDetached(["rm", "-f", thumbDir + id + ".bin"]);
        const t = Object.assign({}, root.thumbs);
        delete t[id];
        root.thumbs = t;
        refreshTimer.restart();
    }

    function wipe(): void {
        Quickshell.execDetached(["cliphist", "wipe"]);
        Quickshell.execDetached(["sh", "-c", "rm -f " + thumbDir + "*.bin"]);
        root.thumbs = ({});
        refreshTimer.restart();
    }

    function thumb(id: int): string {
        return root.thumbs[id] ? "file://" + thumbDir + id + ".bin" : "";
    }

    function mimeFor(fmt: string): string {
        const f = fmt.toLowerCase();
        if (f === "png")
            return "image/png";
        if (f === "jpeg" || f === "jpg")
            return "image/jpeg";
        if (f === "gif")
            return "image/gif";
        if (f === "bmp")
            return "image/bmp";
        if (f === "webp")
            return "image/webp";
        if (f === "svg")
            return "image/svg+xml";
        return "";
    }

    function sizeBytes(num: real, unit: string): real {
        if (unit === "KiB")
            return num * 1024;
        if (unit === "MiB")
            return num * 1048576;
        return num;
    }

    function queueThumb(id: int): void {
        if (root.thumbs[id] || root.pending.indexOf(id) >= 0)
            return;
        root.pending = [...root.pending, id];
        if (!thumbProc.running)
            nextThumb();
    }

    function nextThumb(): void {
        if (root.pending.length === 0)
            return;
        const id = root.pending[0];
        thumbProc.command = ["sh", "-c", "cliphist decode " + id + " > " + thumbDir + id + ".bin"];
        thumbProc.running = true;
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", thumbDir]);
        ensureWatching();
        refresh();
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
    Timer {
        id: watchTimer
        interval: 3000
        repeat: false
        onTriggered: root.refresh()
    }
    Timer {
        id: refreshTimer
        interval: 500
        repeat: false
        onTriggered: root.refresh()
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = true;
                if (text.indexOf("please store something") >= 0) {
                    root.items = [];
                    return;
                }
                const out = [];
                for (const line of text.split("\n")) {
                    const tab = line.indexOf("\t");
                    if (tab < 0)
                        continue;
                    const id = parseInt(line.slice(0, tab), 10);
                    if (isNaN(id))
                        continue;
                    const preview = line.slice(tab + 1);
                    const m = preview.match(/^\[\[ binary data (.+) \]\]$/);
                    if (m) {
                        const parts = m[1].split(" ");
                        const mime = parts.length >= 3 ? root.mimeFor(parts[2]) : "";
                        const bytes = parts.length >= 2 ? root.sizeBytes(parseFloat(parts[0]) || 0, parts[1]) : 0;
                        const sizeText = parts.length >= 2 ? parts[0] + " " + parts[1] : "";
                        out.push({
                            id: id,
                            preview: preview,
                            binary: true,
                            mime: mime,
                            fmt: parts.length >= 3 ? parts[2] : "",
                            dims: parts.length >= 4 ? parts[3] : "",
                            sizeText: sizeText
                        });
                        if (mime.indexOf("image/") === 0 && bytes > 0 && bytes < 8388608)
                            root.queueThumb(id);
                    } else {
                        out.push({
                            id: id,
                            preview: preview,
                            binary: false,
                            mime: "",
                            fmt: "",
                            dims: "",
                            sizeText: ""
                        });
                    }
                }
                root.items = out;
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.available = false;
        }
    }

    Process {
        id: thumbProc
        onExited: exitCode => {
            const id = root.pending[0];
            root.pending = root.pending.slice(1);
            if (exitCode === 0 && id !== undefined) {
                const t = Object.assign({}, root.thumbs);
                t[id] = true;
                root.thumbs = t;
            }
            root.nextThumb();
        }
    }

    Process {
        id: watchProc
        command: ["sh", "-c", "pgrep -f '[w]l-paste.*watch' >/dev/null && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: root.watching = text.trim() === "yes"
        }
    }
}
