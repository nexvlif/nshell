import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import qs.ndesign
import qs.services

Scope {
    id: root

    readonly property int pillSize: Config.options.bar.height
    readonly property string pos: Config.options.bar.position
    readonly property bool vertical: pos === "left" || pos === "right"
    readonly property var barMargins: Config.options.bar.margins[pos] ?? Config.options.bar.margins["bottom"]

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            readonly property bool hasWindows: {
                Hypr.winRevision;
                const mon = Hyprland.monitorFor(screen);
                const ws = mon ? mon.activeWorkspace : null;
                if (!ws)
                    return false;
                const all = Hyprland.toplevels;
                const tls = all ? all.values : [];
                for (let i = 0; i < tls.length; ++i) {
                    const t = tls[i];
                    if (t.workspace && t.workspace.id === ws.id) {
                        const ipc = t.lastIpcObject;
                        if (!ipc || !ipc.floating)
                            return true;
                    }
                }
                if (tls.length > 0)
                    return false;
                const wipc = ws.lastIpcObject;
                return wipc ? wipc.windows > 0 : false;
            }
            readonly property bool barFull: {
                if (!vertical)
                    return false;
                const m = Config.options.bar.verticalMode;
                if (m === "full")
                    return true;
                if (m === "compact")
                    return false;
                return hasWindows;
            }

            anchors {
                top: pos === "top" || barFull
                bottom: pos === "bottom" || barFull
                left: pos === "left" || !vertical
                right: pos === "right" || !vertical
            }
            margins {
                top: barMargins.top
                bottom: barMargins.bottom
                left: barMargins.left
                right: barMargins.right
            }
            implicitWidth: vertical ? pillSize + barMargins.left + barMargins.right : 0
            implicitHeight: vertical ? (barFull ? 0 : vcol.implicitHeight + 24) : pillSize + barMargins.top + barMargins.bottom
            color: "transparent"

            Item {
                visible: !vertical
                anchors.fill: parent

                NRect {
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    implicitHeight: pillSize
                    implicitWidth: clockCol.implicitWidth + Config.options.bar.pillPadding
                    corner: Tokens.rounding.xxlarge
                    fill: "bg1"
                    stroke: "subtle"
                    shadow: Config.options.bar.shadow

                    ColumnLayout {
                        id: clockCol
                        anchors.centerIn: parent
                        spacing: 0
                        NText {
                            Layout.alignment: Qt.AlignHCenter
                            kind: "body"
                            semibold: true
                            text: Config.options.bar.clock12h ? Time.timeShort : Time.format("HH:mm")
                        }
                        NText {
                            Layout.alignment: Qt.AlignHCenter
                            kind: "caption"
                            color: Theme.fg3
                            text: Time.dateShort
                            visible: Config.options.bar.showDate
                        }
                    }
                }

                NRect {
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    implicitHeight: pillSize
                    implicitWidth: trayRow.implicitWidth + Config.options.bar.pillPadding
                    corner: Tokens.rounding.xxlarge
                    fill: "bg1"
                    stroke: "subtle"
                    shadow: Config.options.bar.shadow

                    RowLayout {
                        id: trayRow
                        anchors.centerIn: parent
                        spacing: 10

                        Repeater {
                            visible: Config.options.bar.showTray
                            model: SystemTray.items
                            delegate: Item {
                                required property var modelData
                                readonly property bool nixed: {
                                    const id = (modelData.id || "").toLowerCase();
                                    const title = (modelData.title || "").toLowerCase();
                                    return id.indexOf("nm-applet") >= 0 || id.indexOf("network") >= 0 || title.indexOf("network") >= 0;
                                }
                                implicitWidth: nixed ? 0 : 20
                                implicitHeight: 20
                                visible: !nixed
                                Image {
                                    anchors.fill: parent
                                    source: modelData.icon
                                    sourceSize.width: 18
                                    sourceSize.height: 18
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.LeftButton)
                                            modelData.activate();
                                        else
                                            modelData.secondaryActivate();
                                    }
                                }
                            }
                        }
                        NIcon {
                            name: Network.icon
                            iconSize: 18
                            color: Network.connected ? Theme.fg2 : Theme.fg3
                        }
                        NIcon {
                            visible: Config.options.bar.showVolume
                            name: Audio.muted ? "speaker_mute" : "speaker_2"
                            iconSize: 18
                            color: Theme.fg2
                        }
                        NIcon {
                            visible: Config.options.bar.showBattery && Battery.ready
                            name: Battery.icon
                            iconSize: 18
                            color: Battery.stateColor !== "" ? Battery.stateColor : Theme.fg2
                        }
                    }
                }

                NRect {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    implicitHeight: pillSize
                    implicitWidth: centerRow.implicitWidth + Config.options.bar.pillPadding
                    corner: Tokens.rounding.xxlarge
                    fill: "bg1"
                    stroke: "subtle"
                    shadow: Config.options.bar.shadow

                    RowLayout {
                        id: centerRow
                        anchors.centerIn: parent
                        spacing: 8

                        NAvatar {
                            diameter: Config.options.bar.avatarSize
                            source: "file://" + Quickshell.env("HOME") + "/Pictures/pp.jpg" // It will be dynamic later
                            onClicked: Ui.toggleSession()
                        }

                        // search pill inset — beranimasi saat palette terbuka
                        Rectangle {
                            id: searchPill
                            visible: Config.options.bar.showSearch
                            implicitWidth: Config.options.bar.searchWidth
                            implicitHeight: 36
                            radius: Tokens.rounding.pill
                            color: Theme.bg3
                            border.width: Ui.launcherOpen ? 2 : 1
                            border.color: Ui.launcherOpen ? Theme.brandBg : Theme.stroke2
                            transformOrigin: Item.Center
                            Behavior on border.color {
                                ColorAnimation {
                                    duration: Tokens.anim.fast
                                }
                            }
                            SequentialAnimation {
                                id: searchPulse
                                ScaleAnimator {
                                    target: searchPill
                                    from: 1
                                    to: 0.94
                                    duration: 90
                                }
                                ScaleAnimator {
                                    target: searchPill
                                    from: 0.94
                                    to: 1
                                    duration: 140
                                    easing.type: Easing.OutBack
                                }
                            }
                            Connections {
                                target: Ui
                                function onLauncherOpenChanged() {
                                    if (Ui.launcherOpen)
                                        searchPulse.restart();
                                }
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8
                                NIcon {
                                    name: "search"
                                    iconSize: 16
                                    color: Ui.launcherOpen ? Theme.brandFg1 : Theme.fg3
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Tokens.anim.fast
                                        }
                                    }
                                }
                                NText {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    kind: "small"
                                    color: Theme.fg3
                                    text: "Type here to search"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!Ui.launcherOpen)
                                        Ui.toggleLauncher();
                                }
                            }
                        }

                        RowLayout {
                            visible: Config.options.bar.showWorkspaces
                            spacing: 4
                            Repeater {
                                model: Hyprland.workspaces
                                delegate: Rectangle {
                                    required property var modelData
                                    visible: modelData.monitor?.name === win.screen.name
                                    implicitWidth: 40
                                    implicitHeight: 40
                                    radius: Tokens.rounding.large
                                    color: {
                                        if (wsHover.pressed)
                                            return Theme.subtlePressed;
                                        if (modelData.focused)
                                            return Theme.light ? Theme.brand160 : Qt.rgba(0.28, 0.62, 0.96, 0.16);
                                        if (wsHover.containsMouse)
                                            return Theme.subtleHover;
                                        return "transparent";
                                    }
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Tokens.anim.faster
                                        }
                                    }
                                    NText {
                                        anchors.centerIn: parent
                                        text: modelData.id
                                        kind: "small"
                                        semibold: modelData.focused
                                        color: modelData.focused ? Theme.brandFg1 : Theme.fg2
                                    }
                                    Rectangle {
                                        visible: modelData.urgent && !modelData.focused
                                        anchors.top: parent.top
                                        anchors.topMargin: 7
                                        anchors.right: parent.right
                                        anchors.rightMargin: 7
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: "#d13438"
                                    }
                                    MouseArea {
                                        id: wsHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Hypr.workspaceById(modelData.id)
                                    }
                                }
                            }
                        }

                        NText {
                            visible: Config.options.bar.showActiveWindow
                            Layout.maximumWidth: 180
                            elide: Text.ElideMiddle
                            kind: "small"
                            color: Theme.fg3
                            text: ToplevelManager.activeToplevel?.appId ?? ToplevelManager.activeToplevel?.title ?? ""
                        }
                    }
                }
            }

            NRect {
                visible: vertical
                anchors.fill: parent
                anchors.margins: 0
                corner: Tokens.rounding.xxlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: Config.options.bar.shadow

                ColumnLayout {
                    id: vcol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    NAvatar {
                        Layout.alignment: Qt.AlignHCenter
                        diameter: Config.options.bar.avatarSize
                        source: "file://" + Quickshell.env("HOME") + "/Pictures/pp.jpg"
                        onClicked: Ui.toggleSession()
                    }
                    NIconButton {
                        Layout.alignment: Qt.AlignHCenter
                        name: "search"
                        restColor: Ui.launcherOpen ? Theme.brandFg1 : Theme.fg2
                        onClicked: Ui.toggleLauncher()
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6
                        implicitHeight: 1
                        color: Theme.stroke2
                    }

                    ColumnLayout {
                        visible: Config.options.bar.showWorkspaces
                        spacing: 4
                        Repeater {
                            model: Hyprland.workspaces
                            delegate: Rectangle {
                                required property var modelData
                                visible: modelData.monitor?.name === win.screen.name
                                implicitWidth: 40
                                implicitHeight: 40
                                radius: Tokens.rounding.large
                                color: {
                                    if (vwsHover.pressed)
                                        return Theme.subtlePressed;
                                    if (modelData.focused)
                                        return Theme.light ? Theme.brand160 : Qt.rgba(0.28, 0.62, 0.96, 0.16);
                                    if (vwsHover.containsMouse)
                                        return Theme.subtleHover;
                                    return "transparent";
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: Tokens.anim.faster
                                    }
                                }
                                NText {
                                    anchors.centerIn: parent
                                    text: modelData.id
                                    kind: "small"
                                    semibold: modelData.focused
                                    color: modelData.focused ? Theme.brandFg1 : Theme.fg2
                                }
                                MouseArea {
                                    id: vwsHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Hypr.workspaceById(modelData.id)
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6
                        implicitHeight: 1
                        color: Theme.stroke2
                    }

                    Item {
                        visible: barFull
                        Layout.fillHeight: true
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        Repeater {
                            visible: Config.options.bar.showTray
                            model: SystemTray.items
                            delegate: Item {
                                required property var modelData
                                readonly property bool nixed: {
                                    const id = (modelData.id || "").toLowerCase();
                                    const title = (modelData.title || "").toLowerCase();
                                    return id.indexOf("nm-applet") >= 0 || id.indexOf("network") >= 0 || title.indexOf("network") >= 0;
                                }
                                implicitWidth: 20
                                implicitHeight: nixed ? 0 : 20
                                visible: !nixed
                                Image {
                                    anchors.fill: parent
                                    source: modelData.icon
                                    sourceSize.width: 18
                                    sourceSize.height: 18
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.LeftButton)
                                            modelData.activate();
                                        else
                                            modelData.secondaryActivate();
                                    }
                                }
                            }
                        }
                        NIcon {
                            Layout.alignment: Qt.AlignHCenter
                            name: Network.icon
                            iconSize: 18
                            color: Network.connected ? Theme.fg2 : Theme.fg3
                        }
                        NIcon {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Config.options.bar.showVolume
                            name: Audio.muted ? "speaker_mute" : "speaker_2"
                            iconSize: 18
                            color: Theme.fg2
                        }
                        NIcon {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Config.options.bar.showBattery && Battery.ready
                            name: Battery.icon
                            iconSize: 18
                            color: Battery.stateColor !== "" ? Battery.stateColor : Theme.fg2
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6
                        implicitHeight: 1
                        color: Theme.stroke2
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 0
                        NText {
                            Layout.alignment: Qt.AlignHCenter
                            kind: "small"
                            semibold: true
                            text: Config.options.bar.clock12h ? Time.format("h:mm") : Time.format("HH:mm")
                        }
                        NText {
                            Layout.alignment: Qt.AlignHCenter
                            kind: "caption"
                            color: Theme.fg3
                            text: Time.format("AP")
                            visible: Config.options.bar.clock12h
                        }
                    }
                }
            }
        }
    }
}
