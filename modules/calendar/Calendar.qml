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
            readonly property var barM: Config.options.bar.margins[pos] ?? Config.options.bar.margins["bottom"]
            // Safe per-edge clearance (12px default on non-bar sides).
            readonly property int vClearSafe: (pos === "top" || pos === "bottom") ? (Config.options.bar.height + barM.top + barM.bottom + 12) : 12
            readonly property int hClearSafe: (pos === "left" || pos === "right") ? (Config.options.bar.height + barM.left + barM.right + 12) : 12
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
                height: calCol.implicitHeight + 40
                x: (pos === "right") ? win.width - width - win.hClearSafe : win.hClearSafe
                y: (pos === "top") ? win.vClearSafe : win.height - height - win.vClearSafe
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 16

                ColumnLayout {
                    id: calCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 12

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
                        rowSpacing: 4
                        columnSpacing: 4
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
                                implicitHeight: 36
                                radius: Tokens.rounding.pill
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
                                    color: parent.isToday ? Theme.primaryFg : Theme.fg1
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
