pragma Singleton

import QtQuick
import Quickshell
import qs.services

// Central avatar resolution so a custom image never needs a file override.
// Set `bar.avatarPath` to an absolute path (Settings > Bar > Avatar image).
// Empty falls back to ~/Pictures/pp.jpg; NAvatar shows the USER initial
// when neither file exists.
Singleton {
    id: root
    readonly property string customPath: Config.options.bar.avatarPath ?? ""
    readonly property string defaultPath: Quickshell.env("HOME") + "/Pictures/pp.jpg"
    readonly property string resolvedPath: customPath !== "" ? customPath : defaultPath
    readonly property string source: resolvedPath !== "" ? "file://" + resolvedPath : ""
}
