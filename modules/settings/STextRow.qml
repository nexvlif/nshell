import QtQuick
import QtQuick.Layouts
import qs.ndesign

SRow {
    id: root
    property string value: ""
    property string placeholder: "Type here"
    signal committed(string text)

    RowLayout {
        spacing: 8
        NSearchBox {
            id: box
            Layout.preferredWidth: 190
            icon: "edit"
            placeholder: root.placeholder
            text: root.value
            onAccepted: root.committed(box.text.trim())
        }
        NButton {
            variant: "secondary"
            text: "Set"
            onClicked: root.committed(box.text.trim())
        }
    }
}
