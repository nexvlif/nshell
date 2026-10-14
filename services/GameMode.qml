pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root
    property bool enabled: Config.options.gamemode.enabled === true
    property string prevProfile: ""

    function toggle(): void {
        Config.set("gamemode.enabled", !root.enabled);
    }
    function setEnabled(v: bool): void {
        Config.set("gamemode.enabled", v);
    }

    onEnabledChanged: {
        if (root.enabled)
            applyGame();
        else
            restoreGame();
    }

    function applyGame(): void {
        Quickshell.execDetached(["hyprctl", "keyword", "animations:enabled", "0"]);
        Quickshell.execDetached(["hyprctl", "keyword", "decoration:blur:enabled", "0"]);
        if (!profGet.running)
            profGet.running = true;
        Quickshell.execDetached(["notify-send", "nshell", "Game mode on"]);
    }

    function restoreGame(): void {
        const anim = HyprConf.ready ? HyprConf.boolean("animations:enabled", true) : true;
        const blur = HyprConf.ready ? HyprConf.boolean("decoration:blur:enabled", true) : true;
        Quickshell.execDetached(["hyprctl", "keyword", "animations:enabled", anim ? "1" : "0"]);
        Quickshell.execDetached(["hyprctl", "keyword", "decoration:blur:enabled", blur ? "1" : "0"]);
        if (root.prevProfile !== "")
            Quickshell.execDetached(["powerprofilesctl", "set", root.prevProfile]);
        root.prevProfile = "";
        Quickshell.execDetached(["notify-send", "nshell", "Game mode off"]);
    }

    Process {
        id: profGet
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                if (p !== "" && p !== "performance")
                    root.prevProfile = p;
                Quickshell.execDetached(["powerprofilesctl", "set", "performance"]);
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.prevProfile = "";
        }
    }

    Component.onCompleted: {
        if (root.enabled)
            root.applyGame();
    }
}
