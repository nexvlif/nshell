import QtQuick
import QtQuick.Layouts
import qs.ndesign

ColumnLayout {
    id: root
    property string title: ""
    property string desc: ""
    default property alias content: body.children
    spacing: 6

    NText {
        text: root.title
        kind: "title"
        semibold: true
        Layout.fillWidth: true
    }
    NText {
        visible: root.desc !== ""
        text: root.desc
        kind: "caption"
        color: Theme.fg3
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }
    ColumnLayout {
        id: body
        Layout.fillWidth: true
        spacing: 6
    }
}
