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
        text: "Decoration"
    }
    SSection {
        Layout.fillWidth: true
        title: "Corners & opacity"
        SSliderRow {
            icon: "rounded_corner"
            title: "Rounding"
            value: HyprConf.num("decoration:rounding", 12)
            from: 0
            to: 30
            step: 1
            suffix: "px"
            onMoved: v => HyprConf.setInt("decoration:rounding", Math.round(v))
        }
        SSliderRow {
            icon: "opacity"
            title: "Active opacity"
            value: HyprConf.num("decoration:active_opacity", 1)
            from: 0.3
            to: 1
            step: 0.01
            onMoved: v => HyprConf.setFloat("decoration:active_opacity", v)
        }
        SSliderRow {
            icon: "opacity"
            title: "Inactive opacity"
            value: HyprConf.num("decoration:inactive_opacity", 1)
            from: 0.3
            to: 1
            step: 0.01
            onMoved: v => HyprConf.setFloat("decoration:inactive_opacity", v)
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Shadow"
        SSwitchRow {
            icon: "shadow"
            title: "Shadow enabled"
            checked: HyprConf.boolean("decoration:shadow:enabled", true)
            onToggled: HyprConf.setBool("decoration:shadow:enabled", !HyprConf.boolean("decoration:shadow:enabled", true))
        }
        SSliderRow {
            icon: "blur_circular"
            title: "Shadow range"
            value: HyprConf.num("decoration:shadow:range", 4)
            from: 0
            to: 20
            step: 1
            suffix: "px"
            onMoved: v => HyprConf.setInt("decoration:shadow:range", Math.round(v))
        }
        SSliderRow {
            icon: "contrast"
            title: "Render power"
            value: HyprConf.num("decoration:shadow:render_power", 3)
            from: 1
            to: 4
            step: 1
            onMoved: v => HyprConf.setInt("decoration:shadow:render_power", Math.round(v))
        }
    }
}
