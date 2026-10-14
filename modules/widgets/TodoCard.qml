import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.ndesign
import qs.services

NRect {
    id: root
    implicitWidth: 300
    implicitHeight: 300
    fill: "bg1"
    corner: Tokens.rounding.popover
    shadow: 16

    property bool adding: false

    readonly property var rows: {
        const out = [];
        const pending = adapter.todos ?? [];
        const finished = adapter.dones ?? [];
        for (const t of pending)
            out.push({
                "text": t,
                "done": false
            });
        for (const d of finished)
            out.push({
                "text": d,
                "done": true
            });
        return out;
    }

    function addTodo(raw: string) {
        const s = raw.trim();
        if (s === "")
            return;
        const cur = Array.from(adapter.todos ?? []);
        cur.push(s);
        adapter.todos = cur;
    }
    function toggleAt(i: int) {
        const r = rows[i];
        if (!r)
            return;
        if (r.done) {
            const d = Array.from(adapter.dones ?? []);
            d.splice(d.indexOf(r.text), 1);
            adapter.dones = d;
            const t = Array.from(adapter.todos ?? []);
            t.push(r.text);
            adapter.todos = t;
        } else {
            const t = Array.from(adapter.todos ?? []);
            t.splice(t.indexOf(r.text), 1);
            adapter.todos = t;
            const d = Array.from(adapter.dones ?? []);
            d.push(r.text);
            adapter.dones = d;
        }
    }
    function removeAt(i: int) {
        const r = rows[i];
        if (!r)
            return;
        if (r.done) {
            const d = Array.from(adapter.dones ?? []);
            d.splice(d.indexOf(r.text), 1);
            adapter.dones = d;
        } else {
            const t = Array.from(adapter.todos ?? []);
            t.splice(t.indexOf(r.text), 1);
            adapter.todos = t;
        }
    }

    Timer {
        id: reloadTimer
        interval: 80
        repeat: false
        onTriggered: view.reload()
    }
    Timer {
        id: writeTimer
        interval: 120
        repeat: false
        onTriggered: view.writeAdapter()
    }
    FileView {
        id: view
        path: Quickshell.env("HOME") + "/.config/nshell/widgets-todo.json"
        watchChanges: true
        onFileChanged: reloadTimer.restart()
        onAdapterUpdated: writeTimer.restart()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.config/nshell"]);
                writeAdapter();
            }
        }
        JsonAdapter {
            id: adapter
            property list<string> todos
            property list<string> dones
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            NText {
                Layout.fillWidth: true
                kind: "title"
                semibold: true
                color: Theme.fg1
                text: "To-Do"
            }
            NIconButton {
                name: "add"
                onClicked: root.adding = !root.adding
            }
        }
        NSearchBox {
            id: box
            Layout.fillWidth: true
            visible: root.adding
            placeholder: "New task"
            onAccepted: {
                root.addTodo(box.text);
                box.text = "";
            }
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: root.rows
            delegate: RowLayout {
                required property var modelData
                required property int index
                width: ListView.view.width
                spacing: 10
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 20
                    implicitHeight: 20
                    radius: Tokens.rounding.pill
                    color: modelData.done ? Theme.active : "transparent"
                    border.width: 1
                    border.color: modelData.done ? Theme.active : Theme.fg3
                    NIcon {
                        anchors.centerIn: parent
                        visible: modelData.done
                        name: "check"
                        iconSize: 12
                        color: Theme.activeFg
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleAt(index)
                    }
                }
                NText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    kind: "small"
                    elide: Text.ElideRight
                    color: modelData.done ? Theme.fg3 : Theme.fg1
                    text: modelData.text
                }
                NIconButton {
                    Layout.alignment: Qt.AlignVCenter
                    name: "close"
                    glyphSize: 14
                    onClicked: root.removeAt(index)
                }
            }
        }
    }
}
