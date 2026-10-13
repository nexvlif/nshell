import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
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

            visible: Ui.launcherOpen
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
                    query = "";
                    box.field.text = "";
                    rebuild();
                    box.field.forceActiveFocus();
                }
            }

            property string query: ""
            property var results: []

            function rebuild(): void {
                const q = win.query.toLowerCase().trim();
                const out = [];
                const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay);
                const matched = q ? apps.filter(a => (a.name + " " + (a.genericName || "") + " " + a.id).toLowerCase().includes(q)) : apps;
                const top = matched.slice(0, 7);
                if (top.length > 0) {
                    out.push({
                        kind: "header",
                        name: "Applications"
                    });
                    for (const a of top)
                        out.push({
                            kind: "app",
                            name: a.name,
                            sub: a.genericName || a.id,
                            entry: a
                        });
                }
                const cmds = [{
                    name: "Lock",
                    sub: "Lock session",
                    icon: "lock_closed",
                    run: Session.lock
                }, {
                    name: "Sleep",
                    sub: "Suspend system",
                    icon: "sleep",
                    run: Session.suspend
                }, {
                    name: "Log out",
                    sub: "End session",
                    icon: "door_arrow_right",
                    run: Session.logout
                }, {
                    name: "Restart",
                    sub: "Reboot system",
                    icon: "arrow_sync",
                    run: Session.reboot
                }, {
                    name: "Shut down",
                    sub: "Power off",
                    icon: "power",
                    run: Session.poweroff
                }].filter(c => !q || (c.name + " " + c.sub).toLowerCase().includes(q));
                if (cmds.length > 0) {
                    out.push({
                        kind: "header",
                        name: "System"
                    });
                    for (const c of cmds)
                        out.push({
                            kind: "cmd",
                            name: c.name,
                            sub: c.sub,
                            icon: c.icon,
                            run: c.run
                        });
                }
                win.results = out;
                list.currentIndex = firstActivatable(0, 1);
            }

            function firstActivatable(from: int, dir: int): int {
                let i = from;
                while (i >= 0 && i < win.results.length) {
                    if (win.results[i].kind !== "header")
                        return i;
                    i += dir;
                }
                return -1;
            }

            function moveSelection(dir: int): void {
                if (win.results.length === 0)
                    return;
                let i = list.currentIndex < 0 ? (dir > 0 ? -1 : win.results.length) : list.currentIndex;
                for (let step = 0; step < win.results.length; ++step) {
                    i += dir;
                    if (i < 0)
                        i = win.results.length - 1;
                    if (i >= win.results.length)
                        i = 0;
                    if (win.results[i].kind !== "header") {
                        list.currentIndex = i;
                        return;
                    }
                }
            }

            function activateAt(index: int): void {
                if (index < 0 || index >= win.results.length)
                    return;
                const item = win.results[index];
                if (item.kind === "app") {
                    Ui.closeAll();
                    if (item.entry.runInTerminal)
                        Quickshell.execDetached(["xdg-terminal-exec", ...item.entry.command]);
                    else
                        item.entry.execute();
                } else if (item.kind === "cmd") {
                    Ui.closeAll();
                    item.run();
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.overlay
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.closeAll()
                }
            }

            NRect {
                width: 640
                height: 480
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Math.round(parent.height * 0.18)
                corner: Tokens.rounding.xlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: 28
                scale: win.visible ? 1 : 0.96
                opacity: win.visible ? 1 : 0
                Behavior on scale {
                    NumberAnimation {
                        duration: Tokens.anim.fast
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Tokens.anim.fast
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.spacing.m
                    spacing: Tokens.spacing.s

                    NSearchBox {
                        id: box
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        placeholder: "Type a command or search"
                        field.onTextChanged: {
                            win.query = field.text;
                            win.rebuild();
                        }
                        field.Keys.onDownPressed: win.moveSelection(1)
                        field.Keys.onUpPressed: win.moveSelection(-1)
                        field.Keys.onReturnPressed: win.activateAt(list.currentIndex)
                        field.Keys.onEnterPressed: win.activateAt(list.currentIndex)
                        field.Keys.onEscapePressed: Ui.closeAll()
                    }

                    ListView {
                        id: list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: win.results
                        spacing: 2
                        highlightMoveDuration: Tokens.anim.faster

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: list.width
                            implicitHeight: modelData.kind === "header" ? 28 : 52

                            Rectangle {
                                anchors.fill: parent
                                radius: Tokens.rounding.medium
                                color: {
                                    if (modelData.kind === "header")
                                        return "transparent";
                                    if (list.currentIndex === index)
                                        return Theme.subtleSelected;
                                    return hoverArea.containsMouse ? Theme.subtleHover : "transparent";
                                }
                                NText {
                                    visible: modelData.kind === "header"
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    kind: "caption"
                                    color: Theme.fg3
                                    text: modelData.name
                                }
                                RowLayout {
                                    visible: modelData.kind !== "header"
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12
                                    IconImage {
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: modelData.kind === "app"
                                        asynchronous: true
                                        source: modelData.kind === "app" ? Quickshell.iconPath(modelData.entry?.icon, "image-missing") : ""
                                        implicitSize: 28
                                    }
                                    NIcon {
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: modelData.kind === "cmd"
                                        name: modelData.icon || "settings"
                                        filled: list.currentIndex === index
                                        iconSize: 22
                                        color: list.currentIndex === index ? Theme.brandFg1 : Theme.fg2
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 0
                                        NText {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            kind: "body"
                                            text: modelData.name
                                        }
                                        NText {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            kind: "caption"
                                            color: Theme.fg3
                                            text: modelData.sub || ""
                                        }
                                    }
                                }
                            }
                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: modelData.kind === "header" ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onEntered: {
                                    if (modelData.kind !== "header")
                                        list.currentIndex = index;
                                }
                                onClicked: win.activateAt(index)
                            }
                        }
                    }

                    NText {
                        visible: win.results.length === 0
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        kind: "body"
                        color: Theme.fg3
                        text: "No results"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.stroke2
                    }
                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        kind: "caption"
                        color: Theme.fg3
                        text: "↑↓ navigate · ↵ open · esc close"
                    }
                }
            }
        }
    }
}
