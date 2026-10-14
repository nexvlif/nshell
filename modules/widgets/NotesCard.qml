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

    function addNote(raw: string) {
        const s = raw.trim();
        if (s === "")
            return;
        const cur = Array.from(adapter.notes ?? []);
        cur.push(s);
        adapter.notes = cur;
    }
    function removeAt(i: int) {
        const cur = Array.from(adapter.notes ?? []);
        cur.splice(i, 1);
        adapter.notes = cur;
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
        path: Quickshell.env("HOME") + "/.config/nshell/widgets-notes.json"
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
            property list<string> notes
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
                text: "Notes"
            }
        }
        NSearchBox {
            id: box
            Layout.fillWidth: true
            placeholder: "New note"
            onAccepted: {
                root.addNote(box.text);
                box.text = "";
            }
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: adapter.notes ?? []
            delegate: RowLayout {
                required property var modelData
                required property int index
                width: ListView.view.width
                spacing: 10
                NText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    kind: "small"
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    color: Theme.fg1
                    text: modelData
                }
                NIconButton {
                    Layout.alignment: Qt.AlignTop
                    name: "close"
                    glyphSize: 14
                    onClicked: root.removeAt(index)
                }
            }
        }
    }
}
