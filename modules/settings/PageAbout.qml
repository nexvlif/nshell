import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign
import qs.services

ColumnLayout {
    Layout.fillWidth: true
    spacing: 12
    NText {
        kind: "subtitle"
        semibold: true
        text: "System & Files"
    }
    SSection {
        Layout.fillWidth: true
        title: "System"
        desc: "About this machine and shell."
        SRow {
            icon: ""
            title: SysInfo.ready ? SysInfo.osName : "Loading..."
            sub: SysInfo.ready ? (SysInfo.osVersion !== "" ? SysInfo.osVersion : SysInfo.osId) : "Reading system info..."
            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignVCenter
                radius: 22
                color: Theme.active
                NText {
                    anchors.centerIn: parent
                    kind: "title"
                    semibold: true
                    color: Theme.activeFg
                    text: SysInfo.osInitial
                }
            }
        }
        SRow {
            icon: "shopping_bag"
            title: "Package manager"
            sub: SysInfo.ready ? SysInfo.pkgManager : "..."
        }
        SRow {
            icon: "memory"
            title: "Kernel"
            sub: SysInfo.ready ? SysInfo.kernel : "..."
        }
        SRow {
            icon: "grid_view"
            title: "Hyprland"
            sub: SysInfo.ready && SysInfo.hyprVersion !== "" ? SysInfo.hyprVersion : "Not running"
        }
        SRow {
            icon: "terminal"
            title: "Quickshell"
            sub: SysInfo.ready && SysInfo.qsVersion !== "" ? SysInfo.qsVersion : "..."
        }
        SRow {
            icon: "info"
            title: "nshell " + SysInfo.nshellVersion
            sub: SysInfo.nshellBuild !== "" ? "build " + SysInfo.nshellBuild : "dev build"
            NButton {
                variant: "secondary"
                text: "Refresh"
                onClicked: SysInfo.refresh()
            }
        }
        SRow {
            icon: SysInfo.updateAvailable ? "system_update" : "check_circle"
            title: SysInfo.updateChecking ? "Checking for updates..." : (SysInfo.updateAvailable ? "Update available" : "Up to date")
            sub: SysInfo.updateChecking ? "Comparing with git remote..." : (SysInfo.updateStatus !== "" ? SysInfo.updateStatus : "Run git pull in your checkout to update")
            NButton {
                variant: "secondary"
                text: "Check"
                onClicked: SysInfo.checkUpdates()
            }
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Dependencies"
        desc: "External tools nshell shells out to. Missing ones disable related features."
        SRow {
            icon: "handyman"
            title: Deps.ready ? (Deps.missing.length === 0 ? "All tools installed" : Deps.missing.length + " tools missing") : "Checking..."
            sub: Deps.ready && Deps.missing.length > 0 ? Deps.missing.map(m => m.tool).join(", ") : "grim, wl-copy, gio, hyprshot, wf-recorder, hyprpicker, brightnessctl, playerctl, cliphist, hyprsunset, powerprofilesctl, python-pillow"
            NButton {
                variant: "secondary"
                text: "Rescan"
                onClicked: Deps.refresh()
            }
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Hyprland persistence"
        desc: "nshell applies Hyprland changes live via hyprctl and saves them to nshell-managed.lua."
        SRow {
            icon: HyprConf.integrated ? "check_circle" : "warning"
            title: HyprConf.integrated ? "hyprland.lua loads nshell settings" : "Not integrated yet"
            sub: HyprConf.integrated ? "Your tweaks survive restarts." : "Add the dofile loader to hyprland.lua so tweaks survive restarts."
            NButton {
                visible: !HyprConf.integrated
                variant: "secondary"
                text: "Integrate"
                onClicked: HyprConf.integrate()
            }
        }
        SRow {
            icon: "restart_alt"
            title: "Reload Hyprland"
            sub: "Re-reads all Hyprland config files"
            NButton {
                variant: "secondary"
                text: "Reload"
                onClicked: HyprConf.reloadHypr()
            }
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Files"
        SRow {
            icon: "folder"
            title: "Hyprland config folder"
            sub: "~/.config/hypr"
            NButton {
                variant: "secondary"
                text: "Open"
                onClicked: HyprConf.openHyprFolder()
            }
        }
        SRow {
            icon: "description"
            title: "nshell config"
            sub: "~/.config/nshell/config.json"
            NButton {
                variant: "secondary"
                text: "Open"
                onClicked: HyprConf.openNshellConfig()
            }
        }
        SRow {
            icon: "keyboard"
            title: "Settings shortcut"
            sub: "Copies an hl.bind snippet for SUPER + comma to the clipboard"
            NButton {
                variant: "secondary"
                text: "Copy"
                onClicked: HyprConf.copySettingsSnippet()
            }
        }
        SRow {
            icon: "lock"
            title: "Lock shortcut"
            sub: "Copies an hl.bind snippet for SUPER + L to the clipboard"
            NButton {
                variant: "secondary"
                text: "Copy bind"
                onClicked: HyprConf.copyLockSnippet()
            }
        }
    }
    SSection {
        Layout.fillWidth: true
        title: "Backup"
        desc: "Snapshots of config.json, widget data and nshell-managed.lua under ~/Documents/nshell-backups."
        SRow {
            icon: "backup"
            title: "Export backup"
            sub: "Save a timestamped snapshot now"
            NButton {
                variant: "secondary"
                text: "Export"
                onClicked: Backup.exportNow()
            }
        }
        Repeater {
            model: Backup.backups
            delegate: SRow {
                required property var modelData
                icon: "history"
                title: modelData
                sub: "Restore this snapshot (reloads Hyprland)"
                NButton {
                    variant: "secondary"
                    text: "Restore"
                    onClicked: Backup.restore(modelData)
                }
            }
        }
    }
}
