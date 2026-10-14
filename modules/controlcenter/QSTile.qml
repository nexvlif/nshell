import QtQuick
import QtQuick.Layouts
import qs.ndesign

// OneUI 9 quick tile: tonal card (radius 20) + circle icon well.
// ON = mono active well (white in dark, near-black in light, like NBattery),
// OFF = gray well. Card itself stays tonal.
Rectangle {
    id: root
    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool hasMenu: false
    signal clicked
    signal menuClicked

    implicitHeight: 68
    radius: Tokens.rounding.large
    color: {
        if (tileHover.pressed)
            return Theme.cardPressed;
        if (tileHover.containsMouse)
            return Theme.cardHover;
        return Theme.cardBg;
    }
    Behavior on color {
        ColorAnimation {
            duration: Tokens.anim.faster
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 10
        spacing: 12
        z: 1
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 44
            implicitHeight: 44
            radius: 22
            color: {
                if (tileHover.pressed)
                    return root.active ? Theme.activePressed : Theme.subtlePressed;
                if (tileHover.containsMouse)
                    return root.active ? Theme.activeHover : Theme.surfaceContainerHigh;
                return root.active ? Theme.active : Theme.surfaceContainerHigh;
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
                iconSize: 22
                color: root.active ? Theme.activeFg : Theme.surfaceVariantFg
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
        Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            visible: root.hasMenu
            NIcon {
                anchors.centerIn: parent
                name: "chevron_right"
                iconSize: 16
                color: tileHover.containsMouse ? Theme.fg1 : Theme.fg3
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.menuClicked()
            }
        }
    }
    MouseArea {
        id: tileHover
        anchors.fill: parent
        z: 0
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
