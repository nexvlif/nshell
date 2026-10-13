pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root
    readonly property var players: Mpris.players
    readonly property var active: {
        if (!players)
            return null;
        for (let i = players.values.length - 1; i >= 0; --i) {
            const p = players.values[i];
            if (p.playbackState === MprisPlaybackState.Playing)
                return p;
        }
        return players.values.length > 0 ? players.values[0] : null;
    }
    readonly property string title: active?.trackTitle || ""
    readonly property string artist: active?.trackArtist || ""
    readonly property bool playing: active?.playbackState === MprisPlaybackState.Playing
}
