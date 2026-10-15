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
        text: "General & Layout"
    }
    NText {
        visible: !HyprConf.ready
        kind: "caption"
        color: Theme.fg3
        text: "Reading live Hyprland values..."
    }
    SSection {
        Layout.fillWidth: true
        title: "Gaps & borders"
        desc: "Applied instantly via hl.config and saved to nshell-managed.lua."
        SSliderRow {
            icon: "border_inner"
            title: "Gaps in"
            sub: "Space between windows"
            value: HyprConf.num("general:gaps_in", 5)
            from: 0
            to: 30
            step: 1
            suffix: "px"
            onMoved: v => HyprConf.setInt("general:gaps_in", Math.round(v))
        }
        SSliderRow {
            icon: "border_outer"
            title: "Gaps out"
            sub: "Space between windows and screen edge"
            value: HyprConf.num("general:gaps_out", 10)
            from: 0
            to: 40
            step: 1
            suffix: "px"
            onMoved: v => HyprConf.setInt("general:gaps_out", Math.round(v))
        }
        SSliderRow {
            icon: "border_style"
            title: "Border size"
            value: HyprConf.num("general:border_size", 2)
            from: 0
            to: 10
            step: 1
            suffix: "px"
            onMoved: v => HyprConf.setInt("general:border_size", Math.round(v))
        }
        STextRow {
            icon: "border_color"
            title: "Active border"
            sub: "Gradient: two colors + angle, e.g. rgba(77,159,255,0.9) rgba(77,159,255,0.9) 45deg"
            value: HyprConf.str("general:col.active_border", "")
            placeholder: "color1 color2 45deg"
            onCommitted: t => {
                if (t !== "")
                    HyprConf.setStr("general:col.active_border", t);
            }
        }
        STextRow {
            icon: "border_color"
            title: "Inactive border"
            value: HyprConf.str("general:col.inactive_border", "")
            placeholder: "rgba(131313aa)"
            onCommitted: t => {
                if (t !== "")
                    HyprConf.setStr("general:col.inactive_border", t);
            }
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Layout & behavior"
        SChoiceRow {
            icon: "grid_view"
            title: "Layout"
            options: [["dwindle", "Dwindle"], ["master", "Master"], ["scrolling", "Scrolling"]]
            current: HyprConf.str("general:layout", "dwindle")
            onPicked: v => HyprConf.setStr("general:layout", v)
        }
        SSwitchRow {
            icon: "open_in_full"
            title: "Resize on border"
            sub: "Resize windows by dragging borders and gaps"
            checked: HyprConf.boolean("general:resize_on_border", true)
            onToggled: HyprConf.setBool("general:resize_on_border", !HyprConf.boolean("general:resize_on_border", true))
        }
        SSwitchRow {
            icon: "warning"
            title: "Allow tearing"
            sub: "See Hyprland tearing wiki before enabling"
            checked: HyprConf.boolean("general:allow_tearing", false)
            onToggled: HyprConf.setBool("general:allow_tearing", !HyprConf.boolean("general:allow_tearing", false))
        }
    }
}
