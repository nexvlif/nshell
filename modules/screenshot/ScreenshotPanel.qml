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

            visible: Ui.screenshotOpen
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

                opacity: Ui.screenshotOpen ? 1 : 0
                scale: Ui.screenshotOpen ? 1 : 0.97
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
                            color: Theme.bg2
                            NIcon {
                                anchors.centerIn: parent
                                name: "photo_camera"
                                filled: true
                                iconSize: 22
                                color: Theme.fg1
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0
                            NText {
                                kind: "title"
                                semibold: true
                                text: "Screenshot"
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

                    NText {
                        kind: "caption"
                        color: Theme.fg3
                        text: "CAPTURE MODE"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ScreenshotModeCard {
                            icon: "crop"
                            title: "Area"
                            sub: "Drag select"
                            selected: Capture.mode === "area"
                            onClicked: Capture.setMode("area")
                        }
                        ScreenshotModeCard {
                            icon: "fullscreen"
                            title: "Full"
                            sub: "All screens"
                            selected: Capture.mode === "full"
                            onClicked: Capture.setMode("full")
                        }
                        ScreenshotModeCard {
                            icon: "window"
                            title: "Window"
                            sub: "Active app"
                            selected: Capture.mode === "window"
                            onClicked: Capture.setMode("window")
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
                            text: Capture.delaySec === 0 ? "Instant" : Capture.delaySec + "s"
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
                                    color: Capture.delaySec === modelData ? Theme.primary : "transparent"
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Tokens.anim.faster
                                        }
                                    }
                                    NText {
                                        anchors.centerIn: parent
                                        kind: "small"
                                        semibold: Capture.delaySec === parent.modelData
                                        color: Capture.delaySec === parent.modelData ? Theme.primaryFg : Theme.fg2
                                        text: parent.modelData === 0 ? "0s" : parent.modelData + "s"
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Capture.setDelay(modelData)
                                    }
                                }
                            }
                        }
                    }

                    NText {
                        kind: "caption"
                        color: Theme.fg3
                        text: "OPTIONS"
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            NIcon {
                                name: "content_copy"
                                iconSize: 18
                                color: Theme.fg2
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                NText {
                                    kind: "small"
                                    semibold: true
                                    text: "Copy to clipboard"
                                }
                                NText {
                                    kind: "caption"
                                    color: Theme.fg3
                                    text: "Auto copy PNG after capture"
                                }
                            }
                            NSwitch {
                                checked: Capture.copyClipboard
                                onClicked: Capture.copyClipboard = !Capture.copyClipboard
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            NIcon {
                                name: "mouse"
                                iconSize: 18
                                color: Theme.fg2
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                NText {
                                    kind: "small"
                                    semibold: true
                                    text: "Include cursor"
                                }
                                NText {
                                    kind: "caption"
                                    color: Theme.fg3
                                    text: "Show pointer in screenshot"
                                }
                            }
                            NSwitch {
                                checked: Capture.includeCursor
                                onClicked: Capture.includeCursor = !Capture.includeCursor
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            opacity: Capture.delaySec > 0 ? 1 : 0.45
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
                                    text: "Fullscreen timer before capture"
                                }
                            }
                            NSwitch {
                                checked: Capture.showCountdown
                                onClicked: Capture.showCountdown = !Capture.showCountdown
                            }
                        }
                    }

                    Rectangle {
                        visible: Capture.lastFile !== ""
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.large
                        color: Theme.bg2
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 8
                            NIcon {
                                name: "check_circle"
                                filled: true
                                iconSize: 18
                                color: Theme.fg2
                            }
                            NText {
                                Layout.fillWidth: true
                                elide: Text.ElideMiddle
                                kind: "caption"
                                color: Theme.fg2
                                text: Capture.lastFile
                            }
                            NIconButton {
                                name: "open_in_new"
                                glyphSize: 16
                                onClicked: Capture.openFile()
                            }
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
                            icon: Capture.mode === "full" ? "fullscreen" : Capture.mode === "window" ? "window" : "crop"
                            text: Capture.delaySec > 0 ? "Capture in " + Capture.delaySec + "s" : "Capture"
                            onClicked: {
                                Ui.closeAll();
                                Capture.capture();
                            }
                        }
                    }

                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignCenter
                        kind: "caption"
                        color: Theme.fg3
                        text: "Area: drag to select  •  Files: ~/Pictures/Screenshots"
                    }
                }
            }
        }
    }
}
