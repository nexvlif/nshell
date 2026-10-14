pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var items: []
    property bool busy: false
    property string dir: (Quickshell.env("HOME") || "/tmp")
    property bool showHidden: false
    property string sortMode: "name"

    readonly property string home: Quickshell.env("HOME") || "/tmp"
    readonly property var places: [
        {
            name: "Home",
            icon: "home",
            path: home
        },
        {
            name: "Documents",
            icon: "description",
            path: home + "/Documents"
        },
        {
            name: "Downloads",
            icon: "download",
            path: home + "/Downloads"
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
            name: "Music",
            icon: "music_note",
            path: home + "/Music"
        },
        {
            name: "System",
            icon: "computer",
            path: "/"
        }
    ]

    property string _py: "import os,sys\n" + "d=sys.argv[1] if len(sys.argv)>1 else '.'\n" + "hid=len(sys.argv)>2 and sys.argv[2]=='1'\n" + "sort=sys.argv[3] if len(sys.argv)>3 else 'name'\n" + "dirs=[]\n" + "files=[]\n" + "try:\n" + "  es=list(os.scandir(d))\n" + "except Exception:\n" + "  es=[]\n" + "for e in es:\n" + "  n=e.name\n" + "  if not hid and n.startswith('.'):\n" + "    continue\n" + "  try:\n" + "    st=e.stat(follow_symlinks=False)\n" + "    isd=e.is_dir(follow_symlinks=False)\n" + "  except Exception:\n" + "    continue\n" + "  r=('d' if isd else 'f',st.st_mtime,0 if isd else st.st_size,e.path)\n" + "  (dirs if isd else files).append(r)\n" + "if sort=='date':\n" + "  dirs.sort(key=lambda r:-r[1])\n" + "  files.sort(key=lambda r:-r[1])\n" + "elif sort=='size':\n" + "  dirs.sort(key=lambda r:r[3].lower())\n" + "  files.sort(key=lambda r:-r[2])\n" + "else:\n" + "  dirs.sort(key=lambda r:r[3].lower())\n" + "  files.sort(key=lambda r:r[3].lower())\n" + "for r in dirs+files:\n" + "  print(r[0]+'|'+str(r[1])+'|'+str(int(r[2]))+'|'+r[3])\n"

    function iconFor(name: string, folder: bool): string {
        if (folder)
            return "folder";
        if (/\.(png|jpe?g|webp|bmp|gif|svg|ico|avif)$/i.test(name))
            return "image";
        if (/\.(mp4|mkv|webm|mov|avi)$/i.test(name))
            return "videocam";
        if (/\.(mp3|flac|wav|ogg|opus|m4a)$/i.test(name))
            return "music_note";
        if (/\.pdf$/i.test(name))
            return "picture_as_pdf";
        if (/\.(zip|tar|gz|bz2|xz|7z|rar)$/i.test(name))
            return "archive";
        return "description";
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
        return Qt.formatDateTime(new Date(epoch * 1000), "dd MMM HH:mm");
    }

    function refresh(): void {
        if (listProc.running)
            return;
        root.busy = true;
        listProc.running = true;
    }

    function setDir(d: string): void {
        if (d === "" || d === root.dir)
            return;
        root.dir = d;
        root.refresh();
    }

    function goUp(): void {
        const i = root.dir.lastIndexOf("/");
        if (i > 0)
            root.setDir(root.dir.substring(0, i));
        else if (root.dir !== "/")
            root.setDir("/");
    }

    function openEntry(item: var): void {
        if (!item)
            return;
        if (item.folder)
            root.setDir(item.path);
        else
            Quickshell.execDetached(["xdg-open", item.path]);
    }

    function shQuote(s: string): string {
        return "'" + s.split("'").join("'\"'\"'") + "'";
    }

    function newFolder(): void {
        const cmd = "d=" + shQuote(root.dir) + "; n='New folder'; i=1; while [ -e \"$d/$n\" ]; do i=$((i+1)); n=\"New folder $i\"; done; mkdir -p \"$d/$n\"";
        Quickshell.execDetached(["sh", "-c", cmd]);
        refreshTimer.restart();
    }

    function trashEntry(item: var): void {
        if (!item)
            return;
        const safe = shQuote(item.path);
        Quickshell.execDetached(["sh", "-c", "if command -v gio >/dev/null 2>&1; then gio trash " + safe + " && notify-send 'Files' 'Moved to trash'; else notify-send 'Files' 'Install gio to trash files'; fi"]);
        refreshTimer.restart();
    }

    function copyPath(item: var): void {
        if (!item)
            return;
        Quickshell.execDetached(["sh", "-c", "printf '%s' " + shQuote(item.path) + " | wl-copy && notify-send 'Files' 'Path copied'"]);
    }

    Timer {
        id: refreshTimer
        interval: 600
        repeat: false
        onTriggered: root.refresh()
    }

    Process {
        id: listProc
        command: ["python3", "-c", root._py, root.dir, root.showHidden ? "1" : "0", root.sortMode]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const ln of text.split("\n")) {
                    const t = ln.trim();
                    if (t === "")
                        continue;
                    const parts = t.split("|");
                    if (parts.length < 4)
                        continue;
                    const path = parts.slice(3).join("|");
                    const nm = path.substring(path.lastIndexOf("/") + 1);
                    out.push({
                        path: path,
                        name: nm,
                        size: parseFloat(parts[2]),
                        epoch: parseFloat(parts[1]),
                        folder: parts[0] === "d",
                        icon: root.iconFor(nm, parts[0] === "d")
                    });
                }
                root.items = out;
                root.busy = false;
            }
        }
        onExited: root.busy = false
    }
}
