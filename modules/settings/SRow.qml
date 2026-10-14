import QtQuick
import QtQuick.Layouts
import qs.ndesign

NRect {
    id: root
    property string icon: ""
    property string title: ""
    property string sub: ""
    default property alias action: slot.children

    Layout.fillWidth: true
    implicitHeight: Math.max(58, row.implicitHeight + 20)
    corner: Tokens.rounding.large
    fill: "bg2"
    stroke: "none"

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12
        NIcon {
            visible: root.icon !== ""
            Layout.alignment: Qt.AlignVCenter
            name: root.icon
            iconSize: 20
            color: Theme.fg2
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2
            NText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                kind: "small"
                semibold: true
                text: root.title
            }
            NText {
                visible: root.sub !== ""
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                kind: "caption"
                color: Theme.fg3
                text: root.sub
            }
        }
        RowLayout {
            id: slot
            Layout.alignment: Qt.AlignVCenter
            spacing: 8
        }
    }
}
