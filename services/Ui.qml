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
    property bool osdOpen: false
    property string osdKind: "volume"
    property var trayMenuItem: null
    property var trayMenuScreen: null
    property real trayMenuX: 0
    property real trayMenuY: 0

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
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        launcherOpen = !launcherOpen;
    }
    function toggleSession(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        sessionOpen = !sessionOpen;
    }
    function toggleNflyout(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        sessionOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        nflyoutOpen = !nflyoutOpen;
    }
    function toggleControl(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        notifOpen = false;
        calendarOpen = false;
        controlOpen = !controlOpen;
    }
    function toggleClipboard(): void {
        clipOpen = !clipOpen;
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
    }
    function toggleNotif(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        calendarOpen = false;
        notifOpen = !notifOpen;
        if (notifOpen) {
            Notifs.clearPopup();
            Notifs.markSeen();
        }
    }
    function toggleCalendar(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = !calendarOpen;
    }
    function closeAll(): void {
        clipOpen = false;
        closeTrayMenu();
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
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
