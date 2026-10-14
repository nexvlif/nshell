pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var vals: ({})
    property bool ready: false
    property bool integrated: false
    property var binds: []

    readonly property var optList: ["general:gaps_in", "general:gaps_out", "general:border_size", "general:layout", "general:resize_on_border", "general:allow_tearing", "general:col.active_border", "general:col.inactive_border", "decoration:rounding", "decoration:rounding_power", "decoration:active_opacity", "decoration:inactive_opacity", "decoration:shadow:enabled", "decoration:shadow:range", "decoration:shadow:render_power", "decoration:blur:enabled", "decoration:blur:size", "decoration:blur:passes", "decoration:blur:vibrancy", "animations:enabled", "input:kb_layout", "input:kb_variant", "input:kb_options", "input:sensitivity", "input:accel_profile", "input:follow_mouse", "input:touchpad:natural_scroll", "misc:disable_hyprland_logo", "misc:disable_splash_rendering", "misc:force_default_wallpaper"]
    readonly property string managedPath: (Quickshell.env("HOME") || "") + "/.config/hypr/nshell-managed.lua"

    property string _py: "import json,subprocess\n" + "OPTS=['general:gaps_in','general:gaps_out','general:border_size','general:layout','general:resize_on_border','general:allow_tearing','general:col.active_border','general:col.inactive_border','decoration:rounding','decoration:rounding_power','decoration:active_opacity','decoration:inactive_opacity','decoration:shadow:enabled','decoration:shadow:range','decoration:shadow:render_power','decoration:blur:enabled','decoration:blur:size','decoration:blur:passes','decoration:blur:vibrancy','animations:enabled','input:kb_layout','input:kb_variant','input:kb_options','input:sensitivity','input:accel_profile','input:follow_mouse','input:touchpad:natural_scroll','misc:disable_hyprland_logo','misc:disable_splash_rendering','misc:force_default_wallpaper']\n" + "OUT={}\n" + "for o in OPTS:\n" + "  try:\n" + "    r=subprocess.run(['hyprctl','getoption','-j',o],capture_output=True,text=True,timeout=5)\n" + "    d=json.loads(r.stdout)\n" + "    v=None\n" + "    ks=[k for k in ['int','float','bool','str','gradient','css'] if k in d]\n" + "    v=d[ks[0]] if ks else None\n" + "    sv=str(v) if v is not None else ''\n" + "    pv=sv.split()\n" + "    fv=pv[0] if pv else sv\n" + "    OUT[o]=int(fv) if o in ['general:gaps_in','general:gaps_out'] and pv else v\n" + "    OUT[o]='' if OUT[o]=='[[EMPTY]]' else OUT[o]\n" + "  except Exception:\n" + "    OUT[o]=None\n" + "print(json.dumps(OUT))\n"

    function num(opt: string, def: real): real {
        const v = vals[opt];
        return (typeof v === "number") ? v : def;
    }
    function boolean(opt: string, def: bool): bool {
        const v = vals[opt];
        return (typeof v === "boolean") ? v : def;
    }
    function str(opt: string, def: string): string {
        const v = vals[opt];
        return (typeof v === "string") ? v : def;
    }

    function put(opt: string, v: var): void {
        const c = Object.assign({}, vals);
        c[opt] = v;
        vals = c;
    }
    function luaSnippet(opt: string, luaVal: string): string {
        const parts = opt.split(":");
        let s = parts[parts.length - 1] + " = " + luaVal;
        for (let i = parts.length - 2; i >= 0; --i)
            s = parts[i] + " = { " + s + " }";
        return "hl.config({ " + s + " })";
    }
    function luaQuote(s: string): string {
        return "\"" + cleanText(s) + "\"";
    }
    function applyLive(opt: string): void {
        let code = "";
        if (opt === "general:col.active_border") {
            const ab = activeBorder();
            code = "hl.config({ general = { col = { active_border = { colors = { \"" + ab.colors[0] + "\", \"" + ab.colors[1] + "\" }, angle = " + ab.angle + " } } } })";
        } else if (opt === "general:col.inactive_border") {
            code = "hl.config({ general = { col = { inactive_border = \"" + firstColor(str(opt, "rgba(131313aa)"), "rgba(131313aa)") + "\" } } } })";
        } else {
            const v = vals[opt];
            let luaVal = "nil";
            if (typeof v === "boolean")
                luaVal = v ? "true" : "false";
            else if (typeof v === "number")
                luaVal = String(v);
            else if (typeof v === "string")
                luaVal = luaQuote(v);
            else
                return;
            code = luaSnippet(opt, luaVal);
        }
        Quickshell.execDetached(["hyprctl", "eval", code]);
    }
    function setInt(opt: string, v: int): void {
        put(opt, Math.round(v));
        applyLive(opt);
        writeTimer.restart();
    }
    function setFloat(opt: string, v: real): void {
        put(opt, v);
        applyLive(opt);
        writeTimer.restart();
    }
    function setBool(opt: string, v: bool): void {
        put(opt, v);
        applyLive(opt);
        writeTimer.restart();
    }
    function setStr(opt: string, v: string): void {
        put(opt, v);
        applyLive(opt);
        writeTimer.restart();
    }

    function refresh(): void {
        if (!loader.running) {
            loader.command = ["python3", "-c", root._py];
            loader.running = true;
        }
    }
    function loadBinds(): void {
        if (!bindProc.running) {
            bindProc.command = ["hyprctl", "binds", "-j"];
            bindProc.running = true;
        }
    }
    function checkIntegrated(): void {
        if (!intCheck.running) {
            intCheck.command = ["grep", "-q", "nshell-managed", root.managedPath];
            intCheck.running = true;
        }
    }

    function cleanColor(s: string, fallback: string): string {
        let c = (s || "").replace(/[^a-zA-Z0-9(),.#]/g, "");
        return c === "" ? fallback : c;
    }
    function firstColor(s: string, fallback: string): string {
        const parts = (s || "").trim().split(/\s+/);
        for (let i = 0; i < parts.length; ++i) {
            const p = cleanColor(parts[i], "");
            if (p !== "" && !p.endsWith("deg"))
                return p;
        }
        return fallback;
    }
    function cleanText(s: string): string {
        return (s || "").replace(/["\\$`]/g, "").slice(0, 64);
    }
    function activeBorder(): var {
        const g = str("general:col.active_border", "rgba(131313aa) rgba(131313aa) 45deg");
        const parts = g.trim().split(/\s+/);
        let angle = 45;
        const cols = [];
        for (let i = 0; i < parts.length; ++i) {
            const p = cleanColor(parts[i], "");
            if (p === "")
                continue;
            if (p.endsWith("deg"))
                angle = parseInt(p, 10) || 0;
            else
                cols.push(p);
        }
        while (cols.length < 2)
            cols.push(cols.length > 0 ? cols[0] : "rgba(131313aa)");
        return {
            "colors": cols.slice(0, 2),
            "angle": angle
        };
    }

    function managedText(): string {
        const ab = activeBorder();
        const ib = firstColor(str("general:col.inactive_border", "rgba(131313aa)"), "rgba(131313aa)");
        const layout = str("general:layout", "dwindle");
        const okLayout = ["dwindle", "master", "scrolling"].includes(layout) ? layout : "dwindle";
        const kbLayout = cleanText(str("input:kb_layout", "us")) || "us";
        const kbVariant = cleanText(str("input:kb_variant", ""));
        const kbOptions = cleanText(str("input:kb_options", ""));
        const accel = str("input:accel_profile", "flat");
        const okAccel = ["flat", "adaptive", "custom"].includes(accel) ? accel : "flat";
        const L = [];
        L.push("-- Managed by nshell Settings. Do not edit manually.");
        L.push("-- Loaded from hyprland.lua via dofile(...nshell-managed.lua).");
        L.push("hl.config({");
        L.push("  general = {");
        L.push("    gaps_in = " + Math.round(num("general:gaps_in", 5)) + ",");
        L.push("    gaps_out = " + Math.round(num("general:gaps_out", 10)) + ",");
        L.push("    border_size = " + Math.round(num("general:border_size", 2)) + ",");
        L.push("    layout = \"" + okLayout + "\",");
        L.push("    resize_on_border = " + (boolean("general:resize_on_border", true) ? "true" : "false") + ",");
        L.push("    allow_tearing = " + (boolean("general:allow_tearing", false) ? "true" : "false") + ",");
        L.push("    col = {");
        L.push("      active_border = { colors = { \"" + ab.colors[0] + "\", \"" + ab.colors[1] + "\" }, angle = " + ab.angle + " },");
        L.push("      inactive_border = \"" + ib + "\",");
        L.push("    },");
        L.push("  },");
        L.push("  decoration = {");
        L.push("    rounding = " + Math.round(num("decoration:rounding", 12)) + ",");
        L.push("    rounding_power = " + num("decoration:rounding_power", 2).toFixed(1) + ",");
        L.push("    active_opacity = " + num("decoration:active_opacity", 1).toFixed(3) + ",");
        L.push("    inactive_opacity = " + num("decoration:inactive_opacity", 1).toFixed(3) + ",");
        L.push("    shadow = {");
        L.push("      enabled = " + (boolean("decoration:shadow:enabled", true) ? "true" : "false") + ",");
        L.push("      range = " + Math.round(num("decoration:shadow:range", 4)) + ",");
        L.push("      render_power = " + Math.round(num("decoration:shadow:render_power", 3)) + ",");
        L.push("    },");
        L.push("    blur = {");
        L.push("      enabled = " + (boolean("decoration:blur:enabled", true) ? "true" : "false") + ",");
        L.push("      size = " + Math.round(num("decoration:blur:size", 3)) + ",");
        L.push("      passes = " + Math.round(num("decoration:blur:passes", 1)) + ",");
        L.push("      vibrancy = " + num("decoration:blur:vibrancy", 0.1696).toFixed(4) + ",");
        L.push("    },");
        L.push("  },");
        L.push("  animations = {");
        L.push("    enabled = " + (boolean("animations:enabled", true) ? "true" : "false") + ",");
        L.push("  },");
        L.push("  input = {");
        L.push("    kb_layout = \"" + kbLayout + "\",");
        L.push("    kb_variant = \"" + kbVariant + "\",");
        L.push("    kb_options = \"" + kbOptions + "\",");
        L.push("    sensitivity = " + num("input:sensitivity", 0).toFixed(3) + ",");
        L.push("    accel_profile = \"" + okAccel + "\",");
        L.push("    follow_mouse = " + Math.round(num("input:follow_mouse", 1)) + ",");
        L.push("    touchpad = {");
        L.push("      natural_scroll = " + (boolean("input:touchpad:natural_scroll", true) ? "true" : "false") + ",");
        L.push("    },");
        L.push("  },");
        L.push("  misc = {");
        L.push("    disable_hyprland_logo = " + (boolean("misc:disable_hyprland_logo", true) ? "true" : "false") + ",");
        L.push("    disable_splash_rendering = " + (boolean("misc:disable_splash_rendering", true) ? "true" : "false") + ",");
        L.push("    force_default_wallpaper = " + Math.round(num("misc:force_default_wallpaper", 0)) + ",");
        L.push("  },");
        L.push("})");
        return L.join("\n");
    }

    function writeManaged(): void {
        const t = managedText();
        const cmd = "cat > \"$HOME/.config/hypr/nshell-managed.lua\" <<'NSHELL_HYPR_EOF'\n" + t + "\nNSHELL_HYPR_EOF";
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    function integrate(): void {
        Quickshell.execDetached(["sh", "-c", "grep -q 'nshell-managed' \"$HOME/.config/hypr/hyprland.lua\" 2>/dev/null || printf '\\n-- nshell Settings (managed)\\ndofile((os.getenv(\"HOME\") or \"\") .. \"/.config/hypr/nshell-managed.lua\")\\n' >> \"$HOME/.config/hypr/hyprland.lua\""]);
        intRecheck.restart();
    }
    function reloadHypr(): void {
        Quickshell.execDetached(["hyprctl", "reload"]);
    }
    function openHyprFolder(): void {
        Quickshell.execDetached(["sh", "-c", "xdg-open \"$HOME/.config/hypr\" 2>/dev/null || $TERMINAL -e sh -c 'ls \"$HOME/.config/hypr\"; read'"]);
    }
    function openNshellConfig(): void {
        Quickshell.execDetached(["sh", "-c", "xdg-open \"$HOME/.config/nshell/config.json\" 2>/dev/null || true"]);
    }
    function copySettingsSnippet(): void {
        Quickshell.execDetached(["sh", "-c", "printf '%s' 'hl.bind(\"SUPER + comma\", hl.dsp.global(\"nshell:settingsToggle\"), { description = \"nshell: Settings\" })' | wl-copy 2>/dev/null; notify-send 'nshell' 'Keybind snippet copied — paste into hyprland.lua' 2>/dev/null || true"]);
    }
    function copyLockSnippet(): void {
        const snippet = "hl.bind(mainMod .. \" + L\", hl.dsp.exec_cmd(\"qs -p " + Quickshell.shellDir + "/shell.qml ipc call nshell lock\"), { description = \"nshell: Lock\" })";
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy 2>/dev/null; notify-send 'nshell' 'Lock bind snippet copied — paste into hyprland.lua' 2>/dev/null || true", "sh", snippet]);
    }

    function modText(m: int): string {
        const p = [];
        if ((m & 64) !== 0)
            p.push("SUPER");
        if ((m & 4) !== 0)
            p.push("Ctrl");
        if ((m & 8) !== 0)
            p.push("Alt");
        if ((m & 1) !== 0)
            p.push("Shift");
        return p.join(" + ");
    }
    function bindText(b: var): string {
        let s = modText(b.modmask || 0);
        if (b.key && b.key !== "")
            s += (s !== "" ? " + " : "") + b.key;
        else if (b.keycode)
            s += (s !== "" ? " + " : "") + "code:" + b.keycode;
        if (b.submap && b.submap !== "")
            s = "[" + b.submap + "] " + s;
        if (b.mouse)
            s += " (mouse)";
        return s;
    }

    Timer {
        id: writeTimer
        interval: 800
        repeat: false
        onTriggered: root.writeManaged()
    }
    Timer {
        id: intRecheck
        interval: 600
        repeat: false
        onTriggered: root.checkIntegrated()
    }

    Process {
        id: loader
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(text);
                    const c = {};
                    for (const k in o)
                        c[k] = o[k];
                    root.vals = c;
                    root.ready = true;
                } catch (e) {}
            }
        }
    }
    Process {
        id: bindProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const a = JSON.parse(text);
                    root.binds = Array.isArray(a) ? a : [];
                } catch (e) {}
            }
        }
    }
    Process {
        id: intCheck
        onExited: exitCode => root.integrated = exitCode === 0
    }

    Component.onCompleted: {
        refresh();
        loadBinds();
        checkIntegrated();
    }
}
