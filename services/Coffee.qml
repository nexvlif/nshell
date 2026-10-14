pragma Singleton

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root
    property bool enabled: Config.options.coffee.enabled === true

    function toggle(): void {
        Config.set("coffee.enabled", !root.enabled);
    }
    function setEnabled(v: bool): void {
        Config.set("coffee.enabled", v);
    }
}
