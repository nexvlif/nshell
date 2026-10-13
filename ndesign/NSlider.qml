import QtQuick
import qs.ndesign

Rectangle {
    id: root
    property real value: 0
    property bool interactive: true
    signal moved(real v)

    implicitHeight: 20
    color: "transparent"

    readonly property real ratio: Math.max(0, Math.min(1, drag.active ? drag.v : root.value))

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: (drag.hovered || drag.active) ? 6 : 4
        radius: height / 2
        color: Theme.stroke2
        Behavior on height {
            NumberAnimation {
                duration: Tokens.anim.faster
            }
        }
        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * root.ratio
            height: parent.height
            radius: height / 2
            color: drag.active ? Theme.brandBgPressed : Theme.brandBg
        }
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: parent.width * root.ratio - width / 2
        width: (drag.hovered || drag.active) ? 18 : 14
        height: width
        radius: width / 2
        color: Theme.brandBg
        border.width: 3
        border.color: Theme.bg1
        Behavior on width {
            NumberAnimation {
                duration: Tokens.anim.faster
            }
        }
    }
    MouseArea {
        id: drag
        property bool active: false
        property real v: 0
        property bool hovered: containsMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: root.interactive
        onPressed: mouse => {
            active = true;
            v = Math.max(0, Math.min(1, mouse.x / width));
            root.moved(v);
        }
        onPositionChanged: mouse => {
            if (active) {
                v = Math.max(0, Math.min(1, mouse.x / width));
                root.moved(v);
            }
        }
        onReleased: active = false
    }
}
