import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign
import qs.services

ColumnLayout {
    signal goBinds()
    Layout.fillWidth: true
    spacing: 12
    NText {
        kind: "subtitle"
        semibold: true
        text: "Launcher"
    }
    SSection {
        Layout.fillWidth: true
        title: "Results"
        SSliderRow {
            icon: "format_list_numbered"
            title: "Max shown"
            sub: "Maximum results visible at once"
            value: Config.options.launcher.maxShown
            from: 3
            to: 12
            step: 1
            onMoved: v => Config.set("launcher.maxShown", Math.round(v))
        }
        SRow {
            icon: "keyboard"
            title: "Toggle shortcut"
            sub: "Default bind is SUPER + A (see Keybindings page)"
            NButton {
                variant: "secondary"
                text: "View binds"
                onClicked: goBinds()
            }
        }
    }
}
