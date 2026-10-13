pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    property bool launcherOpen: false

    function toggleLauncher(): void {
        launcherOpen = !launcherOpen;
    }
    function closeAll(): void {
        launcherOpen = false;
    }
}
