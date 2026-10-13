pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Nerd-font / symbol-safe icon strings (text fallback, no font fetch)
    readonly property string launcher: "󰣇"
    readonly property string power: "⏻"
    readonly property string wifi: "󰖩"
    readonly property string volume: "󰕾"
    readonly property string muted: "󰖁"
    readonly property string battery: "󰁹"
}
