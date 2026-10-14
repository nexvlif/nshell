import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

NRect {
    id: root
    implicitWidth: 340
    implicitHeight: 150
    fill: "bg1"
    corner: Tokens.rounding.popover
    stroke: "none"
    shadow: 16
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 0
        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 58
            font.family: Theme.fontFamily
            font.weight: Font.Bold
            color: Theme.fg1
            renderType: Text.QtRendering
            text: Config.options.bar.clock12h ? Time.format("h:mm") : Time.format("HH:mm")
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            NText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                kind: "small"
                color: Theme.fg2
                text: Time.dateShort
            }
            NText {
                visible: Config.options.bar.clock12h
                kind: "small"
                color: Theme.fg3
                text: Time.format("AP")
            }
            NText {
                kind: "small"
                color: Theme.fg3
                text: Time.format("ss")
            }
        }
    }
}
