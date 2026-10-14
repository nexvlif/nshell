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
    property bool hasPillow: false

    readonly property string _ls: "import os,sys\n" + "d=sys.argv[1] if len(sys.argv)>1 else '.'\n" + "exts=('.png','.jpg','.jpeg','.webp','.mp4','.mkv','.webm')\n" + "dirs=[]\n" + "files=[]\n" + "try:\n" + "  es=list(os.scandir(d))\n" + "except Exception:\n" + "  es=[]\n" + "for e in es:\n" + "  n=e.name\n" + "  if n.startswith('.'):\n" + "    continue\n" + "  try:\n" + "    st=e.stat(follow_symlinks=False)\n" + "    isd=e.is_dir(follow_symlinks=False)\n" + "  except Exception:\n" + "    continue\n" + "  if isd:\n" + "    dirs.append(('d',st.st_mtime,0,e.path))\n" + "  elif n.lower().endswith(exts):\n" + "    files.append(('f',st.st_mtime,st.st_size,e.path))\n" + "dirs.sort(key=lambda r:r[3].lower())\n" + "files.sort(key=lambda r:-r[1])\n" + "for r in dirs+files:\n" + "  print(r[0]+'|'+str(r[1])+'|'+str(int(r[2]))+'|'+r[3])\n"

    readonly property string _cropPy: "import sys\n" + "from PIL import Image\n" + "a=sys.argv[1:]\n" + "im=Image.open(a[0])\n" + "im.crop((int(a[1]),int(a[2]),int(a[1])+int(a[3]),int(a[2])+int(a[4]))).save(a[0])\n"
    readonly property string _rotPy: "import sys\n" + "from PIL import Image\n" + "a=sys.argv[1:]\n" + "Image.open(a[0]).transpose(int(a[1])).save(a[0])\n"
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
        Quickshell.execDetached(["sh", "-c", "mkdir -p \"$1\"; xdg-open \"$1\"", "sh", root.dir]);
    }

    function trashFile(path: string): void {
        Quickshell.execDetached(["sh", "-c", "p=\"$1\"; if command -v gio >/dev/null 2>&1; then gio trash \"$p\" && notify-send 'Gallery' 'Moved to trash'; else rm -f \"$p\" && notify-send 'Gallery' 'Deleted'; fi", "sh", path]);
        root.refreshSoon();
    }

    function pillowMissing(): bool {
        if (!root.hasPillow)
            Quickshell.execDetached(["notify-send", "Gallery", "Needs python Pillow"]);
        return !root.hasPillow;
    }

    function copyFile(path: string): void {
        Quickshell.execDetached(["sh", "-c", "wl-copy < \"$1\" && notify-send 'Gallery' 'Copied to clipboard'", "sh", path]);
    }

    function cropFile(path: string, x: int, y: int, w: int, h: int): void {
        if (root.pillowMissing() || pyProc.running)
            return;
        pyProc.command = ["python3", "-c", root._cropPy, path, String(x), String(y), String(w), String(h)];
        pyProc.running = true;
    }

    function rotateFile(path: string, cw: bool): void {
        if (root.pillowMissing() || pyProc.running)
            return;
        pyProc.command = ["python3", "-c", root._rotPy, path, cw ? "4" : "2"];
        pyProc.running = true;
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
        command: ["python3", "-c", root._ls, root.dir]
        stdout: StdioCollector {
            onStreamFinished: root.parseList(this.text)
        }
        onExited: root.busy = false
    }

    Process {
        id: pyProc
        onExited: exitCode => {
            if (exitCode === 0)
                Quickshell.execDetached(["notify-send", "Gallery", "Saved"]);
            else
                Quickshell.execDetached(["notify-send", "Gallery", "Edit failed"]);
            root.refreshSoon();
        }
    }

    Process {
        id: pilCheck
        command: ["python3", "-c", "import PIL"]
        onExited: exitCode => root.hasPillow = exitCode === 0
    }

    Component.onCompleted: pilCheck.running = true
}
