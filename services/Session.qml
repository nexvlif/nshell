pragma Singleton

import QtQuick
import Quickshell

// Aksi sesi: dipakai palette + menu sesi.
Singleton {
    id: root

    function lock(): void {
        Quickshell.execDetached(["loginctl", "lock-session"]);
    }
    function logout(): void {
        Quickshell.execDetached(["sh", "-c", "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"]);
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
