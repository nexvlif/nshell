pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var done: ({})
    property var failed: ({})
    property var pending: []
    property bool working: false
    property string current: ""
    property int rev: 0

    readonly property string cacheDir: (Quickshell.env("HOME") || "/tmp") + "/.cache/nshell/thumbs"

    property string _py: "import os,sys\n" + "src=sys.argv[1] if len(sys.argv)>1 else ''\n" + "dst=sys.argv[2] if len(sys.argv)>2 else ''\n" + "try:\n" + "  from PIL import Image\n" + "  if os.path.exists(dst) and os.path.getmtime(dst) >= os.path.getmtime(src):\n" + "    print('fresh')\n" + "  else:\n" + "    im=Image.open(src)\n" + "    im.thumbnail((512,512))\n" + "    os.makedirs(os.path.dirname(dst),exist_ok=True)\n" + "    im.convert('RGB').save(dst,'JPEG',quality=82)\n" + "    print('ok')\n" + "except Exception:\n" + "  print('err')\n"

    function key(path: string): string {
        let h = 0;
        for (let i = 0; i < path.length; ++i)
            h = ((h << 5) - h + path.charCodeAt(i)) | 0;
        return (h >>> 0).toString(16);
    }
    function thumbPath(path: string): string {
        return root.cacheDir + "/" + root.key(path) + ".jpg";
    }
    function thumb(path: string): string {
        root.rev;
        if (!path || path === "")
            return "";
        if (done[path])
            return done[path];
        ensure(path);
        return "";
    }
    function ensure(path: string): void {
        if (!path || path === "" || done[path] || failed[path])
            return;
        const q = root.pending.slice();
        if (!q.includes(path))
            q.push(path);
        root.pending = q;
        kick();
    }
    function kick(): void {
        if (root.working || root.pending.length === 0 || proc.running)
            return;
        root.working = true;
        const p = root.pending[0];
        root.current = p;
        proc.command = ["python3", "-c", root._py, p, root.thumbPath(p)];
        proc.running = true;
    }
    function finish(ok: bool): void {
        const p = root.current;
        if (p === "")
            return;
        root.current = "";
        root.pending = root.pending.slice(1);
        root.working = false;
        if (p !== "") {
            if (ok) {
                const c = Object.assign({}, root.done);
                c[p] = root.thumbPath(p);
                root.done = c;
            } else {
                const f = Object.assign({}, root.failed);
                f[p] = true;
                root.failed = f;
            }
            root.rev++;
        }
        kick();
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                root.finish(t === "ok" || t === "fresh");
            }
        }
        onExited: {
            if (root.working)
                root.finish(false);
        }
    }
}
