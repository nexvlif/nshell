import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.ndesign

Rectangle {
    id: root
    property int diameter: 32
    property string source: ""
    property string fallback: (Quickshell.env("USER") || "n").substring(0, 1).toUpperCase()
    signal clicked

    implicitWidth: diameter
    implicitHeight: diameter
    radius: diameter / 2
    color: Theme.active
    border.width: 2
    border.color: hoverArea.containsMouse ? Theme.active : Theme.stroke1
    Behavior on border.width {
        NumberAnimation {
            duration: Tokens.anim.faster
        }
    }

    Image {
        id: photo
        anchors.fill: parent
        anchors.margins: 2
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        mipmap: true
        smooth: true
        visible: status === Image.Ready
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: photo.width
                height: photo.height
                visible: false
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                }
            }
        }
    }
    NText {
        anchors.centerIn: parent
        visible: photo.status !== Image.Ready
        text: root.fallback
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
