import QtQuick
import qs.ndesign

Text {
    property string kind: "body"
    property bool semibold: kind === "title" || kind === "subtitle"
    color: Theme.fg1
    font.family: Theme.fontFamily
    font.pixelSize: {
        if (kind === "caption")
            return Tokens.font.caption;
        if (kind === "small")
            return Tokens.font.small;
        if (kind === "title")
            return Tokens.font.title;
        if (kind === "subtitle")
            return Tokens.font.subtitle;
        if (kind === "clock")
            return Tokens.font.clock;
        return Tokens.font.body;
    }
    font.weight: semibold ? Font.DemiBold : Font.Normal
    renderType: Text.NativeRendering
}
