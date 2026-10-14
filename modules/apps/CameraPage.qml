import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtMultimedia
import qs.ndesign
import qs.services

// Simple camera: preview, shutter, switch device, last-shot thumbnail.
// Releases the hardware whenever the page is hidden.
ColumnLayout {
    id: root
    spacing: 10

    readonly property string dir: (Quickshell.env("HOME") || "/tmp") + "/Pictures"
    property int devIdx: 0
    property string lastShot: ""
    property string err: ""

    function stamp(): string {
        return Qt.formatDateTime(new Date(), "yyyyMMdd-HHmmss");
    }
    function shoot(): void {
        if (cams.count === 0)
            return;
        root.err = "";
        cap.captureToFile(root.dir + "/nshell-cam-" + root.stamp() + ".jpg");
    }
    function cycleDevice(): void {
        if (cams.count > 1)
            root.devIdx = (root.devIdx + 1) % cams.count;
    }

    Component.onCompleted: {
        if (!mkDir.running)
            mkDir.running = true;
    }
    Process {
        id: mkDir
        command: ["mkdir", "-p", root.dir]
    }

    MediaDevices {
        id: media
    }
    // Alias with a stable name; count guards the no-camera case.
    readonly property var cams: media.videoInputs
    readonly property int camCount: cams.length

    CaptureSession {
        id: sess
        camera: Camera {
            id: cam
            active: Ui.appsOpen && Ui.appPage === "camera" && root.camCount > 0
            cameraDevice: root.camCount > 0 ? cams[root.devIdx % root.camCount] : media.defaultVideoInput
            onErrorOccurred: (error, errorString) => {
                root.err = errorString !== "" ? errorString : "Camera error";
            }
        }
        imageCapture: ImageCapture {
            id: cap
            onImageSaved: (requestId, path) => {
                root.lastShot = path;
                Quickshell.execDetached(["notify-send", "Camera", "Saved " + path]);
            }
            onErrorOccurred: (requestId, error, errorString) => {
                root.err = errorString !== "" ? errorString : "Capture failed";
            }
        }
        videoOutput: preview
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 300
        radius: Tokens.rounding.large
        color: Theme.surfaceContainerHigh
        clip: true

        VideoOutput {
            id: preview
            anchors.fill: parent
            visible: root.camCount > 0
            fillMode: VideoOutput.PreserveAspectCrop
        }
        ColumnLayout {
            anchors.centerIn: parent
            visible: root.camCount === 0
            spacing: 8
            NIcon {
                Layout.alignment: Qt.AlignHCenter
                name: "videocam_off"
                iconSize: 48
                color: Theme.fg3
            }
            NText {
                Layout.alignment: Qt.AlignHCenter
                kind: "small"
                color: Theme.fg3
                text: "No camera found"
            }
        }
        NText {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            visible: root.err !== ""
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            kind: "caption"
            color: "#ffb4ab"
            text: root.err
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56
            radius: 12
            color: Theme.surfaceContainerHigh
            clip: true
            visible: root.lastShot !== ""
            Image {
                anchors.fill: parent
                source: root.lastShot !== "" ? "file://" + root.lastShot : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
            NIcon {
                anchors.centerIn: parent
                visible: false
                name: "image"
                iconSize: 20
                color: Theme.fg3
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["xdg-open", root.lastShot])
            }
        }
        Item {
            Layout.fillWidth: true
        }
        Rectangle {
            Layout.preferredWidth: 68
            Layout.preferredHeight: 68
            radius: 34
            color: "transparent"
            border.width: 3
            border.color: shutterHover.pressed ? Theme.pressed(Theme.fg1, 0.3) : Theme.fg1
            enabled: root.camCount > 0
            opacity: root.camCount > 0 ? 1 : 0.35
            Rectangle {
                anchors.centerIn: parent
                width: 54
                height: 54
                radius: 27
                color: shutterHover.pressed ? Theme.pressed(Theme.fg1, 0.3) : Theme.fg1
            }
            MouseArea {
                id: shutterHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.shoot()
            }
        }
        Item {
            Layout.fillWidth: true
        }
        NIconButton {
            Layout.alignment: Qt.AlignVCenter
            name: "cameraswitch"
            glyphSize: 24
            enabled: root.camCount > 1
            onClicked: root.cycleDevice()
        }
    }
    NText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        visible: root.camCount > 1
        kind: "caption"
        color: Theme.fg3
        elide: Text.ElideRight
        text: {
            const d = root.camCount > 0 ? cams[root.devIdx % root.camCount] : null;
            return d ? d.description : "";
        }
    }
}
