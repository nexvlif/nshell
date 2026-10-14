import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Config.options.widgets.enabled
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            property string pos: Config.options.bar.position
            readonly property var barM: Config.options.bar.margins[pos] ?? Config.options.bar.margins["bottom"]
            readonly property int y0: (pos === "top") ? Config.options.bar.height + barM.top + barM.bottom + 12 : 12
            readonly property int y1: y0 + 192
            readonly property int y2: y1 + 228

            function posMap(): var {
                try {
                    const o = JSON.parse(Config.options.widgets.pos || "{}");
                    return (o && typeof o === "object") ? o : {};
                } catch (e) {
                    return {};
                }
            }
            function posX(name: string, dx: real): real {
                const p = posMap()[name];
                return (p && p.length === 2) ? p[0] : dx;
            }
            function posY(name: string, dy: real): real {
                const p = posMap()[name];
                return (p && p.length === 2) ? p[1] : dy;
            }
            function commitPos(name: string, px: real, py: real): void {
                if (Ui.wallMoveTarget !== "") {
                    px = Math.round(px / 48) * 48;
                    py = Math.round(py / 48) * 48;
                }
                const o = posMap();
                o[name] = [Math.round(px), Math.round(py)];
                Config.set("widgets.pos", JSON.stringify(o));
                Ui.wallMoveTarget = "";
            }
            function unlocked(name: string): bool {
                return (Config.options.widgets.locked === false) && (Config.options.widgets[name] === true);
            }
            function moveActive(name: string): bool {
                if (!unlocked(name))
                    return false;
                return Ui.wallMoveTarget === "" || Ui.wallMoveTarget === name;
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: mouse => Ui.openWallMenu(mouse.x, mouse.y, win.screen)
            }
            Canvas {
                anchors.fill: parent
                visible: Ui.wallMoveTarget !== ""
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onVisibleChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = "rgba(140,140,140,0.22)";
                    ctx.lineWidth = 1;
                    for (let gx = 0; gx <= width; gx += 48) {
                        ctx.beginPath();
                        ctx.moveTo(gx + 0.5, 0);
                        ctx.lineTo(gx + 0.5, height);
                        ctx.stroke();
                    }
                    for (let gy = 0; gy <= height; gy += 48) {
                        ctx.beginPath();
                        ctx.moveTo(0, gy + 0.5);
                        ctx.lineTo(width, gy + 0.5);
                        ctx.stroke();
                    }
                }
            }

            Item {
                id: statsWrap
                x: win.posX("stats", 12)
                y: win.posY("stats", win.y0)
                width: 480
                height: 140
                StatTiles {
                    anchors.fill: parent
                    visible: Config.options.widgets.stats
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("stats")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: statsWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("stats", statsWrap.x, statsWrap.y);
                        statsWrap.x = Qt.binding(function() { return win.posX("stats", 12); });
                        statsWrap.y = Qt.binding(function() { return win.posY("stats", win.y0); });
                    }
                }
            }
            Item {
                id: clockWrap
                x: win.posX("clock", (win.width - 340) / 2)
                y: win.posY("clock", win.y0)
                width: 340
                height: 150
                ClockCard {
                    anchors.fill: parent
                    visible: Config.options.widgets.clock
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("clock")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: clockWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("clock", clockWrap.x, clockWrap.y);
                        clockWrap.x = Qt.binding(function() { return win.posX("clock", (win.width - 340) / 2); });
                        clockWrap.y = Qt.binding(function() { return win.posY("clock", win.y0); });
                    }
                }
            }
            Item {
                id: weatherWrap
                x: win.posX("weather", win.width - 380 - 12)
                y: win.posY("weather", win.y0)
                width: 380
                height: 180
                WeatherCard {
                    anchors.fill: parent
                    visible: Config.options.widgets.weather
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("weather")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: weatherWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("weather", weatherWrap.x, weatherWrap.y);
                        weatherWrap.x = Qt.binding(function() { return win.posX("weather", win.width - 380 - 12); });
                        weatherWrap.y = Qt.binding(function() { return win.posY("weather", win.y0); });
                    }
                }
            }
            Item {
                id: timersWrap
                x: win.posX("timers", 12)
                y: win.posY("timers", win.y1)
                width: 480
                height: 150
                TimerCards {
                    anchors.fill: parent
                    visible: Config.options.widgets.timers
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("timers")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: timersWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("timers", timersWrap.x, timersWrap.y);
                        timersWrap.x = Qt.binding(function() { return win.posX("timers", 12); });
                        timersWrap.y = Qt.binding(function() { return win.posY("timers", win.y1); });
                    }
                }
            }
            Item {
                id: weekWrap
                x: win.posX("week", (win.width - 380) / 2)
                y: win.posY("week", win.y0 + 162)
                width: 380
                height: 132
                WeekStrip {
                    anchors.fill: parent
                    visible: Config.options.widgets.week
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("week")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: weekWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("week", weekWrap.x, weekWrap.y);
                        weekWrap.x = Qt.binding(function() { return win.posX("week", (win.width - 380) / 2); });
                        weekWrap.y = Qt.binding(function() { return win.posY("week", win.y0 + 162); });
                    }
                }
            }
            Item {
                id: worldWrap
                x: win.posX("worldclock", win.width - 360 - 12)
                y: win.posY("worldclock", win.y1)
                width: 360
                height: 216
                WorldClock {
                    anchors.fill: parent
                    visible: Config.options.widgets.worldclock
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("worldclock")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: worldWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("worldclock", worldWrap.x, worldWrap.y);
                        worldWrap.x = Qt.binding(function() { return win.posX("worldclock", win.width - 360 - 12); });
                        worldWrap.y = Qt.binding(function() { return win.posY("worldclock", win.y1); });
                    }
                }
            }
            Item {
                id: todoWrap
                x: win.posX("todo", 12)
                y: win.posY("todo", win.y2)
                width: 300
                height: 300
                TodoCard {
                    anchors.fill: parent
                    visible: Config.options.widgets.todo
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("todo")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: todoWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("todo", todoWrap.x, todoWrap.y);
                        todoWrap.x = Qt.binding(function() { return win.posX("todo", 12); });
                        todoWrap.y = Qt.binding(function() { return win.posY("todo", win.y2); });
                    }
                }
            }
            Item {
                id: notesWrap
                x: win.posX("notes", 324)
                y: win.posY("notes", win.y2)
                width: 300
                height: 300
                NotesCard {
                    anchors.fill: parent
                    visible: Config.options.widgets.notes
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("notes")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: notesWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("notes", notesWrap.x, notesWrap.y);
                        notesWrap.x = Qt.binding(function() { return win.posX("notes", 324); });
                        notesWrap.y = Qt.binding(function() { return win.posY("notes", win.y2); });
                    }
                }
            }
            Item {
                id: mediaWrap
                x: win.posX("media", win.width - 380 - 12)
                y: win.posY("media", win.y2)
                width: 380
                height: 148
                MediaCard {
                    anchors.fill: parent
                    visible: Config.options.widgets.media
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("media")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: mediaWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("media", mediaWrap.x, mediaWrap.y);
                        mediaWrap.x = Qt.binding(function() { return win.posX("media", win.width - 380 - 12); });
                        mediaWrap.y = Qt.binding(function() { return win.posY("media", win.y2); });
                    }
                }
            }
            Item {
                id: batteryWrap
                x: win.posX("battery", 504)
                y: win.posY("battery", win.y1)
                width: 220
                height: 150
                BatteryCard {
                    anchors.fill: parent
                    visible: Config.options.widgets.battery
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("battery")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: batteryWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("battery", batteryWrap.x, batteryWrap.y);
                        batteryWrap.x = Qt.binding(function() { return win.posX("battery", 504); });
                        batteryWrap.y = Qt.binding(function() { return win.posY("battery", win.y1); });
                    }
                }
            }
            Item {
                id: netWrap
                x: win.posX("net", 1162)
                y: win.posY("net", win.y1)
                width: 220
                height: 150
                NetworkCard {
                    anchors.fill: parent
                    visible: Config.options.widgets.net
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("net")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: netWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("net", netWrap.x, netWrap.y);
                        netWrap.x = Qt.binding(function() { return win.posX("net", 1162); });
                        netWrap.y = Qt.binding(function() { return win.posY("net", win.y1); });
                    }
                }
            }
            Item {
                id: imageWrap
                x: win.posX("image", 636)
                y: win.posY("image", win.y2)
                width: 300
                height: 300
                ImageCard {
                    anchors.fill: parent
                    visible: Config.options.widgets.image
                    screen: win.screen
                }
                MouseArea {
                    anchors.fill: parent
                    visible: win.moveActive("image")
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    drag.target: imageWrap
                    drag.axis: Drag.XAndYAxis
                    onReleased: {
                        win.commitPos("image", imageWrap.x, imageWrap.y);
                        imageWrap.x = Qt.binding(function() { return win.posX("image", 636); });
                        imageWrap.y = Qt.binding(function() { return win.posY("image", win.y2); });
                    }
                }
            }
        }
    }
}
