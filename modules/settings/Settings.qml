import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ndesign
import qs.services

Scope {
    id: root
    property string page: "appearance"
    property string query: ""
    property string bindQuery: ""

    readonly property var nav: [
        {
            "group": "nshell"
        },
        {
            "id": "appearance",
            "icon": "palette",
            "label": "Appearance"
        },
        {
            "id": "bar",
            "icon": "dock_to_bottom",
            "label": "Bar"
        },
        {
            "id": "widgets",
            "icon": "widgets",
            "label": "Widgets"
        },
        {
            "id": "wallpaper",
            "icon": "image",
            "label": "Wallpaper"
        },
        {
            "id": "panels",
            "icon": "notifications",
            "label": "Notifications & OSD"
        },
        {
            "id": "launcher",
            "icon": "search",
            "label": "Launcher"
        },
        {
            "id": "behavior",
            "icon": "settings_suggest",
            "label": "Behavior"
        },
        {
            "group": "Hyprland"
        },
        {
            "id": "hypr-general",
            "icon": "grid_view",
            "label": "General & Layout"
        },
        {
            "id": "hypr-decor",
            "icon": "rounded_corner",
            "label": "Decoration"
        },
        {
            "id": "hypr-blur",
            "icon": "blur_on",
            "label": "Blur & Shadow"
        },
        {
            "id": "hypr-anim",
            "icon": "animation",
            "label": "Animations"
        },
        {
            "id": "hypr-input",
            "icon": "keyboard",
            "label": "Input & Touchpad"
        },
        {
            "id": "hypr-binds",
            "icon": "key",
            "label": "Keybindings"
        },
        {
            "group": "System"
        },
        {
            "id": "about",
            "icon": "info",
            "label": "System & Files"
        }
    ]

    function navMatch(label: string): bool {
        if (root.query.trim() === "")
            return true;
        return label.toLowerCase().indexOf(root.query.trim().toLowerCase()) >= 0;
    }

    readonly property string barPos: Config.options.bar.position
    readonly property var bindFiltered: HyprConf.binds.filter(b => {
        root.bindQuery;
        const q = root.bindQuery.trim().toLowerCase();
        if (q === "")
            return true;
        const hay = (HyprConf.bindText(b) + " " + (b.dispatcher || "") + " " + (b.arg || "") + " " + (b.description || "")).toLowerCase();
        return hay.indexOf(q) >= 0;
    })

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Ui.settingsOpen
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
                    panel.forceActiveFocus();
                    HyprConf.refresh();
                    HyprConf.loadBinds();
                    HyprConf.checkIntegrated();
                    Backup.refreshList();
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45)
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.settingsOpen = false
                }
            }

            NRect {
                id: panel
                focus: true
                Keys.onEscapePressed: Ui.settingsOpen = false
                width: Math.min(1040, win.width - 48)
                height: Math.min(660, win.height - 48)
                anchors.centerIn: parent
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 28

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    ColumnLayout {
                        Layout.preferredWidth: 250
                        Layout.minimumWidth: 250
                        Layout.maximumWidth: 250
                        Layout.fillHeight: true
                        Layout.topMargin: 16
                        Layout.bottomMargin: 16
                        Layout.leftMargin: 16
                        Layout.rightMargin: 8
                        spacing: 8

                        NText {
                            Layout.fillWidth: true
                            kind: "title"
                            semibold: true
                            text: "Settings"
                        }
                        NSearchBox {
                            Layout.fillWidth: true
                            placeholder: "Search settings"
                            onAccepted: root.query = text
                            field.onTextChanged: root.query = text
                        }
                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentHeight: navCol.implicitHeight
                            ColumnLayout {
                                id: navCol
                                width: parent.width
                                spacing: 2
                                Repeater {
                                    model: root.nav
                                    delegate: Item {
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        implicitHeight: modelData.group !== undefined ? (root.navMatch("") ? 28 : 28) : (root.navMatch(modelData.label) ? 40 : 0)
                                        visible: modelData.group !== undefined ? true : root.navMatch(modelData.label)
                                        NText {
                                            visible: modelData.group !== undefined
                                            anchors.left: parent.left
                                            anchors.leftMargin: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            kind: "caption"
                                            color: Theme.fg3
                                            text: modelData.group !== undefined ? modelData.group : ""
                                        }
                                        Rectangle {
                                            visible: modelData.group === undefined
                                            anchors.fill: parent
                                            radius: Tokens.rounding.large
                                            color: root.page === modelData.id ? Theme.primaryContainer : navHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 12
                                                anchors.rightMargin: 12
                                                spacing: 10
                                                NIcon {
                                                    Layout.alignment: Qt.AlignVCenter
                                                    name: modelData.icon ?? "circle"
                                                    filled: root.page === modelData.id
                                                    iconSize: 18
                                                    color: root.page === modelData.id ? Theme.primaryContainerFg : Theme.fg2
                                                }
                                                NText {
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                    elide: Text.ElideRight
                                                    kind: "small"
                                                    semibold: root.page === modelData.id
                                                    text: modelData.label ?? ""
                                                }
                                            }
                                            MouseArea {
                                                id: navHover
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.page = modelData.id
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: Theme.stroke2
                    }

                    Flickable {
                        id: flick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 16
                        Layout.bottomMargin: 16
                        Layout.leftMargin: 12
                        Layout.rightMargin: 16
                        clip: true
                        contentWidth: width
                        contentHeight: contentCol.implicitHeight
                        ColumnLayout {
                            id: contentCol
                            width: flick.width
                            spacing: 18

                            PageAppearance {
                                visible: root.page === "appearance"
                            }

                            PageBar {
                                visible: root.page === "bar"
                                barPos: root.barPos
                            }

                            PageWidgets {
                                visible: root.page === "widgets"
                            }

                            PageWallpaper {
                                visible: root.page === "wallpaper"
                                screen: win.screen
                            }

                            PagePanels {
                                visible: root.page === "panels"
                            }

                            PageLauncher {
                                visible: root.page === "launcher"
                                onGoBinds: {
                                    root.page = "hypr-binds";
                                    root.bindQuery = "launcher";
                                }
                            }

                            PageBehavior {
                                visible: root.page === "behavior"
                            }

                            PageHyprGeneral {
                                visible: root.page === "hypr-general"
                            }

                            PageHyprDecor {
                                visible: root.page === "hypr-decor"
                            }

                            PageHyprBlur {
                                visible: root.page === "hypr-blur"
                            }

                            PageHyprAnim {
                                visible: root.page === "hypr-anim"
                            }

                            PageHyprInput {
                                visible: root.page === "hypr-input"
                            }

                            PageHyprBinds {
                                visible: root.page === "hypr-binds"
                                bindQuery: root.bindQuery
                                bindFiltered: root.bindFiltered
                                onQueryChanged: text => root.bindQuery = text
                            }

                            PageAbout {
                                visible: root.page === "about"
                            }
                        }
                    }
                }
            }
        }
    }
}
