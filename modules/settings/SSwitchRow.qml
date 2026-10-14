import QtQuick
import qs.ndesign

SRow {
    id: root
    property bool checked: false
    signal toggled

    NSwitch {
        checked: root.checked
        onClicked: root.toggled()
    }
}
