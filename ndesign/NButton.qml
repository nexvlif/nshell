import QtQuick
import QtQuick.Layouts
import qs.ndesign

// OneUI 9 mono button: primary filled active, secondary tonal, subtle text, outline stroked.
Rectangle {
    id: root
    property string text: ""
    property string variant: "subtle" // primary | secondary | subtle | outline
    property bool primary: false
    property string icon: ""
    property bool disabled: false
    signal clicked

    readonly property string _v: primary ? "primary" : variant
    readonly property bool _secondary: _v === "secondary" || _v === "outline"

    implicitHeight: 40
    implicitWidth: Math.max(96, row.implicitWidth + 24)
    radius: Tokens.rounding.pill
    opacity: disabled ? 1 : 1
    color: {
        if (disabled)
            return Theme.bgDisabled;
        if (_v === "primary") {
            if (hoverArea.pressed)
                return Theme.activePressed;
            return hoverArea.containsMouse ? Theme.activeHover : Theme.active;
        }
        if (_v === "secondary") {
            if (hoverArea.pressed)
                return Theme.pressed(Theme.primaryContainer, 0.12);
            return hoverArea.containsMouse ? Theme.hover(Theme.primaryContainer, 0.08) : Theme.primaryContainer;
        }
        if (_v === "outline") {
            if (hoverArea.pressed)
                return Theme.bg1Pressed;
            return hoverArea.containsMouse ? Theme.bg1Hover : Theme.bg1;
        }
        if (hoverArea.pressed)
            return Theme.subtlePressed;
        return hoverArea.containsMouse ? Theme.subtleHover : "transparent";
    }
    border.width: (_v === "outline" && !disabled) ? 1 : 0
    border.color: Theme.stroke1
    Behavior on color {
        ColorAnimation {
            duration: Tokens.anim.faster
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
        NIcon {
            visible: root.icon !== ""
            Layout.alignment: Qt.AlignVCenter
            name: root.icon
            filled: hoverArea.containsMouse || hoverArea.pressed
            iconSize: 20
            color: {
                if (root.disabled)
                    return Theme.fgDisabled;
                if (root._v === "primary")
                    return Theme.activeFg;
                if (hoverArea.containsMouse || hoverArea.pressed)
                    return Theme.fg1;
                return root._secondary ? Theme.fg1 : Theme.fg2;
            }
        }
        NText {
            Layout.alignment: Qt.AlignVCenter
            text: root.text
            kind: "body"
            semibold: true
            color: {
                if (root.disabled)
                    return Theme.fgDisabled;
                if (root._v === "primary")
                    return Theme.activeFg;
                if (root._v === "secondary")
                    return Theme.primaryContainerFg;
                return root._secondary ? Theme.fg1 : Theme.fg2;
            }
        }
    }
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.disabled ? Qt.ForbiddenCursor : Qt.PointingHandCursor
        enabled: !root.disabled
        onClicked: root.clicked()
    }
}
