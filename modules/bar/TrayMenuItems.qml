import QtQuick
import QtQuick.Layouts
import qs.ndesign

ColumnLayout {
    id: root
    required property var opener
    signal closeRequested
    spacing: 2

    Repeater {
        model: root.opener ? root.opener.children : []
        delegate: TrayMenuItem {
            Layout.fillWidth: true
            entry: modelData
            onCloseRequested: root.closeRequested()
        }
    }
}
