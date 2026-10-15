import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign
import qs.services

ColumnLayout {
    property string bindQuery: ""
    property var bindFiltered: []
    signal queryChanged(string text)
    Layout.fillWidth: true
    spacing: 12
    NText {
        kind: "subtitle"
        semibold: true
        text: "Keybindings"
    }
    NText {
        kind: "caption"
        color: Theme.fg3
        text: HyprConf.binds.length + " bindings live from Hyprland. Binds are defined in conf/50-binds.lua — this list is read-only."
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        NSearchBox {
            Layout.fillWidth: true
            placeholder: "Filter bindings"
            text: bindQuery
            field.onTextChanged: queryChanged(text)
        }
        NIconButton {
            name: "sync"
            glyphSize: 16
            onClicked: HyprConf.loadBinds()
        }
    }
    Repeater {
        model: bindFiltered
        delegate: SRow {
            required property var modelData
            icon: "key"
            title: HyprConf.bindText(modelData)
            sub: (modelData.description && modelData.description !== "" ? modelData.description : (modelData.dispatcher || "")) + (modelData.arg && modelData.arg !== "" ? "  ·  " + modelData.arg : "")
        }
    }
}
