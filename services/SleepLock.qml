pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root
    property bool armed: true
    property bool hasTools: false
    property bool sleepPending: false

    function sessionPath(): string {
        const sid = Quickshell.env("XDG_SESSION_ID") || "";
        if (sid === "")
            return "";
        let out = "";
        for (let i = 0; i < sid.length; ++i) {
            const c = sid[i];
            const ok = (c >= "A" && c <= "Z") || (c >= "a" && c <= "z") || (c >= "0" && c <= "9") || c === "_";
            if (!ok || (i === 0 && c >= "0" && c <= "9"))
                out += "_" + sid.charCodeAt(i).toString(16);
            else
                out += c;
        }
        return "/org/freedesktop/login1/session/" + out;
    }

    function handleLine(line: string): void {
        if (line.indexOf("member=PrepareForSleep") >= 0) {
            root.sleepPending = true;
            return;
        }
        if (root.sleepPending && line.indexOf("boolean") >= 0) {
            root.sleepPending = false;
            if (line.indexOf("boolean true") >= 0) {
                Session.lock();
                root.armed = false;
            } else {
                root.armed = true;
            }
            return;
        }
        if (line.indexOf("member=Lock") >= 0) {
            const p = root.sessionPath();
            if (p === "" || line.indexOf("path=" + p) >= 0)
                Session.lock();
        }
    }

    function upkeep(): void {
        if (root.armed && root.hasTools && !inhibitProc.running) {
            inhibitProc.running = true;
        }
        if (root.hasTools && !dbusProc.running)
            dbusProc.running = true;
    }

    Timer {
        id: upkeepTimer
        interval: 2000
        repeat: false
        onTriggered: root.upkeep()
    }

    Process {
        id: binCheck
        command: ["sh", "-c", "command -v systemd-inhibit && command -v dbus-monitor"]
        onExited: exitCode => {
            root.hasTools = exitCode === 0;
            if (exitCode !== 0)
                Quickshell.execDetached(["notify-send", "nshell", "Sleep lock unavailable (needs systemd-inhibit + dbus-monitor)"]);
            else
                root.upkeep();
        }
    }

    Process {
        id: inhibitProc
        command: ["systemd-inhibit", "--what=sleep", "--who=nshell", "--why=lock before suspend", "--mode=delay", "sleep", "infinity"]
        onExited: {
            if (root.armed && root.hasTools)
                upkeepTimer.restart();
        }
    }

    Process {
        id: dbusProc
        command: ["dbus-monitor", "--system", "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'", "type='signal',interface='org.freedesktop.login1.Session',member='Lock'"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.handleLine(data)
        }
        onExited: {
            if (root.hasTools)
                upkeepTimer.restart();
        }
    }

    Component.onCompleted: {
        if (!binCheck.running)
            binCheck.running = true;
    }
}
