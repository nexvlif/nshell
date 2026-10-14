import QtQuick
import QtQuick.Layouts
import qs.ndesign

SRow {
    id: root
    property real value: 0
    property real from: 0
    property real to: 100
    property real step: 1
    property string suffix: ""
    signal moved(real v)

    function snapped(v: real): real {
        const c = Math.max(root.from, Math.min(root.to, v));
        return Math.round(c / root.step) * root.step;
    }
    function label(): string {
        if (root.step >= 1)
            return Math.round(root.value) + (root.suffix !== "" ? " " + root.suffix : "");
        return root.value.toFixed(2) + (root.suffix !== "" ? " " + root.suffix : "");
    }

    RowLayout {
        spacing: 6
        NIconButton {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            name: "remove"
            glyphSize: 16
            onClicked: root.moved(root.snapped(root.value - root.step))
        }
        NSlider {
            Layout.preferredWidth: 150
            Layout.alignment: Qt.AlignVCenter
            trackSize: 24
            value: (root.value - root.from) / Math.max(0.0001, root.to - root.from)
            onMoved: v => root.moved(root.snapped(root.from + v * (root.to - root.from)))
        }
        NIconButton {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            name: "add"
            glyphSize: 16
            onClicked: root.moved(root.snapped(root.value + root.step))
        }
        NText {
            Layout.preferredWidth: 64
            horizontalAlignment: Text.AlignRight
            kind: "caption"
            color: Theme.fg2
            text: root.label()
        }
    }
}
