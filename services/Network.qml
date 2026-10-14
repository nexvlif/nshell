pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool wifiEnabled: true
    property bool connected: false
    property string ssid: ""
    property int signal: 0
    property string iface: ""
    property var networks: []
    property bool scanning: false
    property string connecting: ""
    property string lastError: ""
    property var vpns: []
    property string vpnActive: ""
    property bool vpnBusy: false

    readonly property string icon: {
        if (!wifiEnabled || !connected)
            return "wifi_off";
        return "wifi";
    }

    function poll(): void {
        if (!proc.running)
            proc.running = true;
        pollVpn();
    }

    function scan(): void {
        if (scanProc.running)
            return;
        root.scanning = true;
        scanProc.running = true;
    }

    function setWifiEnabled(on: bool): void {
        root.wifiEnabled = on;
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        repollTimer.restart();
    }

    function connect(ssid: string, password: string): void {
        if (connProc.running)
            return;
        root.connecting = ssid;
        root.lastError = "";
        if (password !== "")
            connProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        else
            connProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        connProc.running = true;
    }

    function disconnect(): void {
        if (root.iface !== "")
            Quickshell.execDetached(["nmcli", "device", "disconnect", root.iface]);
        repollTimer.restart();
    }

    function pollVpn(): void {
        if (!vpnProc.running)
            vpnProc.running = true;
    }

    function vpnUp(name: string): void {
        if (root.vpnBusy || name === "" || vpnProc.running)
            return;
        root.vpnBusy = true;
        vpnToggle.command = ["nmcli", "connection", "up", name];
        vpnToggle.running = true;
    }

    function vpnDown(): void {
        if (root.vpnBusy || root.vpnActive === "" || vpnProc.running)
            return;
        root.vpnBusy = true;
        vpnToggle.command = ["nmcli", "connection", "down", root.vpnActive];
        vpnToggle.running = true;
    }

    function parseVpns(text: string, active: bool): void {
        const out = active ? [] : root.vpns.slice();
        const seen = {};
        for (const n of out)
            seen[n] = true;
        for (const line of text.trim().split("\n")) {
            const t = line.trim();
            if (t === "")
                continue;
            const tmp = t.replace(/\\:/g, "\x00");
            const i = tmp.lastIndexOf(":");
            if (i < 0)
                continue;
            const type = tmp.slice(i + 1);
            if (type !== "vpn" && type !== "wireguard")
                continue;
            const name = tmp.slice(0, i).replace(/\x00/g, ":").trim();
            if (name === "")
                continue;
            if (active) {
                out.push(name);
            } else if (!seen[name]) {
                seen[name] = true;
                out.push(name);
            }
        }
        if (active) {
            root.vpnActive = out.length > 0 ? out[0] : "";
        } else {
            root.vpns = out;
        }
    }

    function parseNets(text: string): void {
        const bySsid = {};
        const out = [];
        for (const line of text.trim().split("\n")) {
            if (line === "")
                continue;
            const parts = line.replace(/\\\\/g, "\x01").replace(/\\:/g, "\x00").split(":");
            if (parts.length < 4)
                continue;
            const ssid = parts.slice(3).join(":").replace(/\x00/g, ":").replace(/\x01/g, "\\").trim();
            if (ssid === "" || ssid === "--")
                continue;
            const signal = parseInt(parts[1], 10) || 0;
            const inUse = parts[0] === "*";
            const sec = parts[2] === "--" ? "" : parts[2];
            if (bySsid[ssid] !== undefined) {
                const prev = out[bySsid[ssid]];
                prev.signal = Math.max(prev.signal, signal);
                prev.inUse = prev.inUse || inUse;
                if (prev.security === "" && sec !== "")
                    prev.security = sec;
            } else {
                bySsid[ssid] = out.length;
                out.push({
                    ssid: ssid,
                    signal: signal,
                    security: sec,
                    inUse: inUse
                });
            }
        }
        out.sort((a, b) => ((b.inUse ? 1 : 0) - (a.inUse ? 1 : 0)) || (b.signal - a.signal));
        root.networks = out;
        const cur = out.find(n => n.inUse);
        if (cur) {
            root.connected = true;
            root.signal = cur.signal;
            root.ssid = cur.ssid;
        } else if (out.length === 0 && root.wifiEnabled) {
        } else if (!cur) {
            root.connected = false;
            root.signal = 0;
            root.ssid = "";
        }
    }

    Component.onCompleted: {
        poll();
        ifaceProc.running = true;
    }

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: root.poll()
    }
    Timer {
        id: repollTimer
        interval: 2000
        repeat: false
        onTriggered: root.poll()
    }

    Process {
        id: proc
        command: ["sh", "-c", "nmcli -t -f WIFI general; echo ---NETS---; nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan no"]
        stdout: StdioCollector {
            onStreamFinished: {
                const marker = "---NETS---";
                const mi = text.indexOf(marker);
                const head = (mi >= 0 ? text.slice(0, mi) : text).trim();
                const netText = mi >= 0 ? text.slice(mi + marker.length).trim() : "";
                if (head !== "")
                    root.wifiEnabled = head.split("\n")[0].indexOf("enabled") === 0;
                if (!root.wifiEnabled) {
                    root.networks = [];
                    root.connected = false;
                    root.signal = 0;
                    root.ssid = "";
                    return;
                }
                if (netText !== "" && netText !== "none")
                    root.parseNets(netText);
                else {
                    root.networks = [];
                    root.connected = false;
                    root.signal = 0;
                    root.ssid = "";
                }
            }
        }
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "device", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {
            id: scanOut
            onStreamFinished: {
                root.scanning = false;
                if (text.trim() !== "" && text.trim() !== "none")
                    root.parseNets(text);
                repollTimer.restart();
            }
        }
        onExited: exitCode => {
            root.scanning = false;
        }
    }

    Process {
        id: ifaceProc
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE device | grep ':wifi$' | head -n 1 | cut -d: -f1"]
        stdout: StdioCollector {
            onStreamFinished: root.iface = text.trim()
        }
    }

    Process {
        id: connProc
        stderr: StdioCollector {
            id: connErr
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.lastError = connErr.text.trim().split("\n").filter(l => l.indexOf("Error") >= 0).join(" ") || "Failed to connect";
            root.connecting = "";
            repollTimer.restart();
        }
    }

    Process {
        id: vpnProc
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE connection show; echo ---VPN-ACTIVE---; nmcli -t -f NAME,TYPE connection show --active"]
        stdout: StdioCollector {
            onStreamFinished: {
                const marker = "---VPN-ACTIVE---";
                const mi = text.indexOf(marker);
                const all = mi >= 0 ? text.slice(0, mi) : text;
                const act = mi >= 0 ? text.slice(mi + marker.length) : "";
                root.parseVpns(all, false);
                root.parseVpns(act, true);
            }
        }
    }

    Process {
        id: vpnToggle
        onExited: {
            root.vpnBusy = false;
            root.pollVpn();
            repollTimer.restart();
        }
    }
}
