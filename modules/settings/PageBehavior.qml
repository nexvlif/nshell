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
        text: "Behavior"
    }
    SSection {
        Layout.fillWidth: true
        title: "Screen lock"
        desc: "Idle lock (AutoLock) and suspend lock (SleepLock) are built in and official. hypridle config in scripts/ is only a fallback if SleepLock misbehaves."
        SSliderRow {
            icon: "timer"
            title: "Lock after idle"
            sub: "0 disables idle lock. Coffee and game mode pause it."
            value: Config.options.lock.idleMin ?? 10
            from: 0
            to: 60
            step: 5
            suffix: "min"
            onMoved: v => Config.set("lock.idleMin", Math.round(v))
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Night light"
        desc: "Warmer screen at night. Needs hyprsunset."
        SSwitchRow {
            icon: "nightlight"
            title: "Night light"
            checked: NightLight.enabled
            onToggled: NightLight.toggle()
        }
        SSliderRow {
            icon: "thermometer"
            title: "Temperature"
            sub: "Lower is warmer"
            value: NightLight.temperature
            from: 1000
            to: 6500
            step: 100
            suffix: "K"
            onMoved: v => NightLight.setTemp(Math.round(v))
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Stay awake & performance"
        SSwitchRow {
            icon: "coffee"
            title: "Coffee"
            sub: "Inhibit idle (pauses auto-lock, not suspend)"
            checked: Coffee.enabled
            onToggled: Coffee.toggle()
        }
        SSwitchRow {
            icon: "sports_esports"
            title: "Game mode"
            sub: "Disables animations/blur, inhibits idle, max power profile"
            checked: GameMode.enabled
            onToggled: GameMode.toggle()
        }
    }
}
