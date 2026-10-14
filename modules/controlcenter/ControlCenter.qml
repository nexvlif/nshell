import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
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

            visible: Ui.controlOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            property string pos: Config.options.bar.position
            readonly property var barM: Config.options.bar.margins[pos] ?? Config.options.bar.margins["bottom"]

            readonly property int vClearSafe: (pos === "top" || pos === "bottom") ? (Config.options.bar.height + barM.top + barM.bottom + 12) : 12
            readonly property int hClearSafe: (pos === "left" || pos === "right") ? (Config.options.bar.height + barM.left + barM.right + 12) : 12
            property string pendingSsid: ""
            property string page: "main"
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            onVisibleChanged: {
                if (visible) {
                    win.page = "main";
                    win.pendingSsid = "";
                    panel.forceActiveFocus();
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.closeAll()
                }
            }

            NRect {
                id: panel
                focus: true
                Keys.onEscapePressed: Ui.closeAll()
                width: 400
                height: panelCol.implicitHeight + 40
                x: (pos === "left") ? win.hClearSafe : win.width - width - win.hClearSafe
                y: (pos === "top") ? win.vClearSafe : win.height - height - win.vClearSafe
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 16

                ColumnLayout {
                    id: panelCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: win.page === "main"
                        spacing: 16

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 12
                        QSTile {
                            Layout.fillWidth: true
                            icon: Network.icon
                            title: "Wi-Fi"
                            subtitle: !Network.wifiEnabled ? "Off" : (Network.connected ? (Network.ssid !== "" ? Network.ssid : "On") : "On")
                            active: Network.wifiEnabled
                            hasMenu: true
                            onClicked: Network.setWifiEnabled(!Network.wifiEnabled)
                            onMenuClicked: {
                                win.page = "wifi";
                                Network.scan();
                            }
                        }
                        QSTile {
                            Layout.fillWidth: true
                            icon: Bluetooth.icon
                            title: "Bluetooth"
                            subtitle: !Bluetooth.available ? "No adapter" : (Bluetooth.connectedName !== "" ? Bluetooth.connectedName : (Bluetooth.powered ? "On" : "Off"))
                            active: Bluetooth.powered
                            hasMenu: true
                            onClicked: {
                                if (Bluetooth.available)
                                    Bluetooth.setPowered(!Bluetooth.powered);
                            }
                            onMenuClicked: {
                                win.page = "bluetooth";
                                Bluetooth.poll();
                            }
                        }
                        QSTile {
                            Layout.fillWidth: true
                            icon: "do_not_disturb_on"
                            title: "Do not disturb"
                            subtitle: Notifs.dnd ? "On" : "Off"
                            active: Notifs.dnd
                            onClicked: Notifs.toggleDnd()
                        }
                        QSTile {
                            Layout.fillWidth: true
                            icon: Theme.light ? "light_mode" : "dark_mode"
                            title: "Theme"
                            subtitle: Theme.light ? "Light" : "Dark"
                            active: !Theme.light
                            onClicked: Config.set("theme.mode", Theme.light ? "dark" : "light")
                        }
                        QSTile {
                            Layout.fillWidth: true
                            Layout.columnSpan: 2
                            icon: "content_paste"
                            title: "Clipboard"
                            subtitle: Clipboard.items.length > 0 ? Clipboard.items.length + " items" : "History"
                            active: Ui.clipOpen
                            onClicked: Ui.toggleClipboard()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        NIconButton {
                            name: Audio.muted ? "volume_off" : "volume_up"
                            glyphSize: 18
                            onClicked: Audio.toggleMute()
                        }
                        NSlider {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            trackSize: 30
                            value: Audio.volume
                            onMoved: v => Audio.setVolume(v)
                        }
                        NText {
                            Layout.preferredWidth: 36
                            horizontalAlignment: Text.AlignRight
                            kind: "caption"
                            color: Theme.fg2
                            text: Math.round(Audio.volume * 100)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: Brightness.ready
                        spacing: 8
                        Item {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            Layout.alignment: Qt.AlignVCenter
                            NIcon {
                                anchors.centerIn: parent
                                name: "lightbulb"
                                iconSize: 18
                                color: Theme.fg2
                            }
                        }
                        NSlider {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            trackSize: 30
                            value: Brightness.value
                            interactive: Brightness.ready
                            onMoved: v => Brightness.setValue(v)
                        }
                        NText {
                            Layout.preferredWidth: 36
                            horizontalAlignment: Text.AlignRight
                            kind: "caption"
                            color: Theme.fg2
                            text: Math.round(Brightness.value * 100)
                        }
                    }

                    NRect {
                        Layout.fillWidth: true
                        implicitHeight: 72
                        visible: Mpris.active !== null
                        corner: Tokens.rounding.large
                        fill: "bg2"
                        stroke: "none"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            NRoundedImage {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignVCenter
                                source: Mpris.artUrl
                                imgRadius: Tokens.rounding.medium
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 0
                                NText {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    kind: "small"
                                    semibold: true
                                    maximumLineCount: 1
                                    text: Mpris.title || "Unknown title"
                                }
                                NText {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    kind: "caption"
                                    color: Theme.fg3
                                    maximumLineCount: 1
                                    text: Mpris.artist || "Unknown artist"
                                }
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "skip_previous"
                                glyphSize: 18
                                onClicked: Mpris.previous()
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: Mpris.playing ? "pause" : "play_arrow"
                                glyphSize: 18
                                onClicked: Mpris.playPause()
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "skip_next"
                                glyphSize: 18
                                onClicked: Mpris.next()
                            }
                        }
                    }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: win.page === "wifi"
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            NIconButton {
                                name: "chevron_left"
                                glyphSize: 16
                                onClicked: win.page = "main"
                            }
                            NText {
                                Layout.fillWidth: true
                                kind: "title"
                                semibold: true
                                text: "Wi-Fi"
                            }
                            NSwitch {
                                Layout.alignment: Qt.AlignVCenter
                                checked: Network.wifiEnabled
                                onClicked: Network.setWifiEnabled(!Network.wifiEnabled)
                            }
                        }

                        ColumnLayout {
                        Layout.fillWidth: true
                        visible: Network.wifiEnabled
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            NText {
                                Layout.fillWidth: true
                                kind: "caption"
                                color: Theme.fg3
                                text: Network.scanning ? "Scanning..." : Network.networks.length + " networks"
                            }
                            NIconButton {
                                name: "sync"
                                glyphSize: 14
                                onClicked: Network.scan()
                            }
                        }

                        ListView {
                            id: netList
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.min(220, Math.max(44, Network.networks.length * 44))
                            visible: Network.wifiEnabled && Network.networks.length > 0
                            clip: true
                            spacing: 2
                            model: Network.networks
                            delegate: ColumnLayout {
                                required property var modelData
                                width: ListView.view.width
                                spacing: 4

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 48
                                    radius: Tokens.rounding.large
                                    color: netHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 8
                                        NIcon {
                                            Layout.alignment: Qt.AlignVCenter
                                            name: "wifi"
                                            iconSize: 16
                                            color: modelData.inUse ? Theme.brandFg1 : Theme.fg2
                                        }
                                        NText {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            elide: Text.ElideRight
                                            kind: "small"
                                            semibold: modelData.inUse
                                            text: modelData.ssid
                                        }
                                        NIcon {
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: modelData.security !== ""
                                            name: "lock"
                                            iconSize: 12
                                            color: Theme.fg3
                                        }
                                        NText {
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: Network.connecting === modelData.ssid
                                            kind: "caption"
                                            color: Theme.fg3
                                            text: "Connecting..."
                                        }
                                        NIcon {
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: modelData.inUse && Network.connecting === ""
                                            name: "check"
                                            iconSize: 14
                                            color: Theme.brandFg1
                                        }
                                        NIcon {
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: modelData.security !== "" && !modelData.inUse
                                            name: win.pendingSsid === modelData.ssid ? "expand_more" : "chevron_right"
                                            iconSize: 14
                                            color: Theme.fg3
                                        }
                                    }
                                    MouseArea {
                                        id: netHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.inUse) {
                                                win.pendingSsid = "";
                                                Network.disconnect();
                                            } else if (modelData.security === "") {
                                                Network.connect(modelData.ssid, "");
                                            } else {
                                                win.pendingSsid = win.pendingSsid === modelData.ssid ? "" : modelData.ssid;
                                            }
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    visible: win.pendingSsid === modelData.ssid
                                    spacing: 8
                                    NSearchBox {
                                        id: pwBox
                                        Layout.fillWidth: true
                                        icon: "lock"
                                        echoMode: TextInput.Password
                                        placeholder: "Password"
                                        onAccepted: submitPw()
                                        field.Keys.onEnterPressed: submitPw()
                                    }
                                    NButton {
                                        variant: "secondary"
                                        text: Network.connecting === modelData.ssid ? "..." : "Join"
                                        onClicked: submitPw()
                                    }
                                    function submitPw(): void {
                                        if (Network.connecting !== "")
                                            return;
                                        Network.connect(modelData.ssid, pwBox.text);
                                        pwBox.text = "";
                                        win.pendingSsid = "";
                                    }
                                }
                            }
                        NText {
                            Layout.fillWidth: true
                            visible: Network.wifiEnabled && !Network.scanning && Network.networks.length === 0
                            horizontalAlignment: Text.AlignHCenter
                            kind: "caption"
                            color: Theme.fg3
                            text: "No networks found — try rescan"
                        }
                        NText {
                            Layout.fillWidth: true
                            visible: Network.wifiEnabled && Network.scanning && Network.networks.length === 0
                            horizontalAlignment: Text.AlignHCenter
                            kind: "caption"
                            color: Theme.fg3
                            text: "Scanning for networks..."
                        }
                        NText {
                            Layout.fillWidth: true
                            visible: !Network.wifiEnabled
                            horizontalAlignment: Text.AlignHCenter
                            kind: "caption"
                            color: Theme.fg3
                            text: "Wi-Fi is off"
                        }
                        NButton {
                            Layout.alignment: Qt.AlignHCenter
                            visible: !Network.wifiEnabled
                            variant: "primary"
                            text: "Turn on"
                            onClicked: Network.setWifiEnabled(true)
                        }
                        NText {
                            Layout.fillWidth: true
                            visible: Network.lastError !== ""
                            wrapMode: Text.WordWrap
                            kind: "caption"
                            color: "#d13438"
                            text: Network.lastError
                        }
                    }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: win.page === "bluetooth"
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            NIconButton {
                                name: "chevron_left"
                                glyphSize: 16
                                onClicked: win.page = "main"
                            }
                            NText {
                                Layout.fillWidth: true
                                kind: "title"
                                semibold: true
                                text: "Bluetooth"
                            }
                            NSwitch {
                                Layout.alignment: Qt.AlignVCenter
                                checked: Bluetooth.powered
                                onClicked: {
                                    if (Bluetooth.available)
                                        Bluetooth.setPowered(!Bluetooth.powered);
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 48
                            radius: Tokens.rounding.large
                            visible: Bluetooth.available && Bluetooth.powered && Bluetooth.connectedName !== ""
                            color: "transparent"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8
                                NIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: "bluetooth"
                                    iconSize: 16
                                    color: Theme.brandFg1
                                }
                                NText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    elide: Text.ElideRight
                                    kind: "small"
                                    semibold: true
                                    text: Bluetooth.connectedName
                                }
                                NIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: "check"
                                    iconSize: 14
                                    color: Theme.brandFg1
                                }
                            }
                        }
                        NText {
                            Layout.fillWidth: true
                            visible: !Bluetooth.available
                            horizontalAlignment: Text.AlignHCenter
                            kind: "caption"
                            color: Theme.fg3
                            text: "No adapter found"
                        }
                        NText {
                            Layout.fillWidth: true
                            visible: Bluetooth.available && !Bluetooth.powered
                            horizontalAlignment: Text.AlignHCenter
                            kind: "caption"
                            color: Theme.fg3
                            text: "Bluetooth is off"
                        }
                        NButton {
                            Layout.alignment: Qt.AlignHCenter
                            visible: Bluetooth.available && !Bluetooth.powered
                            variant: "primary"
                            text: "Turn on"
                            onClicked: Bluetooth.setPowered(true)
                        }
                        NText {
                            Layout.fillWidth: true
                            visible: Bluetooth.available && Bluetooth.powered && Bluetooth.connectedName === ""
                            horizontalAlignment: Text.AlignHCenter
                            kind: "caption"
                            color: Theme.fg3
                            text: "No connected devices"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: Audio.sinks.length > 1 && win.page === "main"
                        spacing: 4
                        NText {
                            kind: "caption"
                            color: Theme.fg3
                            text: "Sound output"
                        }
                        Repeater {
                            model: Audio.sinks
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 40
                                radius: Tokens.rounding.large
                                color: sinkHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8
                                    Rectangle {
                                        Layout.alignment: Qt.AlignVCenter
                                        width: 8
                                        height: 8
                                        radius: 4
                                        visible: Audio.sink === modelData
                                        color: Theme.brandBg
                                    }
                                    NText {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        elide: Text.ElideRight
                                        kind: "small"
                                        text: Audio.deviceLabel(modelData)
                                    }
                                }
                                MouseArea {
                                    id: sinkHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Audio.setDefaultSink(modelData)
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: Audio.sources.length > 1 && win.page === "main"
                        spacing: 4
                        NText {
                            kind: "caption"
                            color: Theme.fg3
                            text: "Sound input"
                        }
                        Repeater {
                            model: Audio.sources
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 40
                                radius: Tokens.rounding.large
                                color: srcHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8
                                    Rectangle {
                                        Layout.alignment: Qt.AlignVCenter
                                        width: 8
                                        height: 8
                                        radius: 4
                                        visible: Audio.source === modelData
                                        color: Theme.brandBg
                                    }
                                    NText {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        elide: Text.ElideRight
                                        kind: "small"
                                        text: Audio.deviceLabel(modelData)
                                    }
                                }
                                MouseArea {
                                    id: srcHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Audio.setDefaultSource(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
}
