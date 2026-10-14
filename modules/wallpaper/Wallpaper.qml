import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.ndesign
import qs.services

Scope {
    id: root

    function importHyprpaper(): void {
        if (Config.options.wallpaper.path === "" && !impProc.running)
            impProc.running = true;
    }

    function pickWallpaper(): void {
        Ui.wallMenuOpen = false;
        Ui.wallPickerOpen = true;
        root.scanWalls();
    }

    function scanWalls(): void {
        scanProc.running = false;
        scanProc.running = true;
    }

    property var imgList

    Component.onCompleted: root.importHyprpaper()

    Process {
        id: impProc
        command: ["sh", "-c", "grep -m1 preload ~/.config/hypr/hyprpaper.conf 2>/dev/null | cut -d= -f2-"]
        stdout: StdioCollector {
            onStreamFinished: {
                let t = text.trim();
                if (t === "")
                    return;
                if (t[0] === "~")
                    t = (Quickshell.env("HOME") || "") + t.slice(1);
                if (t[0] === "/")
                    Config.set("wallpaper.path", t);
            }
        }
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

            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Background
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.bg3
            }
            Image {
                anchors.fill: parent
                source: Config.options.wallpaper.path !== "" ? "file://" + Config.options.wallpaper.path : ""
                fillMode: (Config.options.wallpaper.mode ?? "fill") === "fit" ? Image.PreserveAspectFit : (Config.options.wallpaper.mode === "stretch" ? Image.Stretch : Image.PreserveAspectCrop)
                asynchronous: true
                cache: false
                visible: status === Image.Ready
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: menuWin
            required property var modelData
            screen: modelData

            visible: (Ui.wallMenuOpen || Ui.wallEditOpen || Ui.wallPickerOpen) && Ui.wallMenuScreen === screen
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
                    if (Ui.wallPickerOpen) {
                        root.scanWalls();
                        pickerPanel.forceActiveFocus();
                    } else {
                        menuPanel.forceActiveFocus();
                    }
                }
            }

            readonly property int menuW: 280
            readonly property int editW: 300
            readonly property int menuX: Math.min(Math.max(Ui.wallMenuX, 8), menuWin.width - menuW - 8)
            readonly property int menuY: Math.min(Math.max(Ui.wallMenuY, 8), menuWin.height - 150)

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            Ui.openWallMenu(mouse.x, mouse.y, menuWin.screen);
                        else
                            Ui.closeWallMenu();
                    }
                }
            }

            NRect {
                id: menuPanel
                focus: true
                Keys.onEscapePressed: Ui.closeWallMenu()
                visible: Ui.wallMenuOpen && !Ui.wallPickerOpen
                width: menuWin.menuW
                x: menuWin.menuX
                y: menuWin.menuY
                implicitHeight: menuCol.implicitHeight + 24
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 16

                ColumnLayout {
                    id: menuCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.large
                        color: wallHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            NIcon {
                                name: "image"
                                iconSize: 18
                                color: Theme.fg2
                            }
                            NText {
                                Layout.fillWidth: true
                                kind: "small"
                                semibold: true
                                text: "Change wallpaper"
                            }
                        }
                        MouseArea {
                            id: wallHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.pickWallpaper();
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.large
                        color: (editHover.containsMouse || Ui.wallEditOpen) ? Theme.surfaceContainerHigh : "transparent"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            NIcon {
                                name: "tune"
                                filled: Ui.wallEditOpen
                                iconSize: 18
                                color: Ui.wallEditOpen ? Theme.fg1 : Theme.fg2
                            }
                            NText {
                                Layout.fillWidth: true
                                kind: "small"
                                semibold: true
                                text: "Edit widgets"
                            }
                            NIcon {
                                name: "chevron_right"
                                iconSize: 14
                                color: Theme.fg3
                            }
                        }
                        MouseArea {
                            id: editHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Ui.wallEditOpen = !Ui.wallEditOpen
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.large
                        color: settingsHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            NIcon {
                                name: "settings"
                                iconSize: 18
                                color: Theme.fg2
                            }
                            NText {
                                Layout.fillWidth: true
                                kind: "small"
                                semibold: true
                                text: "Settings"
                            }
                        }
                        MouseArea {
                            id: settingsHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Ui.closeWallMenu();
                                Ui.toggleSettings();
                            }
                        }
                    }
                }
            }

            NRect {
                visible: Ui.wallEditOpen && !Ui.wallPickerOpen
                width: menuWin.editW
                x: Math.min(menuWin.menuX + menuWin.menuW + 8, menuWin.width - menuWin.editW - 8)
                y: Math.min(Math.max(Ui.wallMenuY, 8), menuWin.height - editCol.implicitHeight - 32)
                implicitHeight: editCol.implicitHeight + 24
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 16

                ColumnLayout {
                    id: editCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 2

                    NText {
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        kind: "title"
                        semibold: true
                        text: "Widgets"
                    }
                    NText {
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        visible: Config.options.widgets.locked === false
                        wrapMode: Text.WordWrap
                        kind: "caption"
                        color: Theme.fg3
                        text: "Unlocked: drag cards to move, lock to interact"
                    }
                    Repeater {
                        model: [["locked", "Lock positions"], ["enabled", "Show widgets"], ["clock", "Clock"], ["week", "Week strip"], ["stats", "Stats tiles"], ["weather", "Weather"], ["worldclock", "World clock"], ["todo", "To-Do"], ["notes", "Notes"], ["timers", "Timers"], ["media", "Media"], ["battery", "Battery"], ["net", "Network"], ["image", "Image"]]
                        delegate: RowLayout {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            spacing: 8
                            NText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                kind: "small"
                                text: modelData[1]
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                visible: index > 1
                                name: "open_with"
                                glyphSize: 16
                                restColor: Config.options.widgets.locked === false ? (Ui.wallMoveTarget === modelData[0] ? Theme.fg1 : Theme.fg2) : Theme.fg3
                                onClicked: {
                                    if (Config.options.widgets.locked !== false)
                                        return;
                                    Ui.wallMoveTarget = Ui.wallMoveTarget === modelData[0] ? "" : modelData[0];
                                }
                            }
                            NSwitch {
                                Layout.alignment: Qt.AlignVCenter
                                checked: Config.options.widgets[modelData[0]] === true
                                onClicked: Config.set("widgets." + modelData[0], !(Config.options.widgets[modelData[0]] === true))
                            }
                        }
                    }
                }
            }

            NRect {
                id: pickerPanel
                focus: true
                Keys.onEscapePressed: Ui.wallPickerOpen = false
                visible: Ui.wallPickerOpen
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
                            text: "Wallpapers"
                        }
                        NText {
                            kind: "caption"
                            color: Theme.fg3
                            text: (root.imgList ?? []).length + " images"
                        }
                        NIconButton {
                            name: "sync"
                            glyphSize: 16
                            onClicked: root.scanWalls()
                        }
                        NIconButton {
                            name: "close"
                            glyphSize: 16
                            onClicked: Ui.wallPickerOpen = false
                        }
                    }
                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        visible: (root.imgList ?? []).length === 0
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
                        model: root.imgList ?? []
                        delegate: Item {
                            required property var modelData
                            width: 208
                            height: 124
                            NRoundedImage {
                                anchors.fill: parent
                                source: "file://" + modelData
                                imgRadius: Tokens.rounding.medium
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: Tokens.rounding.medium
                                color: "transparent"
                                border.width: modelData === Config.options.wallpaper.path ? 2 : 0
                                border.color: Theme.fg1
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Config.set("wallpaper.path", modelData);
                                    Ui.closeWallMenu();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
