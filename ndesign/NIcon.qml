import QtQuick
import qs.ndesign

Text {
    id: root
    property string name: "search"
    property bool filled: false
    property int iconSize: 20

    font.family: filled ? "FluentSystemIcons-Filled" : "FluentSystemIcons-Regular"
    font.pixelSize: iconSize
    color: Theme.fg1
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    renderType: Text.QtRendering
    text: {
        const key = filled ? root.name + "Filled" : root.name;
        return NIcons[key] ?? "";
    }
}
