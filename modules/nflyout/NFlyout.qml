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

            visible: Ui.nflyoutOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            property string pos: Config.options.bar.position
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
                width: 360
                implicitHeight: 185
                anchors.right: (pos === "left") ? undefined : parent.right
                anchors.left: (pos === "left") ? parent.left : undefined
                anchors.top: (pos === "top") ? parent.top : undefined
                anchors.bottom: (pos !== "top") ? parent.bottom : undefined
                anchors.margins: 12
                corner: Tokens.rounding.xlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: 16

                ColumnLayout {
                    id: flyCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 10
                    visible: Mpris.active !== null

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        Rectangle {
                            implicitWidth: 72
                            implicitHeight: 72
                            color: Theme.bg3
                            NRoundedImage {
                                id: flyArt
                                anchors.fill: parent
                                source: Mpris.artUrl
                                imgRadius: Tokens.rounding.xlarge
                                NIcon {
                                    anchors.centerIn: parent
                                    visible: !flyArt.imgReady
                                    name: "music_note_1"
                                    iconSize: 28
                                    color: Theme.fg3
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2
                            NText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                kind: "body"
                                semibold: true
                                text: Mpris.title || "Unknown title"
                            }
                            NText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                kind: "small"
                                color: Theme.fg2
                                text: Mpris.artist || "Unknown artist"
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        NText {
                            kind: "caption"
                            color: Theme.fg3
                            text: Mpris.fmt(Mpris.position)
                        }
                        NSlider {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            value: Mpris.length > 0 ? Mpris.position / Mpris.length : 0
                            interactive: Mpris.canSeek
                            onMoved: v => Mpris.seekTo(v)
                        }
                        NText {
                            kind: "caption"
                            color: Theme.fg3
                            text: Mpris.fmt(Mpris.length)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Item {
                            Layout.fillWidth: true
                        }
                        NIconButton {
                            name: Mpris.shuffle ? "arrow_shuffle" : "arrow_shuffle_off"
                            restColor: Mpris.shuffle ? Theme.brandFg1 : Theme.fg2
                            onClicked: Mpris.toggleShuffle()
                        }
                        NIconButton {
                            name: "chevron_left"
                            onClicked: Mpris.previous()
                        }
                        Rectangle {
                            implicitWidth: 44
                            implicitHeight: 44
                            radius: 22
                            color: playHover.pressed ? Theme.brandBgPressed : playHover.containsMouse ? Theme.brandBgHover : Theme.brandBg
                            Behavior on color {
                                ColorAnimation {
                                    duration: Tokens.anim.faster
                                }
                            }
                            NIcon {
                                anchors.centerIn: parent
                                name: Mpris.playing ? "pause" : "play"
                                filled: true
                                iconSize: 22
                                color: "#ffffff"
                            }
                            MouseArea {
                                id: playHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Mpris.playPause()
                            }
                        }
                        NIconButton {
                            name: "chevron_right"
                            onClicked: Mpris.next()
                        }
                        NIconButton {
                            name: Mpris.loop === 1 ? "arrow_repeat_1" : (Mpris.loop === 2 ? "arrow_repeat_all" : "arrow_repeat_all_off")
                            restColor: Mpris.loop === 0 ? Theme.fg2 : Theme.brandFg1
                            onClicked: Mpris.cycleLoop()
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }

                ColumnLayout {
                    id: emptyCol
                    width: parent.width - 32
                    x: 16
                    y: (parent.height - implicitHeight) / 2
                    spacing: 8
                    visible: Mpris.active === null
                    NIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "headphones"
                        iconSize: 32
                        color: Theme.fg3
                    }
                    NText {
                        Layout.alignment: Qt.AlignHCenter
                        kind: "body"
                        color: Theme.fg3
                        text: "Nothing playing"
                    }
                }
            }
        }
    }
}
