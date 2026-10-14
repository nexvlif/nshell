import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

Rectangle {
    id: root
    required property string icon
    required property string title
    required property string sub
    property bool selected: false
    signal clicked

    Layout.fillWidth: true
    implicitHeight: 84
    radius: Tokens.rounding.large
    color: {
        if (selected)
            return Theme.primaryContainer;
        if (hover.containsMouse)
            return Theme.surfaceContainerHigh;
        return Theme.bg2;
    }
    border.width: selected ? 2 : 0
    border.color: Theme.brandBg
    Behavior on color {
        ColorAnimation {
            duration: Tokens.anim.faster
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2
        NIcon {
            Layout.alignment: Qt.AlignHCenter
            name: root.icon
            filled: root.selected || hover.containsMouse
            iconSize: 22
            color: root.selected ? Theme.fg1 : Theme.fg2
        }
        NText {
            Layout.alignment: Qt.AlignHCenter
            kind: "small"
            semibold: root.selected
            color: Theme.fg1
            text: root.title
        }
        NText {
            Layout.alignment: Qt.AlignHCenter
            kind: "caption"
            color: Theme.fg3
            text: root.sub
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
