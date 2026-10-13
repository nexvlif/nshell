import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.ndesign
import qs.services

Item {
    id: root
    required property var item
    property string barPos: "bottom"
    property bool menuOpen: false

    implicitWidth: 20
    implicitHeight: 20

    readonly property var anchorEdges: {
        if (barPos === "top")
            return Edges.Bottom;
        if (barPos === "left")
            return Edges.Right;
        if (barPos === "right")
            return Edges.Left;
        return Edges.Top;
    }
    readonly property var anchorGravity: {
        if (barPos === "top")
            return Edges.Top;
        if (barPos === "left")
            return Edges.Left;
        if (barPos === "right")
            return Edges.Right;
        return Edges.Bottom;
    }

    function openMenu(): void {
        if (Ui.trayMenuOwner && Ui.trayMenuOwner !== root)
            Ui.trayMenuOwner.closeMenu();
        Ui.trayMenuOwner = root;
        root.menuOpen = true;
        menuPanel.forceActiveFocus();
    }
    function closeMenu(): void {
        root.menuOpen = false;
        if (Ui.trayMenuOwner === root)
            Ui.trayMenuOwner = null;
    }

    Image {
        anchors.fill: parent
        source: root.item.icon
        sourceSize.width: 18
        sourceSize.height: 18
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (root.item.hasMenu) {
                    if (root.menuOpen)
                        root.closeMenu();
                    else
                        root.openMenu();
                } else {
                    root.item.secondaryActivate();
                }
            } else if (root.item.onlyMenu) {
                if (root.item.hasMenu) {
                    if (root.menuOpen)
                        root.closeMenu();
                    else
                        root.openMenu();
                } else {
                    root.item.activate();
                }
            } else {
                root.closeMenu();
                root.item.activate();
            }
        }
        onWheel: wheel => {
            const d = (wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x) > 0 ? 1 : -1;
            root.item.scroll(d);
        }
    }

    Connections {
        target: Ui
        function onTrayMenuOwnerChanged() {
            if (Ui.trayMenuOwner !== root)
                root.menuOpen = false;
        }
        function onUiRevChanged() {
            root.closeMenu();
        }
    }
    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() {
            root.closeMenu();
        }
    }

    QsMenuOpener {
        id: opener
        menu: root.item.menu
    }

    PopupWindow {
        id: menuPopup
        anchor.item: root
        anchor.edges: root.anchorEdges
        anchor.gravity: root.anchorGravity
        width: 248
        height: Math.min(menuFlick.contentHeight + 12, 480)
        visible: root.menuOpen
        color: "transparent"

        NRect {
            id: menuPanel
            focus: true
            Keys.onEscapePressed: root.closeMenu()
            anchors.fill: parent
            corner: Tokens.rounding.large
            fill: "bg1"
            stroke: "subtle"
            shadow: 16

            Flickable {
                id: menuFlick
                anchors.fill: parent
                anchors.margins: 6
                clip: true
                contentWidth: width
                contentHeight: menuItems.implicitHeight
                ColumnLayout {
                    id: menuItems
                    width: menuFlick.width
                    TrayMenuItems {
                        Layout.fillWidth: true
                        opener: opener
                        onCloseRequested: root.closeMenu()
                    }
                }
            }
        }
    }
}
