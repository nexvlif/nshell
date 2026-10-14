import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.ndesign

// OneUI-style battery indicator (ported from end4-pC's ClippedProgressBar +
// BatteryIndicator): rounded bar + nub tip, percentage text punched through
// the fill, filled bolt when charging, red when critical.
Item {
    id: root
    property real percent: 1 // 0..1
    property bool charging: false
    property bool critical: false
    property bool vertical: false

    readonly property color highlight: (critical && !charging) ? "#d13438" : Theme.fg1
    readonly property int barW: 30
    readonly property int barH: 18
    readonly property int tipW: 2
    readonly property int tipH: 10
    readonly property string pctText: Math.round(percent * 100)

    implicitWidth: vertical ? barH + 6 : barW + tipW + 2
    implicitHeight: vertical ? barW + tipW + 2 : barH + 4

    Item {
        anchors.centerIn: parent
        width: root.vertical ? root.implicitHeight : root.implicitWidth
        height: root.vertical ? root.implicitWidth : root.implicitHeight
        rotation: root.vertical ? -90 : 0

        Item {
            id: content
            anchors.centerIn: parent
            width: root.barW + root.tipW + 2
            height: root.barH
            visible: false

            Rectangle {
                id: track
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: root.barW
                height: root.barH
                radius: 6
                color: Theme.surfaceContainerHigh
                Rectangle {
                    id: fill
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.max(0, Math.min(1, root.percent))
                    color: root.highlight
                }
            }
            Rectangle {
                id: tip
                anchors.left: track.right
                anchors.leftMargin: 1
                anchors.verticalCenter: parent.verticalCenter
                width: root.tipW
                height: root.tipH
                radius: 1
                color: Theme.surfaceContainerHigh
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: root.highlight
                    visible: root.percent > 0.95
                }
            }
        }

        OpacityMask {
            id: rounded
            visible: false
            anchors.centerIn: parent
            width: content.width
            height: content.height
            source: content
            maskSource: Item {
                width: content.width
                height: content.height
                Rectangle {
                    width: root.barW
                    height: root.barH
                    radius: 6
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.barW + 1
                    width: root.tipW
                    height: root.tipH
                    radius: 1
                }
            }
        }

        OpacityMask {
            anchors.centerIn: parent
            width: content.width
            height: content.height
            source: rounded
            invert: true
            maskSource: Item {
                width: content.width
                height: content.height
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 1
                    NIcon {
                        Layout.alignment: Qt.AlignVCenter
                        visible: root.charging && root.percent < 1
                        name: "bolt"
                        filled: true
                        iconSize: 11
                        color: "white"
                    }
                    NText {
                        Layout.alignment: Qt.AlignVCenter
                        kind: "small"
                        semibold: true
                        color: "white"
                        text: root.charging && root.percent >= 1 ? "" : root.pctText
                    }
                }
            }
        }
    }
}
