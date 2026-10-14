import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.services

Scope {
    id: root

    readonly property color dim: Qt.rgba(0, 0, 0, 0.5)
    readonly property color line: "#ffffff"
    readonly property color pillBg: Qt.rgba(10, 10, 10, 0.82)

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Capture.selecting
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

            readonly property var mon: Hyprland.monitorFor(screen)
            readonly property int offX: mon ? mon.x : 0
            readonly property int offY: mon ? mon.y : 0

            property real sx: 0
            property real sy: 0
            property real cx: 0
            property real cy: 0
            property bool dragging: false
            property bool decided: false

            readonly property real x0: Math.min(sx, cx)
            readonly property real y0: Math.min(sy, cy)
            readonly property real selW: Math.abs(cx - sx)
            readonly property real selH: Math.abs(cy - sy)
            readonly property bool hasSel: selW > 4 && selH > 4
            readonly property string sizeText: Math.round(selW) + " × " + Math.round(selH)

            function reset(): void {
                sx = 0;
                sy = 0;
                cx = 0;
                cy = 0;
                dragging = false;
                decided = false;
            }

            function confirm(): void {
                if (!hasSel) {
                    Capture.cancelSelect();
                    return;
                }
                Capture.captureArea(Math.round(offX + x0), Math.round(offY + y0), Math.round(selW), Math.round(selH));
            }

            onVisibleChanged: {
                if (visible) {
                    reset();
                    overlay.forceActiveFocus();
                }
            }

            Item {
                id: overlay
                anchors.fill: parent
                focus: true

                Keys.onEscapePressed: Capture.cancelSelect()
                Keys.onReturnPressed: {
                    if (win.hasSel)
                        win.confirm();
                }
                Keys.onEnterPressed: {
                    if (win.hasSel)
                        win.confirm();
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.CrossCursor
                    property real mx: 0
                    property real my: 0
                    onPositionChanged: e => {
                        mx = e.x;
                        my = e.y;
                        if (win.dragging) {
                            win.cx = e.x;
                            win.cy = e.y;
                        }
                    }
                    onPressed: e => {
                        if (e.button === Qt.RightButton) {
                            Capture.cancelSelect();
                            return;
                        }
                        win.sx = e.x;
                        win.sy = e.y;
                        win.cx = e.x;
                        win.cy = e.y;
                        win.dragging = true;
                        win.decided = false;
                        mx = e.x;
                        my = e.y;
                    }
                    onReleased: e => {
                        if (e.button !== Qt.LeftButton || !win.dragging)
                            return;
                        win.dragging = false;
                        win.cx = e.x;
                        win.cy = e.y;
                        if (win.hasSel)
                            win.decided = true;
                        else
                            win.reset();
                    }
                    onDoubleClicked: {
                        if (win.hasSel)
                            win.confirm();
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    visible: !win.hasSel
                    color: root.dim
                }

                Rectangle {
                    visible: win.hasSel
                    x: 0
                    y: 0
                    width: parent.width
                    height: win.y0
                    color: root.dim
                }
                Rectangle {
                    visible: win.hasSel
                    x: 0
                    y: win.y0 + win.selH
                    width: parent.width
                    height: parent.height - (win.y0 + win.selH)
                    color: root.dim
                }
                Rectangle {
                    visible: win.hasSel
                    x: 0
                    y: win.y0
                    width: win.x0
                    height: win.selH
                    color: root.dim
                }
                Rectangle {
                    visible: win.hasSel
                    x: win.x0 + win.selW
                    y: win.y0
                    width: parent.width - (win.x0 + win.selW)
                    height: win.selH
                    color: root.dim
                }

                Rectangle {
                    visible: !win.decided
                    x: mouse.mx
                    y: 0
                    width: 1
                    height: parent.height
                    color: root.line
                    opacity: 0.55
                }
                Rectangle {
                    visible: !win.decided
                    x: 0
                    y: mouse.my
                    width: parent.width
                    height: 1
                    color: root.line
                    opacity: 0.55
                }

                Rectangle {
                    visible: win.hasSel
                    x: win.x0
                    y: win.y0
                    width: win.selW
                    height: win.selH
                    color: "transparent"
                    border.color: root.line
                    border.width: 2
                }

                Repeater {
                    model: win.hasSel ? 8 : 0
                    delegate: Rectangle {
                        required property int index
                        readonly property var pos: [
                            [win.x0, win.y0],
                            [win.x0 + win.selW / 2, win.y0],
                            [win.x0 + win.selW, win.y0],
                            [win.x0 + win.selW, win.y0 + win.selH / 2],
                            [win.x0 + win.selW, win.y0 + win.selH],
                            [win.x0 + win.selW / 2, win.y0 + win.selH],
                            [win.x0, win.y0 + win.selH],
                            [win.x0, win.y0 + win.selH / 2]
                        ][index]
                        x: pos[0] - 5
                        y: pos[1] - 5
                        width: 10
                        height: 10
                        radius: 3
                        color: root.line
                        border.color: Qt.rgba(0, 0, 0, 0.6)
                        border.width: 1
                    }
                }

                Rectangle {
                    visible: !win.decided
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 24
                    width: hintRow.implicitWidth + 28
                    height: 40
                    radius: 20
                    color: root.pillBg
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
                            text: "Drag to select area"
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
                            text: "Esc cancel · Right-click cancel"
                        }
                    }
                }

                Rectangle {
                    visible: win.hasSel && !win.decided
                    width: sizeText.implicitWidth + 24
                    height: 32
                    x: Math.min(Math.max(win.x0 + win.selW / 2 - width / 2, 8), parent.width - width - 8)
                    y: win.y0 >= 48 ? win.y0 - height - 8 : win.y0 + win.selH + 8
                    radius: 16
                    color: root.pillBg
                    border.color: Qt.rgba(255, 255, 255, 0.16)
                    border.width: 1
                    Text {
                        id: sizeText
                        anchors.centerIn: parent
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.family: "Roboto Mono, Consolas, monospace"
                        text: win.sizeText
                    }
                }

                Rectangle {
                    id: toolbar
                    visible: win.decided && win.hasSel
                    width: toolRow.implicitWidth + 20
                    height: 52
                    x: Math.min(Math.max(win.x0 + win.selW / 2 - width / 2, 8), parent.width - width - 8)
                    y: (win.y0 + win.selH + 12 + height <= parent.height) ? win.y0 + win.selH + 12 : Math.max(8, win.y0 - height - 12)
                    radius: 26
                    color: root.pillBg
                    border.color: Qt.rgba(255, 255, 255, 0.16)
                    border.width: 1
                    Row {
                        id: toolRow
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            leftPadding: 8
                            rightPadding: 4
                            color: Qt.rgba(255, 255, 255, 0.85)
                            font.pixelSize: 12
                            font.family: "Roboto Mono, Consolas, monospace"
                            text: win.sizeText
                        }
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1
                            height: 20
                            color: Qt.rgba(255, 255, 255, 0.2)
                        }
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 40
                            height: 40
                            radius: 20
                            color: cancelHover.containsMouse ? Qt.rgba(255, 255, 255, 0.16) : "transparent"
                            Text {
                                anchors.centerIn: parent
                                color: "#ffffff"
                                font.family: "Material Symbols Lite"
                                font.pixelSize: 18
                                text: "close"
                            }
                            MouseArea {
                                id: cancelHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Capture.cancelSelect()
                            }
                        }
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: capRow.implicitWidth + 24
                            height: 40
                            radius: 20
                            color: capHover.pressed ? "#d7d7d7" : capHover.containsMouse ? "#ffffff" : "#f0f0f0"
                            Row {
                                id: capRow
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "#111111"
                                    font.family: "Material Symbols Lite"
                                    font.pixelSize: 18
                                    text: "check"
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "#111111"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    font.family: "Roboto, Inter, Cantarell, sans-serif"
                                    text: "Capture"
                                }
                            }
                            MouseArea {
                                id: capHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.confirm()
                            }
                        }
                    }
                }
            }
        }
    }
}
