import QtQuick
import QtQuick.Layouts
import qs.ndesign

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

    implicitHeight: 32
    implicitWidth: Math.max(96, row.implicitWidth + 24)
    radius: Tokens.rounding.medium
    opacity: disabled ? 1 : 1
    color: {
        if (disabled)
            return _v === "primary" ? Theme.bgDisabled : Theme.bgDisabled;
        if (_v === "primary") {
            if (hoverArea.pressed)
                return Theme.brandBgPressed;
            return hoverArea.containsMouse ? Theme.brandBgHover : Theme.brandBg;
        }
        if (_secondary) {
            if (hoverArea.pressed)
                return Theme.bg1Pressed;
            return hoverArea.containsMouse ? Theme.bg1Hover : Theme.bg1;
        }
        if (hoverArea.pressed)
            return Theme.subtlePressed;
        return hoverArea.containsMouse ? Theme.subtleHover : "transparent";
    }
    border.width: (_secondary && !disabled) ? 1 : 0
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
                    return "#ffffff";
                if (hoverArea.containsMouse || hoverArea.pressed)
                    return root._secondary ? Theme.fg1 : Theme.brandIconHover;
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
                    return "#ffffff";
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
