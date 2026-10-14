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
import qs.modules.screenshot
import qs.modules.recording
import qs.modules.gallery
import qs.modules.activewindow
import qs.modules.shortcuts
import qs.modules.notifications
import qs.modules.osd
import qs.modules.widgets
import qs.modules.wallpaper
import qs.modules.settings
import qs.modules.filemanager
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
        function toggleNotif(): void {
            Ui.toggleNotif();
        }
        function toggleLauncher(): void {
            Ui.toggleLauncher();
        }
        function toggleFiles(): void {
            Ui.toggleFileManager();
        }
        function toggleSettings(): void {
            Ui.toggleSettings();
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
    ScreenshotPanel {}
    ScreenshotSelector {}
    ScreenshotCountdown {}
    RecordingPanel {}
    GalleryPanel {}
    Shortcuts {}
    Notifications {}
    Osd {}
    Widgets {}
    ImagePicker {}
    FileManager {}
    Wallpaper {}
    Settings {}
}
