import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services

Scope {
    id: root

    GlobalShortcut {
        appid: "nshell"
        name: "launcherToggle"
        description: "Toggle command palette"
        property bool armed: false
        onPressed: armed = true
        onReleased: {
            if (armed) {
                armed = false;
                Ui.toggleLauncher();
            }
        }
    }

    GlobalShortcut {
        appid: "nshell"
        name: "sessionToggle"
        description: "Toggle session menu"
        onPressed: Ui.toggleSession()
    }
}
