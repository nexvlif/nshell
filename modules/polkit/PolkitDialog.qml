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

            visible: Polkit.hasRequest
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            onVisibleChanged: {
                if (visible) {
                    pwBox.text = "";
                    Polkit.clearNote();
                    pwBox.field.forceActiveFocus();
                }
            }

            function submitPw(): void {
                const pw = pwBox.text;
                pwBox.text = "";
                if (pw === "" && !Polkit.responseVisible)
                    return;
                Polkit.submit(pw);
                pwBox.field.forceActiveFocus();
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.55)
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Polkit.cancel();
                    }
                }
            }

            NRect {
                id: card
                anchors.centerIn: parent
                implicitWidth: 340
                implicitHeight: authCol.implicitHeight + 40
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 28

                ColumnLayout {
                    id: authCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        NIcon {
                            Layout.alignment: Qt.AlignVCenter
                            name: Polkit.iconName !== "" ? Polkit.iconName : "admin_panel_settings"
                            iconSize: 40
                            color: Theme.brandBg
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0
                            NText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                kind: "body"
                                semibold: true
                                text: "Authentication required"
                            }
                            NText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                kind: "caption"
                                color: Theme.fg3
                                text: Polkit.actionId !== "" ? Polkit.actionId : "A system action needs your password"
                            }
                        }
                    }
                    NText {
                        Layout.fillWidth: true
                        visible: Polkit.message !== ""
                        wrapMode: Text.Wrap
                        kind: "caption"
                        color: Theme.fg2
                        text: Polkit.message
                    }
                    NSearchBox {
                        id: pwBox
                        Layout.fillWidth: true
                        icon: "lock"
                        echoMode: Polkit.responseVisible ? TextInput.Normal : TextInput.Password
                        placeholder: Polkit.inputPrompt !== "" ? Polkit.inputPrompt : "Password"
                        onAccepted: submitPw()
                        onEscapePressed: Polkit.cancel()
                    }
                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        visible: text !== ""
                        wrapMode: Text.Wrap
                        kind: "caption"
                        color: Polkit.noteIsError ? "#ffb4ab" : Theme.fg2
                        text: Polkit.note
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        NButton {
                            Layout.fillWidth: true
                            variant: "secondary"
                            text: "Cancel"
                            onClicked: Polkit.cancel()
                        }
                        NButton {
                            Layout.fillWidth: true
                            variant: "primary"
                            text: "Authenticate"
                            onClicked: {
                                pwBox.field.forceActiveFocus();
                                submitPw();
                            }
                        }
                    }
                }
            }
        }
    }
}
