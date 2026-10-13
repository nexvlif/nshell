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
    readonly property string artUrl: active?.trackArtUrl || ""
    readonly property bool playing: active?.playbackState === MprisPlaybackState.Playing
    readonly property real position: active?.position ?? 0
    readonly property real length: active?.length ?? 0
    readonly property bool canSeek: active?.canSeek ?? false
    readonly property bool canGoNext: active?.canGoNext ?? false
    readonly property bool canGoPrevious: active?.canGoPrevious ?? false
    readonly property bool shuffle: active?.shuffle ?? false
    readonly property int loop: active?.loopState ?? 0

    function fmt(sec: real): string {
        const s = Math.max(0, Math.floor(sec));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }
    function playPause(): void {
        if (active?.canTogglePlaying)
            active.togglePlaying();
    }
    function next(): void {
        if (active?.canGoNext)
            active.next();
    }
    function previous(): void {
        if (active?.canGoPrevious)
            active.previous();
    }
    function seekTo(v: real): void {
        if (active && active.canSeek)
            active.seek(v * (active.length || 0) - (active.position || 0));
    }
    function toggleShuffle(): void {
        if (active && active.shuffleSupported)
            active.shuffle = !active.shuffle;
    }
    function cycleLoop(): void {
        if (active && active.loopSupported)
            active.loopState = ((active.loopState ?? 0) + 1) % 3;
    }
}
