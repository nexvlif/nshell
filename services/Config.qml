pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string filePath: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
    property string configDir: root.filePath + "/nshell"
    property string configFile: root.configDir + "/config.json"
    property alias options: adapter
    property bool ready: false

    function set(path: string, value: var): void {
        const keys = path.split(".");
        let obj = adapter;
        for (let i = 0; i < keys.length - 1; ++i) {
            if (!obj[keys[i]] || typeof obj[keys[i]] !== "object")
                obj[keys[i]] = {};
            obj = obj[keys[i]];
        }
        obj[keys[keys.length - 1]] = value;
    }

    Timer {
        id: reloadTimer
        interval: 80
        repeat: false
        onTriggered: view.reload()
    }
    Timer {
        id: writeTimer
        interval: 120
        repeat: false
        onTriggered: view.writeAdapter()
    }

    Process {
        id: moveProc
        onExited: exitCode => {
            if (exitCode === 0) {
                view.writeAdapter();
                Quickshell.execDetached(["notify-send", "nshell", "Config was corrupt — quarantined and reset to defaults"]);
            } else {
                Quickshell.execDetached(["notify-send", "nshell", "Config failed to load and could not be quarantined"]);
            }
            root.ready = true;
        }
    }

    FileView {
        id: view
        path: root.configFile
        watchChanges: true
        onFileChanged: reloadTimer.restart()
        onAdapterUpdated: writeTimer.restart()
        onLoaded: root.ready = true
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                Quickshell.execDetached(["mkdir", "-p", root.configDir]);
                writeAdapter();
                root.ready = true;
            } else {
                const bad = root.configFile + ".corrupt-" + Qt.formatDateTime(new Date(), "yyyyMMdd-HHmmss");
                if (!moveProc.running) {
                    moveProc.command = ["mv", root.configFile, bad];
                    moveProc.running = true;
                }
            }
        }
        onSaveFailed: error => {
            Quickshell.execDetached(["notify-send", "nshell", "Could not save config: " + FileViewError.toString(error)]);
        }

        JsonAdapter {
            id: adapter

            property JsonObject theme: JsonObject {
                property string mode: "dark"

                property string accent: ""
            }
            property JsonObject bar: JsonObject {
                property string position: "bottom"
                property int height: 48
                property string verticalMode: "adaptive"
                property JsonObject margins: JsonObject {
                    property JsonObject top: JsonObject {
                        property int top: 8
                        property int bottom: 8
                        property int left: 8
                        property int right: 8
                    }
                    property JsonObject bottom: JsonObject {
                        property int top: 8
                        property int bottom: 8
                        property int left: 8
                        property int right: 8
                    }
                    property JsonObject left: JsonObject {
                        property int top: 8
                        property int bottom: 8
                        property int left: 8
                        property int right: 8
                    }
                    property JsonObject right: JsonObject {
                        property int top: 8
                        property int bottom: 8
                        property int left: 8
                        property int right: 8
                    }
                }
                property int pillPadding: 20
                property int avatarSize: 32
                property string avatarPath: ""
                property int shadow: 12
                property list<string> pinnedApps: []
                property bool clock12h: true
                property bool showDate: true
                property bool showSearch: true
                property bool showTools: true
                property bool showWeather: true
                property bool showResources: false
                property bool showActiveWindow: true
                property bool showWorkspaces: true
                property bool showTray: true
                property bool showClock: true
                property bool showBattery: true
                property bool showVolume: true
            }
            property JsonObject launcher: JsonObject {
                property int maxShown: 7
            }
            property JsonObject notifications: JsonObject {
                property int timeout: 5000
                property bool dnd: false
            }
            property JsonObject osd: JsonObject {
                property int timeout: 1200
            }
            property JsonObject wallpaper: JsonObject {
                property string path: ""
                property string mode: "fill"
            }
            property JsonObject widgets: JsonObject {
                property bool enabled: true
                property bool locked: true
                property string pos: ""
                property bool clock: true
                property bool week: true
                property bool stats: true
                property bool weather: true
                property bool worldclock: true
                property bool todo: true
                property bool notes: true
                property bool timers: true
                property bool media: true
                property bool battery: true
                property bool net: true
                property bool image: true
                property string imagePath: ""
            }
            property JsonObject lock: JsonObject {
                property int idleMin: 10
            }
            property JsonObject nightlight: JsonObject {
                property bool enabled: false
                property int temperature: 4500
            }
            property JsonObject weather: JsonObject {
                property bool autoLocate: true
                property string place: ""
                property real lat: 9999
                property real lon: 9999
            }
            property JsonObject coffee: JsonObject {
                property bool enabled: false
            }
            property JsonObject gamemode: JsonObject {
                property bool enabled: false
            }
            property JsonObject apps: JsonObject {
                property string pos: ""
            }
        }
    }
}
