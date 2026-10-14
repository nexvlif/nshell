import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.ndesign
import qs.services

// Voice recorder via ffmpeg (PipeWire/Pulse). Keeps recording even with the
// window closed; the red dot state survives because the page stays loaded.
ColumnLayout {
    id: root
    spacing: 12

    readonly property string dir: (Quickshell.env("HOME") || "/tmp") + "/Music/Recordings"
    property bool recording: false
    property bool hasFfmpeg: false
    property int elapsed: 0
    property string lastFile: ""

    function fmt(s: int): string {
        const h = Math.floor(s / 3600);
        const m = Math.floor((s % 3600) / 60);
        const r = s % 60;
        const mm = (h > 0 && m < 10 ? "0" + m : "" + m);
        const ss = r < 10 ? "0" + r : "" + r;
        return (h > 0 ? h + ":" + mm : mm) + ":" + ss;
    }

    function stamp(): string {
        return Qt.formatDateTime(new Date(), "yyyyMMdd-HHmmss");
    }

    function toggle(): void {
        if (root.recording) {
            recProc.running = false;
            return;
        }
        if (!root.hasFfmpeg) {
            Quickshell.execDetached(["notify-send", "Recorder", "Install ffmpeg for voice recording"]);
            if (!ffCheck.running)
                ffCheck.running = true;
            return;
        }
        const f = root.dir + "/rec-" + root.stamp() + ".m4a";
        root.lastFile = f;
        recProc.command = ["ffmpeg", "-y", "-v", "error", "-f", "pulse", "-i", "default", f];
        recProc.running = true;
        root.elapsed = 0;
        root.recording = true;
    }

    Component.onCompleted: {
        if (!mkDir.running)
            mkDir.running = true;
        if (!ffCheck.running)
            ffCheck.running = true;
    }
    Process {
        id: mkDir
        command: ["mkdir", "-p", root.dir]
    }
    Process {
        id: ffCheck
        command: ["sh", "-c", "command -v ffmpeg"]
        onExited: exitCode => {
            root.hasFfmpeg = exitCode === 0;
        }
    }
    Process {
        id: recProc
        onExited: exitCode => {
            if (root.recording) {
                root.recording = false;
                Quickshell.execDetached(["notify-send", "Recorder", "Saved " + root.lastFile]);
            }
        }
    }
    Timer {
        interval: 1000
        running: root.recording
        repeat: true
        onTriggered: root.elapsed++
    }
    SequentialAnimation {
        id: pulse
        running: root.recording
        loops: Animation.Infinite
        NumberAnimation {
            target: recDot
            property: "opacity"
            to: 0.25
            duration: 600
        }
        NumberAnimation {
            target: recDot
            property: "opacity"
            to: 1
            duration: 600
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
    Rectangle {
        id: recDot
        Layout.alignment: Qt.AlignHCenter
        width: 18
        height: 18
        radius: 9
        color: root.recording ? Theme.error : Theme.fg3
    }
    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        font.family: Theme.fontFamily
        font.pixelSize: 52
        font.weight: Font.Bold
        color: Theme.fg1
        text: root.fmt(root.elapsed)
    }
    NText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        kind: "small"
        color: Theme.fg3
        text: root.recording ? "Recording… tap to stop" : (root.hasFfmpeg ? "Tap mic to record" : "Needs ffmpeg")
    }
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 76
        Layout.preferredHeight: 76
        radius: 38
        color: root.recording ? Theme.error : Theme.primary
        NIcon {
            anchors.centerIn: parent
            name: root.recording ? "stop" : "mic"
            filled: true
            iconSize: 32
            color: "#ffffff"
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggle()
        }
    }
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
    NRect {
        Layout.fillWidth: true
        visible: root.lastFile !== ""
        implicitHeight: 56
        corner: Tokens.rounding.large
        fill: "bg2"
        stroke: "none"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 8
            spacing: 8
            NIcon {
                Layout.alignment: Qt.AlignVCenter
                name: "music_note"
                iconSize: 18
                color: Theme.fg2
            }
            NText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideMiddle
                kind: "caption"
                color: Theme.fg2
                text: root.lastFile.split("/").pop()
            }
            NIconButton {
                Layout.alignment: Qt.AlignVCenter
                name: "folder_open"
                glyphSize: 18
                onClicked: Quickshell.execDetached(["xdg-open", root.dir])
            }
        }
    }
}
