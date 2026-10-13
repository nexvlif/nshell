import QtQuick
import QtQuick.Layouts
import Quickshell
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

            property string pos: Config.options.bar.position
            readonly property var barMargins: Config.options.bar.margins[pos] ?? Config.options.bar.margins["bottom"]
            anchors {
                top: pos === "top"
                bottom: pos === "bottom"
                left: pos === "left"
                right: pos === "right"
            }
            margins {
                top: pos === "top" ? Config.options.bar.height + barMargins.top + 12 : 0
                bottom: pos === "bottom" ? Config.options.bar.height + barMargins.bottom + 12 : 0
                left: pos === "left" ? Config.options.bar.height + barMargins.left + 12 : 0
                right: pos === "right" ? Config.options.bar.height + barMargins.right + 12 : 0
            }
            implicitWidth: 580
            implicitHeight: 470
            color: "transparent"

            property string query: ""

            NRect {
                anchors.fill: parent
                corner: Tokens.rounding.xlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: 28

                onVisibleChanged: {
                    if (visible) {
                        win.query = "";
                        box.field.text = "";
                        box.field.forceActiveFocus();
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.spacing.xl
                    spacing: Tokens.spacing.m

                    NSearchBox {
                        id: box
                        Layout.fillWidth: true
                        placeholder: "Type here to search"
                        onAccepted: {
                            if (grid.count > 0) {
                                const first = grid.filtered[0];
                                if (first)
                                    launchApp(first);
                            }
                        }
                        field.onTextChanged: win.query = field.text
                        field.Keys.onEscapePressed: Ui.closeAll()
                    }

                    NText {
                        kind: "body"
                        semibold: true
                        text: "Pinned"
                    }

                    GridView {
                        id: grid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: 104
                        cellHeight: 92

                        property var filtered: {
                            const q = win.query.toLowerCase();
                            const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay);
                            if (!q)
                                return apps.slice(0, 30);
                            return apps.filter(a => (a.name + " " + (a.genericName || "") + " " + a.id).toLowerCase().includes(q)).slice(0, 30);
                        }
                        model: filtered

                        delegate: Item {
                            required property DesktopEntry modelData
                            width: 104
                            height: 92

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 3
                                radius: Tokens.rounding.medium
                                color: appHover.pressed ? Theme.subtlePressed : appHover.containsMouse ? Theme.subtleHover : "transparent"
                                Behavior on color {
                                    ColorAnimation {
                                        duration: Tokens.anim.fast
                                    }
                                }
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 4
                                    IconImage {
                                        Layout.alignment: Qt.AlignHCenter
                                        asynchronous: true
                                        source: Quickshell.iconPath(modelData?.icon, "image-missing")
                                        implicitSize: 32
                                    }
                                    NText {
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                        wrapMode: Text.WordWrap
                                        kind: "caption"
                                        color: Theme.fg1
                                        text: modelData?.name ?? ""
                                    }
                                }
                            }
                            MouseArea {
                                id: appHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: launchApp(modelData)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.s
                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: Theme.brandBg
                            NText {
                                anchors.centerIn: parent
                                text: (Quickshell.env("USER") || "n").substring(0, 1).toUpperCase()
                                color: "#ffffff"
                                kind: "title"
                            }
                        }
                        NText {
                            Layout.fillWidth: true
                            kind: "body"
                            color: Theme.fg1
                            text: Quickshell.env("USER") || "user"
                        }
                        NButton {
                            variant: "subtle"
                            icon: "power"
                            text: "Power"
                            onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
                        }
                    }
                }
            }
        }
    }

    function launchApp(entry: DesktopEntry): void {
        Ui.closeAll();
        if (entry.runInTerminal)
            Quickshell.execDetached(["xdg-terminal-exec", ...entry.command]);
        else
            entry.execute();
    }
}
