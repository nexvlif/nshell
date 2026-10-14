import QtQuick
import QtQuick.Layouts
import Quickshell
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

            visible: Ui.osdOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            property string pos: Config.options.bar.position
            readonly property var barMargins: Config.options.bar.margins[pos] ?? Config.options.bar.margins["bottom"]
            anchors {
                top: pos === "top"
                bottom: pos === "bottom"
                left: pos === "left"
                right: pos === "right"
            }
            margins {
                top: pos === "top" ? Config.options.bar.height + barMargins.top + 12 : 0
                bottom: pos === "bottom" ? Config.options.bar.height + barMargins.bottom + 12 : 0
                left: pos === "left" ? Config.options.bar.height + barMargins.left + 12 : 0
                right: pos === "right" ? Config.options.bar.height + barMargins.right + 12 : 0
            }
            implicitWidth: 260
            implicitHeight: 56

            NRect {
                anchors.fill: parent
                corner: Tokens.rounding.xxlarge
                fill: "bg1"
                stroke: "subtle"
                shadow: Config.options.bar.shadow

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 14
                    NIcon {
                        Layout.alignment: Qt.AlignVCenter
                        name: Ui.osdKind === "brightness" ? "sunny" : (Audio.muted ? "volume_off" : "volume_up")
                        filled: true
                        iconSize: 20
                        color: Theme.fg1
                    }
                    NSlider {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        trackSize: 30
                        interactive: false
                        value: Ui.osdKind === "brightness" ? Brightness.value : Audio.volume
                    }
                }
            }
        }
    }

    Timer {
        id: grace
        interval: 3000
        running: true
        repeat: false
    }
    Connections {
        target: Audio
        function onVolumeChanged() {
            if (!grace.running)
                Ui.flashOsd("volume");
        }
        function onMutedChanged() {
            if (!grace.running)
                Ui.flashOsd("volume");
        }
    }
    Connections {
        target: Brightness
        function onValueChanged() {
            if (!grace.running && Brightness.ready)
                Ui.flashOsd("brightness");
        }
    }
}
