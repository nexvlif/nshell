pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string osName: ""
    property string osVersion: ""
    property string osId: ""
    property string pkgManager: ""
    property string kernel: ""
    property string hyprVersion: ""
    property string qsVersion: ""
    property string nshellBuild: ""
    property bool ready: false

    readonly property string nshellVersion: "0.1.0"
    readonly property string osInitial: osName !== "" ? osName.substring(0, 1).toUpperCase() : "?"

    function refresh(): void {
        if (!proc.running)
            proc.running = true;
    }

    Process {
        id: proc
        command: ["sh", "-c", ". /etc/os-release 2>/dev/null; echo \"NS_OS=${NAME:-Unknown}\"; echo \"NS_VER=${VERSION:-$VERSION_ID}\"; echo \"NS_ID=${ID:-unknown}\"; echo \"NS_KERNEL=$(uname -r 2>/dev/null)\"; NS_PM=\"unknown\"; if [ -f /etc/arch-release ]; then NS_PM=\"pacman\"; elif [ -n \"$NIX_STATE_DIR\" ] || [ -f /etc/NIXOS ] || [ -d /run/current-system ]; then NS_PM=\"nix\"; elif [ -f /etc/fedora-release ]; then NS_PM=\"dnf\"; elif [ -f /etc/debian_version ]; then NS_PM=\"apt\"; elif [ -f /etc/gentoo-release ]; then NS_PM=\"portage\"; elif [ -f /etc/alpine-release ]; then NS_PM=\"apk\"; elif [ -f /etc/void-release ]; then NS_PM=\"xbps\"; elif [ -f /etc/opensuse-release ]; then NS_PM=\"zypper\"; fi; echo \"NS_PM=$NS_PM\"; echo \"NS_HYPR=$(hyprctl version 2>/dev/null | head -1)\"; echo \"NS_QS=$(qs --version 2>/dev/null | head -1)\"; echo \"NS_BUILD=$(git -C \"$HOME/Projects/nshell\" rev-parse --short HEAD 2>/dev/null)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    const m = line.match(/^NS_([A-Z]+)=(.*)$/);
                    if (!m)
                        continue;
                    const v = m[2].trim();
                    if (m[1] === "OS")
                        root.osName = v;
                    else if (m[1] === "VER")
                        root.osVersion = v;
                    else if (m[1] === "ID")
                        root.osId = v.toLowerCase();
                    else if (m[1] === "KERNEL")
                        root.kernel = v;
                    else if (m[1] === "PM")
                        root.pkgManager = v;
                    else if (m[1] === "HYPR")
                        root.hyprVersion = v;
                    else if (m[1] === "QS")
                        root.qsVersion = v;
                    else if (m[1] === "BUILD")
                        root.nshellBuild = v;
                }
                root.ready = true;
            }
        }
    }

    Component.onCompleted: refresh()
}
