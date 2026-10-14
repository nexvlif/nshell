import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import qs.modules.activewindow
import qs.modules.pinned
import qs.modules.screenshot
import qs.modules.recording
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
                            visible: Config.options.bar.showClock
                            implicitWidth: clockRow.implicitWidth + Config.options.bar.pillPadding
                            corner: Tokens.rounding.xxlarge
                            fill: "bg1"
                            stroke: "subtle"
                            shadow: Config.options.bar.shadow
                            border.width: Ui.calendarOpen ? 2 : 1
                            border.color: Ui.calendarOpen ? Theme.brandBg : Theme.stroke2
                            RowLayout {
                                id: clockRow
                                anchors.centerIn: parent
                                spacing: 8
                                NIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: "schedule"
                                    filled: Ui.calendarOpen
                                    iconSize: 18
                                    color: Ui.calendarOpen ? Theme.fg1 : Theme.fg2
                                }
                                NText {
                                    Layout.alignment: Qt.AlignVCenter
                                    kind: "body"
                                    semibold: true
                                    text: Config.options.bar.clock12h ? Time.timeShort : Time.format("HH:mm")
                                }
                                NText {
                                    Layout.alignment: Qt.AlignVCenter
                                    kind: "small"
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
                                    imgRadius: Tokens.rounding.pill
                                    NIcon {
                                        anchors.centerIn: parent
                                        visible: !barArt.imgReady
                                        name: "music_note"
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
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: Bluetooth.icon
                                filled: Bluetooth.connectedName !== ""
                                iconSize: 18
                                color: Bluetooth.connectedName !== "" ? Theme.fg2 : Theme.fg3
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
                                name: Audio.muted ? "volume_off" : "volume_up"
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
                            implicitHeight: 22
                            RowLayout {
                                id: battRow
                                anchors.centerIn: parent
                                spacing: 2
                                NBattery {
                                    Layout.alignment: Qt.AlignVCenter
                                    percent: Battery.percent
                                    charging: Battery.charging
                                    critical: Battery.critical
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleControl()
                            }
                        }
                        Item {
                            visible: Coffee.enabled
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: "coffee"
                                iconSize: 18
                                color: Theme.brandBg
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Coffee.toggle()
                            }
                        }
                        Item {
                            visible: GameMode.enabled
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: "sports_esports"
                                iconSize: 18
                                color: Theme.brandBg
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: GameMode.toggle()
                            }
                        }
                        Item {
                            implicitWidth: 32
                            implicitHeight: 32
                            NIconButton {
                                anchors.fill: parent
                                name: Notifs.dnd ? "notifications_off" : "notifications"
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
                                color: Theme.error
                                NText {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    kind: "caption"
                                    color: Theme.light ? "#ffffff" : "#1d1b20"
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
                            source: Avatar.source
                            onClicked: Ui.toggleSession()
                        }

                        NIconButton {
                            visible: Config.options.bar.showSearch
                            name: "search"
                            glyphSize: 20
                            restColor: Ui.launcherOpen ? Theme.fg1 : Theme.fg2
                            onClicked: Ui.toggleLauncher()
                        }

                        RowLayout {
                            visible: Config.options.bar.showWorkspaces
                            spacing: 4
                            Repeater {
                                model: Hyprland.workspaces
                                delegate: Rectangle {
                                    required property var modelData
                                    visible: modelData.monitor?.name === win.screen.name

                                    implicitWidth: modelData.focused ? 48 : 32
                                    implicitHeight: 32
                                    radius: Tokens.rounding.pill
                                    color: {
                                        if (wsHover.pressed)
                                            return Theme.pressed(Theme.primary, 0.15);
                                        if (modelData.focused)
                                            return Theme.primary;
                                        if (wsHover.containsMouse)
                                            return Theme.surfaceContainerHigh;
                                        return Theme.surfaceContainerHigh;
                                    }
                                    opacity: modelData.focused ? 1 : 0.72
                                    Behavior on implicitWidth {
                                        NumberAnimation {
                                            duration: Tokens.anim.fast
                                            easing.type: Easing.OutCubic
                                        }
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
                                        color: modelData.focused ? Theme.primaryFg : Theme.fg2
                                    }
                                    Rectangle {
                                        visible: modelData.urgent && !modelData.focused
                                        anchors.top: parent.top
                                        anchors.topMargin: 6
                                        anchors.right: parent.right
                                        anchors.rightMargin: 6
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: Theme.error
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
                        RowLayout {
                            visible: Config.options.bar.showTools
                            spacing: 0
                            ScreenshotBarButton {}
                            RecordingBarButton {}
                            NIconButton {
                                name: "colorize"
                                glyphSize: 20
                                onClicked: Capture.pick()
                            }
                            NIconButton {
                                name: "photo_library"
                                glyphSize: 20
                                onClicked: Ui.toggleGallery()
                            }
                            NIconButton {
                                name: "folder"
                                glyphSize: 20
                                restColor: Ui.fileOpen ? Theme.fg1 : Theme.fg2
                                onClicked: Ui.toggleFileManager()
                            }
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
                        source: Avatar.source
                        onClicked: Ui.toggleSession()
                    }
                    NIconButton {
                        Layout.alignment: Qt.AlignHCenter
                        name: "search"
                        restColor: Ui.launcherOpen ? Theme.brandFg1 : Theme.fg2
                        onClicked: Ui.toggleLauncher()
                    }

                    Rectangle {
                        visible: false
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
                                implicitWidth: 32
                                implicitHeight: modelData.focused ? 48 : 32
                                radius: Tokens.rounding.pill
                                color: {
                                    if (vwsHover.pressed)
                                        return Theme.pressed(Theme.primary, 0.15);
                                    if (modelData.focused)
                                        return Theme.primary;
                                    if (vwsHover.containsMouse)
                                        return Theme.surfaceContainerHigh;
                                    return Theme.surfaceContainerHigh;
                                }
                                opacity: modelData.focused ? 1 : 0.72
                                Behavior on implicitHeight {
                                    NumberAnimation {
                                        duration: Tokens.anim.fast
                                        easing.type: Easing.OutCubic
                                    }
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
                                    color: modelData.focused ? Theme.primaryFg : Theme.fg2
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
                        visible: false
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
                                name: Audio.muted ? "volume_off" : "volume_up"
                                iconSize: 18
                                color: Theme.fg2
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleControl()
                            }
                        }
                        NBattery {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Config.options.bar.showBattery && Battery.ready
                            vertical: true
                            percent: Battery.percent
                            charging: Battery.charging
                            critical: Battery.critical
                        }
                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: Bluetooth.icon
                                filled: Bluetooth.connectedName !== ""
                                iconSize: 18
                                color: Bluetooth.connectedName !== "" ? Theme.fg2 : Theme.fg3
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Ui.toggleControl()
                            }
                        }
                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Coffee.enabled
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: "coffee"
                                iconSize: 18
                                color: Theme.brandBg
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Coffee.toggle()
                            }
                        }
                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            visible: GameMode.enabled
                            implicitWidth: 20
                            implicitHeight: 20
                            NIcon {
                                anchors.centerIn: parent
                                name: "sports_esports"
                                iconSize: 18
                                color: Theme.brandBg
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: GameMode.toggle()
                            }
                        }
                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 32
                            implicitHeight: 32
                            NIconButton {
                                anchors.fill: parent
                                name: Notifs.dnd ? "notifications_off" : "notifications"
                                restColor: Notifs.dnd ? Theme.brandBg : (Ui.notifOpen ? Theme.brandFg1 : Theme.fg2)
                                onClicked: Ui.toggleNotif()
                            }
                            Rectangle {
                                visible: Notifs.unread > 0
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 2
                                anchors.rightMargin: 2
                                implicitWidth: 10
                                implicitHeight: 10
                                radius: 5
                                color: Theme.error
                            }
                        }
                        NIconButton {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Config.options.bar.showTools
                            name: "photo_camera"
                            glyphSize: 20
                            restColor: Ui.screenshotOpen ? Theme.fg1 : Theme.fg2
                            onClicked: Ui.toggleScreenshot()
                        }
                        NIconButton {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Config.options.bar.showTools
                            name: Capture.recording ? "stop_circle" : "videocam"
                            glyphSize: 20
                            restColor: Ui.recordingOpen ? Theme.fg1 : Capture.recording ? Theme.error : Theme.fg2
                            onClicked: Ui.toggleRecording()
                        }
                    }

                    Rectangle {
                        visible: false
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
                height: Math.min(menuFlick.contentHeight + 16, 480)
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 16

                Flickable {
                    id: menuFlick
                    anchors.fill: parent
                    anchors.margins: 8
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
