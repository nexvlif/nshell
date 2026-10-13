pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    property bool launcherOpen: false
    property bool sessionOpen: false

    function toggleLauncher(): void {
        sessionOpen = false;
        launcherOpen = !launcherOpen;
    }
    function toggleSession(): void {
        launcherOpen = false;
        sessionOpen = !sessionOpen;
    }
    function closeAll(): void {
        launcherOpen = false;
        sessionOpen = false;
    }
}
