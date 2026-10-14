pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.services

Singleton {
    id: root
    property var current: null
    property var queue: []
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
        root.queue = [];
        root.current = null;
    }
    function popupFor(n): void {
        root.current = n;
        popupTimer.interval = (n && n.expireTimeout > 0) ? n.expireTimeout : ((n && n.urgency === NotificationUrgency.Critical) ? 8000 : 5000);
        popupTimer.restart();
    }
    function enqueue(n): void {
        if (root.current === null && root.queue.length === 0) {
            popupFor(n);
            return;
        }
        if (n === root.current)
            return;
        const q = root.queue.slice();
        if (!q.includes(n))
            q.push(n);
        root.queue = q;
    }
    function dequeue(): void {
        const alive = root.queue.filter(x => x !== root.current && root.items.includes(x));
        const next = alive.length > 0 ? alive[0] : null;
        root.queue = alive.slice(1);
        if (next)
            popupFor(next);
        else
            root.current = null;
    }
    function markSeen(): void {
        const s = {};
        for (const t of root.items)
            s[t.id] = true;
        root.seenIds = s;
    }
    function dismiss(n): void {
        if (!n)
            return;
        root.queue = root.queue.filter(x => x !== n);
        if (root.current === n) {
            popupTimer.stop();
            n.dismiss();
            dequeue();
        } else {
            n.dismiss();
        }
        root.rev++;
    }
    function dismissAll(): void {
        for (const t of root.items)
            t.dismiss();
        root.queue = [];
        root.current = null;
        root.rev++;
    }

    Timer {
        id: popupTimer
        repeat: false
        onTriggered: root.dequeue()
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
            n.tracked = true;
            root.rev++;
            if (!root.dnd)
                root.enqueue(n);
        }
    }
}
