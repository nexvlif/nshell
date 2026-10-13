pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.services

Singleton {
    id: root
    property var current: null
    onCurrentChanged: console.log("NSHELLDBG current now: " + (current ? current.summary : "null"))
    property var seenIds: ({})
    property int rev: 0
    property bool dnd: Config.options.notifications.dnd ?? false
    onDndChanged: {
        Config.set("notifications.dnd", dnd);
        if (dnd)
            clearPopup();
    }
    readonly property var items: {
        root.rev;
        return server.trackedNotifications ? server.trackedNotifications.values : [];
    }
    readonly property int unread: {
        root.rev;
        let n = 0;
        for (const t of root.items) {
            if (!root.seenIds[t.id])
                n++;
        }
        return n;
    }

    function toggleDnd(): void {
        root.dnd = !root.dnd;
    }
    function clearPopup(): void {
        popupTimer.stop();
        root.current = null;
    }
    function popupFor(n): void {
        root.current = n;
        popupTimer.interval = (n && n.expireTimeout > 0) ? n.expireTimeout : ((n && n.urgency === NotificationUrgency.Critical) ? 8000 : 5000);
        popupTimer.restart();
    }
    function markSeen(): void {
        const s = {};
        for (const t of root.items)
            s[t.id] = true;
        root.seenIds = s;
    }
    function dismiss(n): void {
        if (n) {
            if (root.current === n)
                root.current = null;
            n.dismiss();
            root.rev++;
        }
    }
    function dismissAll(): void {
        for (const t of root.items)
            t.dismiss();
        root.current = null;
        root.rev++;
    }

    Timer {
        id: popupTimer
        repeat: false
        onTriggered: root.current = null
    }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        inlineReplySupported: true
        onNotification: n => {
            console.log("NSHELLDBG notif recv: " + n.summary);
            n.tracked = true;
            root.rev++;
            if (!root.dnd)
                root.popupFor(n);
            console.log("NSHELLDBG popup current set: " + (root.current !== null));
        }
    }
}
