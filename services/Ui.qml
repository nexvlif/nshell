pragma Singleton

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root
    property bool launcherOpen: false
    property bool sessionOpen: false
    property bool nflyoutOpen: false
    property bool notifOpen: false
    property bool calendarOpen: false
    property bool osdOpen: false
    property string osdKind: "volume"

    function toggleLauncher(): void {
        sessionOpen = false;
        nflyoutOpen = false;
        notifOpen = false;
        calendarOpen = false;
        launcherOpen = !launcherOpen;
    }
    function toggleSession(): void {
        launcherOpen = false;
        nflyoutOpen = false;
        notifOpen = false;
        calendarOpen = false;
        sessionOpen = !sessionOpen;
    }
    function toggleNflyout(): void {
        launcherOpen = false;
        sessionOpen = false;
        notifOpen = false;
        calendarOpen = false;
        nflyoutOpen = !nflyoutOpen;
    }
    function toggleNotif(): void {
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        calendarOpen = false;
        notifOpen = !notifOpen;
        if (notifOpen) {
            Notifs.clearPopup();
            Notifs.markSeen();
        }
    }
    function toggleCalendar(): void {
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
        notifOpen = false;
        calendarOpen = !calendarOpen;
    }
    function closeAll(): void {
        launcherOpen = false;
        sessionOpen = false;
        nflyoutOpen = false;
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
