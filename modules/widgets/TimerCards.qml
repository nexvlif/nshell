import QtQuick
import QtQuick.Layouts
import qs.ndesign

Item {
    id: root
    implicitWidth: 480
    implicitHeight: 150

    function mmss(sec: int): string {
        var s = Math.max(0, Math.floor(sec));
        var m = Math.floor(s / 60);
        var r = s % 60;
        var ms = ("0" + m).slice(-2);
        var rs = ("0" + r).slice(-2);
        return ms + ":" + rs;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        NRect {
            id: focusCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            fill: "bg1"
            corner: Tokens.rounding.large
            stroke: "none"
            shadow: 8
            property int remaining: 25 * 60
            property bool running: false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                z: 1
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    NText {
                        Layout.fillWidth: true
                        kind: "caption"
                        color: Theme.fg3
                        text: "Focus"
                    }
                }
                NText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    kind: "title"
                    semibold: true
                    color: Theme.fg1
                    text: root.mmss(focusCard.remaining)
                }
            }
            MouseArea {
                anchors.fill: parent
                z: 0
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (focusCard.remaining <= 0) {
                        focusCard.remaining = 25 * 60;
                    }
                    focusCard.running = !focusCard.running;
                }
            }
            Timer {
                interval: 1000
                running: focusCard.running
                repeat: true
                onTriggered: {
                    if (focusCard.remaining > 0) {
                        focusCard.remaining -= 1;
                    }
                    if (focusCard.remaining <= 0) {
                        focusCard.running = false;
                    }
                }
            }
        }

        NRect {
            id: stopCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            fill: "bg1"
            corner: Tokens.rounding.large
            stroke: "none"
            shadow: 8
            property int elapsed: 0
            property bool running: false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                z: 1
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    NText {
                        Layout.fillWidth: true
                        kind: "caption"
                        color: Theme.fg3
                        text: "Stopwatch"
                    }
                }
                NText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    kind: "title"
                    semibold: true
                    color: Theme.fg1
                    text: root.mmss(stopCard.elapsed)
                }
            }
            MouseArea {
                anchors.fill: parent
                z: 0
                cursorShape: Qt.PointingHandCursor
                onClicked: stopCard.running = !stopCard.running
                onDoubleClicked: {
                    stopCard.elapsed = 0;
                    stopCard.running = false;
                }
            }
            Timer {
                interval: 1000
                running: stopCard.running
                repeat: true
                onTriggered: stopCard.elapsed += 1
            }
        }

        NRect {
            id: countCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            fill: "bg1"
            corner: Tokens.rounding.large
            stroke: "none"
            shadow: 8
            property int remaining: 5 * 60
            property bool running: false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                z: 1
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    NText {
                        Layout.fillWidth: true
                        kind: "caption"
                        color: Theme.fg3
                        text: "Countdown"
                    }
                }
                NText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    kind: "title"
                    semibold: true
                    color: Theme.fg1
                    text: root.mmss(countCard.remaining)
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6
                    NRect {
                        implicitWidth: 44
                        implicitHeight: 22
                        corner: Tokens.rounding.pill
                        fill: "bg2"
                        stroke: "none"
                        shadow: 0
                        NText {
                            anchors.centerIn: parent
                            kind: "caption"
                            color: Theme.fg2
                            text: "+1m"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!countCard.running) {
                                    countCard.remaining += 60;
                                }
                            }
                        }
                    }
                    NRect {
                        implicitWidth: 44
                        implicitHeight: 22
                        corner: Tokens.rounding.pill
                        fill: "bg2"
                        stroke: "none"
                        shadow: 0
                        NText {
                            anchors.centerIn: parent
                            kind: "caption"
                            color: Theme.fg2
                            text: "+5m"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!countCard.running) {
                                    countCard.remaining += 300;
                                }
                            }
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                z: 0
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (countCard.remaining <= 0) {
                        countCard.remaining = 5 * 60;
                    }
                    countCard.running = !countCard.running;
                }
            }
            Timer {
                interval: 1000
                running: countCard.running
                repeat: true
                onTriggered: {
                    if (countCard.remaining > 0) {
                        countCard.remaining -= 1;
                    }
                    if (countCard.remaining <= 0) {
                        countCard.running = false;
                    }
                }
            }
        }
    }
}
