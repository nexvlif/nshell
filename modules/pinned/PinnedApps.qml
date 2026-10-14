import QtQuick
import QtQuick.Layouts
import Quickshell
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
            NAppIcon {
                anchors.centerIn: parent
                width: 26
                height: 26
                visible: parent.entry !== null
                source: parent.entry ? Quickshell.iconPath(parent.entry.icon, "") : ""
                letter: (parent.entry ? parent.entry.name : "?").substring(0, 1).toUpperCase()
                radius: 8
            }
            MouseArea {
                id: pinHover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        const p = Array.from(Config.options.bar.pinnedApps ?? []);
                        const i = p.indexOf(modelData);
                        if (i >= 0) {
                            p.splice(i, 1);
                            Config.set("bar.pinnedApps", p);
                        }
                        return;
                    }
                    root.launch(parent.entry);
                }
            }
        }
    }
}
