pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var items: []
    property bool busy: false
    property int rev: 0

    readonly property string home: Quickshell.env("HOME") || "/tmp"
    readonly property string shotsDir: home + "/Pictures/Screenshots"
    property string dir: home + "/Pictures"
    readonly property var places: [
        {
            name: "Screenshots",
            icon: "photo_camera",
            path: shotsDir
        },
        {
            name: "Pictures",
            icon: "photo_library",
            path: home + "/Pictures"
        },
        {
            name: "Videos",
            icon: "videocam",
            path: home + "/Videos"
        },
        {
            name: "Downloads",
            icon: "download",
            path: home + "/Downloads"
        }
    ]

    function isVideo(name: string): bool {
        return /\.(mp4|mkv|webm|mov)$/i.test(name);
    }

    function fmtSize(b: real): string {
        if (b < 1024)
            return Math.round(b) + " B";
        if (b < 1048576)
            return (b / 1024).toFixed(1) + " KB";
        if (b < 1073741824)
            return (b / 1048576).toFixed(1) + " MB";
        return (b / 1073741824).toFixed(2) + " GB";
    }

    function fmtDate(epoch: real): string {
        return Qt.formatDateTime(new Date(epoch * 1000), "dd MMM yyyy HH:mm");
    }

    function shQuote(s: string): string {
        return "'" + s.split("'").join("'\"'\"'") + "'";
    }

    function refresh(): void {
        if (listProc.running)
            return;
        root.busy = true;
        listProc.running = true;
    }

    function setDir(d: string): void {
        if (d === "")
            return;
        root.dir = d;
        root.refresh();
    }

    function goUp(): void {
        const i = root.dir.lastIndexOf("/");
        if (i > 0)
            root.setDir(root.dir.substring(0, i));
    }

    function refreshSoon(): void {
        refreshTimer.restart();
    }

    function parseList(text: string): void {
        const files = [];
        const folders = [];
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const ln = lines[i].trim();
            if (ln === "")
                continue;
            const parts = ln.split("|");
            if (parts.length < 4)
                continue;
            const kind = parts[0];
            const epoch = parseFloat(parts[1]);
            const size = parseFloat(parts[2]);
            const path = parts.slice(3).join("|");
            const name = path.substring(path.lastIndexOf("/") + 1);
            if (kind === "d") {
                folders.push({
                    path: path,
                    name: name,
                    size: 0,
                    epoch: epoch,
                    video: false,
                    folder: true
                });
                continue;
            }
            files.push({
                path: path,
                name: name,
                size: size,
                epoch: epoch,
                video: root.isVideo(name),
                folder: false
            });
        }
        folders.sort((a, b) => a.name.localeCompare(b.name));
        files.sort((a, b) => b.epoch - a.epoch);
        root.items = folders.concat(files);
        root.busy = false;
    }

    function openFile(path: string): void {
        Quickshell.execDetached(["xdg-open", path]);
    }

    function openFolder(): void {
        Quickshell.execDetached(["sh", "-c", "mkdir -p " + root.shQuote(root.dir) + "; xdg-open " + root.shQuote(root.dir)]);
    }

    function trashFile(path: string): void {
        const q = root.shQuote(path);
        Quickshell.execDetached(["sh", "-c", "if command -v gio >/dev/null 2>&1; then gio trash " + q + " && notify-send 'Gallery' 'Moved to trash'; else rm -f " + q + " && notify-send 'Gallery' 'Deleted'; fi"]);
        root.refreshSoon();
    }

    function pyGuard(): string {
        return "python3 -c \"import PIL\" 2>/dev/null || { notify-send 'Gallery' 'Needs python Pillow'; exit 1; }; ";
    }

    function copyFile(path: string): void {
        Quickshell.execDetached(["sh", "-c", "wl-copy < " + root.shQuote(path) + " && notify-send 'Gallery' 'Copied to clipboard'"]);
    }

    function cropFile(path: string, x: int, y: int, w: int, h: int): void {
        const q = root.shQuote(path);
        Quickshell.execDetached(["sh", "-c", root.pyGuard() + "python3 -c \"import sys; from PIL import Image; a=sys.argv[1:]; im=Image.open(a[0]); im.crop((int(a[1]),int(a[2]),int(a[1])+int(a[3]),int(a[2])+int(a[4]))).save(a[0])\" " + q + " " + x + " " + y + " " + w + " " + h + " && notify-send 'Gallery' 'Cropped'"]);
        root.refreshSoon();
    }

    function rotateFile(path: string, cw: bool): void {
        const q = root.shQuote(path);
        const t = cw ? 4 : 2;
        Quickshell.execDetached(["sh", "-c", root.pyGuard() + "python3 -c \"import sys; from PIL import Image; a=sys.argv[1:]; Image.open(a[0]).transpose(int(a[1])).save(a[0])\" " + q + " " + t + " && notify-send 'Gallery' 'Rotated'"]);
        root.refreshSoon();
    }

    Timer {
        id: refreshTimer
        interval: 600
        repeat: false
        onTriggered: {
            root.rev++;
            root.refresh();
        }
    }

    Process {
        id: listProc
        command: ["sh", "-c", "mkdir -p '" + root.dir + "'; find '" + root.dir + "' -maxdepth 1 -mindepth 1 ! -name '.*' \\( -type d -o -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' \\) \\) -printf '%y|%T@|%s|%p\\n' 2>/dev/null | sort -t'|' -k4"]
        stdout: StdioCollector {
            onStreamFinished: root.parseList(this.text)
        }
        onExited: root.busy = false
    }
}
