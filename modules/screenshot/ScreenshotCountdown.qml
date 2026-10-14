import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Capture.counting || Capture.recCounting
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            onVisibleChanged: {
                if (visible)
                    overlay.forceActiveFocus();
            }

            readonly property bool rec: Capture.recCounting
            readonly property int num: rec ? Capture.recCountdownLeft : Capture.countdownLeft
            readonly property int total: rec ? Capture.recDelaySec : Capture.delaySec
            readonly property real frac: total > 0 ? (total - num) / total : 0
            readonly property string caption: rec ? "Starting recording" : "Taking screenshot"

            function cancel(): void {
                if (rec)
                    Capture.cancelRecCountdown();
                else
                    Capture.cancelCountdown();
            }

            function skip(): void {
                if (rec)
                    Capture.skipRecCountdown();
                else
                    Capture.skipCountdown();
            }

            Item {
                id: overlay
                anchors.fill: parent
                focus: true

                Keys.onEscapePressed: win.cancel()
                Keys.onReturnPressed: win.skip()
                Keys.onEnterPressed: win.skip()

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.35)
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.cancel()
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 148
                        height: 148
                        radius: 74
                        color: Qt.rgba(10, 10, 10, 0.85)
                        border.color: Qt.rgba(255, 255, 255, 0.22)
                        border.width: 2
                        Text {
                            id: num
                            anchors.centerIn: parent
                            color: "#ffffff"
                            font.pixelSize: 64
                            font.weight: Font.DemiBold
                            font.family: "Roboto Mono, Consolas, monospace"
                            text: win.num
                            onTextChanged: pop.restart()
                        }
                        NumberAnimation {
                            id: pop
                            target: num
                            property: "scale"
                            from: 1.3
                            to: 1.0
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 168
                        height: 6
                        radius: 3
                        color: Qt.rgba(255, 255, 255, 0.22)
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(6, parent.width * win.frac)
                            height: parent.height
                            radius: 3
                            color: "#ffffff"
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: hintRow.implicitWidth + 28
                        height: 40
                        radius: 20
                        color: Qt.rgba(10, 10, 10, 0.82)
                        border.color: Qt.rgba(255, 255, 255, 0.16)
                        border.width: 1
                        Row {
                            id: hintRow
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.family: "Roboto, Inter, Cantarell, sans-serif"
                                text: win.caption
                            }
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 1
                                height: 14
                                color: Qt.rgba(255, 255, 255, 0.25)
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                color: Qt.rgba(255, 255, 255, 0.7)
                                font.pixelSize: 12
                                font.family: "Roboto, Inter, Cantarell, sans-serif"
                                text: "Enter now · Click cancel"
                            }
                        }
                    }
                }
            }
        }
    }
}
