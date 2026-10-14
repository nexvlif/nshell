pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var backups: []

    function dir(): string {
        return (Quickshell.env("HOME") || "") + "/Documents/nshell-backups";
    }

    property string _ls: "import os,sys\n" + "d=sys.argv[1] if len(sys.argv)>1 else '.'\n" + "try:\n" + "  es=sorted([e.name for e in os.scandir(d) if e.is_dir(follow_symlinks=False)],reverse=True)\n" + "except Exception:\n" + "  es=[]\n" + "print('\\n'.join(es))\n"

    function refreshList(): void {
        if (!listProc.running)
            listProc.running = true;
    }

    function exportNow(): void {
        Quickshell.execDetached(["sh", "-c", "d=\"$1/$(date +%Y%m%d-%H%M%S)\"; mkdir -p \"$d\"; cp \"$HOME/.config/nshell/\"*.json \"$d/\" 2>/dev/null; [ -f \"$HOME/.config/hypr/nshell-managed.lua\" ] && cp \"$HOME/.config/hypr/nshell-managed.lua\" \"$d/\"; notify-send 'nshell' \"Backup saved to $d\";", "sh", dir()]);
        listTimer.restart();
    }

    function validName(name: string): bool {
        return /^[0-9]{8}-[0-9]{6}$/.test(name);
    }

    function configDir(): string {
        return (Quickshell.env("HOME") || "") + "/.config/nshell";
    }

    property string _restorePy: "import json,os,shutil,sys,time\n" + "src=sys.argv[1]\n" + "dst=sys.argv[2]\n" + "try:\n" + "  files=sorted(f for f in os.listdir(src) if f.endswith('.json'))\n" + "except Exception as e:\n" + "  print('cannot list backup: %s' % e,file=sys.stderr)\n" + "  sys.exit(2)\n" + "if not files:\n" + "  print('no config files in backup',file=sys.stderr)\n" + "  sys.exit(2)\n" + "try:\n" + "  [json.load(open(os.path.join(src,f))) for f in files]\n" + "except Exception as e:\n" + "  print('invalid backup: %s' % e,file=sys.stderr)\n" + "  sys.exit(1)\n" + "bk=os.path.join(os.path.dirname(dst.rstrip('/')),'pre-restore-'+time.strftime('%Y%m%d-%H%M%S'))\n" + "os.makedirs(bk,exist_ok=True)\n" + "for f in files:\n" + "  cur=os.path.join(dst,f)\n" + "  curbak=os.path.join(bk,f)\n" + "  dat=open(cur,'rb').read() if os.path.isfile(cur) else None\n" + "  shutil.copy(os.path.join(src,f),cur)\n" + "  open(curbak,'wb').write(dat) if dat is not None else None\n" + "lua=os.path.join(src,'nshell-managed.lua')\n" + "if os.path.isfile(lua):\n" + "  shutil.copy(lua,os.path.join(os.path.expanduser('~'),'.config','hypr','nshell-managed.lua'))\n" + "print('restored %d file(s), previous kept in %s' % (len(files),bk))\n"

    function restore(name: string): void {
        if (!validName(name) || restoreProc.running)
            return;
        restoreProc.command = ["python3", "-c", root._restorePy, root.dir() + "/" + name, root.configDir()];
        restoreProc.running = true;
    }

    Timer {
        id: listTimer
        interval: 800
        repeat: false
        onTriggered: root.refreshList()
    }

    Process {
        id: listProc
        command: ["python3", "-c", root._ls, root.dir()]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                root.backups = t === "" ? [] : t.split("\n");
            }
        }
    }

    Process {
        id: restoreProc
        stderr: StdioCollector {
            id: restoreErr
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                Quickshell.execDetached(["hyprctl", "reload"]);
                Quickshell.execDetached(["notify-send", "nshell", "Backup restored — Hyprland reloaded"]);
            } else {
                const why = restoreErr.text.trim() !== "" ? restoreErr.text.trim() : "unknown error";
                Quickshell.execDetached(["notify-send", "nshell", "Restore failed: " + why]);
            }
            root.refreshList();
        }
    }

    Component.onCompleted: refreshList()
}
