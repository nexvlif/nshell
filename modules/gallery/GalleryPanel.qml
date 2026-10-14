import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ndesign
import qs.services

Scope {
    id: root
    property string filter: "all"
    property string current: ""
    property real zoom: 1
    property bool cropping: false
    property real csx: 0
    property real csy: 0
    property real ccx: 0
    property real ccy: 0
    property bool cdrag: false
    property bool pandrag: false
    property real plx: 0
    property real ply: 0
    property bool refitPending: false
    readonly property list<string> filters: ["all", "images", "videos"]
    readonly property var shown: {
        const list = Gallery.items.filter(i => !i.folder);
        if (filter === "images")
            return list.filter(i => !i.video);
        if (filter === "videos")
            return list.filter(i => i.video);
        return list;
    }
    readonly property var folders: Gallery.items.filter(i => i.folder)
    readonly property var gridModel: folders.concat(shown)
    readonly property var currentItem: {
        const f = Gallery.items.find(i => i.path === current);
        return f ? f : null;
    }
    readonly property bool isImage: currentItem && !currentItem.video
    readonly property string dirName: {
        const p = Gallery.dir.split("/");
        return p[p.length - 1] || Gallery.dir;
    }
    readonly property real kx0: Math.min(csx, ccx)
    readonly property real ky0: Math.min(csy, ccy)
    readonly property real kcw: Math.abs(ccx - csx)
    readonly property real kch: Math.abs(ccy - csy)
    readonly property bool hasCrop: kcw > 8 && kch > 8

    function filterLabel(f: string): string {
        if (f === "images")
            return "Images";
        if (f === "videos")
            return "Videos";
        return "All";
    }

    function openPreview(path: string): void {
        root.current = path;
        root.cropping = false;
        root.cdrag = false;
        root.zoom = 1;
        root.refitPending = true;
        flick.contentX = 0;
        flick.contentY = 0;
    }

    function fitZoom(): void {
        if (!viewImg || viewImg.implicitWidth <= 0 || viewImg.implicitHeight <= 0)
            return;
        if (flick.width <= 0 || flick.height <= 0)
            return;
        const z = Math.min(flick.width / viewImg.implicitWidth, flick.height / viewImg.implicitHeight);
        if (!isFinite(z) || z <= 0)
            return;
        root.zoom = Math.min(8, Math.max(0.05, z));
        flick.contentX = 0;
        flick.contentY = 0;
    }

    function fitValue(): real {
        if (!viewImg || viewImg.implicitWidth <= 0 || viewImg.implicitHeight <= 0)
            return 1;
        const z = Math.min(flick.width / viewImg.implicitWidth, flick.height / viewImg.implicitHeight);
        return isFinite(z) && z > 0 ? z : 1;
    }

    function setZoom(z: real): void {
        root.zoom = Math.min(8, Math.max(0.1, z));
    }

    function zoomAt(x: real, y: real, f: real): void {
        const nz = Math.min(8, Math.max(0.1, root.zoom * f));
        const k = nz / root.zoom;
        flick.contentX = (flick.contentX + x) * k - x;
        flick.contentY = (flick.contentY + y) * k - y;
        root.zoom = nz;
    }

    function applyCrop(): void {
        if (!hasCrop || !currentItem || !viewImg || viewImg.implicitWidth <= 0)
            return;
        const iw = viewImg.implicitWidth;
        const ih = viewImg.implicitHeight;
        const ox = Math.min(iw - 1, Math.max(0, Math.round(kx0 / zoom)));
        const oy = Math.min(ih - 1, Math.max(0, Math.round(ky0 / zoom)));
        const ow = Math.min(iw - ox, Math.max(1, Math.round(kcw / zoom)));
        const oh = Math.min(ih - oy, Math.max(1, Math.round(kch / zoom)));
        Gallery.cropFile(current, ox, oy, ow, oh);
        root.cropping = false;
        root.cdrag = false;
        root.refitPending = true;
    }

    FloatingWindow {
        id: win
        visible: Ui.galleryOpen
        title: currentItem ? currentItem.name + " — Gallery" : dirName + " — Gallery"
        minimumSize: Qt.size(860, 560)
        implicitWidth: 1120
        implicitHeight: 700
        color: Theme.bg1
        onClosed: Ui.galleryOpen = false
        onVisibleChanged: {
            if (visible) {
                root.current = "";
                root.filter = "all";
                root.cropping = false;
                root.zoom = 1;
                Gallery.refresh();
                body.forceActiveFocus();
            }
        }

        Item {
            id: body
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: {
                if (root.cropping) {
                    root.cropping = false;
                    root.cdrag = false;
                } else if (root.current !== "") {
                    root.current = "";
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                ColumnLayout {
                    Layout.preferredWidth: 190
                    Layout.fillHeight: true
                    spacing: 4
                    NText {
                        Layout.leftMargin: 12
                        Layout.bottomMargin: 4
                        kind: "caption"
                        color: Theme.fg3
                        text: "PLACES"
                    }
                    Repeater {
                        model: Gallery.places
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 44
                            radius: Tokens.rounding.large
                            color: Gallery.dir === modelData.path ? Theme.primaryContainer : placeHover.containsMouse ? Theme.subtleHover : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: Tokens.anim.faster
                                }
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10
                                NIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: modelData.icon
                                    filled: Gallery.dir === modelData.path || placeHover.containsMouse
                                    iconSize: 18
                                    color: Gallery.dir === modelData.path ? Theme.fg1 : Theme.fg2
                                }
                                NText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    elide: Text.ElideRight
                                    kind: "small"
                                    semibold: Gallery.dir === modelData.path
                                    color: Theme.fg1
                                    text: modelData.name
                                }
                            }
                            MouseArea {
                                id: placeHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Gallery.setDir(modelData.path)
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    NText {
                        Layout.leftMargin: 12
                        kind: "caption"
                        color: Theme.fg3
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 166
                        text: Gallery.dir
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 14

                    Item {
                        visible: root.current === ""
                        Layout.fillWidth: true
                        implicitHeight: 44
                        MouseArea {
                            anchors.fill: parent
                            onPressed: win.startSystemMove()
                        }
                        RowLayout {
                            anchors.fill: parent
                            spacing: 8
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "arrow_upward"
                                glyphSize: 18
                                onClicked: Gallery.goUp()
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 0
                                NText {
                                    kind: "title"
                                    semibold: true
                                    text: dirName
                                }
                                NText {
                                    kind: "caption"
                                    color: Theme.fg3
                                    elide: Text.ElideMiddle
                                    Layout.maximumWidth: 380
                                    text: Gallery.busy && Gallery.items.length === 0 ? "Loading..." : Gallery.dir + "  •  " + Gallery.items.length + (Gallery.items.length === 1 ? " item" : " items")
                                }
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "sync"
                                glyphSize: 18
                                onClicked: Gallery.refresh()
                            }
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "folder"
                                glyphSize: 18
                                onClicked: Gallery.openFolder()
                            }
                        }
                    }

                    Rectangle {
                        visible: root.current === ""
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.pill
                        color: Theme.bg2
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 2
                            Repeater {
                                model: root.filters
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: Tokens.rounding.pill
                                    color: root.filter === modelData ? Theme.primary : "transparent"
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Tokens.anim.faster
                                        }
                                    }
                                    NText {
                                        anchors.centerIn: parent
                                        kind: "small"
                                        semibold: root.filter === parent.modelData
                                        color: root.filter === parent.modelData ? Theme.primaryFg : Theme.fg2
                                        text: root.filterLabel(parent.modelData)
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.filter = modelData
                                    }
                                }
                            }
                        }
                    }

                    GridView {
                        visible: root.current === "" && root.gridModel.length > 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: 216
                        cellHeight: 192
                        model: root.gridModel
                        delegate: Item {
                            required property var modelData
                            readonly property string ext: modelData.folder ? "" : modelData.name.split(".").pop().toUpperCase()
                            width: 216
                            height: 192
                            NRoundedImage {
                                x: 8
                                y: 0
                                width: 200
                                height: 148
                                visible: !modelData.folder && !modelData.video
                                source: "file://" + modelData.path + "?rev=" + Gallery.rev
                                imgRadius: Tokens.rounding.large
                            }
                            Rectangle {
                                x: 8
                                y: 0
                                width: 200
                                height: 148
                                visible: modelData.folder || modelData.video
                                radius: Tokens.rounding.large
                                color: Theme.bg3
                                NIcon {
                                    anchors.centerIn: parent
                                    name: modelData.folder ? "folder" : "play_circle"
                                    filled: modelData.folder
                                    iconSize: modelData.folder ? 44 : 44
                                    color: modelData.folder ? Theme.fg1 : Theme.fg2
                                }
                                Rectangle {
                                    visible: modelData.video
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 8
                                    width: badgeText.implicitWidth + 16
                                    height: 24
                                    radius: 12
                                    color: Qt.rgba(0, 0, 0, 0.65)
                                    NText {
                                        id: badgeText
                                        anchors.centerIn: parent
                                        kind: "caption"
                                        color: "#ffffff"
                                        text: ext
                                    }
                                }
                            }
                            Rectangle {
                                x: 8
                                y: 0
                                width: 200
                                height: 148
                                visible: thumbHover.containsMouse
                                radius: Tokens.rounding.large
                                color: "transparent"
                                border.color: Theme.fg1
                                border.width: 2
                            }
                            NText {
                                x: 8
                                y: 154
                                width: 200
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                kind: "caption"
                                color: Theme.fg2
                                text: modelData.name
                            }
                            MouseArea {
                                id: thumbHover
                                x: 8
                                y: 0
                                width: 200
                                height: 148
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.folder)
                                        Gallery.setDir(modelData.path);
                                    else
                                        root.openPreview(modelData.path);
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: root.current === "" && root.gridModel.length === 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        NIcon {
                            Layout.alignment: Qt.AlignHCenter
                            name: Gallery.busy ? "sync" : "folder_open"
                            iconSize: 48
                            color: Theme.fg3
                        }
                        NText {
                            Layout.alignment: Qt.AlignHCenter
                            kind: "body"
                            semibold: true
                            color: Theme.fg2
                            text: Gallery.busy ? "Loading..." : "Folder empty"
                        }
                        NButton {
                            Layout.alignment: Qt.AlignHCenter
                            visible: !Gallery.busy
                            primary: true
                            icon: "photo_camera"
                            text: "Take screenshot"
                            onClicked: Ui.toggleScreenshot()
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }

                    Item {
                        visible: root.current !== ""
                        Layout.fillWidth: true
                        implicitHeight: 44
                        MouseArea {
                            anchors.fill: parent
                            onPressed: win.startSystemMove()
                        }
                        RowLayout {
                            anchors.fill: parent
                            spacing: 8
                            NIconButton {
                                Layout.alignment: Qt.AlignVCenter
                                name: "arrow_back"
                                glyphSize: 18
                                onClicked: {
                                    root.current = "";
                                    root.cropping = false;
                                }
                            }
                            NText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                elide: Text.ElideRight
                                kind: "body"
                                semibold: true
                                text: root.currentItem ? root.currentItem.name : ""
                            }
                        }
                    }

                    RowLayout {
                        visible: root.current !== ""
                        Layout.fillWidth: true
                        spacing: 2
                        NIconButton {
                            visible: root.isImage
                            name: "zoom_out"
                            glyphSize: 18
                            onClicked: root.zoomAt(flick.width / 2, flick.height / 2, 1 / 1.25)
                        }
                        NText {
                            visible: root.isImage
                            Layout.preferredWidth: 56
                            horizontalAlignment: Text.AlignHCenter
                            kind: "caption"
                            color: Theme.fg2
                            text: Math.round(root.zoom * 100) + "%"
                        }
                        NIconButton {
                            visible: root.isImage
                            name: "zoom_in"
                            glyphSize: 18
                            onClicked: root.zoomAt(flick.width / 2, flick.height / 2, 1.25)
                        }
                        NIconButton {
                            visible: root.isImage
                            name: "fit_screen"
                            glyphSize: 18
                            onClicked: root.fitZoom()
                        }
                        Rectangle {
                            visible: root.isImage
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 6
                            Layout.rightMargin: 6
                            width: 1
                            height: 20
                            color: Theme.stroke2
                        }
                        NIconButton {
                            visible: root.isImage
                            name: "rotate_left"
                            glyphSize: 18
                            onClicked: Gallery.rotateFile(root.current, false)
                        }
                        NIconButton {
                            visible: root.isImage
                            name: "rotate_right"
                            glyphSize: 18
                            onClicked: Gallery.rotateFile(root.current, true)
                        }
                        NIconButton {
                            visible: root.isImage
                            name: "crop"
                            glyphSize: 18
                            restColor: root.cropping ? Theme.fg1 : Theme.fg2
                            onClicked: {
                                root.cropping = !root.cropping;
                                root.cdrag = false;
                            }
                        }
                        NIconButton {
                            visible: root.isImage && root.cropping && root.hasCrop
                            name: "check"
                            glyphSize: 18
                            restColor: Theme.fg1
                            onClicked: root.applyCrop()
                        }
                        NIconButton {
                            visible: root.isImage && root.cropping
                            name: "close"
                            glyphSize: 18
                            onClicked: {
                                root.cropping = false;
                                root.cdrag = false;
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        NIconButton {
                            visible: root.isImage
                            name: "content_copy"
                            glyphSize: 18
                            onClicked: Gallery.copyFile(root.current)
                        }
                        NIconButton {
                            name: "open_in_new"
                            glyphSize: 18
                            onClicked: Gallery.openFile(root.current)
                        }
                        NIconButton {
                            name: "delete"
                            glyphSize: 18
                            onClicked: {
                                Gallery.trashFile(root.current);
                                root.current = "";
                                root.cropping = false;
                            }
                        }
                    }

                    Rectangle {
                        visible: root.current !== ""
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Tokens.rounding.large
                        color: Theme.bg3
                        clip: true
                        Flickable {
                            id: flick
                            anchors.fill: parent
                            contentWidth: viewImg.width
                            contentHeight: viewImg.height
                            interactive: false
                            clip: true
                            Image {
                                id: viewImg
                                visible: root.isImage
                                source: root.current === "" ? "" : "file://" + root.current + "?rev=" + Gallery.rev
                                width: Math.max(1, implicitWidth * root.zoom)
                                height: Math.max(1, implicitHeight * root.zoom)
                                fillMode: Image.Stretch
                                asynchronous: true
                                mipmap: true
                                smooth: true
                                onStatusChanged: {
                                    if (status === Image.Ready && root.refitPending) {
                                        root.refitPending = false;
                                        root.fitZoom();
                                    }
                                }
                            }
                            ColumnLayout {
                                anchors.centerIn: parent
                                visible: root.currentItem && root.currentItem.video
                                spacing: 12
                                NIcon {
                                    Layout.alignment: Qt.AlignHCenter
                                    name: "play_circle"
                                    iconSize: 64
                                    color: Theme.fg2
                                }
                                NButton {
                                    Layout.alignment: Qt.AlignHCenter
                                    primary: true
                                    icon: "play_arrow"
                                    text: "Play video"
                                    onClicked: Gallery.openFile(root.current)
                                }
                            }
                        }
                        Rectangle {
                            visible: root.cropping && root.hasCrop
                            x: 0
                            y: 0
                            width: parent.width
                            height: Math.max(0, root.ky0 - flick.contentY)
                            color: Qt.rgba(0, 0, 0, 0.55)
                        }
                        Rectangle {
                            visible: root.cropping && root.hasCrop
                            x: 0
                            y: root.ky0 + root.kch - flick.contentY
                            width: parent.width
                            height: Math.max(0, parent.height - (root.ky0 + root.kch - flick.contentY))
                            color: Qt.rgba(0, 0, 0, 0.55)
                        }
                        Rectangle {
                            visible: root.cropping && root.hasCrop
                            x: 0
                            y: root.ky0 - flick.contentY
                            width: Math.max(0, root.kx0 - flick.contentX)
                            height: root.kch
                            color: Qt.rgba(0, 0, 0, 0.55)
                        }
                        Rectangle {
                            visible: root.cropping && root.hasCrop
                            x: root.kx0 + root.kcw - flick.contentX
                            y: root.ky0 - flick.contentY
                            width: Math.max(0, parent.width - (root.kx0 + root.kcw - flick.contentX))
                            height: root.kch
                            color: Qt.rgba(0, 0, 0, 0.55)
                        }
                        Rectangle {
                            visible: root.cropping && root.hasCrop
                            x: root.kx0 - flick.contentX
                            y: root.ky0 - flick.contentY
                            width: root.kcw
                            height: root.kch
                            color: "transparent"
                            border.color: "#ffffff"
                            border.width: 2
                        }
                        MouseArea {
                            id: editMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            cursorShape: root.cropping ? Qt.CrossCursor : Qt.SizeAllCursor
                            onWheel: e => {
                                if (!root.isImage)
                                    return;
                                root.zoomAt(e.x, e.y, e.angleDelta.y > 0 ? 1.15 : 1 / 1.15);
                            }
                            onPressed: e => {
                                if (!root.isImage)
                                    return;
                                if (root.cropping) {
                                    root.csx = e.x + flick.contentX;
                                    root.csy = e.y + flick.contentY;
                                    root.ccx = root.csx;
                                    root.ccy = root.csy;
                                    root.cdrag = true;
                                } else {
                                    root.plx = e.x;
                                    root.ply = e.y;
                                    root.pandrag = true;
                                }
                            }
                            onPositionChanged: e => {
                                if (root.cdrag) {
                                    root.ccx = e.x + flick.contentX;
                                    root.ccy = e.y + flick.contentY;
                                } else if (root.pandrag) {
                                    flick.contentX -= e.x - root.plx;
                                    flick.contentY -= e.y - root.ply;
                                    root.plx = e.x;
                                    root.ply = e.y;
                                }
                            }
                            onReleased: {
                                root.cdrag = false;
                                root.pandrag = false;
                            }
                            onDoubleClicked: {
                                if (root.isImage && !root.cropping) {
                                    const f = root.fitValue();
                                    if (Math.abs(root.zoom - f) / Math.max(0.01, f) < 0.02)
                                        root.setZoom(1);
                                    else
                                        root.fitZoom();
                                }
                            }
                        }
                    }

                    NText {
                        visible: root.current !== "" && root.currentItem
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignCenter
                        kind: "caption"
                        color: Theme.fg3
                        text: (root.isImage && viewImg.implicitWidth > 0 ? viewImg.implicitWidth + "×" + viewImg.implicitHeight + "  •  " : "") + (root.currentItem ? Gallery.fmtSize(root.currentItem.size) : "") + "  •  " + (root.currentItem ? Gallery.fmtDate(root.currentItem.epoch) : "")
                    }
                }
            }
        }
    }
}
