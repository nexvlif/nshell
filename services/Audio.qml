pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isStream && !n.isSink && n.audio)

    function deviceLabel(n): string {
        return n.nickname || n.description || n.name;
    }
    function setDefaultSink(n): void {
        Pipewire.preferredDefaultAudioSink = n;
    }
    function setDefaultSource(n): void {
        Pipewire.preferredDefaultAudioSource = n;
    }

    function setVolume(v): void {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, v));
    }
    function increment(step = 0.05): void {
        setVolume(volume + step);
    }
    function decrement(step = 0.05): void {
        setVolume(volume - step);
    }
    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function streamLabel(n): string {
        return n.nickname || n.description || n.name || "App";
    }
    function setStreamVolume(n, v): void {
        if (n?.audio)
            n.audio.volume = Math.max(0, Math.min(1, v));
    }
    function toggleStreamMute(n): void {
        if (n?.audio)
            n.audio.muted = !n.audio.muted;
    }

    PwObjectTracker {
        objects: sink ? [sink] : []
    }
    PwObjectTracker {
        objects: root.streams
    }
}
