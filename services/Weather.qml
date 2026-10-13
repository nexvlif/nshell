pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root
    property real temp: 0
    property int code: -1
    property bool ready: false
    property string place: ""
    property real lat: -6.2
    property real lon: 106.8

    readonly property string icon: {
        if (code < 0)
            return "weather_cloudy";
        if (code === 0)
            return isDay ? "weather_sunny" : "weather_moon";
        if (code <= 3)
            return isDay ? "weather_partly_cloudy_day" : "weather_partly_cloudy_night";
        if (code === 45 || code === 48)
            return "weather_fog";
        if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82))
            return "weather_rain";
        if ((code >= 71 && code <= 77) || code === 85 || code === 86)
            return "weather_snow";
        if (code >= 95)
            return "weather_thunderstorm";
        return "weather_cloudy";
    }
    readonly property bool isDay: {
        const h = Time.date.getHours();
        return h >= 6 && h < 18;
    }
    readonly property string text: ready ? Math.round(temp) + "°" : "--"

    function locate(): void {
        locProc.running = true;
    }
    function fetch(): void {
        wxProc.running = true;
    }

    Component.onCompleted: locate()

    Timer {
        interval: 900000
        running: true
        repeat: true
        onTriggered: root.fetch()
    }

    Process {
        id: locProc
        command: ["sh", "-c", "curl -s --max-time 10 'http://ip-api.com/json/?fields=lat,lon,city'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(text);
                    if (o.lat && o.lon) {
                        root.lat = o.lat;
                        root.lon = o.lon;
                        root.place = o.city || "";
                    }
                } catch (e) {}
                root.fetch();
            }
        }
    }

    Process {
        id: wxProc
        command: ["sh", "-c", "curl -s --max-time 15 'https://api.open-meteo.com/v1/forecast?latitude=" + root.lat + "&longitude=" + root.lon + "&current=temperature_2m,weather_code'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const cur = JSON.parse(text).current;
                    if (cur) {
                        root.temp = cur.temperature_2m;
                        root.code = cur.weather_code;
                        root.ready = true;
                    }
                } catch (e) {}
            }
        }
    }
}
