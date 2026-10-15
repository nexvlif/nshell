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
        text: "Widgets"
    }
    SSection {
        Layout.fillWidth: true
        title: "Desktop widgets"
        desc: "Floating cards on the wallpaper. Unlock positions, then drag cards."
        SSwitchRow {
            icon: "widgets"
            title: "Show widgets"
            checked: Config.options.widgets.enabled !== false
            onToggled: Config.set("widgets.enabled", !(Config.options.widgets.enabled !== false))
        }
        SSwitchRow {
            icon: "lock"
            title: "Lock positions"
            sub: "Unlock to drag cards around"
            checked: Config.options.widgets.locked !== false
            onToggled: Config.set("widgets.locked", !(Config.options.widgets.locked !== false))
        }
        Repeater {
            model: WidgetReg.widgets
            delegate: SSwitchRow {
                required property var modelData
                title: modelData.title
                checked: Config.options.widgets[modelData.id] ?? modelData.on
                onToggled: Config.set("widgets." + modelData.id, !(Config.options.widgets[modelData.id] ?? modelData.on))
            }
        }
        SRow {
            icon: "restart_alt"
            title: "Reset card positions"
            sub: "Cards return to their default layout"
            NButton {
                variant: "secondary"
                text: "Reset"
                onClicked: Config.set("widgets.pos", "")
            }
        }
        STextRow {
            icon: "image"
            title: "Image card path"
            value: Config.options.widgets.imagePath ?? ""
            placeholder: "/path/to/image (or pick from Widgets)"
            onCommitted: text => Config.set("widgets.imagePath", text)
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Weather"
        desc: "Auto uses IP geolocation. Turn it off to pin a city."
        SSwitchRow {
            icon: "explore"
            title: "Auto-detect location"
            sub: "Off = use the manual coordinates below"
            checked: Config.options.weather.autoLocate !== false
            onToggled: Weather.setAuto(!(Config.options.weather.autoLocate !== false))
        }
        STextRow {
            icon: "location_city"
            title: "City label"
            value: (Config.options.weather.autoLocate !== false ? Weather.place : (Config.options.weather.place ?? "")) ?? ""
            placeholder: Weather.place || "e.g. Jakarta"
            onCommitted: text => {
                Config.set("weather.place", text);
                if (text !== "")
                    Weather.place = text;
            }
        }
        STextRow {
            icon: "height"
            title: "Latitude"
            value: (Config.options.weather.autoLocate !== false || (Config.options.weather.lat ?? 9999) >= 9000) ? "" : String(Config.options.weather.lat)
            placeholder: String(Math.round(Weather.lat * 100) / 100)
            onCommitted: text => {
                const v = parseFloat(text);
                if (!isNaN(v) && v >= -90 && v <= 90)
                    Weather.setManual(v, Weather.lon, Config.options.weather.place ?? Weather.place);
            }
        }
        STextRow {
            icon: "width"
            title: "Longitude"
            value: (Config.options.weather.autoLocate !== false || (Config.options.weather.lon ?? 9999) >= 9000) ? "" : String(Config.options.weather.lon)
            placeholder: String(Math.round(Weather.lon * 100) / 100)
            onCommitted: text => {
                const v = parseFloat(text);
                if (!isNaN(v) && v >= -180 && v <= 180)
                    Weather.setManual(Weather.lat, v, Config.options.weather.place ?? Weather.place);
            }
        }
        SRow {
            icon: "sync"
            title: "Weather data"
            sub: Weather.ready ? (Weather.place || "Local") + " · " + Weather.text + " " + Weather.desc : "Not loaded yet"
            NButton {
                variant: "secondary"
                text: "Refresh"
                onClicked: {
                    if (Config.options.weather.autoLocate !== false)
                        Weather.locate();
                    else
                        Weather.fetch();
                }
            }
        }
    }
}
