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
            id: toastWin
            required property var modelData
            screen: modelData

            visible: Notifs.current !== null
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            anchors {
                top: true
                right: true
            }
            margins {
                top: 12
                right: 12
            }
            implicitWidth: 360
            implicitHeight: toastCol.implicitHeight + 24

            function sendToastReply(): void {
                const n = Notifs.current;
                if (!n || toastReply.text.trim() === "")
                    return;
                n.sendInlineReply(toastReply.text);
                toastReply.text = "";
                Notifs.dismiss(n);
            }

            NRect {
                anchors.fill: parent
                corner: Tokens.rounding.xlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: 16

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        const n = Notifs.current;
                        if (n && n.actions && n.actions.length > 0)
                            n.actions[0].invoke();
                    }
                }

                ColumnLayout {
                    id: toastCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Rectangle {
                            implicitWidth: 40
                            implicitHeight: 40
                            radius: Tokens.rounding.medium
                            color: Theme.bg3
                            IconImage {
                                anchors.centerIn: parent
                                asynchronous: true
                                implicitSize: 28
                                source: (Notifs.current && Notifs.current.image) || Quickshell.iconPath(Notifs.current ? Notifs.current.appIcon : "", "dialog-information")
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            NText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                kind: "body"
                                semibold: true
                                text: Notifs.current ? Notifs.current.summary : ""
                            }
                            NText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                kind: "caption"
                                color: Theme.fg3
                                text: Notifs.current ? Notifs.current.appName : ""
                            }
                        }
                        NIconButton {
                            name: "dismiss"
                            glyphSize: 14
                            onClicked: Notifs.dismiss(Notifs.current)
                        }
                    }
                    NText {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        kind: "small"
                        color: Theme.fg2
                        visible: (Notifs.current ? Notifs.current.body : "") !== ""
                        text: Notifs.current ? Notifs.current.body : ""
                    }
                    RowLayout {
                        visible: Notifs.current && Notifs.current.actions && Notifs.current.actions.length > 0
                        spacing: 8
                        Repeater {
                            model: Notifs.current && Notifs.current.actions ? Notifs.current.actions.slice(0, 2) : []
                            delegate: NButton {
                                required property var modelData
                                variant: "secondary"
                                text: modelData.text
                                onClicked: {
                                    modelData.invoke();
                                    Notifs.dismiss(Notifs.current);
                                }
                            }
                        }
                    }
                    RowLayout {
                        visible: Notifs.current && Notifs.current.hasInlineReply
                        spacing: 8
                        NSearchBox {
                            id: toastReply
                            Layout.fillWidth: true
                            icon: "chat"
                            placeholder: (Notifs.current && Notifs.current.inlineReplyPlaceholder) || "Reply..."
                            onAccepted: sendToastReply()
                        }
                        NIconButton {
                            name: "send"
                            glyphSize: 16
                            onClicked: sendToastReply()
                        }
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: centerWin
            required property var modelData
            screen: modelData

            visible: Ui.notifOpen
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
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 12
                corner: Tokens.rounding.xlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: 28

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        NText {
                            Layout.fillWidth: true
                            kind: "title"
                            semibold: true
                            text: "Notifications"
                        }
                        NIconButton {
                            name: "weather_moon"
                            glyphSize: 16
                            restColor: Notifs.dnd ? Theme.brandBg : Theme.fg2
                            onClicked: Notifs.toggleDnd()
                        }
                        NButton {
                            variant: "subtle"
                            text: "Clear all"
                            onClicked: Notifs.dismissAll()
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        visible: Notifs.items.length > 0
                        model: Notifs.items
                        delegate: NRect {
                            required property var modelData
                            readonly property var notif: modelData
                            width: ListView.view.width
                            implicitHeight: nCol.implicitHeight + 20
                            corner: Tokens.rounding.medium
                            fill: "bg2"
                            stroke: "subtle"
                            shadow: 0

                            function sendReply(): void {
                                if (replyBox.text.trim() === "")
                                    return;
                                notif.sendInlineReply(replyBox.text);
                                replyBox.text = "";
                                Notifs.dismiss(notif);
                            }

                            ColumnLayout {
                                id: nCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 10
                                spacing: 6
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    Rectangle {
                                        implicitWidth: 32
                                        implicitHeight: 32
                                        radius: Tokens.rounding.small
                                        color: Theme.bg3
                                        IconImage {
                                            anchors.centerIn: parent
                                            asynchronous: true
                                            implicitSize: 22
                                            source: notif.image || Quickshell.iconPath(notif.appIcon, "dialog-information")
                                        }
                                    }
                                    NText {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        kind: "small"
                                        semibold: true
                                        text: notif.summary
                                    }
                                    NIconButton {
                                        name: "dismiss"
                                        glyphSize: 12
                                        onClicked: Notifs.dismiss(notif)
                                    }
                                }
                                NText {
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 4
                                    elide: Text.ElideRight
                                    kind: "caption"
                                    color: Theme.fg2
                                    visible: notif.body !== ""
                                    text: notif.body
                                }
                                Flow {
                                    Layout.fillWidth: true
                                    visible: notif.actions.length > 0
                                    spacing: 8
                                    Repeater {
                                        model: notif.actions
                                        delegate: NButton {
                                            required property var modelData
                                            variant: "secondary"
                                            text: modelData.text
                                            onClicked: {
                                                modelData.invoke();
                                                Notifs.dismiss(notif);
                                            }
                                        }
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    visible: notif.hasInlineReply
                                    spacing: 8
                                    NSearchBox {
                                        id: replyBox
                                        Layout.fillWidth: true
                                        icon: "chat"
                                        placeholder: notif.inlineReplyPlaceholder || "Reply..."
                                        onAccepted: sendReply()
                                    }
                                    NIconButton {
                                        name: "send"
                                        glyphSize: 16
                                        onClicked: sendReply()
                                    }
                                }
                                NText {
                                    kind: "caption"
                                    color: Theme.fg3
                                    text: notif.appName
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: Notifs.items.length === 0
                        spacing: 12
                        Item {
                            Layout.fillHeight: true
                        }
                        NIcon {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            name: "alert"
                            iconSize: 40
                            color: Theme.fg3
                        }
                        NText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            kind: "body"
                            color: Theme.fg3
                            text: "All caught up"
                        }
                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }
}
