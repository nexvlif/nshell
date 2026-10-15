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
        text: "Notifications & OSD"
    }
    SSection {
        Layout.fillWidth: true
        title: "Notifications"
        SSwitchRow {
            icon: "do_not_disturb_on"
            title: "Do not disturb"
            checked: Config.options.notifications.dnd === true
            onToggled: Config.set("notifications.dnd", !(Config.options.notifications.dnd === true))
        }
        SSliderRow {
            icon: "timer"
            title: "Popup timeout"
            value: Config.options.notifications.timeout
            from: 1000
            to: 10000
            step: 500
            suffix: "ms"
            onMoved: v => Config.set("notifications.timeout", Math.round(v))
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "On-screen display"
        SSliderRow {
            icon: "timer"
            title: "OSD timeout"
            value: Config.options.osd.timeout
            from: 400
            to: 3000
            step: 100
            suffix: "ms"
            onMoved: v => Config.set("osd.timeout", Math.round(v))
        }
    }
}
