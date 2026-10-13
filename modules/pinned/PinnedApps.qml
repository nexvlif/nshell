import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.ndesign
import qs.services

RowLayout {
    id: root
    spacing: 4

    function entryFor(id: string): var {
        const apps = DesktopEntries.applications.values;
        for (let i = 0; i < apps.length; ++i) {
            if (apps[i].id === id)
                return apps[i];
        }
        return null;
    }

    function launch(entry): void {
        if (!entry)
            return;
        if (entry.runInTerminal)
            Quickshell.execDetached(["xdg-terminal-exec", ...entry.command]);
        else
            entry.execute();
    }

    Repeater {
        model: Config.options.bar.pinnedApps
        delegate: Rectangle {
            required property var modelData
            readonly property var entry: root.entryFor(modelData)
            visible: entry !== null
            implicitWidth: visible ? 40 : 0
            implicitHeight: 40
            radius: Tokens.rounding.large
            color: pinHover.containsMouse ? Theme.subtleHover : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: Tokens.anim.faster
                }
            }
            IconImage {
                anchors.centerIn: parent
                asynchronous: true
                source: parent.entry ? Quickshell.iconPath(parent.entry.icon, "image-missing") : ""
                implicitSize: 26
            }
            MouseArea {
                id: pinHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.launch(parent.entry)
            }
        }
    }
}
