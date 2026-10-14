import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.ndesign
import qs.services

Scope {
    id: root
    property var imgList: []

    function scanImages(): void {
        scanProc.running = false;
        scanProc.running = true;
    }

    Process {
        id: scanProc
        command: ["sh", "-c", "find \"$HOME/Pictures\" -maxdepth 3 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' \\) 2>/dev/null | sort | head -100"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.imgList = text.trim() === "" ? [] : text.trim().split("\n");
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: Ui.imgPickerOpen && Ui.imgPickerScreen === screen
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
                    root.scanImages();
                    pickerPanel.forceActiveFocus();
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45)
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.imgPickerOpen = false
                }
            }

            NRect {
                id: pickerPanel
                focus: true
                Keys.onEscapePressed: Ui.imgPickerOpen = false
                width: 720
                implicitHeight: 500
                anchors.centerIn: parent
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 28

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        NText {
                            Layout.fillWidth: true
                            kind: "title"
                            semibold: true
                            text: "Choose image"
                        }
                        NText {
                            kind: "caption"
                            color: Theme.fg3
                            text: root.imgList.length + " images"
                        }
                        NIconButton {
                            name: "sync"
                            glyphSize: 16
                            onClicked: root.scanImages()
                        }
                        NIconButton {
                            name: "close"
                            glyphSize: 16
                            onClicked: Ui.imgPickerOpen = false
                        }
                    }
                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        visible: root.imgList.length === 0
                        kind: "body"
                        color: Theme.fg3
                        text: "No images in ~/Pictures"
                    }
                    GridView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: 224
                        cellHeight: 140
                        model: root.imgList
                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: 208
                            height: 124
                            NThumb {
                                anchors.fill: parent
                                file: modelData
                                imgRadius: Tokens.rounding.medium
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: Tokens.rounding.medium
                                color: "transparent"
                                border.width: modelData === Config.options.widgets.imagePath ? 2 : 0
                                border.color: Theme.fg1
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Config.set("widgets.imagePath", modelData);
                                    Ui.imgPickerOpen = false;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
