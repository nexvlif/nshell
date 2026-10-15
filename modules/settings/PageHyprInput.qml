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
        text: "Input & Touchpad"
    }
    SSection {
        Layout.fillWidth: true
        title: "Keyboard"
        STextRow {
            icon: "keyboard"
            title: "Layout"
            sub: "e.g. us, de, fr, us,ru"
            value: HyprConf.str("input:kb_layout", "us")
            placeholder: "us"
            onCommitted: t => {
                if (t !== "")
                    HyprConf.setStr("input:kb_layout", t);
            }
        }
        STextRow {
            icon: "keyboard"
            title: "Variant"
            value: HyprConf.str("input:kb_variant", "")
            placeholder: "(empty)"
            onCommitted: t => HyprConf.setStr("input:kb_variant", t)
        }
        STextRow {
            icon: "keyboard"
            title: "Options"
            sub: "e.g. caps:escape"
            value: HyprConf.str("input:kb_options", "")
            placeholder: "(empty)"
            onCommitted: t => HyprConf.setStr("input:kb_options", t)
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Mouse & touchpad"
        SSliderRow {
            icon: "mouse"
            title: "Sensitivity"
            value: HyprConf.num("input:sensitivity", 0)
            from: -1
            to: 1
            step: 0.05
            onMoved: v => HyprConf.setFloat("input:sensitivity", v)
        }
        SChoiceRow {
            icon: "speed"
            title: "Acceleration profile"
            options: [["flat", "Flat"], ["adaptive", "Adaptive"], ["custom", "Custom"]]
            current: HyprConf.str("input:accel_profile", "") || "flat"
            onPicked: v => HyprConf.setStr("input:accel_profile", v)
        }
        SChoiceRow {
            icon: "near_me"
            title: "Follow mouse"
            sub: "Focus follows the cursor"
            options: [[0, "Off"], [1, "On"]]
            current: Math.round(HyprConf.num("input:follow_mouse", 1))
            onPicked: v => HyprConf.setInt("input:follow_mouse", v)
        }
        SSwitchRow {
            icon: "swipe"
            title: "Natural scroll (touchpad)"
            checked: HyprConf.boolean("input:touchpad:natural_scroll", true)
            onToggled: HyprConf.setBool("input:touchpad:natural_scroll", !HyprConf.boolean("input:touchpad:natural_scroll", true))
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Misc"
        SSwitchRow {
            icon: "block"
            title: "Disable Hyprland logo"
            checked: HyprConf.boolean("misc:disable_hyprland_logo", true)
            onToggled: HyprConf.setBool("misc:disable_hyprland_logo", !HyprConf.boolean("misc:disable_hyprland_logo", true))
        }
        SSwitchRow {
            icon: "block"
            title: "Disable splash rendering"
            checked: HyprConf.boolean("misc:disable_splash_rendering", true)
            onToggled: HyprConf.setBool("misc:disable_splash_rendering", !HyprConf.boolean("misc:disable_splash_rendering", true))
        }
        SChoiceRow {
            icon: "image"
            title: "Force default wallpaper"
            options: [[0, "Off"], [1, "On"]]
            current: Math.round(HyprConf.num("misc:force_default_wallpaper", 0))
            onPicked: v => HyprConf.setInt("misc:force_default_wallpaper", v)
        }
    }
}
