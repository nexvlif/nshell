pragma Singleton

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root
    property bool launcherOpen: false
    property bool sessionOpen: false
    property bool nflyoutOpen: false
    property bool controlOpen: false
    property bool clipOpen: false
    property bool notifOpen: false
    property bool calendarOpen: false
    property bool screenshotOpen: false
    property bool recordingOpen: false
    property bool galleryOpen: false
    property bool fileOpen: false
    property bool settingsOpen: false
    property bool osdOpen: false
    property string osdKind: "volume"
    property var trayMenuItem: null
    property var trayMenuScreen: null
    property real trayMenuX: 0
    property real trayMenuY: 0
    property bool wallMenuOpen: false
    property real wallMenuX: 0
    property real wallMenuY: 0
    property var wallMenuScreen: null
    property bool wallEditOpen: false
    property bool wallPickerOpen: false
    property string wallMoveTarget: ""
    property bool imgPickerOpen: false
    property var imgPickerScreen: null
    property bool lockOpen: false
    property bool appsOpen: false
    property string appPage: "calc"

    readonly property var _panels: ["launcherOpen", "sessionOpen", "nflyoutOpen", "controlOpen", "clipOpen", "notifOpen", "calendarOpen", "screenshotOpen", "recordingOpen", "galleryOpen", "fileOpen", "settingsOpen", "appsOpen"]

    function _flip(prop: string): void {
        const v = !root[prop];
        closeAll();
        root[prop] = v;
    }

    function showLock(): void {
        closeAll();
        lockOpen = true;
    }
    function hideLock(): void {
        lockOpen = false;
    }

    function openWallMenu(x, y, screen): void {
        wallMenuX = x;
        wallMenuY = y;
        wallMenuScreen = screen;
        wallMenuOpen = true;
    }
    function closeWallMenu(): void {
        wallMenuOpen = false;
        wallEditOpen = false;
        wallPickerOpen = false;
        wallMoveTarget = "";
        wallMenuScreen = null;
    }

    function openTrayMenu(item, screen, x, y): void {
        trayMenuItem = item;
        trayMenuScreen = screen;
        trayMenuX = x;
        trayMenuY = y;
    }
    function closeTrayMenu(): void {
        trayMenuItem = null;
        trayMenuScreen = null;
    }

    function toggleLauncher(): void {
        _flip("launcherOpen");
    }
    function toggleSession(): void {
        _flip("sessionOpen");
    }
    function toggleNflyout(): void {
        _flip("nflyoutOpen");
    }
    function toggleControl(): void {
        _flip("controlOpen");
    }
    function toggleClipboard(): void {
        _flip("clipOpen");
    }
    function toggleCalendar(): void {
        _flip("calendarOpen");
    }
    function toggleScreenshot(): void {
        _flip("screenshotOpen");
    }
    function toggleRecording(): void {
        _flip("recordingOpen");
    }
    function toggleGallery(): void {
        _flip("galleryOpen");
    }
    function toggleSettings(): void {
        _flip("settingsOpen");
    }
    function toggleFileManager(): void {
        _flip("fileOpen");
    }
    function toggleNotif(): void {
        const v = !notifOpen;
        closeAll();
        notifOpen = v;
        if (v) {
            Notifs.clearPopup();
            Notifs.markSeen();
        }
    }
    function openApp(page: string): void {
        closeAll();
        appPage = page;
        appsOpen = true;
    }
    function toggleApps(page: string): void {
        if (appsOpen && appPage === page) {
            appsOpen = false;
            return;
        }
        closeAll();
        appPage = page;
        appsOpen = true;
    }
    function closeAll(): void {
        for (const p of root._panels)
            root[p] = false;
        closeTrayMenu();
        closeWallMenu();
    }

    Timer {
        id: osdTimer
        interval: Config.options.osd.timeout
        repeat: false
        onTriggered: root.osdOpen = false
    }

    function flashOsd(kind: string): void {
        osdKind = kind;
        osdOpen = true;
        osdTimer.restart();
    }
}
