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
            if (Ui.recordingOpen)
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
            name: Capture.recording ? "stop_circle" : "videocam"
            filled: Ui.recordingOpen || btnHover.containsMouse || Capture.recording
            iconSize: 20
            color: {
                if (Ui.recordingOpen)
                    return Theme.primaryFg;
                if (Capture.recording)
                    return Theme.error;
                return Theme.fg2;
            }
        }
        Rectangle {
            visible: Capture.recording && !Ui.recordingOpen
            anchors.top: parent.top
            anchors.topMargin: 7
            anchors.right: parent.right
            anchors.rightMargin: 7
            width: 8
            height: 8
            radius: 4
            color: Theme.error
            SequentialAnimation on opacity {
                running: Capture.recording
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.3
                    duration: 600
                }
                NumberAnimation {
                    to: 1.0
                    duration: 600
                }
            }
        }
    }
    MouseArea {
        id: btnHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.toggleRecording()
    }
}
