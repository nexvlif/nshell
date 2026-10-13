import QtQuick
import QtQuick.Layouts
import qs.ndesign

Rectangle {
    id: root
    property string placeholder: "Search"
    property string icon: "search"
    property alias text: input.text
    property alias field: input
    signal accepted

    implicitHeight: 32
    radius: Tokens.rounding.medium
    color: Theme.bg3
    border.width: 1
    border.color: input.activeFocus ? Theme.brandStroke1 : Theme.stroke1
    Behavior on border.color {
        ColorAnimation {
            duration: Tokens.anim.fast
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
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
            font.family: Theme.fontFamily
            font.pixelSize: Tokens.font.body
            clip: true
            Keys.onReturnPressed: root.accepted()
        }
    }
    // underline
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.bottomMargin: 1
        height: input.activeFocus ? 2 : 1
        radius: 1
        color: input.activeFocus ? Theme.brandBg : Theme.stroke1
        Behavior on height {
            NumberAnimation {
                duration: Tokens.anim.fast
            }
        }
    }
}
