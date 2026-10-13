import QtQuick
import qs.ndesign

Rectangle {
    id: root
    property string name: "search"
    property int glyphSize: 20
    property color restColor: Theme.fg2
    signal clicked

    implicitWidth: 32
    implicitHeight: 32
    radius: Tokens.rounding.medium
    color: hoverArea.pressed ? Theme.subtlePressed : hoverArea.containsMouse ? Theme.subtleHover : "transparent"
    Behavior on color {
        ColorAnimation {
            duration: Tokens.anim.faster
        }
    }

    NIcon {
        anchors.centerIn: parent
        name: root.name
        filled: hoverArea.containsMouse || hoverArea.pressed
        iconSize: root.glyphSize
        color: hoverArea.pressed ? Theme.brandIconPressed : hoverArea.containsMouse ? Theme.brandIconHover : root.restColor
        Behavior on color {
            ColorAnimation {
                duration: Tokens.anim.faster
            }
        }
    }
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
