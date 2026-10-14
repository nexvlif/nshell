pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool recording: false
    readonly property string dir: (Quickshell.env("HOME") || "/tmp") + "/Pictures/Screenshots"

    function stamp(): string {
        return Qt.formatDateTime(new Date(), "yyyyMMdd-HHmmss");
    }

    function screenshot(): void {
        Quickshell.execDetached(["sh", "-c",
            "mkdir -p '" + root.dir + "'; f='" + root.dir + "/shot-" + root.stamp() + ".png'; " +
            "g=$(slurp 2>/dev/null) || exit 0; " +
            "grim -g \"$g\" \"$f\" && wl-copy < \"$f\" && notify-send 'Screenshot' \"$f\""]);
    }

    function pick(): void {
        Quickshell.execDetached(["sh", "-c",
            "c=$(hyprpicker -a 2>/dev/null); [ -n \"$c\" ] && notify-send 'Color picker' \"$c\""]);
    }

    function gallery(): void {
        Quickshell.execDetached(["sh", "-c", "mkdir -p '" + root.dir + "'; xdg-open '" + root.dir + "'"]);
    }

    function toggleRecord(): void {
        if (root.recording) {
            Quickshell.execDetached(["sh", "-c", "pkill -INT -x wf-recorder; notify-send 'Recording' 'Saved to " + root.dir + "'"]);
            root.recording = false;
            return;
        }
        if (!recCheck.running)
            recCheck.running = true;
    }

    Process {
        id: recCheck
        command: ["sh", "-c", "command -v wf-recorder"]
        onExited: exitCode => {
            if (exitCode !== 0) {
                Quickshell.execDetached(["notify-send", "nshell", "Install wf-recorder for screen recording"]);
                return;
            }
            const f = root.dir + "/rec-" + root.stamp() + ".mp4";
            Quickshell.execDetached(["sh", "-c", "mkdir -p '" + root.dir + "'; wf-recorder -f '" + f + "'"]);
            root.recording = true;
            Quickshell.execDetached(["notify-send", "Recording", "Saving to " + f]);
        }
    }

    Process {
        id: recPoll
        command: ["pgrep", "-x", "wf-recorder"]
        onExited: exitCode => {
            if (root.recording && exitCode !== 0)
                root.recording = false;
        }
    }
    Timer {
        interval: 5000
        running: root.recording
        repeat: true
        onTriggered: {
            if (!recPoll.running)
                recPoll.running = true;
        }
    }
}
