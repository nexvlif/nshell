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
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            onVisibleChanged: {
                if (visible)
                    panel.forceActiveFocus();
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
                width: 360
                implicitHeight: panelCol.implicitHeight + 32
                anchors.right: (pos === "left") ? undefined : parent.right
                anchors.left: (pos === "left") ? parent.left : undefined
                anchors.top: (pos === "top") ? parent.top : undefined
                anchors.bottom: (pos !== "top") ? parent.bottom : undefined
                anchors.margins: 12
                corner: Tokens.rounding.xlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: 16

                ColumnLayout {
                    id: panelCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 12

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8
                        QSTile {
                            Layout.fillWidth: true
                            icon: Network.icon
                            title: "Wi-Fi"
                            subtitle: !Network.wifiEnabled ? "Off" : (Network.connected ? (Network.ssid !== "" ? Network.ssid : "On") : "On")
                            active: Network.wifiEnabled
                            onClicked: Network.setWifiEnabled(!Network.wifiEnabled)
                        }
                        QSTile {
                            Layout.fillWidth: true
                            icon: Bluetooth.icon
                            title: "Bluetooth"
                            subtitle: !Bluetooth.available ? "No adapter" : (Bluetooth.connectedName !== "" ? Bluetooth.connectedName : (Bluetooth.powered ? "On" : "Off"))
                            active: Bluetooth.powered
                            onClicked: {
                                if (Bluetooth.available)
                                    Bluetooth.setPowered(!Bluetooth.powered);
                            }
                        }
                        QSTile {
                            Layout.fillWidth: true
                            icon: "weather_moon"
                            title: "Do not disturb"
                            subtitle: Notifs.dnd ? "On" : "Off"
                            active: Notifs.dnd
                            onClicked: Notifs.toggleDnd()
                        }
                        QSTile {
                            Layout.fillWidth: true
                            icon: Theme.light ? "weather_sunny" : "weather_moon"
                            title: "Theme"
                            subtitle: Theme.light ? "Light" : "Dark"
                            active: !Theme.light
                            onClicked: Config.set("theme.mode", Theme.light ? "dark" : "light")
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        NIconButton {
                            name: Audio.muted ? "speaker_mute" : "speaker_2"
                            glyphSize: 18
                            onClicked: Audio.toggleMute()
                        }
                        NSlider {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
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
                        NIcon {
                            Layout.alignment: Qt.AlignVCenter
                            name: "lightbulb"
                            iconSize: 18
                            color: Theme.fg2
                        }
                        NSlider {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
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
                }
            }
        }
    }
}
