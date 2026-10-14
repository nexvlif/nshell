pragma Singleton

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root

    function lock(): void {
        Ui.showLock();
    }
    function logout(): void {
        Quickshell.execDetached(["sh", "-c", "hyprctl dispatch exit 2>/dev/null || loginctl terminate-session"]);
    }
    function suspend(): void {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }
    function reboot(): void {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }
    function poweroff(): void {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }
}
