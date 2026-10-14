import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

Item {
    id: root
    implicitWidth: 480
    implicitHeight: 140
    RowLayout {
        anchors.fill: parent
        spacing: 12
        NRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            corner: Tokens.rounding.large
            fill: "bg1"
            stroke: "none"
            shadow: 8
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: Theme.surfaceContainerHigh
                        NIcon {
                            anchors.centerIn: parent
                            name: "memory"
                            iconSize: 16
                            color: Theme.fg2
                        }
                    }
                }
                NText {
                    Layout.fillWidth: true
                    kind: "title"
                    semibold: true
                    color: Theme.fg1
                    elide: Text.ElideRight
                    text: Resources.ready ? Math.round(Resources.cpu * 100) + "%" : "--"
                }
                NText {
                    Layout.fillWidth: true
                    kind: "caption"
                    color: Theme.fg3
                    elide: Text.ElideRight
                    text: "CPU"
                }
            }
        }
        NRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            corner: Tokens.rounding.large
            fill: "bg1"
            stroke: "none"
            shadow: 8
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: Theme.surfaceContainerHigh
                        NIcon {
                            anchors.centerIn: parent
                            name: "storage"
                            iconSize: 16
                            color: Theme.fg2
                        }
                    }
                }
                NText {
                    Layout.fillWidth: true
                    kind: "title"
                    semibold: true
                    color: Theme.fg1
                    elide: Text.ElideRight
                    text: Resources.ready ? Math.round(Resources.mem * 100) + "%" : "--"
                }
                NText {
                    Layout.fillWidth: true
                    kind: "caption"
                    color: Theme.fg3
                    elide: Text.ElideRight
                    text: "RAM"
                }
            }
        }
        NRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            corner: Tokens.rounding.large
            fill: "bg1"
            stroke: "none"
            shadow: 8
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: Theme.surfaceContainerHigh
                        NIcon {
                            anchors.centerIn: parent
                            name: "bolt"
                            iconSize: 16
                            color: Theme.fg2
                            filled: Battery.charging
                        }
                    }
                }
                NText {
                    Layout.fillWidth: true
                    kind: "title"
                    semibold: true
                    color: Battery.critical ? Theme.error : Theme.fg1
                    elide: Text.ElideRight
                    text: Battery.ready ? Math.round(Battery.percent * 100) + "%" : "--"
                }
                NText {
                    Layout.fillWidth: true
                    kind: "caption"
                    color: Theme.fg3
                    elide: Text.ElideRight
                    text: "Battery"
                }
            }
        }
        NRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            corner: Tokens.rounding.large
            fill: "bg1"
            stroke: "none"
            shadow: 8
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: Theme.surfaceContainerHigh
                        NIcon {
                            anchors.centerIn: parent
                            name: "save"
                            iconSize: 16
                            color: Theme.fg2
                        }
                    }
                }
                NText {
                    Layout.fillWidth: true
                    kind: "title"
                    semibold: true
                    color: Theme.fg1
                    elide: Text.ElideRight
                    text: Resources.ready ? Math.round(Resources.disk * 100) + "%" : "--"
                }
                NText {
                    Layout.fillWidth: true
                    kind: "caption"
                    color: Theme.fg3
                    elide: Text.ElideRight
                    text: "Disk"
                }
            }
        }
    }
}
