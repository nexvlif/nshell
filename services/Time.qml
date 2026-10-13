pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property var date: clock.date

    function format(fmt: string): string {
        if (!clock.date)
            return "";
        return Qt.formatDateTime(clock.date, fmt);
    }
    readonly property string timeShort: format("h:mm AP")
    readonly property string dateShort: format("ddd dd/MM/yyyy")

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
