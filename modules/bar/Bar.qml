import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import qs.modules.activewindow
import qs.modules.pinned
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

                Item {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    implicitHeight: pillSize
                    implicitWidth: leftRow.implicitWidth
                    RowLayout {
                        id: leftRow
                        anchors.fill: parent
                        spacing: 8
                        NRect {
                            Layout.preferredHeight: pillSize
                            implicitWidth: clockCol.implicitWidth + Config.options.bar.pillPadding
                            corner: Tokens.rounding.xxlarge
                            fill: "bg1"
                            stroke: "subtle"
                            shadow: Config.options.bar.shadow
                            border.width: Ui.calendarOpen ? 2 : 1
                            border.color: Ui.calendarOpen ? Theme.brandBg : Theme.stroke2
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
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleCalendar()
                            }
                        }
                        NRect {
                            visible: Config.options.bar.showActiveWindow && ToplevelManager.activeToplevel !== null
                            Layout.preferredHeight: pillSize
                            implicitWidth: winText.implicitWidth + Config.options.bar.pillPadding
                            corner: Tokens.rounding.xxlarge
                            fill: "bg1"
                            stroke: "subtle"
                            shadow: Config.options.bar.shadow
                            ActiveWindow {
                                id: winText
                                anchors.centerIn: parent
                            }
                        }
                        NRect {
                            visible: Config.options.bar.showWeather
                            Layout.preferredHeight: pillSize
                            implicitWidth: wxRow.implicitWidth + Config.options.bar.pillPadding
                            corner: Tokens.rounding.xxlarge
                            fill: "bg1"
                            stroke: "subtle"
                            shadow: Config.options.bar.shadow
                            RowLayout {
                                id: wxRow
                                anchors.centerIn: parent
                                spacing: 6
                                NIcon {
                                    name: Weather.icon
                                    iconSize: 18
                                    color: Theme.fg1
                                }
                                NText {
                                    kind: "small"
                                    semibold: true
                                    text: Weather.text
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Weather.fetch()
                            }
                        }
                        NRect {
                            visible: Config.options.bar.showResources
                            Layout.preferredHeight: pillSize
                            implicitWidth: resRow.implicitWidth + Config.options.bar.pillPadding
                            corner: Tokens.rounding.xxlarge
                            fill: "bg1"
                            stroke: "subtle"
                            shadow: Config.options.bar.shadow
                            RowLayout {
                                id: resRow
                                anchors.centerIn: parent
                                spacing: 10
                                RowLayout {
                                    spacing: 4
                                    NText {
                                        kind: "caption"
                                        color: Theme.fg3
                                        text: "CPU"
                                    }
                                    NText {
                                        kind: "small"
                                        semibold: true
                                        text: Math.round(Resources.cpu * 100) + "%"
                                    }
                                }
                                RowLayout {
                                    spacing: 4
                                    NText {
                                        kind: "caption"
                                        color: Theme.fg3
                                        text: "MEM"
                                    }
                                    NText {
                                        kind: "small"
                                        semibold: true
                                        text: Math.round(Resources.mem * 100) + "%"
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    implicitHeight: pillSize
                    implicitWidth: rightRow.implicitWidth
                    RowLayout {
                        id: rightRow
                        anchors.fill: parent
                        spacing: 8
                        NRect {
                            visible: Mpris.active !== null
                            Layout.preferredHeight: pillSize
                            implicitWidth: mediaRow.implicitWidth + 20
                            corner: Tokens.rounding.xxlarge
                            fill: "bg1"
                            stroke: "subtle"
                            shadow: Config.options.bar.shadow
                            RowLayout {
                                id: mediaRow
                                anchors.centerIn: parent
                                spacing: 8
                                NRoundedImage {
                                    id: barArt
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    source: Mpris.artUrl
                                    imgRadius: Tokens.rounding.small
                                    NIcon {
                                        anchors.centerIn: parent
                                        visible: !barArt.imgReady
                                        name: "music_note_1"
                                        iconSize: 16
                                        color: Theme.fg3
                                    }
                                }
                                ColumnLayout {
                                    spacing: 0
                                    NText {
                                        Layout.maximumWidth: 140
                                        elide: Text.ElideRight
                                        kind: "small"
                                        semibold: true
                                        text: Mpris.title || "Unknown"
                                    }
                                    NText {
                                        Layout.maximumWidth: 140
                                        elide: Text.ElideRight
                                        kind: "caption"
                                        color: Theme.fg3
                                        text: Mpris.artist
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleNflyout()
                            }
                        }
                        NRect {
                            Layout.preferredHeight: pillSize
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
                                TrayIcon {
                                    anchors.fill: parent
                                    item: modelData
                                    barPos: pos
                                    trayScreen: win.screen
                                }
                            }
                        }
                        Item {
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: Network.icon
                                iconSize: 18
                                color: Network.connected ? Theme.fg2 : Theme.fg3
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleControl()
                            }
                        }
                        Item {
                            visible: Config.options.bar.showVolume
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: Audio.muted ? "speaker_mute" : "speaker_2"
                                iconSize: 18
                                color: Theme.fg2
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleControl()
                            }
                        }
                        Item {
                            visible: Config.options.bar.showBattery && Battery.ready
                            implicitWidth: battRow.implicitWidth
                            implicitHeight: 20
                            RowLayout {
                                id: battRow
                                anchors.centerIn: parent
                                spacing: 2
                                NIcon {
                                    name: Battery.icon
                                    iconSize: 18
                                    color: Battery.stateColor !== "" ? Battery.stateColor : Theme.fg2
                                }
                                NIcon {
                                    visible: Battery.charging && !Battery.critical
                                    name: "flash"
                                    filled: true
                                    iconSize: 11
                                    color: Theme.brandFg1
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleControl()
                            }
                        }
                        Item {
                            implicitWidth: 32
                            implicitHeight: 32
                            NIconButton {
                                anchors.fill: parent
                                name: Notifs.dnd ? "weather_moon" : "alert"
                                restColor: Notifs.dnd ? Theme.brandBg : (Ui.notifOpen ? Theme.brandFg1 : Theme.fg2)
                                onClicked: Ui.toggleNotif()
                            }
                            Rectangle {
                                visible: Notifs.unread > 0
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 2
                                anchors.rightMargin: 2
                                implicitWidth: Math.max(16, badgeText.implicitWidth + 8)
                                implicitHeight: 16
                                radius: 8
                                color: "#d13438"
                                NText {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    kind: "caption"
                                    color: "#ffffff"
                                    text: Notifs.unread > 99 ? "99+" : Notifs.unread
                                }
                            }
                        }
                    }
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
                        PinnedApps {
                            visible: Config.options.bar.pinnedApps.length > 0
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
                                TrayIcon {
                                    anchors.fill: parent
                                    item: modelData
                                    barPos: pos
                                    trayScreen: win.screen
                                }
                            }
                        }
                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: Network.icon
                                iconSize: 18
                                color: Network.connected ? Theme.fg2 : Theme.fg3
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleControl()
                            }
                        }
                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Config.options.bar.showVolume
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: Audio.muted ? "speaker_mute" : "speaker_2"
                                iconSize: 18
                                color: Theme.fg2
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleControl()
                            }
                        }
                        NIcon {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Config.options.bar.showBattery && Battery.ready
                            name: Battery.icon
                            iconSize: 18
                            color: Battery.stateColor !== "" ? Battery.stateColor : Theme.fg2
                        }
                        NIcon {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Config.options.bar.showBattery && Battery.ready && Battery.charging && !Battery.critical
                            name: "flash"
                            filled: true
                            iconSize: 11
                            color: Theme.brandFg1
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

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: Ui.trayMenuItem !== null && Ui.trayMenuScreen === screen
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
                if (visible)
                    menuPanel.forceActiveFocus();
            }

            readonly property int menuW: 248
            readonly property real menuX: {
                if (!Ui.trayMenuScreen)
                    return 8;
                return Math.min(Math.max(Ui.trayMenuX + 20 - menuW, 8), Ui.trayMenuScreen.width - menuW - 8);
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.closeTrayMenu()
                }
            }

            QsMenuOpener {
                id: menuOpener
                menu: Ui.trayMenuItem ? Ui.trayMenuItem.menu : null
            }

            NRect {
                id: menuPanel
                focus: true
                Keys.onEscapePressed: Ui.closeTrayMenu()
                width: menuW
                x: menuX
                y: pos === "top" ? Ui.trayMenuY + 24 : Math.max(8, Ui.trayMenuY - 4 - height)
                height: Math.min(menuFlick.contentHeight + 12, 480)
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
                            opener: menuOpener
                            onCloseRequested: Ui.closeTrayMenu()
                        }
                    }
                }
            }
        }
    }
}
