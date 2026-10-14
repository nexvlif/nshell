import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

NRect {
    id: root
    implicitWidth: 380
    implicitHeight: 132
    fill: "bg1"
    corner: Tokens.rounding.popover
    stroke: "none"
    shadow: 16
    readonly property var dayNames: ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
    readonly property var weekDays: {
        const t = Time.date;
        if (!t) {
            return [];
        }
        const off = (t.getDay() + 6) % 7;
        const mon = new Date(t.getFullYear(), t.getMonth(), t.getDate() - off);
        const arr = [];
        for (let i = 0; i < 7; ++i) {
            arr.push(new Date(mon.getFullYear(), mon.getMonth(), mon.getDate() + i));
        }
        return arr;
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10
        NText {
            Layout.fillWidth: true
            kind: "small"
            semibold: true
            color: Theme.fg1
            text: Time.date ? Qt.formatDateTime(Time.date, "MMMM yyyy") : ""
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: root.weekDays
                delegate: ColumnLayout {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    spacing: 6
                    NText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        kind: "caption"
                        color: Theme.fg3
                        text: root.dayNames[modelData.getDay()]
                    }
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: isToday ? Theme.active : "transparent"
                        readonly property bool isToday: {
                            const t = Time.date;
                            return t && modelData && t.getFullYear() === modelData.getFullYear() && t.getMonth() === modelData.getMonth() && t.getDate() === modelData.getDate();
                        }
                        NText {
                            anchors.centerIn: parent
                            kind: "small"
                            semibold: parent.isToday
                            color: parent.isToday ? Theme.activeFg : Theme.fg1
                            text: modelData.getDate()
                        }
                    }
                }
            }
        }
    }
}
