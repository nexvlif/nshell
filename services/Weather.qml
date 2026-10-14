pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root
    property real temp: 0
    property int code: -1
    property real humidity: 0
    property real wind: 0
    property bool ready: false
    property string place: ""
    property real lat: -6.2
    property real lon: 106.8

    readonly property string icon: {
        if (code < 0)
            return "cloudy";
        if (code === 0)
            return isDay ? "sunny" : "clear_night";
        if (code <= 3)
            return isDay ? "partly_cloudy_day" : "partly_cloudy_night";
        if (code === 45 || code === 48)
            return "foggy";
        if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82))
            return "rainy";
        if ((code >= 71 && code <= 77) || code === 85 || code === 86)
            return "weather_snowy";
        if (code >= 95)
            return "thunderstorm";
        return "cloudy";
    }
    readonly property bool isDay: {
        const h = Time.date.getHours();
        return h >= 6 && h < 18;
    }
    readonly property string text: ready ? Math.round(temp) + "°" : "--"
    readonly property string desc: {
        if (code < 0)
            return "";
        if (code === 0)
            return "Clear sky";
        if (code === 1)
            return "Mainly clear";
        if (code === 2)
            return "Partly cloudy";
        if (code === 3)
            return "Overcast";
        if (code === 45 || code === 48)
            return "Fog";
        if (code >= 51 && code <= 57)
            return "Drizzle";
        if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82))
            return "Rain";
        if ((code >= 71 && code <= 77) || code === 85 || code === 86)
            return "Snow";
        if (code >= 95)
            return "Thunderstorm";
        return "Cloudy";
    }

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
        command: ["sh", "-c", "curl -s --max-time 15 'https://api.open-meteo.com/v1/forecast?latitude=" + root.lat + "&longitude=" + root.lon + "&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const cur = JSON.parse(text).current;
                    if (cur) {
                        root.temp = cur.temperature_2m;
                        root.code = cur.weather_code;
                        root.humidity = cur.relative_humidity_2m ?? 0;
                        root.wind = cur.wind_speed_10m ?? 0;
                        root.ready = true;
                    }
                } catch (e) {}
            }
        }
    }
}
