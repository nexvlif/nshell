import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign
import qs.services

ColumnLayout {
    Layout.fillWidth: true
    spacing: 12
    NText {
        kind: "subtitle"
        semibold: true
        text: "Appearance"
    }
    SSection {
        Layout.fillWidth: true
        title: "Theme"
        desc: "Applies instantly to the whole shell."
        SChoiceRow {
            icon: "dark_mode"
            title: "Color mode"
            sub: "Dark or light shell theme"
            options: [["dark", "Dark"], ["light", "Light"]]
            current: Config.options.theme.mode
            onPicked: v => Config.set("theme.mode", v)
        }
        SChoiceRow {
            icon: "palette"
            title: "Accent color"
            sub: "Recolors buttons, toggles and highlights"
            options: [["", "Auto"], ["#479ef5", "Blue"], ["#43a047", "Green"], ["#fb8c00", "Orange"], ["#e53935", "Red"], ["#8e24aa", "Purple"], ["#00acc1", "Teal"]]
            current: Config.options.theme.accent ?? ""
            onPicked: v => Config.set("theme.accent", v)
        }
    }
}
