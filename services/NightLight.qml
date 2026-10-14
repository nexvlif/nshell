pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root
    property bool enabled: Config.options.nightlight.enabled === true
    property int temperature: Config.options.nightlight.temperature || 4500
    property bool ownsDaemon: false

    function toggle(): void {
        root.setEnabled(!root.enabled);
    }
    function setEnabled(v: bool): void {
        Config.set("nightlight.enabled", v);
    }
    function setTemp(t: int): void {
        const c = Math.max(1000, Math.min(6500, Math.round(t)));
        Config.set("nightlight.temperature", c);
        tempTimer.restart();
    }

    onEnabledChanged: {
        if (!binCheck.running) {
            binCheck.command = ["sh", "-c", "command -v hyprsunset"];
            binCheck.running = true;
        }
    }

    function clampTemp(): int {
        return Math.max(1000, Math.min(6500, Math.round(root.temperature)));
    }

    function ensureDaemon(): void {
        if (!daemonCheck.running)
            daemonCheck.running = true;
    }

    function applyTemp(): void {
        if (!root.enabled)
            return;
        Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(root.clampTemp())]);
    }

    function turnOff(): void {
        Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"]);
        if (root.ownsDaemon) {
            root.ownsDaemon = false;
            Quickshell.execDetached(["pkill", "-x", "hyprsunset"]);
        }
    }

    Timer {
        id: tempTimer
        interval: 150
        repeat: false
        onTriggered: root.applyTemp()
    }

    Process {
        id: binCheck
        onExited: exitCode => {
            if (exitCode !== 0) {
                Quickshell.execDetached(["notify-send", "nshell", "Install hyprsunset for night light"]);
                if (root.enabled)
                    Config.set("nightlight.enabled", false);
                return;
            }
            if (root.enabled)
                root.ensureDaemon();
            else
                root.turnOff();
        }
    }

    Process {
        id: daemonCheck
        command: ["pgrep", "-x", "hyprsunset"]
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.ownsDaemon = true;
                Quickshell.execDetached(["hyprsunset"]);
                daemonWait.restart();
            } else {
                root.applyTemp();
            }
        }
    }

    Timer {
        id: daemonWait
        interval: 800
        repeat: false
        onTriggered: root.applyTemp()
    }

    Component.onCompleted: {
        if (root.enabled) {
            binCheck.command = ["sh", "-c", "command -v hyprsunset"];
            binCheck.running = true;
        }
    }
}
