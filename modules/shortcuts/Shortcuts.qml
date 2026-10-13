import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services

Scope {
    id: root

    GlobalShortcut {
        appid: "nshell"
        name: "launcherToggle"
        description: "Toggle command palette"
        property bool armed: false
        onPressed: armed = true
        onReleased: {
            if (armed) {
                armed = false;
                Ui.toggleLauncher();
            }
        }
    }

    GlobalShortcut {
        appid: "nshell"
        name: "sessionToggle"
        description: "Toggle session menu"
        onPressed: Ui.toggleSession()
    }

    GlobalShortcut {
        appid: "nshell"
        name: "volumeUp"
        description: "Volume up + OSD"
        onPressed: Audio.increment(0.05)
    }
    GlobalShortcut {
        appid: "nshell"
        name: "volumeDown"
        description: "Volume down + OSD"
        onPressed: Audio.decrement(0.05)
    }
    GlobalShortcut {
        appid: "nshell"
        name: "volumeMute"
        description: "Mute toggle + OSD"
        onPressed: Audio.toggleMute()
    }
    GlobalShortcut {
        appid: "nshell"
        name: "brightnessUp"
        description: "Brightness up + OSD"
        onPressed: {
            Brightness.increment(0.05);
            Ui.flashOsd("brightness");
        }
    }
    GlobalShortcut {
        appid: "nshell"
        name: "brightnessDown"
        description: "Brightness down + OSD"
        onPressed: {
            Brightness.decrement(0.05);
            Ui.flashOsd("brightness");
        }
    }
    GlobalShortcut {
        appid: "nshell"
        name: "mediaToggle"
        description: "Toggle media playback"
        onPressed: Mpris.playPause()
    }
    GlobalShortcut {
        appid: "nshell"
        name: "mediaNext"
        description: "Next track"
        onPressed: Mpris.next()
    }
    GlobalShortcut {
        appid: "nshell"
        name: "mediaPrev"
        description: "Previous track"
        onPressed: Mpris.previous()
    }
}
