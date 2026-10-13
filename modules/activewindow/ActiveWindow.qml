import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.ndesign

NText {
    Layout.maximumWidth: 180
    elide: Text.ElideMiddle
    kind: "small"
    color: Theme.fg3
    text: ToplevelManager.activeToplevel?.appId ?? ToplevelManager.activeToplevel?.title ?? ""
}
