import QtQuick
import Qt5Compat.GraphicalEffects
import qs.ndesign

Rectangle {
    id: root
    property url source
    property int imgRadius: Tokens.rounding.small
    property int fillModeImage: Image.PreserveAspectCrop
    property alias imgReady: img.visible

    color: Theme.bg3
    radius: imgRadius

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        fillMode: root.fillModeImage
        asynchronous: true
        mipmap: true
        smooth: true
        visible: status === Image.Ready
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: img.width
                height: img.height
                visible: false
                Rectangle {
                    anchors.fill: parent
                    radius: root.imgRadius
                }
            }
        }
    }
}
