import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ndesign
import qs.services

Scope {
    id: root

    readonly property var months: ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"]
    readonly property var days: ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Ui.calendarOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            onVisibleChanged: {
                if (visible)
                    panel.forceActiveFocus();
            }

            property string pos: Config.options.bar.position
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            property date shown: new Date(Time.date.getFullYear(), Time.date.getMonth(), 1)

            function shift(m: int): void {
                shown = new Date(shown.getFullYear(), shown.getMonth() + m, 1);
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.closeAll()
                }
            }

            NRect {
                id: panel
                focus: true
                Keys.onEscapePressed: Ui.closeAll()
                width: 320
                implicitHeight: calCol.implicitHeight + 32
                anchors.left: (pos === "right") ? undefined : parent.left
                anchors.right: (pos === "right") ? parent.right : undefined
                anchors.top: (pos === "top") ? parent.top : undefined
                anchors.bottom: (pos !== "top") ? parent.bottom : undefined
                anchors.margins: 12
                corner: Tokens.rounding.xlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: 16

                ColumnLayout {
                    id: calCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        NText {
                            Layout.fillWidth: true
                            kind: "title"
                            semibold: true
                            text: months[shown.getMonth()] + " " + shown.getFullYear()
                        }
                        NIconButton {
                            name: "chevron_left"
                            onClicked: shift(-1)
                        }
                        NIconButton {
                            name: "chevron_right"
                            onClicked: shift(1)
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 7
                        rowSpacing: 2
                        columnSpacing: 2
                        Repeater {
                            model: root.days
                            delegate: NText {
                                required property var modelData
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                kind: "caption"
                                color: Theme.fg3
                                text: modelData
                            }
                        }
                        Repeater {
                            model: {
                                const y = shown.getFullYear();
                                const m = shown.getMonth();
                                const lead = new Date(y, m, 1).getDay();
                                const dim = new Date(y, m + 1, 0).getDate();
                                const cells = [];
                                for (let i = 0; i < lead; ++i)
                                    cells.push(0);
                                for (let d = 1; d <= dim; ++d)
                                    cells.push(d);
                                return cells;
                            }
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 34
                                radius: Tokens.rounding.medium
                                color: {
                                    if (modelData === 0)
                                        return "transparent";
                                    if (isToday)
                                        return Theme.brandBg;
                                    if (dayHover.containsMouse)
                                        return Theme.subtleHover;
                                    return "transparent";
                                }
                                readonly property bool isToday: {
                                    const t = Time.date;
                                    return modelData !== 0 && t.getFullYear() === shown.getFullYear() && t.getMonth() === shown.getMonth() && t.getDate() === modelData;
                                }
                                NText {
                                    anchors.centerIn: parent
                                    kind: "small"
                                    semibold: parent.isToday
                                    color: parent.isToday ? "#ffffff" : Theme.fg1
                                    text: modelData === 0 ? "" : modelData
                                }
                                MouseArea {
                                    id: dayHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: modelData !== 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
