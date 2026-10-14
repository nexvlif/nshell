import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.ndesign
import qs.services

NRect {
    id: root
    implicitWidth: 360
    implicitHeight: 216
    fill: "bg1"
    corner: Tokens.rounding.popover
    shadow: 16

    component ZoneRow: RowLayout {
        id: row
        property string city: ""
        property string zone: ""
        property string stamp: "--:--"

        function refresh() {
            zoneProc.running = true;
        }

        Component.onCompleted: refresh()

        Timer {
            interval: 30000
            running: true
            repeat: true
            onTriggered: row.refresh()
        }
        Process {
            id: zoneProc
            command: ["sh", "-c", "TZ='" + row.zone + "' date +%H:%M"]
            stdout: StdioCollector {
                onStreamFinished: row.stamp = text.trim()
            }
        }
        NText {
            Layout.fillWidth: true
            kind: "small"
            color: Theme.fg1
            text: row.city
        }
        NText {
            kind: "body"
            semibold: true
            horizontalAlignment: Text.AlignRight
            text: row.stamp
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            NIcon {
                name: "public"
                iconSize: 16
                color: Theme.fg2
            }
            NText {
                Layout.fillWidth: true
                kind: "small"
                semibold: true
                color: Theme.fg1
                text: "World clock"
            }
        }
        RowLayout {
            Layout.fillWidth: true
            NText {
                Layout.fillWidth: true
                kind: "small"
                color: Theme.fg1
                text: "Local"
            }
            NText {
                kind: "body"
                semibold: true
                horizontalAlignment: Text.AlignRight
                text: Time.format("HH:mm")
            }
        }
        ZoneRow {
            Layout.fillWidth: true
            city: "Tokyo"
            zone: "Asia/Tokyo"
        }
        ZoneRow {
            Layout.fillWidth: true
            city: "London"
            zone: "Europe/London"
        }
        ZoneRow {
            Layout.fillWidth: true
            city: "New York"
            zone: "America/New_York"
        }
    }
}
