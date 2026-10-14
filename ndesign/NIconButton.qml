import QtQuick
import qs.ndesign

Rectangle {
    id: root
    property string name: "search"
    property int glyphSize: 20
    property color restColor: Theme.fg2
    signal clicked

    implicitWidth: 40
    implicitHeight: 40
    radius: Tokens.rounding.pill
    color: hoverArea.pressed ? Theme.subtlePressed : hoverArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"
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
        color: hoverArea.pressed ? Theme.fg1 : hoverArea.containsMouse ? Theme.fg1 : root.restColor
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
