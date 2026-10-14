import QtQuick
import QtQuick.Layouts
import qs.ndesign

SRow {
    id: root
    property var options: []
    property var current: ""
    signal picked(var v)

    Flow {
        spacing: 6
        Repeater {
            model: root.options
            delegate: Rectangle {
                required property var modelData
                readonly property bool sel: modelData[0] === root.current
                implicitWidth: Math.max(56, optText.implicitWidth + 24)
                implicitHeight: 32
                radius: Tokens.rounding.pill
                color: sel ? Theme.active : Theme.surfaceContainerHigh
                NText {
                    id: optText
                    anchors.centerIn: parent
                    kind: "caption"
                    semibold: sel
                    color: sel ? Theme.activeFg : Theme.fg2
                    text: modelData[1]
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.picked(modelData[0])
                }
            }
        }
    }
}
