import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ndesign
import qs.services

// Bundled everyday apps (calculator, camera, voice recorder) in one floating
// window, ala Android/Windows inbox apps. The window is panel-sized and
// positioned via layer-shell anchors+margins, so clicks outside of it fall
// through to windows below (no modal dim, no close-on-outside-click).
// Drag the title bar to move; position persists in `apps.pos`.
// Double-click the title bar to re-center.
//
// Open via Launcher ("nshell" section),
// `qs ipc call nshell openApp <calc|camera|rec>`, or Ui.openApp().
Scope {
    id: root

    readonly property var pages: [
        {
            "id": "calc",
            "icon": "calculate",
            "label": "Calc",
            "title": "Calculator"
        },
        {
            "id": "camera",
            "icon": "photo_camera",
            "label": "Camera",
            "title": "Camera"
        },
        {
            "id": "rec",
            "icon": "mic",
            "label": "Voice",
            "title": "Voice recorder"
        }
    ]
    readonly property int contentW: Ui.appPage === "camera" ? 560 : 340
    readonly property int winH: 620

    function pageTitle(): string {
        for (const p of root.pages) {
            if (p.id === Ui.appPage)
                return p.title;
        }
        return "Apps";
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Ui.appsOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            // Free-floating: window hugs the panel; margins place it.
            anchors {
                top: true
                left: true
            }
            margins {
                top: win.posY
                left: win.posX
            }
            implicitWidth: 150 + 8 + 1 + root.contentW + 32
            implicitHeight: Math.min(root.winH, win.screen.height - 48)

            property int posX: 0
            property int posY: 0
            property bool placed: false

            function stored(): var {
                try {
                    const o = JSON.parse(Config.options.apps.pos || "null");
                    return (o && o.length === 2) ? o : null;
                } catch (e) {
                    return null;
                }
            }
            function centerX(): int {
                return Math.max(8, Math.round((win.screen.width - win.implicitWidth) / 2));
            }
            function centerY(): int {
                return Math.max(8, Math.round((win.screen.height - win.implicitHeight) / 2));
            }
            function clampX(v: int): int {
                return Math.max(8, Math.min(Math.round(v), Math.max(8, win.screen.width - win.implicitWidth - 8)));
            }
            function clampY(v: int): int {
                return Math.max(8, Math.min(Math.round(v), Math.max(8, win.screen.height - win.implicitHeight - 8)));
            }
            function place(): void {
                const s = win.stored();
                if (s) {
                    win.posX = win.clampX(s[0]);
                    win.posY = win.clampY(s[1]);
                } else {
                    win.posX = win.centerX();
                    win.posY = win.centerY();
                }
                win.placed = true;
            }

            onVisibleChanged: {
                if (visible) {
                    win.placed = false;
                    win.place();
                    panel.forceActiveFocus();
                }
            }
            // Re-clamp when the page (hence width) changes.
            onImplicitWidthChanged: {
                if (visible && placed) {
                    posX = clampX(posX);
                    posY = clampY(posY);
                }
            }

            NRect {
                id: panel
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: Ui.closeAll()
                Keys.onPressed: e => {
                    if (Ui.appPage === "calc" && calcPage.handleKey(e))
                        e.accepted = true;
                }
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "subtle"
                shadow: 28

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Title bar: drag handle + close.
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        color: "transparent"
                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                            property real startX: 0
                            property real startY: 0
                            property int origX: 0
                            property int origY: 0
                            onPressed: mouse => {
                                startX = mouse.x;
                                startY = mouse.y;
                                origX = win.posX;
                                origY = win.posY;
                            }
                            onPositionChanged: mouse => {
                                if (pressed) {
                                    win.posX = win.clampX(origX + (mouse.x - startX));
                                    win.posY = win.clampY(origY + (mouse.y - startY));
                                }
                            }
                            onReleased: {
                                Config.set("apps.pos", JSON.stringify([win.posX, win.posY]));
                            }
                            onDoubleClicked: {
                                Config.set("apps.pos", "");
                                win.place();
                            }
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 8
                            spacing: 8
                            NText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                kind: "body"
                                semibold: true
                                elide: Text.ElideRight
                                text: root.pageTitle()
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "close"
                                glyphSize: 18
                                onClicked: Ui.closeAll()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.stroke2
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 0

                        ColumnLayout {
                            Layout.preferredWidth: 150
                            Layout.minimumWidth: 150
                            Layout.maximumWidth: 150
                            Layout.fillHeight: true
                            Layout.topMargin: 12
                            Layout.bottomMargin: 12
                            Layout.leftMargin: 12
                            Layout.rightMargin: 8
                            spacing: 4

                            Repeater {
                                model: root.pages
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 64
                                    radius: Tokens.rounding.large
                                    color: Ui.appPage === modelData.id ? Theme.primaryContainer : navHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 2
                                        NIcon {
                                            Layout.alignment: Qt.AlignHCenter
                                            name: modelData.icon
                                            filled: Ui.appPage === modelData.id
                                            iconSize: 22
                                            color: Ui.appPage === modelData.id ? Theme.primaryContainerFg : Theme.fg2
                                        }
                                        NText {
                                            Layout.alignment: Qt.AlignHCenter
                                            kind: "caption"
                                            semibold: Ui.appPage === modelData.id
                                            color: Ui.appPage === modelData.id ? Theme.primaryContainerFg : Theme.fg2
                                            text: modelData.label
                                        }
                                    }
                                    MouseArea {
                                        id: navHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Ui.appPage = modelData.id
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            color: Theme.stroke2
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 16

                            CalcPage {
                                id: calcPage
                                anchors.fill: parent
                                visible: Ui.appPage === "calc"
                            }
                            CameraPage {
                                anchors.fill: parent
                                visible: Ui.appPage === "camera"
                            }
                            RecPage {
                                anchors.fill: parent
                                visible: Ui.appPage === "rec"
                            }
                        }
                    }
                }
            }
        }
    }
}
