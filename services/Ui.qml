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
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appsOpen = false;
        launcherOpen = !launcherOpen;
    }
    function toggleSession(): void {
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appsOpen = false;
        sessionOpen = !sessionOpen;
    }
    function toggleNflyout(): void {
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appsOpen = false;
        nflyoutOpen = !nflyoutOpen;
    }
    function toggleControl(): void {
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appsOpen = false;
        controlOpen = !controlOpen;
    }
    function toggleClipboard(): void {
        clipOpen = !clipOpen;
        appsOpen = false;
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
    }
    function toggleNotif(): void {
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appsOpen = false;
        notifOpen = !notifOpen;
        if (notifOpen) {
            Notifs.clearPopup();
            Notifs.markSeen();
        }
    }
    function toggleCalendar(): void {
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appsOpen = false;
        calendarOpen = !calendarOpen;
    }
    function toggleScreenshot(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appsOpen = false;
        screenshotOpen = !screenshotOpen;
    }
    function toggleRecording(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appsOpen = false;
        recordingOpen = !recordingOpen;
    }
    function toggleGallery(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        settingsOpen = false;
        appsOpen = false;
        galleryOpen = !galleryOpen;
    }
    function toggleSettings(): void {
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        appsOpen = false;
        settingsOpen = !settingsOpen;
    }
    function toggleFileManager(): void {
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        settingsOpen = false;
        appsOpen = false;
        fileOpen = !fileOpen;
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
        clipOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
        appPage = page;
        appsOpen = true;
    }
    function closeAll(): void {
        clipOpen = false;
        appsOpen = false;
        closeTrayMenu();
        closeWallMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        screenshotOpen = false;
        recordingOpen = false;
        galleryOpen = false;
        fileOpen = false;
        settingsOpen = false;
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
