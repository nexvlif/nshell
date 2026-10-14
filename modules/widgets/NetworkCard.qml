import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

NRect {
    id: root
    implicitWidth: 220
    implicitHeight: 150
    fill: "bg1"
    corner: Tokens.rounding.large
    stroke: "none"
    shadow: 8
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 2
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            NIcon {
                Layout.alignment: Qt.AlignVCenter
                name: Network.icon
                iconSize: 18
                color: Network.connected ? Theme.fg2 : Theme.fg3
            }
            NText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                kind: "caption"
                color: Theme.fg3
                text: "Wi-Fi"
            }
        }
        NText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            kind: "title"
            semibold: true
            color: Theme.fg1
            text: !Network.wifiEnabled ? "Off" : Network.connected ? (Network.ssid !== "" ? Network.ssid : "Connected") : "No connection"
        }
        NText {
            Layout.fillWidth: true
            elide: Text.ElideRight
            kind: "caption"
            color: Theme.fg3
            text: Network.connected && Network.signal > 0 ? "Signal " + Network.signal + "%" : Network.iface !== "" ? Network.iface : ""
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.toggleControl()
    }
}
