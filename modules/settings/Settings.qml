import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.ndesign
import qs.services

Scope {
    id: root
    property string page: "appearance"
    property string query: ""
    property string bindQuery: ""

    readonly property var nav: [
        {
            "group": "nshell"
        },
        {
            "id": "appearance",
            "icon": "palette",
            "label": "Appearance"
        },
        {
            "id": "bar",
            "icon": "dock_to_bottom",
            "label": "Bar"
        },
        {
            "id": "widgets",
            "icon": "widgets",
            "label": "Widgets"
        },
        {
            "id": "wallpaper",
            "icon": "image",
            "label": "Wallpaper"
        },
        {
            "id": "panels",
            "icon": "notifications",
            "label": "Notifications & OSD"
        },
        {
            "id": "launcher",
            "icon": "search",
            "label": "Launcher"
        },
        {
            "id": "behavior",
            "icon": "settings_suggest",
            "label": "Behavior"
        },
        {
            "group": "Hyprland"
        },
        {
            "id": "hypr-general",
            "icon": "grid_view",
            "label": "General & Layout"
        },
        {
            "id": "hypr-decor",
            "icon": "rounded_corner",
            "label": "Decoration"
        },
        {
            "id": "hypr-blur",
            "icon": "blur_on",
            "label": "Blur & Shadow"
        },
        {
            "id": "hypr-anim",
            "icon": "animation",
            "label": "Animations"
        },
        {
            "id": "hypr-input",
            "icon": "keyboard",
            "label": "Input & Touchpad"
        },
        {
            "id": "hypr-binds",
            "icon": "key",
            "label": "Keybindings"
        },
        {
            "group": "System"
        },
        {
            "id": "about",
            "icon": "info",
            "label": "System & Files"
        }
    ]

    function navMatch(label: string): bool {
        if (root.query.trim() === "")
            return true;
        return label.toLowerCase().indexOf(root.query.trim().toLowerCase()) >= 0;
    }

    readonly property string barPos: Config.options.bar.position
    readonly property var bindFiltered: HyprConf.binds.filter(b => {
        root.bindQuery;
        const q = root.bindQuery.trim().toLowerCase();
        if (q === "")
            return true;
        const hay = (HyprConf.bindText(b) + " " + (b.dispatcher || "") + " " + (b.arg || "") + " " + (b.description || "")).toLowerCase();
        return hay.indexOf(q) >= 0;
    })

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Ui.settingsOpen
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            onVisibleChanged: {
                if (visible) {
                    panel.forceActiveFocus();
                    HyprConf.refresh();
                    HyprConf.loadBinds();
                    HyprConf.checkIntegrated();
                    Backup.refreshList();
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45)
                MouseArea {
                    anchors.fill: parent
                    onClicked: Ui.settingsOpen = false
                }
            }

            NRect {
                id: panel
                focus: true
                Keys.onEscapePressed: Ui.settingsOpen = false
                width: Math.min(1040, win.width - 48)
                height: Math.min(660, win.height - 48)
                anchors.centerIn: parent
                corner: Tokens.rounding.popover
                fill: "bg1"
                stroke: "none"
                shadow: 28

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    ColumnLayout {
                        Layout.preferredWidth: 250
                        Layout.minimumWidth: 250
                        Layout.maximumWidth: 250
                        Layout.fillHeight: true
                        Layout.topMargin: 16
                        Layout.bottomMargin: 16
                        Layout.leftMargin: 16
                        Layout.rightMargin: 8
                        spacing: 8

                        NText {
                            Layout.fillWidth: true
                            kind: "title"
                            semibold: true
                            text: "Settings"
                        }
                        NSearchBox {
                            Layout.fillWidth: true
                            placeholder: "Search settings"
                            onAccepted: root.query = text
                            field.onTextChanged: root.query = text
                        }
                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentHeight: navCol.implicitHeight
                            ColumnLayout {
                                id: navCol
                                width: parent.width
                                spacing: 2
                                Repeater {
                                    model: root.nav
                                    delegate: Item {
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        implicitHeight: modelData.group !== undefined ? (root.navMatch("") ? 28 : 28) : (root.navMatch(modelData.label) ? 40 : 0)
                                        visible: modelData.group !== undefined ? true : root.navMatch(modelData.label)
                                        NText {
                                            visible: modelData.group !== undefined
                                            anchors.left: parent.left
                                            anchors.leftMargin: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            kind: "caption"
                                            color: Theme.fg3
                                            text: modelData.group !== undefined ? modelData.group : ""
                                        }
                                        Rectangle {
                                            visible: modelData.group === undefined
                                            anchors.fill: parent
                                            radius: Tokens.rounding.large
                                            color: root.page === modelData.id ? Theme.primaryContainer : navHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 12
                                                anchors.rightMargin: 12
                                                spacing: 10
                                                NIcon {
                                                    Layout.alignment: Qt.AlignVCenter
                                                    name: modelData.icon ?? "circle"
                                                    filled: root.page === modelData.id
                                                    iconSize: 18
                                                    color: root.page === modelData.id ? Theme.primaryContainerFg : Theme.fg2
                                                }
                                                NText {
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                    elide: Text.ElideRight
                                                    kind: "small"
                                                    semibold: root.page === modelData.id
                                                    text: modelData.label ?? ""
                                                }
                                            }
                                            MouseArea {
                                                id: navHover
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.page = modelData.id
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: Theme.stroke2
                    }

                    Flickable {
                        id: flick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 16
                        Layout.bottomMargin: 16
                        Layout.leftMargin: 12
                        Layout.rightMargin: 16
                        clip: true
                        contentWidth: width
                        contentHeight: contentCol.implicitHeight
                        ColumnLayout {
                            id: contentCol
                            width: flick.width
                            spacing: 18

                            ColumnLayout {
                                visible: root.page === "appearance"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Appearance"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Theme"
                                    desc: "Applies instantly to the whole shell."
                                    SChoiceRow {
                                        icon: "dark_mode"
                                        title: "Color mode"
                                        sub: "Dark or light shell theme"
                                        options: [["dark", "Dark"], ["light", "Light"]]
                                        current: Config.options.theme.mode
                                        onPicked: v => Config.set("theme.mode", v)
                                    }
                                    SChoiceRow {
                                        icon: "palette"
                                        title: "Accent color"
                                        sub: "Recolors buttons, toggles and highlights"
                                        options: [["", "Auto"], ["#479ef5", "Blue"], ["#43a047", "Green"], ["#fb8c00", "Orange"], ["#e53935", "Red"], ["#8e24aa", "Purple"], ["#00acc1", "Teal"]]
                                        current: Config.options.theme.accent ?? ""
                                        onPicked: v => Config.set("theme.accent", v)
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "bar"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Bar"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Position & size"
                                    SChoiceRow {
                                        icon: "dock_to_bottom"
                                        title: "Position"
                                        sub: "Screen edge for the bar"
                                        options: [["top", "Top"], ["bottom", "Bottom"], ["left", "Left"], ["right", "Right"]]
                                        current: Config.options.bar.position
                                        onPicked: v => Config.set("bar.position", v)
                                    }
                                    SChoiceRow {
                                        visible: root.barPos === "left" || root.barPos === "right"
                                        icon: "vertical_align_center"
                                        title: "Vertical mode"
                                        sub: "Full stretches edge to edge, adaptive only when windows exist"
                                        options: [["adaptive", "Adaptive"], ["compact", "Compact"], ["full", "Full"]]
                                        current: Config.options.bar.verticalMode
                                        onPicked: v => Config.set("bar.verticalMode", v)
                                    }
                                    SSliderRow {
                                        icon: "height"
                                        title: "Bar height"
                                        value: Config.options.bar.height
                                        from: 32
                                        to: 72
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => Config.set("bar.height", Math.round(v))
                                    }
                                    SSliderRow {
                                        icon: "padding"
                                        title: "Pill padding"
                                        value: Config.options.bar.pillPadding
                                        from: 8
                                        to: 32
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => Config.set("bar.pillPadding", Math.round(v))
                                    }
                                    SSliderRow {
                                        icon: "account_circle"
                                        title: "Avatar size"
                                        value: Config.options.bar.avatarSize
                                        from: 24
                                        to: 48
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => Config.set("bar.avatarSize", Math.round(v))
                                    }
                                    STextRow {
                                        icon: "photo"
                                        title: "Avatar image"
                                        value: Config.options.bar.avatarPath ?? ""
                                        placeholder: "/path/to/avatar (empty = ~/Pictures/pp.jpg)"
                                        onCommitted: text => Config.set("bar.avatarPath", text)
                                    }
                                    SSliderRow {
                                        icon: "shadow"
                                        title: "Shadow"
                                        value: Config.options.bar.shadow
                                        from: 0
                                        to: 24
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => Config.set("bar.shadow", Math.round(v))
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Margins (" + root.barPos + ")"
                                    desc: "Distance from the screen edge for the current bar position."
                                    SSliderRow {
                                        title: "Top"
                                        value: (Config.options.bar.margins[root.barPos] ?? {}).top ?? 8
                                        from: 0
                                        to: 32
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => Config.set("bar.margins." + root.barPos + ".top", Math.round(v))
                                    }
                                    SSliderRow {
                                        title: "Bottom"
                                        value: (Config.options.bar.margins[root.barPos] ?? {}).bottom ?? 8
                                        from: 0
                                        to: 32
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => Config.set("bar.margins." + root.barPos + ".bottom", Math.round(v))
                                    }
                                    SSliderRow {
                                        title: "Left"
                                        value: (Config.options.bar.margins[root.barPos] ?? {}).left ?? 8
                                        from: 0
                                        to: 32
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => Config.set("bar.margins." + root.barPos + ".left", Math.round(v))
                                    }
                                    SSliderRow {
                                        title: "Right"
                                        value: (Config.options.bar.margins[root.barPos] ?? {}).right ?? 8
                                        from: 0
                                        to: 32
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => Config.set("bar.margins." + root.barPos + ".right", Math.round(v))
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Modules"
                                    desc: "Show or hide bar modules."
                                    SSwitchRow {
                                        icon: "schedule"
                                        title: "Clock"
                                        checked: Config.options.bar.showClock !== false
                                        onToggled: Config.set("bar.showClock", !(Config.options.bar.showClock !== false))
                                    }
                                    SSwitchRow {
                                        icon: "calendar_month"
                                        title: "Date"
                                        checked: Config.options.bar.showDate !== false
                                        onToggled: Config.set("bar.showDate", !(Config.options.bar.showDate !== false))
                                    }
                                    SSwitchRow {
                                        icon: "schedule"
                                        title: "12-hour clock"
                                        checked: Config.options.bar.clock12h !== false
                                        onToggled: Config.set("bar.clock12h", !(Config.options.bar.clock12h !== false))
                                    }
                                    SSwitchRow {
                                        icon: "search"
                                        title: "Search button"
                                        checked: Config.options.bar.showSearch !== false
                                        onToggled: Config.set("bar.showSearch", !(Config.options.bar.showSearch !== false))
                                    }
                                    SSwitchRow {
                                        icon: "workspaces"
                                        title: "Workspaces"
                                        checked: Config.options.bar.showWorkspaces !== false
                                        onToggled: Config.set("bar.showWorkspaces", !(Config.options.bar.showWorkspaces !== false))
                                    }
                                    SSwitchRow {
                                        icon: "mimo"
                                        title: "Active window"
                                        checked: Config.options.bar.showActiveWindow !== false
                                        onToggled: Config.set("bar.showActiveWindow", !(Config.options.bar.showActiveWindow !== false))
                                    }
                                    SSwitchRow {
                                        icon: "partly_cloudy_day"
                                        title: "Weather"
                                        checked: Config.options.bar.showWeather !== false
                                        onToggled: Config.set("bar.showWeather", !(Config.options.bar.showWeather !== false))
                                    }
                                    SSwitchRow {
                                        icon: "memory"
                                        title: "Resources (CPU/MEM)"
                                        checked: Config.options.bar.showResources === true
                                        onToggled: Config.set("bar.showResources", !(Config.options.bar.showResources === true))
                                    }
                                    SSwitchRow {
                                        icon: "construction"
                                        title: "Tools"
                                        checked: Config.options.bar.showTools !== false
                                        onToggled: Config.set("bar.showTools", !(Config.options.bar.showTools !== false))
                                    }
                                    SSwitchRow {
                                        icon: "apps"
                                        title: "System tray"
                                        checked: Config.options.bar.showTray !== false
                                        onToggled: Config.set("bar.showTray", !(Config.options.bar.showTray !== false))
                                    }
                                    SSwitchRow {
                                        icon: "volume_up"
                                        title: "Volume icon"
                                        checked: Config.options.bar.showVolume !== false
                                        onToggled: Config.set("bar.showVolume", !(Config.options.bar.showVolume !== false))
                                    }
                                    SSwitchRow {
                                        icon: "battery_full"
                                        title: "Battery"
                                        checked: Config.options.bar.showBattery !== false
                                        onToggled: Config.set("bar.showBattery", !(Config.options.bar.showBattery !== false))
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Pinned apps"
                                    SRow {
                                        icon: "push_pin"
                                        title: (Config.options.bar.pinnedApps ?? []).length + " pinned apps"
                                        sub: "Pin apps from the launcher. Clearing removes all pins."
                                        NButton {
                                            variant: "secondary"
                                            text: "Clear"
                                            onClicked: Config.set("bar.pinnedApps", [])
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "widgets"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Widgets"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Desktop widgets"
                                    desc: "Floating cards on the wallpaper. Unlock positions, then drag cards."
                                    SSwitchRow {
                                        icon: "widgets"
                                        title: "Show widgets"
                                        checked: Config.options.widgets.enabled !== false
                                        onToggled: Config.set("widgets.enabled", !(Config.options.widgets.enabled !== false))
                                    }
                                    SSwitchRow {
                                        icon: "lock"
                                        title: "Lock positions"
                                        sub: "Unlock to drag cards around"
                                        checked: Config.options.widgets.locked !== false
                                        onToggled: Config.set("widgets.locked", !(Config.options.widgets.locked !== false))
                                    }
                                    Repeater {
                                        model: WidgetReg.widgets
                                        delegate: SSwitchRow {
                                            required property var modelData
                                            title: modelData.title
                                            checked: Config.options.widgets[modelData.id] ?? modelData.on
                                            onToggled: Config.set("widgets." + modelData.id, !(Config.options.widgets[modelData.id] ?? modelData.on))
                                        }
                                    }
                                    SRow {
                                        icon: "restart_alt"
                                        title: "Reset card positions"
                                        sub: "Cards return to their default layout"
                                        NButton {
                                            variant: "secondary"
                                            text: "Reset"
                                            onClicked: Config.set("widgets.pos", "")
                                        }
                                    }
                                    STextRow {
                                        icon: "image"
                                        title: "Image card path"
                                        value: Config.options.widgets.imagePath ?? ""
                                        placeholder: "/path/to/image (or pick from Widgets)"
                                        onCommitted: text => Config.set("widgets.imagePath", text)
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Weather"
                                    desc: "Auto uses IP geolocation. Turn it off to pin a city."
                                    SSwitchRow {
                                        icon: "explore"
                                        title: "Auto-detect location"
                                        sub: "Off = use the manual coordinates below"
                                        checked: Config.options.weather.autoLocate !== false
                                        onToggled: Weather.setAuto(!(Config.options.weather.autoLocate !== false))
                                    }
                                    STextRow {
                                        icon: "location_city"
                                        title: "City label"
                                        value: (Config.options.weather.autoLocate !== false ? Weather.place : (Config.options.weather.place ?? "")) ?? ""
                                        placeholder: Weather.place || "e.g. Jakarta"
                                        onCommitted: text => {
                                            Config.set("weather.place", text);
                                            if (text !== "")
                                                Weather.place = text;
                                        }
                                    }
                                    STextRow {
                                        icon: "height"
                                        title: "Latitude"
                                        value: (Config.options.weather.autoLocate !== false || (Config.options.weather.lat ?? 9999) >= 9000) ? "" : String(Config.options.weather.lat)
                                        placeholder: String(Math.round(Weather.lat * 100) / 100)
                                        onCommitted: text => {
                                            const v = parseFloat(text);
                                            if (!isNaN(v) && v >= -90 && v <= 90)
                                                Weather.setManual(v, Weather.lon, Config.options.weather.place ?? Weather.place);
                                        }
                                    }
                                    STextRow {
                                        icon: "width"
                                        title: "Longitude"
                                        value: (Config.options.weather.autoLocate !== false || (Config.options.weather.lon ?? 9999) >= 9000) ? "" : String(Config.options.weather.lon)
                                        placeholder: String(Math.round(Weather.lon * 100) / 100)
                                        onCommitted: text => {
                                            const v = parseFloat(text);
                                            if (!isNaN(v) && v >= -180 && v <= 180)
                                                Weather.setManual(Weather.lat, v, Config.options.weather.place ?? Weather.place);
                                        }
                                    }
                                    SRow {
                                        icon: "sync"
                                        title: "Weather data"
                                        sub: Weather.ready ? (Weather.place || "Local") + " · " + Weather.text + " " + Weather.desc : "Not loaded yet"
                                        NButton {
                                            variant: "secondary"
                                            text: "Refresh"
                                            onClicked: {
                                                if (Config.options.weather.autoLocate !== false)
                                                    Weather.locate();
                                                else
                                                    Weather.fetch();
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "wallpaper"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Wallpaper"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Current"
                                    NRoundedImage {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 170
                                        source: Config.options.wallpaper.path !== "" ? "file://" + Config.options.wallpaper.path : ""
                                        imgRadius: Tokens.rounding.medium
                                    }
                                    SRow {
                                        icon: "image"
                                        title: "File"
                                        sub: Config.options.wallpaper.path !== "" ? Config.options.wallpaper.path : "No wallpaper set"
                                        NButton {
                                            variant: "secondary"
                                            text: "Choose"
                                            onClicked: {
                                                Ui.wallMenuScreen = win.screen;
                                                Ui.wallPickerOpen = true;
                                            }
                                        }
                                    }
                                    SChoiceRow {
                                        icon: "fit_screen"
                                        title: "Fit mode"
                                        sub: "How the image fills the screen"
                                        options: [["fill", "Fill"], ["fit", "Fit"], ["stretch", "Stretch"]]
                                        current: Config.options.wallpaper.mode ?? "fill"
                                        onPicked: v => Config.set("wallpaper.mode", v)
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "panels"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Notifications & OSD"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Notifications"
                                    SSwitchRow {
                                        icon: "do_not_disturb_on"
                                        title: "Do not disturb"
                                        checked: Config.options.notifications.dnd === true
                                        onToggled: Config.set("notifications.dnd", !(Config.options.notifications.dnd === true))
                                    }
                                    SSliderRow {
                                        icon: "timer"
                                        title: "Popup timeout"
                                        value: Config.options.notifications.timeout
                                        from: 1000
                                        to: 10000
                                        step: 500
                                        suffix: "ms"
                                        onMoved: v => Config.set("notifications.timeout", Math.round(v))
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "On-screen display"
                                    SSliderRow {
                                        icon: "timer"
                                        title: "OSD timeout"
                                        value: Config.options.osd.timeout
                                        from: 400
                                        to: 3000
                                        step: 100
                                        suffix: "ms"
                                        onMoved: v => Config.set("osd.timeout", Math.round(v))
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "launcher"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Launcher"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Results"
                                    SSliderRow {
                                        icon: "format_list_numbered"
                                        title: "Max shown"
                                        sub: "Maximum results visible at once"
                                        value: Config.options.launcher.maxShown
                                        from: 3
                                        to: 12
                                        step: 1
                                        onMoved: v => Config.set("launcher.maxShown", Math.round(v))
                                    }
                                    SRow {
                                        icon: "keyboard"
                                        title: "Toggle shortcut"
                                        sub: "Default bind is SUPER + A (see Keybindings page)"
                                        NButton {
                                            variant: "secondary"
                                            text: "View binds"
                                            onClicked: {
                                                root.page = "hypr-binds";
                                                root.bindQuery = "launcher";
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "behavior"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Behavior"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Screen lock"
                                    desc: "Idle lock (AutoLock) and suspend lock (SleepLock) are built in and official. hypridle config in scripts/ is only a fallback if SleepLock misbehaves."
                                    SSliderRow {
                                        icon: "timer"
                                        title: "Lock after idle"
                                        sub: "0 disables idle lock. Coffee and game mode pause it."
                                        value: Config.options.lock.idleMin ?? 10
                                        from: 0
                                        to: 60
                                        step: 5
                                        suffix: "min"
                                        onMoved: v => Config.set("lock.idleMin", Math.round(v))
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Night light"
                                    desc: "Warmer screen at night. Needs hyprsunset."
                                    SSwitchRow {
                                        icon: "nightlight"
                                        title: "Night light"
                                        checked: NightLight.enabled
                                        onToggled: NightLight.toggle()
                                    }
                                    SSliderRow {
                                        icon: "thermometer"
                                        title: "Temperature"
                                        sub: "Lower is warmer"
                                        value: NightLight.temperature
                                        from: 1000
                                        to: 6500
                                        step: 100
                                        suffix: "K"
                                        onMoved: v => NightLight.setTemp(Math.round(v))
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Stay awake & performance"
                                    SSwitchRow {
                                        icon: "coffee"
                                        title: "Coffee"
                                        sub: "Inhibit idle (pauses auto-lock, not suspend)"
                                        checked: Coffee.enabled
                                        onToggled: Coffee.toggle()
                                    }
                                    SSwitchRow {
                                        icon: "sports_esports"
                                        title: "Game mode"
                                        sub: "Disables animations/blur, inhibits idle, max power profile"
                                        checked: GameMode.enabled
                                        onToggled: GameMode.toggle()
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "hypr-general"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "General & Layout"
                                }
                                NText {
                                    visible: !HyprConf.ready
                                    kind: "caption"
                                    color: Theme.fg3
                                    text: "Reading live Hyprland values..."
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Gaps & borders"
                                    desc: "Applied instantly via hl.config and saved to nshell-managed.lua."
                                    SSliderRow {
                                        icon: "border_inner"
                                        title: "Gaps in"
                                        sub: "Space between windows"
                                        value: HyprConf.num("general:gaps_in", 5)
                                        from: 0
                                        to: 30
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => HyprConf.setInt("general:gaps_in", Math.round(v))
                                    }
                                    SSliderRow {
                                        icon: "border_outer"
                                        title: "Gaps out"
                                        sub: "Space between windows and screen edge"
                                        value: HyprConf.num("general:gaps_out", 10)
                                        from: 0
                                        to: 40
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => HyprConf.setInt("general:gaps_out", Math.round(v))
                                    }
                                    SSliderRow {
                                        icon: "border_style"
                                        title: "Border size"
                                        value: HyprConf.num("general:border_size", 2)
                                        from: 0
                                        to: 10
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => HyprConf.setInt("general:border_size", Math.round(v))
                                    }
                                    STextRow {
                                        icon: "border_color"
                                        title: "Active border"
                                        sub: "Gradient: two colors + angle, e.g. rgba(77,159,255,0.9) rgba(77,159,255,0.9) 45deg"
                                        value: HyprConf.str("general:col.active_border", "")
                                        placeholder: "color1 color2 45deg"
                                        onCommitted: t => {
                                            if (t !== "")
                                                HyprConf.setStr("general:col.active_border", t);
                                        }
                                    }
                                    STextRow {
                                        icon: "border_color"
                                        title: "Inactive border"
                                        value: HyprConf.str("general:col.inactive_border", "")
                                        placeholder: "rgba(131313aa)"
                                        onCommitted: t => {
                                            if (t !== "")
                                                HyprConf.setStr("general:col.inactive_border", t);
                                        }
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Layout & behavior"
                                    SChoiceRow {
                                        icon: "grid_view"
                                        title: "Layout"
                                        options: [["dwindle", "Dwindle"], ["master", "Master"], ["scrolling", "Scrolling"]]
                                        current: HyprConf.str("general:layout", "dwindle")
                                        onPicked: v => HyprConf.setStr("general:layout", v)
                                    }
                                    SSwitchRow {
                                        icon: "open_in_full"
                                        title: "Resize on border"
                                        sub: "Resize windows by dragging borders and gaps"
                                        checked: HyprConf.boolean("general:resize_on_border", true)
                                        onToggled: HyprConf.setBool("general:resize_on_border", !HyprConf.boolean("general:resize_on_border", true))
                                    }
                                    SSwitchRow {
                                        icon: "warning"
                                        title: "Allow tearing"
                                        sub: "See Hyprland tearing wiki before enabling"
                                        checked: HyprConf.boolean("general:allow_tearing", false)
                                        onToggled: HyprConf.setBool("general:allow_tearing", !HyprConf.boolean("general:allow_tearing", false))
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "hypr-decor"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Decoration"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Corners & opacity"
                                    SSliderRow {
                                        icon: "rounded_corner"
                                        title: "Rounding"
                                        value: HyprConf.num("decoration:rounding", 12)
                                        from: 0
                                        to: 30
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => HyprConf.setInt("decoration:rounding", Math.round(v))
                                    }
                                    SSliderRow {
                                        icon: "opacity"
                                        title: "Active opacity"
                                        value: HyprConf.num("decoration:active_opacity", 1)
                                        from: 0.3
                                        to: 1
                                        step: 0.01
                                        onMoved: v => HyprConf.setFloat("decoration:active_opacity", v)
                                    }
                                    SSliderRow {
                                        icon: "opacity"
                                        title: "Inactive opacity"
                                        value: HyprConf.num("decoration:inactive_opacity", 1)
                                        from: 0.3
                                        to: 1
                                        step: 0.01
                                        onMoved: v => HyprConf.setFloat("decoration:inactive_opacity", v)
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Shadow"
                                    SSwitchRow {
                                        icon: "shadow"
                                        title: "Shadow enabled"
                                        checked: HyprConf.boolean("decoration:shadow:enabled", true)
                                        onToggled: HyprConf.setBool("decoration:shadow:enabled", !HyprConf.boolean("decoration:shadow:enabled", true))
                                    }
                                    SSliderRow {
                                        icon: "blur_circular"
                                        title: "Shadow range"
                                        value: HyprConf.num("decoration:shadow:range", 4)
                                        from: 0
                                        to: 20
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => HyprConf.setInt("decoration:shadow:range", Math.round(v))
                                    }
                                    SSliderRow {
                                        icon: "contrast"
                                        title: "Render power"
                                        value: HyprConf.num("decoration:shadow:render_power", 3)
                                        from: 1
                                        to: 4
                                        step: 1
                                        onMoved: v => HyprConf.setInt("decoration:shadow:render_power", Math.round(v))
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "hypr-blur"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Blur & Shadow"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Blur"
                                    SSwitchRow {
                                        icon: "blur_on"
                                        title: "Blur enabled"
                                        checked: HyprConf.boolean("decoration:blur:enabled", true)
                                        onToggled: HyprConf.setBool("decoration:blur:enabled", !HyprConf.boolean("decoration:blur:enabled", true))
                                    }
                                    SSliderRow {
                                        icon: "photo_size_select_large"
                                        title: "Blur size"
                                        value: HyprConf.num("decoration:blur:size", 3)
                                        from: 0
                                        to: 12
                                        step: 1
                                        suffix: "px"
                                        onMoved: v => HyprConf.setInt("decoration:blur:size", Math.round(v))
                                    }
                                    SSliderRow {
                                        icon: "layers"
                                        title: "Blur passes"
                                        value: HyprConf.num("decoration:blur:passes", 1)
                                        from: 0
                                        to: 4
                                        step: 1
                                        onMoved: v => HyprConf.setInt("decoration:blur:passes", Math.round(v))
                                    }
                                    SSliderRow {
                                        icon: "contrast"
                                        title: "Vibrancy"
                                        value: HyprConf.num("decoration:blur:vibrancy", 0.1696)
                                        from: 0
                                        to: 1
                                        step: 0.01
                                        onMoved: v => HyprConf.setFloat("decoration:blur:vibrancy", v)
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "hypr-anim"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Animations"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Global toggle"
                                    desc: "Per-animation curves and speeds are defined in conf/41-animations.lua."
                                    SSwitchRow {
                                        icon: "animation"
                                        title: "Animations enabled"
                                        checked: HyprConf.boolean("animations:enabled", true)
                                        onToggled: HyprConf.setBool("animations:enabled", !HyprConf.boolean("animations:enabled", true))
                                    }
                                    SRow {
                                        icon: "code"
                                        title: "Fine-tune curves"
                                        sub: "Edit hl.curve / hl.animation blocks in conf/41-animations.lua"
                                        NButton {
                                            variant: "secondary"
                                            text: "Open file"
                                            onClicked: HyprConf.openHyprFolder()
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "hypr-input"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Input & Touchpad"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Keyboard"
                                    STextRow {
                                        icon: "keyboard"
                                        title: "Layout"
                                        sub: "e.g. us, de, fr, us,ru"
                                        value: HyprConf.str("input:kb_layout", "us")
                                        placeholder: "us"
                                        onCommitted: t => {
                                            if (t !== "")
                                                HyprConf.setStr("input:kb_layout", t);
                                        }
                                    }
                                    STextRow {
                                        icon: "keyboard"
                                        title: "Variant"
                                        value: HyprConf.str("input:kb_variant", "")
                                        placeholder: "(empty)"
                                        onCommitted: t => HyprConf.setStr("input:kb_variant", t)
                                    }
                                    STextRow {
                                        icon: "keyboard"
                                        title: "Options"
                                        sub: "e.g. caps:escape"
                                        value: HyprConf.str("input:kb_options", "")
                                        placeholder: "(empty)"
                                        onCommitted: t => HyprConf.setStr("input:kb_options", t)
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Mouse & touchpad"
                                    SSliderRow {
                                        icon: "mouse"
                                        title: "Sensitivity"
                                        value: HyprConf.num("input:sensitivity", 0)
                                        from: -1
                                        to: 1
                                        step: 0.05
                                        onMoved: v => HyprConf.setFloat("input:sensitivity", v)
                                    }
                                    SChoiceRow {
                                        icon: "speed"
                                        title: "Acceleration profile"
                                        options: [["flat", "Flat"], ["adaptive", "Adaptive"], ["custom", "Custom"]]
                                        current: HyprConf.str("input:accel_profile", "") || "flat"
                                        onPicked: v => HyprConf.setStr("input:accel_profile", v)
                                    }
                                    SChoiceRow {
                                        icon: "near_me"
                                        title: "Follow mouse"
                                        sub: "Focus follows the cursor"
                                        options: [[0, "Off"], [1, "On"]]
                                        current: Math.round(HyprConf.num("input:follow_mouse", 1))
                                        onPicked: v => HyprConf.setInt("input:follow_mouse", v)
                                    }
                                    SSwitchRow {
                                        icon: "swipe"
                                        title: "Natural scroll (touchpad)"
                                        checked: HyprConf.boolean("input:touchpad:natural_scroll", true)
                                        onToggled: HyprConf.setBool("input:touchpad:natural_scroll", !HyprConf.boolean("input:touchpad:natural_scroll", true))
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Misc"
                                    SSwitchRow {
                                        icon: "block"
                                        title: "Disable Hyprland logo"
                                        checked: HyprConf.boolean("misc:disable_hyprland_logo", true)
                                        onToggled: HyprConf.setBool("misc:disable_hyprland_logo", !HyprConf.boolean("misc:disable_hyprland_logo", true))
                                    }
                                    SSwitchRow {
                                        icon: "block"
                                        title: "Disable splash rendering"
                                        checked: HyprConf.boolean("misc:disable_splash_rendering", true)
                                        onToggled: HyprConf.setBool("misc:disable_splash_rendering", !HyprConf.boolean("misc:disable_splash_rendering", true))
                                    }
                                    SChoiceRow {
                                        icon: "image"
                                        title: "Force default wallpaper"
                                        options: [[0, "Off"], [1, "On"]]
                                        current: Math.round(HyprConf.num("misc:force_default_wallpaper", 0))
                                        onPicked: v => HyprConf.setInt("misc:force_default_wallpaper", v)
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "hypr-binds"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "Keybindings"
                                }
                                NText {
                                    kind: "caption"
                                    color: Theme.fg3
                                    text: HyprConf.binds.length + " bindings live from Hyprland. Binds are defined in conf/50-binds.lua — this list is read-only."
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    NSearchBox {
                                        Layout.fillWidth: true
                                        placeholder: "Filter bindings"
                                        field.onTextChanged: root.bindQuery = text
                                    }
                                    NIconButton {
                                        name: "sync"
                                        glyphSize: 16
                                        onClicked: HyprConf.loadBinds()
                                    }
                                }
                                Repeater {
                                    model: root.bindFiltered
                                    delegate: SRow {
                                        required property var modelData
                                        icon: "key"
                                        title: HyprConf.bindText(modelData)
                                        sub: (modelData.description && modelData.description !== "" ? modelData.description : (modelData.dispatcher || "")) + (modelData.arg && modelData.arg !== "" ? "  ·  " + modelData.arg : "")
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: root.page === "about"
                                Layout.fillWidth: true
                                spacing: 12
                                NText {
                                    kind: "subtitle"
                                    semibold: true
                                    text: "System & Files"
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "System"
                                    desc: "About this machine and shell."
                                    SRow {
                                        icon: ""
                                        title: SysInfo.ready ? SysInfo.osName : "Loading..."
                                        sub: SysInfo.ready ? (SysInfo.osVersion !== "" ? SysInfo.osVersion : SysInfo.osId) : "Reading system info..."
                                        Rectangle {
                                            Layout.preferredWidth: 44
                                            Layout.preferredHeight: 44
                                            Layout.alignment: Qt.AlignVCenter
                                            radius: 22
                                            color: Theme.active
                                            NText {
                                                anchors.centerIn: parent
                                                kind: "title"
                                                semibold: true
                                                color: Theme.activeFg
                                                text: SysInfo.osInitial
                                            }
                                        }
                                    }
                                    SRow {
                                        icon: "shopping_bag"
                                        title: "Package manager"
                                        sub: SysInfo.ready ? SysInfo.pkgManager : "..."
                                    }
                                    SRow {
                                        icon: "memory"
                                        title: "Kernel"
                                        sub: SysInfo.ready ? SysInfo.kernel : "..."
                                    }
                                    SRow {
                                        icon: "grid_view"
                                        title: "Hyprland"
                                        sub: SysInfo.ready && SysInfo.hyprVersion !== "" ? SysInfo.hyprVersion : "Not running"
                                    }
                                    SRow {
                                        icon: "terminal"
                                        title: "Quickshell"
                                        sub: SysInfo.ready && SysInfo.qsVersion !== "" ? SysInfo.qsVersion : "..."
                                    }
                                    SRow {
                                        icon: "info"
                                        title: "nshell " + SysInfo.nshellVersion
                                        sub: SysInfo.nshellBuild !== "" ? "build " + SysInfo.nshellBuild : "dev build"
                                        NButton {
                                            variant: "secondary"
                                            text: "Refresh"
                                            onClicked: SysInfo.refresh()
                                        }
                                    }
                                    SRow {
                                        icon: SysInfo.updateAvailable ? "system_update" : "check_circle"
                                        title: SysInfo.updateChecking ? "Checking for updates..." : (SysInfo.updateAvailable ? "Update available" : "Up to date")
                                        sub: SysInfo.updateChecking ? "Comparing with git remote..." : (SysInfo.updateStatus !== "" ? SysInfo.updateStatus : "Run git pull in your checkout to update")
                                        NButton {
                                            variant: "secondary"
                                            text: "Check"
                                            onClicked: SysInfo.checkUpdates()
                                        }
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Dependencies"
                                    desc: "External tools nshell shells out to. Missing ones disable related features."
                                    SRow {
                                        icon: "handyman"
                                        title: Deps.ready ? (Deps.missing.length === 0 ? "All tools installed" : Deps.missing.length + " tools missing") : "Checking..."
                                        sub: Deps.ready && Deps.missing.length > 0 ? Deps.missing.map(m => m.tool).join(", ") : "grim, wl-copy, gio, hyprshot, wf-recorder, hyprpicker, brightnessctl, playerctl, cliphist, hyprsunset, powerprofilesctl, python-pillow"
                                        NButton {
                                            variant: "secondary"
                                            text: "Rescan"
                                            onClicked: Deps.refresh()
                                        }
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Hyprland persistence"
                                    desc: "nshell applies Hyprland changes live via hyprctl and saves them to nshell-managed.lua."
                                    SRow {
                                        icon: HyprConf.integrated ? "check_circle" : "warning"
                                        title: HyprConf.integrated ? "hyprland.lua loads nshell settings" : "Not integrated yet"
                                        sub: HyprConf.integrated ? "Your tweaks survive restarts." : "Add the dofile loader to hyprland.lua so tweaks survive restarts."
                                        NButton {
                                            visible: !HyprConf.integrated
                                            variant: "secondary"
                                            text: "Integrate"
                                            onClicked: HyprConf.integrate()
                                        }
                                    }
                                    SRow {
                                        icon: "restart_alt"
                                        title: "Reload Hyprland"
                                        sub: "Re-reads all Hyprland config files"
                                        NButton {
                                            variant: "secondary"
                                            text: "Reload"
                                            onClicked: HyprConf.reloadHypr()
                                        }
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Files"
                                    SRow {
                                        icon: "folder"
                                        title: "Hyprland config folder"
                                        sub: "~/.config/hypr"
                                        NButton {
                                            variant: "secondary"
                                            text: "Open"
                                            onClicked: HyprConf.openHyprFolder()
                                        }
                                    }
                                    SRow {
                                        icon: "description"
                                        title: "nshell config"
                                        sub: "~/.config/nshell/config.json"
                                        NButton {
                                            variant: "secondary"
                                            text: "Open"
                                            onClicked: HyprConf.openNshellConfig()
                                        }
                                    }
                                    SRow {
                                        icon: "keyboard"
                                        title: "Settings shortcut"
                                        sub: "Copies an hl.bind snippet for SUPER + comma to the clipboard"
                                        NButton {
                                            variant: "secondary"
                                            text: "Copy"
                                            onClicked: HyprConf.copySettingsSnippet()
                                        }
                                    }
                                    SRow {
                                        icon: "lock"
                                        title: "Lock shortcut"
                                        sub: "Copies an hl.bind snippet for SUPER + L to the clipboard"
                                        NButton {
                                            variant: "secondary"
                                            text: "Copy bind"
                                            onClicked: HyprConf.copyLockSnippet()
                                        }
                                    }
                                }
                                SSection {
                                    Layout.fillWidth: true
                                    title: "Backup"
                                    desc: "Snapshots of config.json, widget data and nshell-managed.lua under ~/Documents/nshell-backups."
                                    SRow {
                                        icon: "backup"
                                        title: "Export backup"
                                        sub: "Save a timestamped snapshot now"
                                        NButton {
                                            variant: "secondary"
                                            text: "Export"
                                            onClicked: Backup.exportNow()
                                        }
                                    }
                                    Repeater {
                                        model: Backup.backups
                                        delegate: SRow {
                                            required property var modelData
                                            icon: "history"
                                            title: modelData
                                            sub: "Restore this snapshot (reloads Hyprland)"
                                            NButton {
                                                variant: "secondary"
                                                text: "Restore"
                                                onClicked: Backup.restore(modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
