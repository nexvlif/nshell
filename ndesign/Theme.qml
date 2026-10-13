pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root
    readonly property bool light: Config.options.theme.mode === "light"

    readonly property color brand30: "#0a2e4a"
    readonly property color brand40: "#0c3b5e"
    readonly property color brand50: "#0e4775"
    readonly property color brand60: "#0f548c"
    readonly property color brand70: "#115ea3"
    readonly property color brand80: "#0f6cbd"
    readonly property color brand90: "#2886de"
    readonly property color brand100: "#479ef5"
    readonly property color brand110: "#62abf5"
    readonly property color brand150: "#cfe4fa"
    readonly property color brand160: "#ebf3fc"

    readonly property color fg1: light ? "#242424" : "#ffffff"
    readonly property color fg2: light ? "#424242" : "#d6d6d6"
    readonly property color fg3: light ? "#616161" : "#adadad"
    readonly property color fgDisabled: light ? "#bdbdbd" : "#767676"

    readonly property color bg1: light ? "#ffffff" : "#292929"
    readonly property color bg1Hover: light ? "#f5f5f5" : "#3d3d3d"
    readonly property color bg1Pressed: light ? "#e0e0e0" : "#1f1f1f"
    readonly property color bg2: light ? "#fafafa" : "#1f1f1f"
    readonly property color bg3: light ? "#f5f5f5" : "#141414"
    readonly property color bgDisabled: light ? "#f0f0f0" : "#2e2e2e"

    readonly property color subtleHover: light ? "#f5f5f5" : "#383838"
    readonly property color subtlePressed: light ? "#e0e0e0" : "#2e2e2e"
    readonly property color subtleSelected: light ? "#ebebeb" : "#333333"

    readonly property color cardBg: light ? "#fafafa" : "#333333"
    readonly property color cardHover: light ? "#ffffff" : "#3d3d3d"
    readonly property color cardPressed: light ? "#f5f5f5" : "#2e2e2e"

    readonly property bool customAccent: (Config.options.theme.accent || "") !== ""
    readonly property color accentBase: Config.options.theme.accent || brand80
    readonly property color brandBg: light ? accentBase : (customAccent ? accentBase : brand70)
    readonly property color brandBgHover: light ? (customAccent ? Qt.lighter(accentBase, 1.12) : brand70) : (customAccent ? Qt.lighter(accentBase, 1.12) : brand80)
    readonly property color brandBgPressed: light ? (customAccent ? Qt.darker(accentBase, 1.15) : brand40) : (customAccent ? Qt.darker(accentBase, 1.15) : brand60)
    readonly property color brandBgSelected: light ? brand60 : brand80
    readonly property color brandFg1: light ? brand80 : brand100
    readonly property color brandFg2: light ? brand70 : brand110
    readonly property color brandFgOnLight: light ? brand80 : brand100
    readonly property color brandIconHover: light ? brand80 : brand100
    readonly property color brandIconPressed: light ? brand70 : brand90

    readonly property color stroke1: light ? "#d1d1d1" : "#666666"
    readonly property color stroke2: light ? "#e0e0e0" : "#525252"
    readonly property color stroke3: light ? "#f0f0f0" : "#3d3d3d"
    readonly property color strokeAccessible: light ? "#616161" : "#adadad"
    readonly property color brandStroke1: light ? brand80 : brand100

    readonly property color shadowAmbient: light ? Qt.rgba(0, 0, 0, 0.12) : Qt.rgba(0, 0, 0, 0.24)
    readonly property color shadowKey: light ? Qt.rgba(0, 0, 0, 0.14) : Qt.rgba(0, 0, 0, 0.28)

    readonly property string fontFamily: "Segoe UI, Segoe UI Variable Text, Inter, Cantarell, sans-serif"
    readonly property string fontMono: "Consolas, Courier New, monospace"

    readonly property color accent: brandBg
    readonly property color accentFg: "#ffffff"
    readonly property color bg: bg1
    readonly property color bgSolid: bg1
    readonly property color surface: bg2
    readonly property color stroke: stroke2
    readonly property color fg: fg1
    readonly property color fgDim: fg2
    readonly property color controlFill: bg2
    readonly property color controlHover: subtleHover
    readonly property color controlPressed: subtlePressed
    readonly property color controlStroke: stroke1
    readonly property color controlStrokeBottom: stroke1
    readonly property color cardFill: cardBg
    readonly property color cardStroke: stroke2
    readonly property color mica: bg1
    readonly property color acrylic: bg2
    readonly property color acrylicFallback: bg1
    readonly property color edgeHighlight: stroke3
    readonly property color shadow: shadowKey

    readonly property color overlay: Qt.rgba(0, 0, 0, 0.4)
    readonly property color textPrimary: fg1
    readonly property color textSecondary: fg2

    function hover(c, amt = 0.08): color {
        return Qt.lighter(c, 1 + amt);
    }
    function pressed(c, amt = 0.08): color {
        return Qt.darker(c, 1 + amt);
    }
}
