pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool recording: false
    property int recElapsed: 0
    property int recDelaySec: 0
    property bool recShowCountdown: true
    property bool recCounting: false
    property int recCountdownLeft: 0

    property string mode: "area"
    property int delaySec: 0
    property bool copyClipboard: true
    property bool includeCursor: false
    property bool showCountdown: true
    property string lastFile: ""

    property bool selecting: false
    property bool counting: false
    property int countdownLeft: 0
    property string pendingCmd: ""
    property int preWait: 400

    readonly property string dir: (Quickshell.env("HOME") || "/tmp") + "/Pictures/Screenshots"

    function setMode(m: string): void {
        root.mode = m;
    }
    function setDelay(s: int): void {
        root.delaySec = s;
    }

    function stamp(): string {
        return Qt.formatDateTime(new Date(), "yyyyMMdd-HHmmss");
    }

    function recTime(): string {
        const m = Math.floor(root.recElapsed / 60);
        const s = root.recElapsed % 60;
        return (m < 10 ? "0" + m : "" + m) + ":" + (s < 10 ? "0" + s : "" + s);
    }

    function sh(cmd: string): void {
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    function notify(title: string, body: string): void {
        Quickshell.execDetached(["notify-send", title, body]);
    }

    function shotFile(): string {
        const f = root.dir + "/shot-" + root.stamp() + ".png";
        root.lastFile = f;
        return f;
    }

    function finishArgs(f: string): string {
        const copy = root.copyClipboard ? " && wl-copy < \"" + f + "\"" : "";
        return copy + " && notify-send 'Screenshot' \"" + f + "\"";
    }

    function cursorFlag(): string {
        return root.includeCursor ? "-c " : "";
    }

    function screenshot(): void {
        capture();
    }

    function capture(): void {
        if (root.mode === "full") {
            const f = root.shotFile();
            const cmd = "mkdir -p '" + root.dir + "'; grim " + root.cursorFlag() + "\"" + f + "\"" + root.finishArgs(f);
            root.runShot(cmd, 350);
        } else if (root.mode === "window") {
            const f = root.shotFile();
            const cmd = "mkdir -p '" + root.dir + "'; g=$(hyprctl -j activewindow | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"' 2>/dev/null); grim " + root.cursorFlag() + "-g \"$g\" \"" + f + "\"" + root.finishArgs(f);
            root.runShot(cmd, 350);
        } else {
            root.beginSelect();
        }
    }

    function runShot(cmd: string, hideMs: int): void {
        if (root.delaySec > 0 && root.showCountdown) {
            root.pendingCmd = cmd;
            root.preWait = hideMs;
            preTimer.restart();
        } else {
            const delay = root.delaySec > 0 ? "sleep " + root.delaySec + "; " : "";
            sh("sleep " + (hideMs / 1000) + "; " + delay + cmd);
        }
    }

    function beginSelect(): void {
        root.selecting = true;
    }

    function cancelSelect(): void {
        root.selecting = false;
    }

    function captureArea(gx: int, gy: int, w: int, h: int): void {
        root.selecting = false;
        const f = root.shotFile();
        const cmd = "mkdir -p '" + root.dir + "'; grim " + root.cursorFlag() + "-g \"" + gx + "," + gy + " " + w + "x" + h + "\" \"" + f + "\"" + root.finishArgs(f);
        root.runShot(cmd, 400);
    }

    function startCountdown(): void {
        root.countdownLeft = root.delaySec;
        root.counting = true;
    }

    function cancelCountdown(): void {
        root.counting = false;
        root.pendingCmd = "";
        root.notify("Screenshot", "Countdown cancelled");
    }

    function skipCountdown(): void {
        if (!root.counting)
            return;
        root.counting = false;
        const c = root.pendingCmd;
        root.pendingCmd = "";
        sh("sleep 0.35; " + c);
    }

    function pick(): void {
        Quickshell.execDetached(["sh", "-c",
            "c=$(hyprpicker -a 2>/dev/null); [ -n \"$c\" ] && notify-send 'Color picker' \"$c\""]);
    }

    function gallery(): void {
        Quickshell.execDetached(["sh", "-c", "mkdir -p '" + root.dir + "'; xdg-open '" + root.dir + "'"]);
    }

    function openFile(): void {
        if (root.lastFile !== "")
            Quickshell.execDetached(["sh", "-c", "xdg-open '" + root.lastFile + "' 2>/dev/null || xdg-open '" + root.dir + "'"]);
        else
            gallery();
    }

    function toggleRecord(): void {
        if (root.recording) {
            Quickshell.execDetached(["sh", "-c", "pkill -INT -x wf-recorder; notify-send 'Recording' 'Saved to " + root.dir + "'"]);
            root.recording = false;
            return;
        }
        if (root.recDelaySec > 0 && root.recShowCountdown) {
            root.startRecCountdown();
        } else if (root.recDelaySec > 0) {
            recDelayTimer.restart();
        } else {
            root.beginRecord();
        }
    }

    function beginRecord(): void {
        if (!recCheck.running)
            recCheck.running = true;
    }

    function setRecDelay(s: int): void {
        root.recDelaySec = s;
    }

    function startRecCountdown(): void {
        root.recCountdownLeft = root.recDelaySec;
        root.recCounting = true;
    }

    function cancelRecCountdown(): void {
        root.recCounting = false;
        root.notify("Screen recording", "Countdown cancelled");
    }

    function skipRecCountdown(): void {
        if (!root.recCounting)
            return;
        root.recCounting = false;
        root.beginRecord();
    }

    Timer {
        id: preTimer
        interval: root.preWait
        repeat: false
        onTriggered: root.startCountdown()
    }

    Timer {
        id: countdownTick
        interval: 1000
        running: root.counting
        repeat: true
        onTriggered: {
            root.countdownLeft--;
            if (root.countdownLeft <= 0) {
                root.counting = false;
                const c = root.pendingCmd;
                root.pendingCmd = "";
                sh("sleep 0.35; " + c);
            }
        }
    }

    Timer {
        id: recDelayTimer
        interval: root.recDelaySec * 1000
        repeat: false
        onTriggered: root.beginRecord()
    }

    Timer {
        id: recCountdownTick
        interval: 1000
        running: root.recCounting
        repeat: true
        onTriggered: {
            root.recCountdownLeft--;
            if (root.recCountdownLeft <= 0) {
                root.recCounting = false;
                root.beginRecord();
            }
        }
    }

    Timer {
        interval: 1000
        running: root.recording
        repeat: true
        onTriggered: root.recElapsed++
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
            root.recElapsed = 0;
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
