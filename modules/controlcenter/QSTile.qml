import QtQuick
import QtQuick.Layouts
import qs.ndesign

NRect {
    id: root
    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked

    implicitHeight: 56
    corner: Tokens.rounding.large
    fill: "bg2"
    stroke: "none"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 10
        spacing: 10
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 32
            implicitHeight: 32
            radius: 16
            color: {
                if (tileHover.pressed)
                    return root.active ? Theme.brandBgPressed : Theme.subtlePressed;
                if (tileHover.containsMouse)
                    return root.active ? Theme.brandBgHover : Theme.subtleHover;
                return root.active ? Theme.brandBg : Theme.bg3;
            }
            Behavior on color {
                ColorAnimation {
                    duration: Tokens.anim.faster
                }
            }
            NIcon {
                anchors.centerIn: parent
                name: root.icon
                filled: root.active
                iconSize: 18
                color: root.active ? "#ffffff" : Theme.fg1
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0
            NText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                kind: "small"
                semibold: true
                text: root.title
            }
            NText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                kind: "caption"
                color: Theme.fg3
                text: root.subtitle
            }
        }
    }
    MouseArea {
        id: tileHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
