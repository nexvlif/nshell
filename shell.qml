//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import qs.modules.bar
import qs.modules.launcher
import qs.modules.session
import qs.modules.shortcuts
import qs.modules.notifications
import qs.modules.osd
import qs.services

ShellRoot {
    id: root

    property var _cfg: Config

    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/FluentSystemIcons-Regular.ttf")
    }
    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/FluentSystemIcons-Filled.ttf")
    }

    Bar {}
    Launcher {}
    SessionMenu {}
    Shortcuts {}
    Notifications {}
    Osd {}
}
