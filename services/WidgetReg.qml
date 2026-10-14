pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // ax: 0 = left, 1 = center, 2 = right. ox = pixel offset from anchor.
    // dy = pixels below the top row. on = default visibility for new configs.
    // Adding a widget = drop its card .qml next to Widgets.qml + one line here.
    readonly property var widgets: [
        {
            id: "stats",
            title: "Stats tiles",
            file: "StatTiles.qml",
            w: 480,
            h: 140,
            ax: 0,
            ox: 12,
            dy: 0,
            on: true
        },
        {
            id: "clock",
            title: "Clock",
            file: "ClockCard.qml",
            w: 340,
            h: 150,
            ax: 1,
            ox: 0,
            dy: 0,
            on: true
        },
        {
            id: "weather",
            title: "Weather",
            file: "WeatherCard.qml",
            w: 380,
            h: 180,
            ax: 2,
            ox: 12,
            dy: 0,
            on: true
        },
        {
            id: "timers",
            title: "Timers",
            file: "TimerCards.qml",
            w: 480,
            h: 150,
            ax: 0,
            ox: 12,
            dy: 192,
            on: true
        },
        {
            id: "week",
            title: "Week strip",
            file: "WeekStrip.qml",
            w: 380,
            h: 132,
            ax: 1,
            ox: 0,
            dy: 162,
            on: true
        },
        {
            id: "worldclock",
            title: "World clock",
            file: "WorldClock.qml",
            w: 360,
            h: 216,
            ax: 2,
            ox: 12,
            dy: 192,
            on: true
        },
        {
            id: "todo",
            title: "To-Do",
            file: "TodoCard.qml",
            w: 300,
            h: 300,
            ax: 0,
            ox: 12,
            dy: 420,
            on: true
        },
        {
            id: "notes",
            title: "Notes",
            file: "NotesCard.qml",
            w: 300,
            h: 300,
            ax: 0,
            ox: 324,
            dy: 420,
            on: true
        },
        {
            id: "media",
            title: "Media",
            file: "MediaCard.qml",
            w: 380,
            h: 148,
            ax: 2,
            ox: 12,
            dy: 420,
            on: true
        },
        {
            id: "battery",
            title: "Battery",
            file: "BatteryCard.qml",
            w: 220,
            h: 150,
            ax: 0,
            ox: 504,
            dy: 192,
            on: true
        },
        {
            id: "net",
            title: "Network",
            file: "NetworkCard.qml",
            w: 220,
            h: 150,
            ax: 0,
            ox: 1162,
            dy: 192,
            on: true
        },
        {
            id: "image",
            title: "Image",
            file: "ImageCard.qml",
            w: 300,
            h: 300,
            ax: 0,
            ox: 636,
            dy: 420,
            on: true
        }
    ]

    function byId(id: string): var {
        for (const w of widgets) {
            if (w.id === id)
                return w;
        }
        return null;
    }
}
