import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign
import qs.services

Scope {
    id: root

    FloatingWindow {
        id: win
        visible: Ui.fileOpen
        title: Files.dir.split("/").filter(s => s !== "").pop() || "/" + " — Files"
        minimumSize: Qt.size(760, 480)
        implicitWidth: 1000
        implicitHeight: 620
        color: Theme.bg1
        onClosed: Ui.fileOpen = false
        onVisibleChanged: {
            if (visible) {
                win.query = "";
                win.selected = null;
                searchBox.text = "";
                Files.refresh();
                body.forceActiveFocus();
            }
        }

        property string query: ""
        property var selected: null

        readonly property var filtered: Files.items.filter(f => {
            win.query;
            const q = win.query.trim().toLowerCase();
            if (q === "")
                return true;
            return f.name.toLowerCase().includes(q);
        })

        function openSelected(): void {
            let f = win.selected;
            if (!f || !win.filtered.some(x => x.path === f.path))
                f = list.currentIndex >= 0 ? win.filtered[list.currentIndex] : null;
            if (!f && win.filtered.length > 0)
                f = win.filtered[0];
            if (f)
                Files.openEntry(f);
        }

        Item {
            id: body
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: Ui.fileOpen = false
            Keys.onDownPressed: {
                list.currentIndex = Math.min(win.filtered.length - 1, list.currentIndex + 1);
                win.selected = win.filtered[list.currentIndex] ?? null;
            }
            Keys.onUpPressed: {
                list.currentIndex = Math.max(0, list.currentIndex - 1);
                win.selected = win.filtered[list.currentIndex] ?? null;
            }
            Keys.onReturnPressed: win.openSelected()
            Keys.onEnterPressed: win.openSelected()

            MouseArea {
                anchors.fill: parent
                onPressed: mouse => {
                    mouse.accepted = false;
                    body.forceActiveFocus();
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                ColumnLayout {
                    Layout.preferredWidth: 190
                    Layout.minimumWidth: 190
                    Layout.maximumWidth: 190
                    Layout.fillHeight: true
                    spacing: 2

                    NText {
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        Layout.bottomMargin: 4
                        kind: "caption"
                        color: Theme.fg3
                        text: "PLACES"
                    }
                    Repeater {
                        model: Files.places
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 44
                            radius: Tokens.rounding.large
                            color: Files.dir === modelData.path ? Theme.primaryContainer : placeHover.containsMouse ? Theme.subtleHover : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: Tokens.anim.faster
                                }
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10
                                NIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: modelData.icon
                                    filled: Files.dir === modelData.path || placeHover.containsMouse
                                    iconSize: 18
                                    color: Files.dir === modelData.path ? Theme.fg1 : Theme.fg2
                                }
                                NText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    elide: Text.ElideRight
                                    kind: "small"
                                    semibold: Files.dir === modelData.path
                                    color: Theme.fg1
                                    text: modelData.name
                                }
                            }
                            MouseArea {
                                id: placeHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Files.setDir(modelData.path)
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    NText {
                        Layout.leftMargin: 12
                        kind: "caption"
                        color: Theme.fg3
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 166
                        text: Files.dir
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        NIconButton {
                            name: "arrow_upward"
                            glyphSize: 18
                            onClicked: Files.goUp()
                        }
                        NIconButton {
                            name: "home"
                            glyphSize: 18
                            onClicked: Files.setDir(Files.home)
                        }
                        NIconButton {
                            name: "refresh"
                            glyphSize: 18
                            onClicked: Files.refresh()
                        }
                        NIconButton {
                            name: "create_new_folder"
                            glyphSize: 18
                            onClicked: Files.newFolder()
                        }
                        NIconButton {
                            name: Files.showHidden ? "visibility" : "visibility_off"
                            glyphSize: 18
                            onClicked: {
                                Files.showHidden = !Files.showHidden;
                                Files.refresh();
                            }
                        }
                        Item {
                            Layout.preferredWidth: 4
                        }
                        Repeater {
                            model: [["name", "Name"], ["date", "Date"], ["size", "Size"]]
                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool sel: Files.sortMode === modelData[0]
                                implicitWidth: Math.max(52, sortText.implicitWidth + 20)
                                implicitHeight: 32
                                radius: Tokens.rounding.pill
                                color: sel ? Theme.active : Theme.surfaceContainerHigh
                                NText {
                                    id: sortText
                                    anchors.centerIn: parent
                                    kind: "caption"
                                    semibold: sel
                                    color: sel ? Theme.activeFg : Theme.fg2
                                    text: modelData[1]
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Files.sortMode = modelData[0];
                                        Files.refresh();
                                    }
                                }
                            }
                        }
                        NSearchBox {
                            id: searchBox
                            Layout.fillWidth: true
                            placeholder: "Search in folder"
                            field.onTextChanged: win.query = text
                            onAccepted: win.openSelected()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        NText {
                            Layout.fillWidth: true
                            elide: Text.ElideMiddle
                            kind: "caption"
                            color: Theme.fg3
                            text: Files.dir
                        }
                        NText {
                            kind: "caption"
                            color: Theme.fg3
                            text: Files.busy ? "..." : Files.items.length + " items"
                        }
                    }

                    ListView {
                        id: list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 2
                        model: win.filtered
                        highlightMoveDuration: Tokens.anim.faster
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            readonly property bool sel: win.selected && win.selected.path === modelData.path
                            width: list.width
                            implicitHeight: 44
                            radius: Tokens.rounding.large
                            color: sel ? Theme.primaryContainer : (list.currentIndex === index ? Theme.surfaceContainerHigh : rowHover.containsMouse ? Theme.subtleHover : "transparent")
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10
                                NIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: modelData.icon
                                    filled: modelData.folder
                                    iconSize: 20
                                    color: sel ? Theme.primaryContainerFg : Theme.fg2
                                }
                                NText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    elide: Text.ElideRight
                                    kind: "small"
                                    semibold: modelData.folder
                                    color: sel ? Theme.primaryContainerFg : Theme.fg1
                                    text: modelData.name
                                }
                                NText {
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: !modelData.folder
                                    kind: "caption"
                                    color: sel ? Theme.primaryContainerFg : Theme.fg3
                                    text: Files.fmtSize(modelData.size)
                                }
                                NText {
                                    Layout.preferredWidth: 96
                                    Layout.alignment: Qt.AlignVCenter
                                    horizontalAlignment: Text.AlignRight
                                    elide: Text.ElideRight
                                    kind: "caption"
                                    color: sel ? Theme.primaryContainerFg : Theme.fg3
                                    text: Files.fmtDate(modelData.epoch)
                                }
                            }
                            MouseArea {
                                id: rowHover
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    list.currentIndex = index;
                                    win.selected = modelData;
                                    if (mouse.button === Qt.LeftButton && modelData.folder)
                                        Files.openEntry(modelData);
                                }
                                onDoubleClicked: {
                                    win.selected = modelData;
                                    Files.openEntry(modelData);
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        NText {
                            Layout.fillWidth: true
                            elide: Text.ElideMiddle
                            kind: "caption"
                            color: Theme.fg3
                            text: win.selected ? win.selected.path : "Double-click to open · Enter opens selection"
                        }
                        NButton {
                            visible: win.selected !== null && !win.selected.folder
                            variant: "secondary"
                            text: "Open"
                            onClicked: Files.openEntry(win.selected)
                        }
                        NButton {
                            visible: win.selected !== null
                            variant: "subtle"
                            text: "Copy path"
                            onClicked: Files.copyPath(win.selected)
                        }
                        NButton {
                            visible: win.selected !== null
                            variant: "subtle"
                            text: "Trash"
                            onClicked: {
                                Files.trashEntry(win.selected);
                                win.selected = null;
                            }
                        }
                    }
                }
            }
        }
    }
}
