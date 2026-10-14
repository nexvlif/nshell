import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

NRect {
    id: root
    property var screen: null
    implicitWidth: 300
    implicitHeight: 300
    fill: "bg1"
    corner: Tokens.rounding.popover
    stroke: "none"
    shadow: 16

    readonly property string imgPath: Config.options.widgets.imagePath ?? ""

    NRoundedImage {
        anchors.fill: parent
        visible: root.imgPath !== ""
        source: root.imgPath !== "" ? "file://" + root.imgPath : ""
        imgRadius: Tokens.rounding.popover
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        visible: root.imgPath === ""
        spacing: 8
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        NIcon {
            Layout.alignment: Qt.AlignHCenter
            name: "image"
            iconSize: 40
            color: Theme.fg3
        }
        NText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            kind: "small"
            color: Theme.fg3
            text: "Click to choose image"
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Ui.imgPickerScreen = root.screen;
            Ui.imgPickerOpen = true;
        }
    }
}
