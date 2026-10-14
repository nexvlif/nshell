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
                name: Battery.icon
                filled: Battery.charging
                iconSize: 18
                color: Theme.fg2
            }
            NText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                kind: "caption"
                color: Theme.fg3
                text: "Battery"
            }
        }
        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 40
            font.family: Theme.fontFamily
            font.weight: Font.Bold
            color: Battery.critical ? Theme.error : Theme.fg1
            renderType: Text.QtRendering
            text: Battery.ready ? Math.round(Battery.percent * 100) + "%" : "--"
        }
        NText {
            Layout.fillWidth: true
            elide: Text.ElideRight
            kind: "caption"
            color: Theme.fg3
            text: !Battery.ready ? "No battery" : Battery.charging ? "Charging" : Battery.low ? "Low" : "Discharging"
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.toggleControl()
    }
}
