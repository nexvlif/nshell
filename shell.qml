//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.launcher
import qs.modules.session
import qs.modules.nflyout
import qs.modules.controlcenter
import qs.modules.clipboard
import qs.modules.calendar
import qs.modules.activewindow
import qs.modules.shortcuts
import qs.modules.notifications
import qs.modules.osd
import qs.services

ShellRoot {
    id: root

    property var _cfg: Config

    IpcHandler {
        target: "nshell"

        function toggleClipboard(): void {
            Ui.toggleClipboard();
        }
        function toggleControl(): void {
            Ui.toggleControl();
        }
    }

    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/MaterialSymbolsLite.ttf")
    }
    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/Roboto-400.ttf")
    }
    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/Roboto-500.ttf")
    }
    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/Roboto-700.ttf")
    }
    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/RobotoMono-400.ttf")
    }
    FontLoader {
        source: Qt.resolvedUrl("assets/fonts/RobotoMono-500.ttf")
    }

    Bar {}
    Launcher {}
    SessionMenu {}
    NFlyout {}
    ControlCenter {}
    ClipPanel {}
    Calendar {}
    Shortcuts {}
    Notifications {}
    Osd {}
}
