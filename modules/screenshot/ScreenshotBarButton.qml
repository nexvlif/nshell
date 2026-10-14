import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

Item {
    id: root

    Layout.preferredWidth: 40
    Layout.preferredHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: Tokens.rounding.pill
        color: {
            if (Ui.screenshotOpen)
                return Theme.primary;
            if (btnHover.pressed)
                return Theme.subtlePressed;
            if (btnHover.containsMouse)
                return Theme.surfaceContainerHigh;
            return "transparent";
        }
        Behavior on color {
            ColorAnimation {
                duration: Tokens.anim.faster
            }
        }
        NIcon {
            anchors.centerIn: parent
            name: "photo_camera"
            filled: Ui.screenshotOpen || btnHover.containsMouse
            iconSize: 20
            color: Ui.screenshotOpen ? Theme.primaryFg : Theme.fg2
        }
    }
    MouseArea {
        id: btnHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.toggleScreenshot()
    }
}
