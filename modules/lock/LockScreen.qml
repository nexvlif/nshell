import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.ndesign
import qs.services

Scope {
    id: root

    WlSessionLock {
        id: sessionLock
        locked: Ui.lockOpen

        surface: Component {
            WlSessionLockSurface {
                id: surf
                color: "black"

                property bool helperError: false
                property int fails: 0
                property string pendingPw: ""

                Component.onCompleted: reset()

                function reset(): void {
                    if (pam.active)
                        pam.abort();
                    helperError = false;
                    fails = 0;
                    pendingPw = "";
                    errText.text = "";
                    pwBox.text = "";
                    pwBox.field.forceActiveFocus();
                }

                function tryUnlock(): void {
                    const pw = pwBox.text;
                    pwBox.text = "";
                    if (pw === "" || pam.active || coolTimer.running)
                        return;
                    helperError = false;
                    errText.text = "";
                    pendingPw = pw;
                    if (!pam.start()) {
                        pendingPw = "";
                        helperError = true;
                        errText.text = "Could not start authentication";
                    }
                }

                PamContext {
                    id: pam
                    config: "login"

                    onResponseRequiredChanged: {
                        if (!responseRequired)
                            return;
                        if (surf.pendingPw !== "") {
                            const r = surf.pendingPw;
                            surf.pendingPw = "";
                            pam.respond(r);
                        } else {
                            pam.abort();
                            surf.fails++;
                            errText.text = pam.message !== "" ? pam.message : "Authentication needs attention — see system log";
                            coolTimer.interval = Math.min(5000, surf.fails * 1000);
                            coolTimer.restart();
                            pwBox.field.forceActiveFocus();
                        }
                    }

                    onCompleted: result => {
                        surf.pendingPw = "";
                        if (result === PamResult.Success) {
                            Ui.hideLock();
                        } else if (result === PamResult.Failed || result === PamResult.MaxTries) {
                            surf.fails++;
                            errText.text = pam.message !== "" && pam.messageIsError ? pam.message : "Wrong password";
                            shake.restart();
                            coolTimer.interval = Math.min(5000, surf.fails * 1000);
                            coolTimer.restart();
                            pwBox.field.forceActiveFocus();
                        } else {
                            surf.helperError = true;
                            errText.text = pam.message !== "" ? pam.message : "Auth error — check /etc/pam.d/login";
                            pwBox.field.forceActiveFocus();
                        }
                    }
                }

                Timer {
                    id: coolTimer
                    repeat: false
                }
                SequentialAnimation {
                    id: shake
                    NumberAnimation {
                        target: cardShift
                        property: "x"
                        to: 12
                        duration: 50
                    }
                    NumberAnimation {
                        target: cardShift
                        property: "x"
                        to: -12
                        duration: 50
                    }
                    NumberAnimation {
                        target: cardShift
                        property: "x"
                        to: 8
                        duration: 50
                    }
                    NumberAnimation {
                        target: cardShift
                        property: "x"
                        to: 0
                        duration: 50
                    }
                }

                Image {
                    anchors.fill: parent
                    source: Config.options.wallpaper.path !== "" ? "file://" + Config.options.wallpaper.path : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.62)
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 84
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                        color: "#ffffff"
                        renderType: Text.QtRendering
                        text: Config.options.bar.clock12h ? Time.format("h:mm") : Time.format("HH:mm")
                    }
                    NText {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 10
                        kind: "subtitle"
                        color: "#d6d6d6"
                        text: Time.dateShort
                    }

                    NRect {
                        id: card
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 320
                        implicitHeight: authCol.implicitHeight + 40
                        corner: Tokens.rounding.popover
                        fill: "bg1"
                        stroke: "none"
                        shadow: 28
                        transform: Translate {
                            id: cardShift
                        }

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
                                NAvatar {
                                    Layout.alignment: Qt.AlignVCenter
                                    diameter: 48
                                    source: Avatar.source
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
                                        text: Quickshell.env("USER") || Quickshell.env("LOGNAME") || "user"
                                    }
                                    NText {
                                        Layout.fillWidth: true
                                        kind: "caption"
                                        color: Theme.fg3
                                        text: "Locked — enter password to unlock"
                                    }
                                }
                            }
                            NSearchBox {
                                id: pwBox
                                Layout.fillWidth: true
                                enabled: !coolTimer.running && !pam.active
                                icon: "lock"
                                echoMode: TextInput.Password
                                placeholder: coolTimer.running ? "Wait..." : pam.active ? "Checking..." : "Password"
                                onAccepted: tryUnlock()
                                onEscapePressed: {
                                    pwBox.text = "";
                                }
                            }
                            NText {
                                id: errText
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                visible: text !== ""
                                kind: "caption"
                                color: "#ffb4ab"
                                text: ""
                            }
                            NButton {
                                Layout.fillWidth: true
                                variant: "primary"
                                enabled: !coolTimer.running && !pam.active
                                text: pam.active ? "Checking..." : "Unlock"
                                onClicked: {
                                    pwBox.field.forceActiveFocus();
                                    tryUnlock();
                                }
                            }
                        }
                    }

                    NRect {
                        Layout.alignment: Qt.AlignHCenter
                        visible: Mpris.active !== null
                        implicitWidth: 320
                        implicitHeight: 64
                        corner: Tokens.rounding.popover
                        fill: "bg1"
                        stroke: "none"
                        shadow: 28
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 10
                            Item {
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 40
                                implicitHeight: 40
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 8
                                    color: Theme.surfaceContainerHigh
                                    clip: true
                                    Image {
                                        anchors.fill: parent
                                        source: Mpris.artUrl
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        visible: status === Image.Ready
                                    }
                                    NIcon {
                                        anchors.centerIn: parent
                                        visible: Mpris.artUrl === ""
                                        name: "music_note"
                                        iconSize: 20
                                        color: Theme.fg3
                                    }
                                }
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
                                    text: Mpris.title !== "" ? Mpris.title : "Nothing playing"
                                }
                                NText {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    kind: "caption"
                                    color: Theme.fg3
                                    text: Mpris.artist
                                }
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "skip_previous"
                                glyphSize: 20
                                onClicked: Mpris.previous()
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: Mpris.playing ? "pause" : "play_arrow"
                                glyphSize: 24
                                onClicked: Mpris.playPause()
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "skip_next"
                                glyphSize: 20
                                onClicked: Mpris.next()
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 6
                        spacing: 8
                        NRect {
                            implicitWidth: lockBattRow.implicitWidth + 24
                            implicitHeight: 40
                            corner: Tokens.rounding.pill
                            fill: "bg1"
                            stroke: "none"
                            shadow: 8
                            RowLayout {
                                id: lockBattRow
                                anchors.centerIn: parent
                                spacing: 6
                                NIcon {
                                    name: Battery.icon
                                    filled: Battery.charging
                                    iconSize: 16
                                    color: Theme.fg2
                                }
                                NText {
                                    kind: "caption"
                                    color: Theme.fg2
                                    text: Battery.ready ? Math.round(Battery.percent * 100) + "%" : "--"
                                }
                            }
                        }
                        NRect {
                            implicitWidth: lockNetRow.implicitWidth + 24
                            implicitHeight: 40
                            corner: Tokens.rounding.pill
                            fill: "bg1"
                            stroke: "none"
                            shadow: 8
                            RowLayout {
                                id: lockNetRow
                                anchors.centerIn: parent
                                spacing: 6
                                NIcon {
                                    name: Network.icon
                                    iconSize: 16
                                    color: Network.connected ? Theme.fg2 : Theme.fg3
                                }
                                NText {
                                    kind: "caption"
                                    color: Theme.fg2
                                    text: !Network.wifiEnabled ? "Wi-Fi off" : Network.connected ? (Network.ssid !== "" ? Network.ssid : "Connected") : "No connection"
                                }
                            }
                        }
                        NRect {
                            implicitWidth: lockCpuRow.implicitWidth + 24
                            implicitHeight: 40
                            corner: Tokens.rounding.pill
                            fill: "bg1"
                            stroke: "none"
                            shadow: 8
                            RowLayout {
                                id: lockCpuRow
                                anchors.centerIn: parent
                                spacing: 6
                                NIcon {
                                    name: "memory"
                                    iconSize: 16
                                    color: Theme.fg2
                                }
                                NText {
                                    kind: "caption"
                                    color: Theme.fg2
                                    text: Resources.ready ? "CPU " + Math.round(Resources.cpu * 100) + "%" : "CPU --"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
