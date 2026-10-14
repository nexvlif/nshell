import QtQuick
import Quickshell.Widgets
import qs.ndesign

Item {
    id: root
    property string source: ""
    property string letter: "?"
    property int radius: 8

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.surfaceContainerHigh
        visible: img.status !== Image.Ready
        NText {
            anchors.centerIn: parent
            kind: "small"
            semibold: true
            color: Theme.fg2
            text: root.letter
        }
    }
    IconImage {
        id: img
        anchors.fill: parent
        asynchronous: true
        source: root.source
    }
}
