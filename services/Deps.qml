pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var missing: []
    property bool ready: false

    readonly property var tools: [
        ["grim", "screenshots"],
        ["wl-copy", "clipboard"],
        ["gio", "trash files"],
        ["hyprshot", "print-screen binds"],
        ["wf-recorder", "screen recording"],
        ["hyprpicker", "color picker"],
        ["brightnessctl", "brightness keys"],
        ["playerctl", "media keys"],
        ["cliphist", "clipboard history"],
        ["hyprsunset", "night light"],
        ["powerprofilesctl", "game mode power profile"],
        ["ffmpeg", "voice recorder"]
    ]

    property string _py: "import shutil\n" + "tools=['grim','wl-copy','gio','hyprshot','wf-recorder','hyprpicker','brightnessctl','playerctl','cliphist','hyprsunset','powerprofilesctl','ffmpeg']\n" + "print(' '.join([t for t in tools if shutil.which(t) is None]))\n" + "try:\n" + "  import PIL\n" + "except ImportError:\n" + "  print('python-pillow')\n"

    function refresh(): void {
        if (!proc.running) {
            root.ready = false;
            proc.command = ["python3", "-c", root._py];
            proc.running = true;
        }
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: {
                const miss = text.trim() === "" ? [] : text.trim().split(/\s+/);
                const labels = {};
                for (const t of root.tools)
                    labels[t[0]] = t[1];
                labels["python-pillow"] = "gallery image editing";
                root.missing = miss.map(m => ({
                    tool: m,
                    use: labels[m] ?? ""
                }));
                root.ready = true;
                if (miss.length > 0)
                    root.report();
            }
        }
    }

    function report(): void {
        const names = root.missing.map(m => m.tool).join(", ");
        Quickshell.execDetached(["notify-send", "nshell", "Missing tools: " + names]);
    }

    Component.onCompleted: refresh()
}
