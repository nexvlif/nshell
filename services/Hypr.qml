pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root
    readonly property bool available: Hyprland.eventSocketPath !== ""
    property int winRevision: 0

    function dispatch(cmd: string): void {
        Hyprland.dispatch(cmd);
    }
    function workspaceById(id: int): void {
        const ws = Hyprland.workspaces.values.find(w => w.id === id);
        if (ws)
            ws.activate();
    }

    Connections {
        function onRawEvent(event: HyprlandEvent): void {
            const n = event.name;
            if (["openwindow", "closewindow", "movewindow", "moveworkspace", "workspace", "workspacev2", "focusedmon", "activespecial", "changefloatingmode", "fullscreen", "minimize", "pin"].includes(n)) {
                if (Hyprland.refreshToplevels)
                    Hyprland.refreshToplevels();
                if (Hyprland.refreshWorkspaces)
                    Hyprland.refreshWorkspaces();
                if (Hyprland.refreshMonitors)
                    Hyprland.refreshMonitors();
                root.winRevision++;
            }
        }
        target: Hyprland
    }

    Process {
        id: blurRule
        command: ["hyprctl", "keyword", "layerrule", "blur, match:namespace quickshell"]
    }
    Component.onCompleted: {
        if (available)
            blurRule.running = true;
    }
}
