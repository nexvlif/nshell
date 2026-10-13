import QtQuick
import QtQuick.Effects
import qs.ndesign

Rectangle {
    id: root
    property int corner: Tokens.rounding.medium
    property string fill: "bg1"
    property string stroke: "subtle"
    property int shadow: 0

    color: {
        if (fill === "bg2")
            return Theme.bg2;
        if (fill === "bg3")
            return Theme.bg3;
        if (fill === "card")
            return Theme.cardBg;
        if (fill === "brandSubtle")
            return Theme.light ? Theme.brand160 : Qt.rgba(0.28, 0.62, 0.96, 0.12);
        if (fill === "transparent")
            return "transparent";
        return Theme.bg1;
    }
    radius: corner
    border.width: stroke === "none" ? 0 : 1
    border.color: {
        if (stroke === "strong")
            return Theme.stroke1;
        if (stroke === "brand")
            return Theme.brandStroke1;
        return Theme.stroke2;
    }

    layer.enabled: shadow > 0
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Theme.shadowKey
        shadowBlur: Math.min(1, root.shadow / 32)
        shadowVerticalOffset: Math.max(1, root.shadow / 4)
        shadowOpacity: 0.9
    }
}
