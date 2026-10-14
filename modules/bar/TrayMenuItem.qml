import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign

ColumnLayout {
    id: root
    property var entry: null
    signal closeRequested
    spacing: 2

    property bool expanded: false
    readonly property bool hasEntry: root.entry !== null
    readonly property bool isSep: root.hasEntry && root.entry.isSeparator

    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        implicitHeight: 1
        visible: root.isSep
        color: Theme.stroke2
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 32
        visible: root.hasEntry && !root.isSep
        radius: Tokens.rounding.small
        color: rowHover.containsMouse && root.entry.enabled ? Theme.subtleHover : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: Tokens.anim.faster
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8
            Item {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 20
                implicitHeight: 20
                visible: root.entry.buttonType !== QsMenuButtonType.None
                NIcon {
                    anchors.centerIn: parent
                    visible: root.entry.buttonType === QsMenuButtonType.CheckBox && root.entry.checkState === Qt.Checked
                    name: "check"
                    iconSize: 14
                    color: Theme.fg1
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    visible: root.entry.buttonType === QsMenuButtonType.RadioButton && root.entry.checkState === Qt.Checked
                    color: Theme.fg1
                }
            }
            Image {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                visible: root.entry.icon !== ""
                source: root.entry.icon
                sourceSize.width: 16
                sourceSize.height: 16
            }
            NText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                kind: "small"
                color: root.entry.enabled ? Theme.fg1 : Theme.fgDisabled
                text: root.entry.text
            }
            NIcon {
                Layout.alignment: Qt.AlignVCenter
                visible: root.entry.hasChildren
                name: "chevron_right"
                iconSize: 14
                color: Theme.fg3
            }
        }
        MouseArea {
            id: rowHover
            anchors.fill: parent
            hoverEnabled: true
            enabled: root.entry.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.entry.hasChildren) {
                    root.expanded = !root.expanded;
                } else {
                    root.entry.triggered();
                    root.closeRequested();
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        visible: root.expanded && root.hasEntry && root.entry.hasChildren
        spacing: 2

        QsMenuOpener {
            id: subOpener
            menu: root.entry
        }
        Repeater {
            model: subOpener.children
            delegate: Loader {
                Layout.fillWidth: true
                required property var modelData
                property var nodeEntry: modelData
                source: Qt.resolvedUrl("TrayMenuItem.qml")
                onLoaded: {
                    item.entry = nodeEntry;
                    item.closeRequested.connect(root.closeRequested);
                }
            }
        }
    }
}
