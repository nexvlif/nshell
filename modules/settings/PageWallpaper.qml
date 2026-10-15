import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign
import qs.services

ColumnLayout {
    property var screen
    Layout.fillWidth: true
    spacing: 12
    NText {
        kind: "subtitle"
        semibold: true
        text: "Wallpaper"
    }
    SSection {
        Layout.fillWidth: true
        title: "Current"
        NRoundedImage {
            Layout.fillWidth: true
            Layout.preferredHeight: 170
            source: Config.options.wallpaper.path !== "" ? "file://" + Config.options.wallpaper.path : ""
            imgRadius: Tokens.rounding.medium
        }
        SRow {
            icon: "image"
            title: "File"
            sub: Config.options.wallpaper.path !== "" ? Config.options.wallpaper.path : "No wallpaper set"
            NButton {
                variant: "secondary"
                text: "Choose"
                onClicked: {
                    Ui.wallMenuScreen = screen;
                    Ui.wallPickerOpen = true;
                }
            }
        }
        SChoiceRow {
            icon: "fit_screen"
            title: "Fit mode"
            sub: "How the image fills the screen"
            options: [["fill", "Fill"], ["fit", "Fit"], ["stretch", "Stretch"]]
            current: Config.options.wallpaper.mode ?? "fill"
            onPicked: v => Config.set("wallpaper.mode", v)
        }
    }
}
