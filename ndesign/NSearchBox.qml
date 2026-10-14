import QtQuick
import QtQuick.Layouts
import qs.ndesign

Rectangle {
    id: root
    property string placeholder: "Search"
    property string icon: "search"
    property int echoMode: TextInput.Normal
    property alias text: input.text
    property alias field: input
    signal accepted
    signal escapePressed

    implicitHeight: 40
    radius: Tokens.rounding.pill
    color: Theme.surfaceContainerHigh
    border.width: 0
    border.color: input.activeFocus ? Theme.fg1 : Theme.stroke1
    Behavior on border.color {
        ColorAnimation {
            duration: Tokens.anim.fast
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8
        NIcon {
            name: root.icon
            iconSize: 16
            color: Theme.fg3
        }
        TextInput {
            id: input
            Layout.fillWidth: true
            color: Theme.fg1
            echoMode: root.echoMode
            font.family: Theme.fontFamily
            font.pixelSize: Tokens.font.body
            clip: true
            Keys.onReturnPressed: root.accepted()
            Keys.onEscapePressed: root.escapePressed()
        }
    }
}
