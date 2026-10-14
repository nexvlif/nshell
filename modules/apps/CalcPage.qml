import QtQuick
import QtQuick.Layouts
import qs.ndesign
import qs.services

// Standard calculator: live preview, history (tap to reuse), keyboard input.
ColumnLayout {
    id: root
    spacing: 10

    property string expr: ""
    property string preview: ""
    property bool justEval: false
    property var history: []

    function isOp(c: string): bool {
        return c === "+" || c === "-" || c === "×" || c === "÷";
    }

    function input(t: string): void {
        if (root.justEval) {
            if (!root.isOp(t) && t !== "%") {
                root.expr = "";
                root.history = root.history;
            }
            root.justEval = false;
        }
        if (t === ".") {
            const m = root.expr.match(/(\d*\.?\d*)$/);
            if (m && m[1].indexOf(".") >= 0)
                return;
            if (root.expr === "" || root.isOp(root.expr[root.expr.length - 1]))
                root.expr += "0";
            root.expr += ".";
        } else if (root.isOp(t)) {
            if (root.expr === "") {
                if (t === "-")
                    root.expr = "-";
                return;
            }
            const last = root.expr[root.expr.length - 1];
            if (root.isOp(last)) {
                if (!(last === "-" && (root.expr.length === 1 || root.isOp(root.expr[root.expr.length - 2]))))
                    root.expr = root.expr.slice(0, -1);
                else if (t !== "-")
                    return;
            }
            root.expr += t;
        } else {
            root.expr += t;
        }
        root.refresh();
    }

    function back(): void {
        root.expr = root.expr.slice(0, -1);
        root.justEval = false;
        root.refresh();
    }

    function clear(): void {
        root.expr = "";
        root.preview = "";
        root.justEval = false;
    }

    function negate(): void {
        const m = root.expr.match(/(-?\d*\.?\d*)$/);
        if (!m || m[1] === "")
            return;
        const num = m[1];
        root.expr = root.expr.slice(0, root.expr.length - num.length) + (num[0] === "-" ? num.slice(1) : "-" + num);
        root.refresh();
    }

    function percent(): void {
        const m = root.expr.match(/(-?\d*\.?\d*)$/);
        if (!m || m[1] === "" || m[1] === "-")
            return;
        const v = parseFloat(m[1]) / 100;
        root.expr = root.expr.slice(0, root.expr.length - m[1].length) + root.fmt(v);
        root.refresh();
    }

    function tokenize(s: string): var {
        const toks = [];
        let i = 0;
        while (i < s.length) {
            const c = s[i];
            if (c === " " || c === ",") {
                i++;
                continue;
            }
            if ((c >= "0" && c <= "9") || c === ".") {
                let j = i;
                while (j < s.length && ((s[j] >= "0" && s[j] <= "9") || s[j] === "."))
                    j++;
                toks.push(parseFloat(s.slice(i, j)));
                i = j;
            } else if (c === "+" || c === "-" || c === "×" || c === "*" || c === "÷" || c === "/") {
                const prev = toks.length > 0 ? toks[toks.length - 1] : null;
                if (c === "-" && (toks.length === 0 || prev === "(" || (typeof prev === "string" && prev !== ")"))) {
                    let j = i + 1;
                    while (j < s.length && ((s[j] >= "0" && s[j] <= "9") || s[j] === "."))
                        j++;
                    if (j > i + 1) {
                        toks.push(-parseFloat(s.slice(i + 1, j)));
                        i = j;
                    } else {
                        toks.push(c);
                        i++;
                    }
                } else {
                    toks.push(c === "*" ? "×" : (c === "/" ? "÷" : c));
                    i++;
                }
            } else if (c === "(" || c === ")") {
                toks.push(c);
                i++;
            } else {
                return null;
            }
        }
        return toks;
    }

    function calc(s: string): var {
        const toks = root.tokenize(s);
        if (!toks || toks.length === 0)
            return null;
        const out = [];
        const ops = [];
        const prec = {
            "+": 1,
            "-": 1,
            "×": 2,
            "÷": 2
        };
        for (const t of toks) {
            if (typeof t === "number") {
                out.push(t);
            } else if (t === "(") {
                ops.push(t);
            } else if (t === ")") {
                let ok = false;
                while (ops.length > 0) {
                    const o = ops.pop();
                    if (o === "(") {
                        ok = true;
                        break;
                    }
                    out.push(o);
                }
                if (!ok)
                    return null;
            } else if (prec[t] !== undefined) {
                while (ops.length > 0 && ops[ops.length - 1] !== "(" && prec[ops[ops.length - 1]] >= prec[t])
                    out.push(ops.pop());
                ops.push(t);
            } else {
                return null;
            }
        }
        while (ops.length > 0) {
            const o = ops.pop();
            if (o === "(" || o === ")")
                return null;
            out.push(o);
        }
        const st = [];
        for (const t of out) {
            if (typeof t === "number") {
                st.push(t);
            } else {
                if (st.length < 2)
                    return null;
                const b = st.pop();
                const a = st.pop();
                if (t === "+")
                    st.push(a + b);
                else if (t === "-")
                    st.push(a - b);
                else if (t === "×")
                    st.push(a * b);
                else if (t === "÷") {
                    if (b === 0)
                        return "div0";
                    st.push(a / b);
                }
            }
        }
        return st.length === 1 ? st[0] : null;
    }

    function fmt(v: real): string {
        if (!isFinite(v))
            return "Error";
        let s = Number(v.toPrecision(10)).toString();
        if (s.indexOf("e") >= 0)
            return s;
        if (s.indexOf(".") >= 0)
            s = s.replace(/\.?0+$/, "");
        return s === "-0" ? "0" : s;
    }

    function refresh(): void {
        if (root.expr === "" || root.isOp(root.expr[root.expr.length - 1]) || root.expr === "-") {
            root.preview = "";
            return;
        }
        const r = root.calc(root.expr);
        root.preview = (r === null || r === "div0") ? "" : root.fmt(r);
    }

    function equals(): void {
        if (root.expr === "")
            return;
        const r = root.calc(root.expr);
        if (r === null)
            return;
        if (r === "div0") {
            root.expr = "";
            root.preview = "Can't divide by 0";
            root.justEval = true;
            return;
        }
        const res = root.fmt(r);
        const h = root.history.slice();
        h.unshift(root.expr + " = " + res);
        root.history = h.slice(0, 10);
        root.expr = res;
        root.preview = "";
        root.justEval = true;
    }

    // Called by the Apps window for physical keyboard input. Returns handled.
    function handleKey(e): bool {
        if (e.text !== "") {
            const t = e.text;
            if ((t >= "0" && t <= "9") || t === "." || t === "+" || t === "-" || t === "%")
                root.input(t);
            else if (t === "*")
                root.input("×");
            else if (t === "/")
                root.input("÷");
            else if (t === "=")
                root.equals();
            else
                return false;
            return true;
        }
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
            root.equals();
            return true;
        }
        if (e.key === Qt.Key_Backspace) {
            root.back();
            return true;
        }
        if (e.key === Qt.Key_Delete || e.key === Qt.Key_C) {
            root.clear();
            return true;
        }
        return false;
    }

    NRect {
        Layout.fillWidth: true
        implicitHeight: 150
        corner: Tokens.rounding.large
        fill: "bg2"
        stroke: "none"
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 2
            NText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                kind: "small"
                color: Theme.fg3
                elide: Text.ElideLeft
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                text: root.expr === "" ? "0" : root.expr
            }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                font.family: Theme.fontFamily
                font.pixelSize: 40
                font.weight: Font.Bold
                color: Theme.fg1
                elide: Text.ElideLeft
                text: root.justEval && root.expr !== "" ? root.expr : (root.preview !== "" ? "= " + root.preview : "")
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 4
        rowSpacing: 8
        columnSpacing: 8

        Repeater {
            model: [
                {
                    "t": "C",
                    "k": "fn",
                    "a": "clear"
                },
                {
                    "t": "backspace",
                    "k": "fn",
                    "i": true,
                    "a": "back"
                },
                {
                    "t": "%",
                    "k": "fn",
                    "a": "pct"
                },
                {
                    "t": "÷",
                    "k": "op",
                    "a": "in:÷"
                },
                {
                    "t": "7",
                    "a": "in:7"
                },
                {
                    "t": "8",
                    "a": "in:8"
                },
                {
                    "t": "9",
                    "a": "in:9"
                },
                {
                    "t": "×",
                    "k": "op",
                    "a": "in:×"
                },
                {
                    "t": "4",
                    "a": "in:4"
                },
                {
                    "t": "5",
                    "a": "in:5"
                },
                {
                    "t": "6",
                    "a": "in:6"
                },
                {
                    "t": "−",
                    "k": "op",
                    "a": "in:-"
                },
                {
                    "t": "1",
                    "a": "in:1"
                },
                {
                    "t": "2",
                    "a": "in:2"
                },
                {
                    "t": "3",
                    "a": "in:3"
                },
                {
                    "t": "+",
                    "k": "op",
                    "a": "in:+"
                },
                {
                    "t": "±",
                    "k": "fn",
                    "a": "neg"
                },
                {
                    "t": "0",
                    "a": "in:0"
                },
                {
                    "t": ".",
                    "a": "in:."
                },
                {
                    "t": "=",
                    "k": "eq",
                    "a": "eq"
                }
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 52
                radius: Tokens.rounding.large
                color: {
                    if (keyHover.pressed)
                        return Theme.pressed(Theme.primary, 0.2);
                    if (modelData.k === "eq")
                        return Theme.primary;
                    if (modelData.k === "op" || modelData.k === "fn")
                        return Theme.primaryContainer;
                    return keyHover.containsMouse ? Theme.subtleHover : Theme.surfaceContainerHigh;
                }
                Behavior on color {
                    ColorAnimation {
                        duration: Tokens.anim.faster
                    }
                }
                NText {
                    visible: !modelData.i
                    anchors.centerIn: parent
                    kind: "subtitle"
                    semibold: true
                    color: modelData.k === "eq" ? Theme.primaryFg : (modelData.k === "op" || modelData.k === "fn") ? Theme.primaryContainerFg : Theme.fg1
                    text: modelData.t
                }
                NIcon {
                    visible: !!modelData.i
                    anchors.centerIn: parent
                    name: modelData.t
                    iconSize: 22
                    color: Theme.primaryContainerFg
                }
                MouseArea {
                    id: keyHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const a = modelData.a;
                        if (a === "clear")
                            root.clear();
                        else if (a === "back")
                            root.back();
                        else if (a === "pct")
                            root.percent();
                        else if (a === "neg")
                            root.negate();
                        else if (a === "eq")
                            root.equals();
                        else if (a.indexOf("in:") === 0)
                            root.input(a.slice(3));
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: root.history.length > 0
        spacing: 2
        RowLayout {
            Layout.fillWidth: true
            NText {
                Layout.fillWidth: true
                kind: "caption"
                color: Theme.fg3
                text: "History (tap to reuse)"
            }
            NIconButton {
                name: "delete"
                glyphSize: 14
                onClicked: root.history = []
            }
        }
        Repeater {
            model: root.history.slice(0, 3)
            delegate: Rectangle {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                implicitHeight: 30
                radius: Tokens.rounding.medium
                color: histHover.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                NText {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft
                    kind: "caption"
                    color: Theme.fg2
                    text: modelData
                }
                MouseArea {
                    id: histHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const parts = modelData.split(" = ");
                        root.expr = parts[0] || "";
                        root.justEval = false;
                        root.refresh();
                    }
                }
            }
        }
    }
}
