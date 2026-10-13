pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root
    readonly property bool ready: UPower.displayDevice?.isLaptopBattery ?? false
    readonly property real percent: ready ? UPower.displayDevice.percentage : 1
    readonly property bool charging: ready ? (UPower.displayDevice.state === UPowerDeviceState.Charging) : false
    readonly property bool low: ready && !charging && percent <= 0.2
    readonly property bool critical: ready && !charging && percent <= 0.1
    readonly property int level: Math.max(0, Math.min(10, Math.round(percent * 10)))
    readonly property string icon: {
        if (!ready)
            return "battery_10";
        if (critical)
            return "battery_warning";
        if (charging)
            return "battery_charge_" + level;
        return "battery_" + level;
    }
    readonly property string stateColor: {
        if (critical)
            return "#d13438";
        if (low)
            return "#da3b01";
        return "";
    }
}
