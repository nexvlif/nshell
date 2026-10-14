import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ndesign
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Ui.clipOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            onVisibleChanged: {
                if (visible) {
                    query = "";
                    box.field.text = "";
                    clipList.currentIndex = 0;
                    Clipboard.refresh();
                    box.field.forceActiveFocus();
                }
            }

            property string query: ""
            readonly property var filtered: {
                const q = win.query.toLowerCase().trim();
                if (q === "")
                    return Clipboard.items;
                return Clipboard.items.filter(i => i.preview.toLowerCase().includes(q));
            }

            function copyAt(index: int): void {
                if (index < 0 || index >= win.filtered.length)
                    return;
                const item = win.filtered[index];
                Clipboard.copy(item.id, item.mime);
                Ui.closeAll();
            }

            function removeAt(index: int): void {
                if (index < 0 || index >= win.filtered.length)
                    return;
                Clipboard.remove(win.filtered[index].id);
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.overlay
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.closeAll()
                }
            }

            NRect {
                width: 640
                height: 480
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Math.round(parent.height * 0.18)
                corner: Tokens.rounding.xlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: 28

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
                            text: "Clipboard"
                        }
                        NButton {
                            variant: "subtle"
                            text: "Clear all"
                            onClicked: Clipboard.wipe()
                        }
                        NIconButton {
                            name: "close"
                            glyphSize: 14
                            onClicked: Ui.closeAll()
                        }
                    }

                    NSearchBox {
                        id: box
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        placeholder: "Search clipboard"
                        field.onTextChanged: {
                            win.query = field.text;
                            clipList.currentIndex = 0;
                        }
                        field.Keys.onDownPressed: clipList.incrementCurrentIndex()
                        field.Keys.onUpPressed: clipList.decrementCurrentIndex()
                        field.Keys.onReturnPressed: win.copyAt(clipList.currentIndex)
                        field.Keys.onEnterPressed: win.copyAt(clipList.currentIndex)
                        field.Keys.onDeletePressed: win.removeAt(clipList.currentIndex)
                        field.Keys.onEscapePressed: Ui.closeAll()
                    }

                    ListView {
                        id: clipList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        visible: Clipboard.available && win.filtered.length > 0
                        model: win.filtered
                        highlightMoveDuration: Tokens.anim.faster
                        delegate: NRect {
                            required property var modelData
                            required property int index
                            width: ListView.view.width
                            implicitHeight: 60
                            corner: Tokens.rounding.medium
                            fill: clipList.currentIndex === index ? "brandSubtle" : "bg2"
                            stroke: "none"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 10
                                z: 1
                                NRoundedImage {
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: modelData.binary && Clipboard.thumb(modelData.id) !== ""
                                    implicitWidth: 44
                                    implicitHeight: 44
                                    source: modelData.binary ? Clipboard.thumb(modelData.id) : ""
                                    imgRadius: Tokens.rounding.small
                                }
                                NIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: !(modelData.binary && Clipboard.thumb(modelData.id) !== "")
                                    name: modelData.binary ? "image" : "content_paste"
                                    iconSize: 22
                                    color: Theme.fg3
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 0
                                    NText {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        maximumLineCount: modelData.binary ? 1 : 2
                                        wrapMode: Text.WordWrap
                                        kind: "small"
                                        text: modelData.binary ? (modelData.fmt.toUpperCase() + " image") : modelData.preview
                                    }
                                    NText {
                                        Layout.fillWidth: true
                                        visible: modelData.binary
                                        elide: Text.ElideRight
                                        kind: "caption"
                                        color: Theme.fg3
                                        text: [modelData.sizeText, modelData.dims].filter(s => s !== "").join(" · ")
                                    }
                                }
                                NIconButton {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: "close"
                                    glyphSize: 12
                                    onClicked: Clipboard.remove(modelData.id)
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                z: 0
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: clipList.currentIndex = index
                                onClicked: win.copyAt(index)
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: !Clipboard.available
                        spacing: 8
                        Item {
                            Layout.fillHeight: true
                        }
                        NIcon {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            name: "content_paste"
                            iconSize: 40
                            color: Theme.fg3
                        }
                        NText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            kind: "body"
                            color: Theme.fg3
                            text: "cliphist is not available"
                        }
                        Item {
                            Layout.fillHeight: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: Clipboard.available && win.filtered.length === 0
                        spacing: 8
                        Item {
                            Layout.fillHeight: true
                        }
                        NIcon {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            name: "content_paste"
                            iconSize: 40
                            color: Theme.fg3
                        }
                        NText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            kind: "body"
                            color: Theme.fg3
                            text: win.query !== "" ? "No matches" : "No history yet"
                        }
                        NText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            visible: win.query === "" && !Clipboard.watching
                            kind: "caption"
                            color: Theme.fg3
                            text: "Run: wl-paste --watch cliphist store"
                        }
                        NButton {
                            Layout.alignment: Qt.AlignHCenter
                            visible: win.query === "" && !Clipboard.watching
                            variant: "secondary"
                            text: "Start watcher"
                            onClicked: Clipboard.ensureWatching()
                        }
                        Item {
                            Layout.fillHeight: true
                        }
                    }

                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        kind: "caption"
                        color: Theme.fg3
                        text: "↑↓ navigate · ↵ copy · del delete · esc close"
                    }
                }
            }
        }
    }
}
