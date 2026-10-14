import QtQuick
import qs.ndesign

Rectangle {
    id: root
    signal clicked

    implicitWidth: 32
    implicitHeight: 32
    radius: Tokens.rounding.large
    color: hoverArea.pressed ? Theme.activePressed : hoverArea.containsMouse ? Theme.activeHover : Theme.active
    Behavior on color {
        ColorAnimation {
            duration: Tokens.anim.faster
        }
    }

    gradient: Gradient {
        GradientStop {
            position: 0
            color: Qt.lighter(root.color, 1.15)
        }
        GradientStop {
            position: 1
            color: root.color
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 1
        anchors.leftMargin: 7
        anchors.rightMargin: 7
        height: 1
        radius: 1
        color: Qt.rgba(1, 1, 1, 0.35)
    }

    NText {
        anchors.centerIn: parent
        text: "n"
        kind: "title"
        semibold: true
        color: Theme.activeFg
    }
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
