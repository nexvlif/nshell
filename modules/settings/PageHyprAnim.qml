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
        text: "Animations"
    }
    SSection {
        Layout.fillWidth: true
        title: "Global toggle"
        desc: "Per-animation curves and speeds are defined in conf/41-animations.lua."
        SSwitchRow {
            icon: "animation"
            title: "Animations enabled"
            checked: HyprConf.boolean("animations:enabled", true)
            onToggled: HyprConf.setBool("animations:enabled", !HyprConf.boolean("animations:enabled", true))
        }
        SRow {
            icon: "code"
            title: "Fine-tune curves"
            sub: "Edit hl.curve / hl.animation blocks in conf/41-animations.lua"
            NButton {
                variant: "secondary"
                text: "Open file"
                onClicked: HyprConf.openHyprFolder()
            }
        }
    }
}
