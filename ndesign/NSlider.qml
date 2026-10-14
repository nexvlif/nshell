import QtQuick
import qs.ndesign

Rectangle {
    id: root
    property real value: 0
    property bool interactive: true
    property bool wavy: false
    property bool animateWave: true
    property real trackSize: 18
    signal moved(real v)

    readonly property real effTrack: root.wavy ? 4 : root.trackSize
    readonly property real trackR: {
        if (effTrack >= 72)
            return 21;
        if (effTrack >= 42)
            return 12;
        if (effTrack >= 30)
            return 9;
        if (effTrack >= 18)
            return 6;
        return effTrack / 2;
    }
    readonly property real trackH: effTrack
    readonly property real handleW: drag.active ? 1.5 : 3
    readonly property real handleH: {
        if (root.wavy)
            return 24;
        return Math.max(33, root.effTrack + 9);
    }
    readonly property real gap: 4

    readonly property color hiColor: drag.active ? Theme.activePressed : Theme.active
    readonly property color trackColor: Theme.surfaceContainerHigh

    implicitHeight: Math.max(root.trackH, root.handleH) + 4
    color: "transparent"
    clip: false

    readonly property real ratio: Math.max(0, Math.min(1, drag.active ? drag.v : root.value))

    Behavior on value {
        SmoothedAnimation {
            velocity: 3.5
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: root.trackH
        radius: root.trackR
        color: root.trackColor

        Rectangle {
            visible: !root.wavy && root.ratio > 0.005
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(0, parent.width * root.ratio - root.handleW / 2 - root.gap)
            height: parent.height
            topLeftRadius: root.trackR
            bottomLeftRadius: root.trackR
            topRightRadius: root.ratio > 0.995 ? root.trackR : 2
            bottomRightRadius: root.ratio > 0.995 ? root.trackR : 2
            color: root.hiColor
        }

        Canvas {
            id: wave
            visible: root.wavy
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(0, parent.width * root.ratio - root.handleW / 2 - root.gap)
            height: 16
            property real phase: 0
            onPhaseChanged: requestPaint()
            onWidthChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                if (width < 4)
                    return;
                const lw = 4;
                const amp = lw * 0.5;
                const freq = 6;
                const cy = height / 2;
                ctx.strokeStyle = root.hiColor;
                ctx.lineWidth = lw;
                ctx.lineCap = "round";
                ctx.beginPath();
                const full = Math.max(1, parent.width);
                for (let x = lw / 2; x <= width - lw / 2; x += 1) {
                    const y = cy + amp * Math.sin(freq * 2 * Math.PI * x / full + wave.phase);
                    if (x <= lw / 2 + 1)
                        ctx.moveTo(x, y);
                    else
                        ctx.lineTo(x, y);
                }
                ctx.stroke();
            }
            NumberAnimation on phase {
                running: root.wavy && root.animateWave && wave.visible
                from: 0
                to: Math.PI * 2
                duration: 1600
                loops: Animation.Infinite
            }
        }

        Rectangle {
            visible: !root.wavy && root.ratio < 0.995
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width - root.gap - 7
            width: 3
            height: 3
            radius: 1.5
            color: Theme.surfaceVariantFg
            opacity: 0.9
        }

        Rectangle {
            visible: !root.wavy && root.ratio > 0.995
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width - root.gap - 7
            width: 3
            height: 3
            radius: 1.5
            color: Theme.activeFg
            opacity: 0.95
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: Math.min(parent.width - width, Math.max(0, parent.width * root.ratio - width / 2))
        width: root.handleW
        height: root.handleH
        radius: width / 2
        color: Theme.active
        border.width: 0
        border.color: Theme.bg1
        Behavior on width {
            NumberAnimation {
                duration: Tokens.anim.faster
            }
        }
    }

    Rectangle {
        visible: drag.active && root.interactive
        anchors.bottom: parent.top
        anchors.bottomMargin: 6
        x: Math.min(parent.width - width, Math.max(0, parent.width * root.ratio - width / 2))
        implicitWidth: tipText.implicitWidth + 16
        implicitHeight: 28
        radius: 14
        color: Theme.active
        NText {
            id: tipText
            anchors.centerIn: parent
            kind: "caption"
            semibold: true
            color: Theme.activeFg
            text: Math.round(root.ratio * 100) + "%"
        }
    }
    MouseArea {
        id: drag
        property bool active: false
        property real v: 0
        property bool hovered: containsMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        enabled: root.interactive
        onPressed: mouse => {
            active = true;
            v = Math.max(0, Math.min(1, mouse.x / width));
            root.moved(v);
        }
        onPositionChanged: mouse => {
            if (active) {
                v = Math.max(0, Math.min(1, mouse.x / width));
                root.moved(v);
            }
        }
        onReleased: active = false
    }
}
