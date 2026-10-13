import QtQuick
import qs.ndesign

QtObject {
    function fast(target: QtObject, prop: string, to: var): QtObject {
        return anim(target, prop, to, Tokens.anim.fast);
    }
    function anim(target: QtObject, prop: string, to: var, dur: int): QtObject {
        const a = Qt.createQmlObject(`import QtQuick; NumberAnimation { duration: ${dur}; easing.type: Easing.OutCubic }`, target);
        a.target = target;
        a.property = prop;
        a.to = to;
        return a;
    }
}
