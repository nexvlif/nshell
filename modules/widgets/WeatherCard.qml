import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

NRect {
    id: root
    implicitWidth: 380
    implicitHeight: 180
    corner: Tokens.rounding.popover
    fill: "bg1"
    stroke: "none"
    shadow: 16
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: 44
                    font.weight: Font.Bold
                    color: Theme.fg1
                    text: Weather.ready ? Weather.text : "--"
                }
                NText {
                    Layout.fillWidth: true
                    kind: "small"
                    color: Theme.fg2
                    elide: Text.ElideRight
                    text: Weather.ready ? Weather.desc : "--"
                }
                NText {
                    Layout.fillWidth: true
                    kind: "caption"
                    color: Theme.fg3
                    elide: Text.ElideRight
                    text: (Weather.place || "Local") + (Config.options.weather.autoLocate !== false ? "" : " · manual")
                }
            }
            NIcon {
                Layout.alignment: Qt.AlignTop
                name: Weather.ready ? Weather.icon : "cloudy"
                iconSize: 56
                color: Theme.fg1
            }
            NIconButton {
                Layout.alignment: Qt.AlignTop
                name: "sync"
                glyphSize: 18
                onClicked: {
                    if (Config.options.weather.autoLocate !== false)
                        Weather.locate();
                    else
                        Weather.fetch();
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            RowLayout {
                spacing: 6
                NIcon {
                    name: "water_drop"
                    iconSize: 14
                    color: Theme.fg2
                }
                NText {
                    kind: "caption"
                    color: Theme.fg2
                    elide: Text.ElideRight
                    text: Weather.ready ? Math.round(Weather.humidity) + "%" : "--"
                }
            }
            RowLayout {
                spacing: 6
                NIcon {
                    name: "air"
                    iconSize: 14
                    color: Theme.fg2
                }
                NText {
                    kind: "caption"
                    color: Theme.fg2
                    elide: Text.ElideRight
                    text: Weather.ready ? Weather.wind.toFixed(1) + " km/h" : "--"
                }
            }
        }
    }
}
