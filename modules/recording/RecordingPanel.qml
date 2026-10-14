import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ndesign
import qs.services

Scope {
    id: root

    readonly property list<int> delays: [0, 3, 5, 10]

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Ui.recordingOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            property string pos: Config.options.bar.position
            readonly property var barM: Config.options.bar.margins[pos] ?? Config.options.bar.margins["bottom"]
            readonly property int vClearSafe: (pos === "top" || pos === "bottom") ? (Config.options.bar.height + barM.top + barM.bottom + 12) : 12
            readonly property int hClearSafe: (pos === "left" || pos === "right") ? (Config.options.bar.height + barM.left + barM.right + 12) : 12
            readonly property bool vertical: pos === "left" || pos === "right"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            onVisibleChanged: {
                if (visible)
                    panel.forceActiveFocus();
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.closeAll()
                }
            }

            NRect {
                id: panel
                focus: true
                Keys.onEscapePressed: Ui.closeAll()
                width: 400
                height: panelCol.implicitHeight + 40
                x: vertical ? (pos === "left" ? win.hClearSafe : win.width - width - win.hClearSafe) : (win.width - width) / 2
                y: vertical ? (win.height - height) / 2 : (pos === "top" ? win.vClearSafe : win.height - height - win.vClearSafe)
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 16

                opacity: Ui.recordingOpen ? 1 : 0
                scale: Ui.recordingOpen ? 1 : 0.97
                transformOrigin: Item.Bottom
                Behavior on opacity {
                    NumberAnimation {
                        duration: Tokens.anim.fast
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Tokens.anim.fast
                        easing.type: Easing.OutCubic
                    }
                }

                ColumnLayout {
                    id: panelCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        Rectangle {
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44
                            Layout.alignment: Qt.AlignVCenter
                            radius: Tokens.rounding.large
                            color: Capture.recording ? Theme.errorContainer : Theme.bg2
                            NIcon {
                                anchors.centerIn: parent
                                name: Capture.recording ? "stop_circle" : "videocam"
                                filled: true
                                iconSize: 22
                                color: Capture.recording ? Theme.error : Theme.fg1
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0
                            NText {
                                kind: "title"
                                semibold: true
                                text: "Screen recording"
                            }
                            NText {
                                kind: "caption"
                                color: Theme.fg3
                                elide: Text.ElideMiddle
                                Layout.maximumWidth: 230
                                text: Capture.dir
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 96
                        radius: Tokens.rounding.large
                        color: Theme.bg2
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8
                                Rectangle {
                                    Layout.alignment: Qt.AlignVCenter
                                    width: 10
                                    height: 10
                                    radius: 5
                                    visible: Capture.recording
                                    color: Theme.error
                                    SequentialAnimation on opacity {
                                        running: Capture.recording
                                        loops: Animation.Infinite
                                        NumberAnimation {
                                            to: 0.3
                                            duration: 600
                                        }
                                        NumberAnimation {
                                            to: 1.0
                                            duration: 600
                                        }
                                    }
                                }
                                NText {
                                    Layout.alignment: Qt.AlignVCenter
                                    kind: "subtitle"
                                    semibold: true
                                    font.family: Theme.fontMono
                                    color: Capture.recording ? Theme.error : Theme.fg1
                                    text: Capture.recording ? Capture.recTime() : "00:00"
                                }
                            }
                            NText {
                                Layout.alignment: Qt.AlignHCenter
                                kind: "caption"
                                color: Theme.fg3
                                text: Capture.recording ? "Recording in progress" : "Ready  •  MP4  •  wf-recorder"
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        NText {
                            Layout.fillWidth: true
                            kind: "caption"
                            color: Theme.fg3
                            text: "DELAY"
                        }
                        NText {
                            kind: "caption"
                            color: Theme.fg2
                            text: Capture.recDelaySec === 0 ? "Instant" : Capture.recDelaySec + "s"
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.pill
                        color: Theme.bg2
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 2
                            Repeater {
                                model: root.delays
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: Tokens.rounding.pill
                                    color: Capture.recDelaySec === modelData ? Theme.primary : "transparent"
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Tokens.anim.faster
                                        }
                                    }
                                    NText {
                                        anchors.centerIn: parent
                                        kind: "small"
                                        semibold: Capture.recDelaySec === parent.modelData
                                        color: Capture.recDelaySec === parent.modelData ? Theme.primaryFg : Theme.fg2
                                        text: parent.modelData === 0 ? "0s" : parent.modelData + "s"
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Capture.setRecDelay(modelData)
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        opacity: Capture.recDelaySec > 0 ? 1 : 0.45
                        NIcon {
                            name: "timer"
                            iconSize: 18
                            color: Theme.fg2
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            NText {
                                kind: "small"
                                semibold: true
                                text: "Show countdown"
                            }
                            NText {
                                kind: "caption"
                                color: Theme.fg3
                                text: "Fullscreen timer before recording"
                            }
                        }
                        NSwitch {
                            checked: Capture.recShowCountdown
                            onClicked: Capture.recShowCountdown = !Capture.recShowCountdown
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        NIcon {
                            name: "folder"
                            iconSize: 18
                            color: Theme.fg2
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            NText {
                                kind: "small"
                                semibold: true
                                text: "Save location"
                            }
                            NText {
                                kind: "caption"
                                color: Theme.fg3
                                elide: Text.ElideMiddle
                                Layout.maximumWidth: 220
                                text: Capture.dir
                            }
                        }
                        NIconButton {
                            name: "open_in_new"
                            glyphSize: 16
                            onClicked: Capture.gallery()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        NButton {
                            variant: "secondary"
                            icon: "photo_library"
                            text: "Files"
                            onClicked: {
                                Gallery.setDir(Gallery.shotsDir);
                                Ui.toggleGallery();
                            }
                        }
                        NButton {
                            Layout.fillWidth: true
                            primary: true
                            icon: Capture.recording ? "stop" : "fiber_manual_record"
                            text: Capture.recording ? "Stop  •  " + Capture.recTime() : Capture.recDelaySec > 0 ? "Start in " + Capture.recDelaySec + "s" : "Start recording"
                            onClicked: {
                                Ui.closeAll();
                                Capture.toggleRecord();
                            }
                        }
                    }

                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignCenter
                        kind: "caption"
                        color: Theme.fg3
                        text: "Requires wf-recorder  •  Videos: ~/Pictures/Screenshots"
                    }
                }
            }
        }
    }
}
