import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.ndesign
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
            function defX(entry: var): real {
                if (entry.ax === 1)
                    return (win.width - entry.w) / 2 + entry.ox;
                if (entry.ax === 2)
                    return win.width - entry.w - entry.ox;
                return entry.ox;
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

            Repeater {
                model: WidgetReg.widgets
                delegate: Item {
                    required property var modelData
                    id: wrap
                    property var comp: Qt.createComponent(modelData.file)
                    x: win.posX(modelData.id, win.defX(modelData))
                    y: win.posY(modelData.id, win.y0 + modelData.dy)
                    width: modelData.w
                    height: modelData.h
                    Loader {
                        anchors.fill: parent
                        visible: Config.options.widgets[modelData.id] ?? modelData.on
                        sourceComponent: wrap.comp.status === Component.Ready ? wrap.comp : null
                        onLoaded: {
                            if (modelData.id === "image" && item)
                                item.screen = win.screen;
                        }
                    }
                    NText {
                        anchors.centerIn: parent
                        visible: wrap.comp.status === Component.Error
                        kind: "caption"
                        color: Theme.error
                        text: "Widget error: " + modelData.id
                    }
                    MouseArea {
                        anchors.fill: parent
                        visible: win.moveActive(modelData.id)
                        hoverEnabled: true
                        cursorShape: Qt.OpenHandCursor
                        drag.target: wrap
                        drag.axis: Drag.XAndYAxis
                        onReleased: {
                            win.commitPos(modelData.id, wrap.x, wrap.y);
                            const entry = modelData;
                            wrap.x = Qt.binding(function() { return win.posX(entry.id, win.defX(entry)); });
                            wrap.y = Qt.binding(function() { return win.posY(entry.id, win.y0 + entry.dy); });
                        }
                    }
                }
            }
        }
    }
}
