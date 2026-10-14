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
            return "battery_full";
        if (charging)
            return percent >= 0.95 ? "battery_charging_full" : percent >= 0.8 ? "battery_charging_80" : percent >= 0.4 ? "battery_charging_50" : "battery_charging_20";
        if (critical)
            return "battery_alert";
        if (percent >= 0.95)
            return "battery_full";
        return "battery_" + Math.round(percent * 6) + "_bar";
    }
    readonly property string stateColor: {
        if (critical)
            return "#d13438";
        if (low)
            return "#da3b01";
        return "";
    }
}
