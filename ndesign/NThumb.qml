import QtQuick
import qs.ndesign
import qs.services

NRoundedImage {
    id: root
    property string file: ""
    property int rev: 0

    source: {
        root.rev;
        const t = root.file !== "" ? Thumbs.thumb(root.file) : "";
        const p = t !== "" ? t : root.file;
        return p !== "" ? "file://" + p + (root.rev > 0 ? "?rev=" + root.rev : "") : "";
    }
    Component.onCompleted: {
        if (root.file !== "")
            Thumbs.ensure(root.file);
    }
}
