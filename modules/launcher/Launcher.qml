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

            Connections {
                target: DesktopEntries.applications
                function onValuesChanged() {
                    if (Ui.launcherOpen)
                        win.rebuild();
                }
            }

            function rebuild(): void {
                const q = win.query.toLowerCase().trim();
                const out = [];
                const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay).sort((a, b) => a.name.localeCompare(b.name));
                const matched = q ? apps.filter(a => (a.name + " " + (a.genericName || "") + " " + a.id).toLowerCase().includes(q)) : apps;
                if (matched.length > 0) {
                    out.push({
                        kind: "header",
                        name: "Applications"
                    });
                    for (const a of matched)
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
                    icon: "lock",
                    run: Session.lock
                }, {
                    name: "Sleep",
                    sub: "Suspend system",
                    icon: "bedtime",
                    run: Session.suspend
                }, {
                    name: "Log out",
                    sub: "End session",
                    icon: "logout",
                    run: Session.logout
                }, {
                    name: "Restart",
                    sub: "Reboot system",
                    icon: "restart_alt",
                    run: Session.reboot
                }, {
                    name: "Shut down",
                    sub: "Power off",
                    icon: "power_settings_new",
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
                        Quickshell.execDetached(["kitty", "--", ...item.entry.command]);
                    else
                        item.entry.execute();
                } else if (item.kind === "cmd") {
                    Ui.closeAll();
                    item.run();
                }
            }

            function isPinned(id: string): bool {
                const p = Config.options.bar.pinnedApps ?? [];
                return p.includes(id);
            }
            function togglePin(entry): void {
                if (!entry || !entry.id)
                    return;
                const p = Array.from(Config.options.bar.pinnedApps ?? []);
                const i = p.indexOf(entry.id);
                if (i >= 0)
                    p.splice(i, 1);
                else
                    p.push(entry.id);
                Config.set("bar.pinnedApps", p);
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
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
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
                    anchors.margins: Tokens.spacing.l
                    spacing: Tokens.spacing.m

                    NSearchBox {
                        id: box
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
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
                        spacing: 4
                        highlightMoveDuration: Tokens.anim.faster

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: list.width
                            implicitHeight: modelData.kind === "header" ? 28 : 56

                            Rectangle {
                                anchors.fill: parent
                                radius: Tokens.rounding.large
                                color: {
                                    if (modelData.kind === "header")
                                        return "transparent";
                                    if (list.currentIndex === index)
                                        return Theme.primaryContainer;
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
                                    NAppIcon {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        visible: modelData.kind === "app"
                                        source: modelData.kind === "app" ? Quickshell.iconPath(modelData.entry?.icon, "") : ""
                                        letter: (modelData.name || "?").substring(0, 1).toUpperCase()
                                        radius: 8
                                    }
                                    NIcon {
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: modelData.kind === "cmd"
                                        name: modelData.icon || "settings"
                                        filled: list.currentIndex === index
                                        iconSize: 22
                                        color: list.currentIndex === index ? Theme.brandFg1 : Theme.fg2
                                    }
                                    NIcon {
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: modelData.kind === "app" && win.isPinned(modelData.entry?.id ?? "")
                                        name: "push_pin"
                                        filled: true
                                        iconSize: 16
                                        color: Theme.fg3
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
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: modelData.kind === "header" ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onEntered: {
                                    if (modelData.kind !== "header")
                                        list.currentIndex = index;
                                }
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton && modelData.kind === "app") {
                                        win.togglePin(modelData.entry);
                                        return;
                                    }
                                    win.activateAt(index);
                                }
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
                        visible: false
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.stroke2
                    }
                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        kind: "caption"
                        color: Theme.fg3
                        text: "↑↓ navigate · ↵ open · right-click pin · esc close"
                    }
                }
            }
        }
    }
}
