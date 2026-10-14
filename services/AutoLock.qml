pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

Singleton {
    id: root

    readonly property int idleMin: Config.options.lock.idleMin ?? 10

    IdleMonitor {
        enabled: root.idleMin > 0
        timeout: Math.max(60, root.idleMin * 60)
        respectInhibitors: true
        onIsIdleChanged: {
            if (isIdle && root.idleMin > 0)
                Session.lock();
        }
    }
}
