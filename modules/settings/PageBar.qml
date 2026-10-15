import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign
import qs.services

ColumnLayout {
    property string barPos: "bottom"
    Layout.fillWidth: true
    spacing: 12
    NText {
        kind: "subtitle"
        semibold: true
        text: "Bar"
    }
    SSection {
        Layout.fillWidth: true
        title: "Position & size"
        SChoiceRow {
            icon: "dock_to_bottom"
            title: "Position"
            sub: "Screen edge for the bar"
            options: [["top", "Top"], ["bottom", "Bottom"], ["left", "Left"], ["right", "Right"]]
            current: Config.options.bar.position
            onPicked: v => Config.set("bar.position", v)
        }
        SChoiceRow {
            visible: barPos === "left" || barPos === "right"
            icon: "vertical_align_center"
            title: "Vertical mode"
            sub: "Full stretches edge to edge, adaptive only when windows exist"
            options: [["adaptive", "Adaptive"], ["compact", "Compact"], ["full", "Full"]]
            current: Config.options.bar.verticalMode
            onPicked: v => Config.set("bar.verticalMode", v)
        }
        SSliderRow {
            icon: "height"
            title: "Bar height"
            value: Config.options.bar.height
            from: 32
            to: 72
            step: 1
            suffix: "px"
            onMoved: v => Config.set("bar.height", Math.round(v))
        }
        SSliderRow {
            icon: "padding"
            title: "Pill padding"
            value: Config.options.bar.pillPadding
            from: 8
            to: 32
            step: 1
            suffix: "px"
            onMoved: v => Config.set("bar.pillPadding", Math.round(v))
        }
        SSliderRow {
            icon: "account_circle"
            title: "Avatar size"
            value: Config.options.bar.avatarSize
            from: 24
            to: 48
            step: 1
            suffix: "px"
            onMoved: v => Config.set("bar.avatarSize", Math.round(v))
        }
        STextRow {
            icon: "photo"
            title: "Avatar image"
            value: Config.options.bar.avatarPath ?? ""
            placeholder: "/path/to/avatar (empty = ~/Pictures/pp.jpg)"
            onCommitted: text => Config.set("bar.avatarPath", text)
        }
        SSliderRow {
            icon: "shadow"
            title: "Shadow"
            value: Config.options.bar.shadow
            from: 0
            to: 24
            step: 1
            suffix: "px"
            onMoved: v => Config.set("bar.shadow", Math.round(v))
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Margins (" + barPos + ")"
        desc: "Distance from the screen edge for the current bar position."
        SSliderRow {
            title: "Top"
            value: (Config.options.bar.margins[barPos] ?? {}).top ?? 8
            from: 0
            to: 32
            step: 1
            suffix: "px"
            onMoved: v => Config.set("bar.margins." + barPos + ".top", Math.round(v))
        }
        SSliderRow {
            title: "Bottom"
            value: (Config.options.bar.margins[barPos] ?? {}).bottom ?? 8
            from: 0
            to: 32
            step: 1
            suffix: "px"
            onMoved: v => Config.set("bar.margins." + barPos + ".bottom", Math.round(v))
        }
        SSliderRow {
            title: "Left"
            value: (Config.options.bar.margins[barPos] ?? {}).left ?? 8
            from: 0
            to: 32
            step: 1
            suffix: "px"
            onMoved: v => Config.set("bar.margins." + barPos + ".left", Math.round(v))
        }
        SSliderRow {
            title: "Right"
            value: (Config.options.bar.margins[barPos] ?? {}).right ?? 8
            from: 0
            to: 32
            step: 1
            suffix: "px"
            onMoved: v => Config.set("bar.margins." + barPos + ".right", Math.round(v))
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Modules"
        desc: "Show or hide bar modules."
        SSwitchRow {
            icon: "schedule"
            title: "Clock"
            checked: Config.options.bar.showClock !== false
            onToggled: Config.set("bar.showClock", !(Config.options.bar.showClock !== false))
        }
        SSwitchRow {
            icon: "calendar_month"
            title: "Date"
            checked: Config.options.bar.showDate !== false
            onToggled: Config.set("bar.showDate", !(Config.options.bar.showDate !== false))
        }
        SSwitchRow {
            icon: "schedule"
            title: "12-hour clock"
            checked: Config.options.bar.clock12h !== false
            onToggled: Config.set("bar.clock12h", !(Config.options.bar.clock12h !== false))
        }
        SSwitchRow {
            icon: "search"
            title: "Search button"
            checked: Config.options.bar.showSearch !== false
            onToggled: Config.set("bar.showSearch", !(Config.options.bar.showSearch !== false))
        }
        SSwitchRow {
            icon: "workspaces"
            title: "Workspaces"
            checked: Config.options.bar.showWorkspaces !== false
            onToggled: Config.set("bar.showWorkspaces", !(Config.options.bar.showWorkspaces !== false))
        }
        SSwitchRow {
            icon: "mimo"
            title: "Active window"
            checked: Config.options.bar.showActiveWindow !== false
            onToggled: Config.set("bar.showActiveWindow", !(Config.options.bar.showActiveWindow !== false))
        }
        SSwitchRow {
            icon: "partly_cloudy_day"
            title: "Weather"
            checked: Config.options.bar.showWeather !== false
            onToggled: Config.set("bar.showWeather", !(Config.options.bar.showWeather !== false))
        }
        SSwitchRow {
            icon: "memory"
            title: "Resources (CPU/MEM)"
            checked: Config.options.bar.showResources === true
            onToggled: Config.set("bar.showResources", !(Config.options.bar.showResources === true))
        }
        SSwitchRow {
            icon: "construction"
            title: "Tools"
            checked: Config.options.bar.showTools !== false
            onToggled: Config.set("bar.showTools", !(Config.options.bar.showTools !== false))
        }
        SSwitchRow {
            icon: "apps"
            title: "System tray"
            checked: Config.options.bar.showTray !== false
            onToggled: Config.set("bar.showTray", !(Config.options.bar.showTray !== false))
        }
        SSwitchRow {
            icon: "volume_up"
            title: "Volume icon"
            checked: Config.options.bar.showVolume !== false
            onToggled: Config.set("bar.showVolume", !(Config.options.bar.showVolume !== false))
        }
        SSwitchRow {
            icon: "battery_full"
            title: "Battery"
            checked: Config.options.bar.showBattery !== false
            onToggled: Config.set("bar.showBattery", !(Config.options.bar.showBattery !== false))
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Pinned apps"
        SRow {
            icon: "push_pin"
            title: (Config.options.bar.pinnedApps ?? []).length + " pinned apps"
            sub: "Pin apps from the launcher. Clearing removes all pins."
            NButton {
                variant: "secondary"
                text: "Clear"
                onClicked: Config.set("bar.pinnedApps", [])
            }
        }
    }
}
