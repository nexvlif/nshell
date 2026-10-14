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
    property bool updateAvailable: false
    property bool updateChecking: false
    property string updateStatus: ""

    readonly property string nshellVersion: "0.1.0"
    readonly property string osInitial: osName !== "" ? osName.substring(0, 1).toUpperCase() : "?"

    function refresh(): void {
        if (!proc.running)
            proc.running = true;
    }

    function checkUpdates(): void {
        if (updProc.running)
            return;
        root.updateChecking = true;
        updProc.command = ["python3", "-c", root._updPy, Quickshell.shellDir];
        updProc.running = true;
    }

    property string _updPy: "import subprocess,sys\n" + "d=sys.argv[1] if len(sys.argv)>1 else '.'\n" + "def git(*a):\n" + "  return subprocess.run(['git','-C',d]+list(a),capture_output=True,text=True,timeout=20)\n" + "try:\n" + "  h=git('rev-parse','HEAD')\n" + "  if h.returncode!=0:\n" + "    print('NOREPO')\n" + "  else:\n" + "    u=git('remote','get-url','origin')\n" + "    url=u.stdout.strip() if u.returncode==0 else ''\n" + "    if not url:\n" + "      print('NOREMOTE')\n" + "    else:\n" + "      ls=git('ls-remote',url,'HEAD')\n" + "      parts=ls.stdout.split() if ls.returncode==0 else []\n" + "      print('LOCAL '+h.stdout.strip())\n" + "      print('REMOTE '+(parts[0] if parts else 'UNKNOWN'))\n" + "except Exception as e:\n" + "  print('ERROR '+str(e))\n"

    Process {
        id: proc
        command: ["sh", "-c", ". /etc/os-release 2>/dev/null; echo \"NS_OS=${NAME:-Unknown}\"; echo \"NS_VER=${VERSION:-$VERSION_ID}\"; echo \"NS_ID=${ID:-unknown}\"; echo \"NS_KERNEL=$(uname -r 2>/dev/null)\"; NS_PM=\"unknown\"; if [ -f /etc/arch-release ]; then NS_PM=\"pacman\"; elif [ -n \"$NIX_STATE_DIR\" ] || [ -f /etc/NIXOS ] || [ -d /run/current-system ]; then NS_PM=\"nix\"; elif [ -f /etc/fedora-release ]; then NS_PM=\"dnf\"; elif [ -f /etc/debian_version ]; then NS_PM=\"apt\"; elif [ -f /etc/gentoo-release ]; then NS_PM=\"portage\"; elif [ -f /etc/alpine-release ]; then NS_PM=\"apk\"; elif [ -f /etc/void-release ]; then NS_PM=\"xbps\"; elif [ -f /etc/opensuse-release ]; then NS_PM=\"zypper\"; fi; echo \"NS_PM=$NS_PM\"; echo \"NS_HYPR=$(hyprctl version 2>/dev/null | head -1)\"; echo \"NS_QS=$(qs --version 2>/dev/null | head -1)\"; echo \"NS_BUILD=$(git -C \"" + Quickshell.shellDir + "\" rev-parse --short HEAD 2>/dev/null)\""]
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

    Component.onCompleted: {
        refresh();
        checkUpdates();
    }

    Process {
        id: updProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.updateChecking = false;
                let local = "";
                let remote = "";
                for (const line of text.split("\n")) {
                    const t = line.trim();
                    if (t.indexOf("LOCAL ") === 0)
                        local = t.slice(6);
                    else if (t.indexOf("REMOTE ") === 0)
                        remote = t.slice(7);
                    else if (t === "NOREMOTE" || t === "NOREPO")
                        root.updateStatus = t === "NOREMOTE" ? "No git remote" : "Not a git checkout";
                    else if (t.indexOf("ERROR ") === 0)
                        root.updateStatus = "Check failed";
                }
                if (local !== "" && remote !== "" && remote !== "UNKNOWN") {
                    root.updateAvailable = local !== remote;
                    root.updateStatus = local !== remote ? "Update available" : "Up to date";
                } else if (remote === "UNKNOWN") {
                    root.updateAvailable = false;
                    root.updateStatus = "Check failed";
                }
            }
        }
        onExited: root.updateChecking = false
    }
}
