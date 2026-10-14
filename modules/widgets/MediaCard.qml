import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

NRect {
    id: root
    implicitWidth: 380
    implicitHeight: 148
    fill: "bg1"
    corner: Tokens.rounding.popover
    stroke: "none"
    shadow: 16

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        visible: Mpris.active !== null

        NRoundedImage {
            id: artImage
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter
            source: Mpris.artUrl
            imgRadius: Tokens.rounding.large
            NIcon {
                anchors.centerIn: parent
                visible: !artImage.imgReady
                name: "music_note"
                iconSize: 28
                color: Theme.fg3
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4
            NText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                kind: "small"
                semibold: true
                maximumLineCount: 1
                text: Mpris.title !== "" ? Mpris.title : "Unknown title"
            }
            NText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                kind: "caption"
                color: Theme.fg3
                maximumLineCount: 1
                text: Mpris.artist !== "" ? Mpris.artist : "Unknown artist"
            }
            NSlider {
                Layout.fillWidth: true
                value: Mpris.length > 0 ? Mpris.position / Mpris.length : 0
                interactive: Mpris.canSeek
                trackSize: 12
                onMoved: v => Mpris.seekTo(v)
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 4
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 44
                implicitHeight: 44
                radius: 22
                color: Theme.active
                NIcon {
                    anchors.centerIn: parent
                    name: Mpris.playing ? "pause" : "play_arrow"
                    filled: true
                    iconSize: 22
                    color: Theme.activeFg
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Mpris.playPause()
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 0
                NIconButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    name: "skip_previous"
                    glyphSize: 16
                    restColor: Theme.fg2
                    onClicked: Mpris.previous()
                }
                NIconButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    name: "skip_next"
                    glyphSize: 16
                    restColor: Theme.fg2
                    onClicked: Mpris.next()
                }
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 8
        visible: Mpris.active === null
        NIcon {
            name: "music_note"
            iconSize: 28
            color: Theme.fg3
        }
        NText {
            kind: "body"
            color: Theme.fg3
            text: "Nothing playing"
        }
    }
}
