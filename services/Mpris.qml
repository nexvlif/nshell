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
    readonly property real position: root.tickPos
    readonly property real length: active?.length ?? 0
    readonly property bool canSeek: active?.canSeek ?? false
    readonly property bool canGoNext: active?.canGoNext ?? false
    readonly property bool canGoPrevious: active?.canGoPrevious ?? false
    readonly property bool shuffle: active?.shuffle ?? false
    readonly property int loop: active?.loopState ?? 0

    property real tickPos: 0
    readonly property string trackKey: (active?.trackTitle ?? "") + "|" + (active?.trackArtist ?? "") + "|" + (active?.length ?? 0)
    onTrackKeyChanged: root.tickPos = active?.position ?? 0
    onActiveChanged: root.tickPos = active?.position ?? 0
    onPlayingChanged: root.tickPos = active?.position ?? root.tickPos

    Timer {
        interval: 1000
        running: root.playing && root.active !== null
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const pos = active?.position;
            if (pos !== undefined && Math.abs(pos - root.tickPos) > 2)
                root.tickPos = pos;
            else if (root.length > 0)
                root.tickPos = Math.min(root.tickPos + 1, root.length);
            else
                root.tickPos = root.tickPos + 1;
        }
    }

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
        if (active && active.canSeek) {
            root.tickPos = v * (active.length || 0);
            active.seek(v * (active.length || 0) - (active.position || 0));
        }
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
