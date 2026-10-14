import QtQuick
import qs.ndesign

Rectangle {
    id: root
    property bool checked: false
    signal clicked

    implicitWidth: 52
    implicitHeight: 32
    radius: implicitHeight / 2
    color: checked ? Theme.active : Theme.surfaceContainerHigh
    border.width: checked ? 0 : 2
    border.color: Theme.stroke1
    Behavior on color {
        ColorAnimation {
            duration: Tokens.anim.faster
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 4 : 4
        width: root.checked ? 24 : 16
        height: root.checked ? 24 : 16
        radius: width / 2
        color: root.checked ? Theme.activeFg : "#ffffff"
        Behavior on x {
            NumberAnimation {
                duration: Tokens.anim.faster
                easing.type: Easing.OutCubic
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: Tokens.anim.faster
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Tokens.anim.faster
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
