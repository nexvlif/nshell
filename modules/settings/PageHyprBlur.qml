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
        text: "Blur & Shadow"
    }
    SSection {
        Layout.fillWidth: true
        title: "Blur"
        SSwitchRow {
            icon: "blur_on"
            title: "Blur enabled"
            checked: HyprConf.boolean("decoration:blur:enabled", true)
            onToggled: HyprConf.setBool("decoration:blur:enabled", !HyprConf.boolean("decoration:blur:enabled", true))
        }
        SSliderRow {
            icon: "photo_size_select_large"
            title: "Blur size"
            value: HyprConf.num("decoration:blur:size", 3)
            from: 0
            to: 12
            step: 1
            suffix: "px"
            onMoved: v => HyprConf.setInt("decoration:blur:size", Math.round(v))
        }
        SSliderRow {
            icon: "layers"
            title: "Blur passes"
            value: HyprConf.num("decoration:blur:passes", 1)
            from: 0
            to: 4
            step: 1
            onMoved: v => HyprConf.setInt("decoration:blur:passes", Math.round(v))
        }
        SSliderRow {
            icon: "contrast"
            title: "Vibrancy"
            value: HyprConf.num("decoration:blur:vibrancy", 0.1696)
            from: 0
            to: 1
            step: 0.01
            onMoved: v => HyprConf.setFloat("decoration:blur:vibrancy", v)
        }
    }
}
