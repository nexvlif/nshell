//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import qs.modules.bar
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.osd
import qs.services

ShellRoot {
    id: root

    // Paksa Config load duluan biar ready sebelum modul baca options.
    property var _cfg: Config

    // Font ikon resmi Microsoft (FluentSystemIcons, MIT) — dipakai NIcon.
    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/FluentSystemIcons-Regular.ttf")
    }
    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/FluentSystemIcons-Filled.ttf")
    }

    Bar {}
    Launcher {}
    Notifications {}
    Osd {}
}
