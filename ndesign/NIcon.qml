import QtQuick
import qs.ndesign

Text {
    id: root
    property string name: "search"
    property bool filled: false
    property int iconSize: 20

    font.family: "Material Symbols Lite"
    font.pixelSize: iconSize
    font.weight: filled ? Font.DemiBold : Font.Normal
    font.variableAxes: {
        "FILL": filled ? 1 : 0,
        "opsz": iconSize
    }
    color: Theme.fg1
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    renderType: Text.NativeRendering
    font.hintingPreference: Font.PreferNoHinting
    text: root.name
}
