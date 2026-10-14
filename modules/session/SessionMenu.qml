import QtQuick
import QtQuick.Layouts
import Quickshell
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

            visible: Ui.sessionOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            property string pos: Config.options.bar.position
            anchors {
                top: pos === "top"
                bottom: pos === "bottom"
                left: pos === "left"
                right: pos === "right"
            }
            margins {
                top: pos === "top" ? Config.options.bar.height + 16 : 0
                bottom: pos === "bottom" ? Config.options.bar.height + 16 : 0
                left: pos === "left" ? Config.options.bar.height + 16 : 0
                right: pos === "right" ? Config.options.bar.height + 16 : 0
            }
            implicitWidth: 300
            implicitHeight: menuCol.implicitHeight + 32

            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: Ui.closeAll()
            }

            NRect {
                anchors.fill: parent
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 16

                ColumnLayout {
                    id: menuCol
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8
                        spacing: 12
                        NAvatar {
                            diameter: 40
                            source: Avatar.source
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            NText {
                                kind: "body"
                                semibold: true
                                text: Quickshell.env("USER") || "user"
                            }
                            NText {
                                kind: "caption"
                                color: Theme.fg3
                                text: Time.dateShort
                            }
                        }
                    }

                    NButton {
                        Layout.fillWidth: true
                        variant: "subtle"
                        icon: "lock"
                        text: "Lock"
                        onClicked: {
                            Ui.closeAll();
                            Session.lock();
                        }
                    }
                    NButton {
                        Layout.fillWidth: true
                        variant: "subtle"
                        icon: "bedtime"
                        text: "Sleep"
                        onClicked: {
                            Ui.closeAll();
                            Session.suspend();
                        }
                    }
                    NButton {
                        Layout.fillWidth: true
                        variant: "subtle"
                        icon: "logout"
                        text: "Log out"
                        onClicked: {
                            Ui.closeAll();
                            Session.logout();
                        }
                    }
                    NButton {
                        Layout.fillWidth: true
                        variant: "subtle"
                        icon: "restart_alt"
                        text: "Restart"
                        onClicked: {
                            Ui.closeAll();
                            Session.reboot();
                        }
                    }
                    NButton {
                        Layout.fillWidth: true
                        variant: "subtle"
                        icon: "power_settings_new"
                        text: "Shut down"
                        onClicked: {
                            Ui.closeAll();
                            Session.poweroff();
                        }
                    }
                }
            }
        }
    }
}
