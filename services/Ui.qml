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
    property bool notifOpen: false
    property bool calendarOpen: false
    property bool osdOpen: false
    property string osdKind: "volume"
    property var trayMenuOwner: null
    property int uiRev: 0

    function toggleLauncher(): void {
        uiRev++;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        launcherOpen = !launcherOpen;
    }
    function toggleSession(): void {
        uiRev++;
        launcherOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        sessionOpen = !sessionOpen;
    }
    function toggleNflyout(): void {
        uiRev++;
        launcherOpen = false;
        sessionOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = false;
        nflyoutOpen = !nflyoutOpen;
    }
    function toggleControl(): void {
        uiRev++;
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        notifOpen = false;
        calendarOpen = false;
        controlOpen = !controlOpen;
    }
    function toggleNotif(): void {
        uiRev++;
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
        uiRev++;
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        controlOpen = false;
        notifOpen = false;
        calendarOpen = !calendarOpen;
    }
    function closeAll(): void {
        uiRev++;
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
