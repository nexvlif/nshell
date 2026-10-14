pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool material: true

    readonly property QtObject rounding: QtObject {
        readonly property int none: 0
        readonly property int small: 8
        readonly property int control: 10
        readonly property int medium: 12
        readonly property int large: 20
        readonly property int card: 20
        readonly property int xlarge: 24
        readonly property int popover: 28
        readonly property int xxlarge: 32
        readonly property int pill: 999
    }
    readonly property QtObject spacing: QtObject {
        readonly property int none: 0
        readonly property int xxs: 2
        readonly property int xs: 4
        readonly property int tiny: 4
        readonly property int s: 8
        readonly property int small: 8
        readonly property int m: 12
        readonly property int medium: 12
        readonly property int l: 16
        readonly property int large: 16
        readonly property int xl: 20
        readonly property int xxl: 24
    }
    readonly property QtObject padding: QtObject {
        readonly property int small: 6
        readonly property int medium: 10
        readonly property int large: 14
    }
    readonly property QtObject stroke: QtObject {
        readonly property int thin: 1
        readonly property int thick: 2
    }
    readonly property QtObject font: QtObject {
        readonly property int caption: 10
        readonly property int small: 12
        readonly property int body: 14
        readonly property int title: 16
        readonly property int subtitle: 20
        readonly property int clock: 12
    }
    readonly property QtObject anim: QtObject {
        readonly property int faster: 100
        readonly property int fast: 150
        readonly property int normal: 200
        readonly property int gentle: 250
        readonly property int slow: 300
    }
    readonly property QtObject acrylic: QtObject {
        readonly property real tintOpacity: 1.0
    }
    readonly property QtObject taskbar: QtObject {
        readonly property int height: 48
        readonly property int iconSize: 20
        readonly property int itemWidth: 40
    }
}
