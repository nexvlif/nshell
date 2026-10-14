import QtQuick
import QtQuick.Effects
import qs.ndesign

Rectangle {
    id: root
    property int corner: Tokens.rounding.large
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
            return Theme.primaryContainer;
        if (fill === "transparent")
            return "transparent";
        return Theme.bg1;
    }
    radius: corner
    // OneUI: panels & pills are borderless — only explicit strong/brand strokes draw.
    border.width: {
        if (stroke === "none" || stroke === "subtle")
            return 0;
        return 1;
    }
    border.color: {
        if (stroke === "strong")
            return Theme.stroke1;
        if (stroke === "brand")
            return Theme.fg1;
        return Theme.stroke2;
    }

    layer.enabled: shadow > 0
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Theme.shadowKey
        // end4 StyledRectangularShadow: soft blur ~9px, 1px y-offset, ~30% black.
        shadowBlur: Math.min(32, Math.max(8, root.shadow))
        shadowVerticalOffset: 1
        shadowOpacity: 0.32
    }
}
