pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services

// OneUI 9 theme — full mono. No blue accent anywhere.
// Active fill mirrors NBattery: white fill on dark track in dark mode,
// near-black fill on light track in light mode.
Singleton {
    id: root
    readonly property bool light: Config.options.theme.mode === "light"

    // Deprecated alias — always true. Kept so old QML referencing
    // true doesn't break. New code shouldn't use it.
    readonly property bool material: true

    // Deprecated — OneUI 9 mono keeps no blue ramp. Values retained only
    // so old QML referencing brandXX doesn't break. Do not use.
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

    // OneUI 9 mono: neutral surfaces, no accent tint.
    readonly property color bg1: light ? "#ffffff" : "#131313"
    readonly property color bg1Hover: light ? "#f0f0f0" : "#2b2b2b"
    readonly property color bg1Pressed: light ? "#e0e0e0" : "#1f1f1f"
    readonly property color bg2: light ? "#f1f1f1" : "#1e1e1e"
    readonly property color bg3: light ? "#e9e9e9" : "#0d0d0d"
    readonly property color bgDisabled: light ? "#f0f0f0" : "#2e2e2e"

    readonly property color subtleHover: light ? "#e8e8e8" : "#2b2b2b"
    readonly property color subtlePressed: light ? "#e0e0e0" : "#333333"
    readonly property color subtleSelected: light ? "#dedede" : "#333333"

    readonly property color cardBg: light ? "#f1f1f1" : "#1e1e1e"
    readonly property color cardHover: light ? "#e8e8e8" : "#2b2b2b"
    readonly property color cardPressed: light ? "#e0e0e0" : "#333333"

    // Mono active — same language as NBattery (fg1 fill on dark track).
    readonly property color active: light ? "#242424" : "#ffffff"
    readonly property color activeFg: light ? "#ffffff" : "#1a1a1a"
    readonly property color activeHover: light ? "#3a3a3a" : "#e0e0e0"
    readonly property color activePressed: light ? "#101010" : "#c4c4c4"

    // Deprecated: accent config is ignored in mono mode. Kept for compat.
    readonly property bool customAccent: false
    readonly property color accentBase: active
    readonly property color brandBg: active
    readonly property color brandBgHover: activeHover
    readonly property color brandBgPressed: activePressed
    readonly property color brandBgSelected: active
    readonly property color brandFg1: fg1
    readonly property color brandFg2: fg1
    readonly property color brandFgOnLight: fg1
    readonly property color brandIconHover: fg1
    readonly property color brandIconPressed: fg1

    readonly property color stroke1: light ? "#cacaca" : "#3a3a3a"
    readonly property color stroke2: light ? "#e5e5e5" : "#2b2b2b"
    readonly property color stroke3: light ? "#f0f0f0" : "#3d3d3d"
    readonly property color strokeAccessible: light ? "#616161" : "#adadad"
    readonly property color brandStroke1: fg1

    readonly property color shadowAmbient: light ? Qt.rgba(0, 0, 0, 0.12) : Qt.rgba(0, 0, 0, 0.24)
    readonly property color shadowKey: light ? Qt.rgba(0, 0, 0, 0.14) : Qt.rgba(0, 0, 0, 0.28)

    readonly property string fontFamily: "Roboto, Inter, Cantarell, sans-serif"
    readonly property string fontMono: "Roboto Mono, Consolas, monospace"

    readonly property color accent: active
    readonly property color accentFg: activeFg
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

    // Tonal roles — all neutral in mono mode (no purple/blue containers).
    // Note: QML reserves the `on*` prefix for signal handlers, so M3 `onX`
    // roles are named `xFg` instead.
    readonly property color primary: active
    readonly property color primaryFg: activeFg
    readonly property color primaryContainer: light ? "#e8e8e8" : "#2b2b2b"
    readonly property color primaryContainerFg: fg1
    readonly property color surfaceContainer: bg2
    readonly property color surfaceContainerHigh: subtleHover
    readonly property color surfaceVariantFg: fg2
    // Secondary/tertiary containers — slider track, chips, icon wells.
    readonly property color secondaryContainer: light ? "#e8e8e8" : "#2b2b2b"
    readonly property color secondaryContainerFg: fg2
    readonly property color tertiaryContainer: light ? "#e8e8e8" : "#2b2b2b"
    readonly property color tertiaryContainerFg: fg1
    // Error roles (badges / destructive hints).
    readonly property color error: light ? "#ba1a1a" : "#ffb4ab"
    readonly property color errorContainer: light ? "#ffdad6" : "#93000a"

    function hover(c, amt = 0.08): color {
        return Qt.lighter(c, 1 + amt);
    }
    function pressed(c, amt = 0.08): color {
        return Qt.darker(c, 1 + amt);
    }
}
