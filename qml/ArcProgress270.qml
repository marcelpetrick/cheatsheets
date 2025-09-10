// ArcProgress270.qml (Qt 6)

// ArcProgress270 is a Qt 6 QML Canvas-based circular progress indicator that renders a 270° ring with the progress starting at the 315° mark.
// It supports mouse and touch interaction for dragging the knob, plus wheel-based fine adjustments.
// You can customize it via value, trackColor, progressColor, arcWidth, size, and an interactive toggle.
// It does not include built-in labels/ticks, value text, or animations, and it won’t draw across the top gap (225°–315°).
// It also doesn’t manage accessibility/keyboard focus or persistence by itself—embed it in your app logic as needed.

import QtQuick

Item {
    id: root
    width: 200
    height: 200

    // Public API
    property real value: 0.0        // 0.0 (start at 315°) .. 1.0 (end at 225°)
    property color trackColor: "blue"
    property color progressColor: "red"
    property int arcWidth: 10       // stroke thickness (px)
    property bool interactive: true

    // Geometry
    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real radius: Math.min(width, height) / 2 - arcWidth / 2

    // Angles (Canvas: 0° = right, 90° = down; angles increase clockwise)
    // Top gap is 225°..315° (missing quarter). Visible ring spans 270°.
    readonly property real gapStart: 225
    readonly property real gapEnd:   315
    readonly property real startAngle: 315        // where value==0 lives (tip of blue arc)
    readonly property real span: 270               // total visible travel: 315→225 CW

    // Helpers
    function clamp01(v) { return Math.max(0, Math.min(1, v)) }
    function deg2rad(d) { return d * Math.PI / 180.0 }
    function rad2deg(r) {
        var d = r * 180.0 / Math.PI
        return d < 0 ? d + 360.0 : d
    }
    function normDeg(a) { a = a % 360; if (a < 0) a += 360; return a }

    // Map value -> handle angle along the visible ring, moving CW from 315° to 225°.
    function valueToAngle(v) {
        var vv = clamp01(v)
        var a = startAngle + span * vv  // 315 .. 585
        return a % 360                   // normalize to [0, 360)
    }

    // Map pointer angle to value along the same CW path, projecting touches inside the gap
    // to the nearest visible edge (225° or 315°).
    function angleToValue(aDeg) {
        var a = normDeg(aDeg)

        // Project any touch inside the missing top quarter onto the nearest visible edge
        if (a > gapStart && a < gapEnd) {
            a = (a < 270) ? gapStart : gapEnd
        }

        // Compute CW distance from 315° along visible path.
        var d;
        if (a >= startAngle) {
            // 315..360 => 0..45
            d = a - startAngle
        } else {
            // 0..225 => 45..270
            d = (360 - startAngle) + a  // 45 + a
        }
        // Clamp to the 270° visible span
        if (d < 0) d = 0
        if (d > span) d = span
        return d / span
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.save()
            ctx.clearRect(0, 0, width, height)

            var r = root.radius
            var cx = root.cx
            var cy = root.cy

            ctx.lineWidth = root.arcWidth
            ctx.lineCap = "round"

            // --- TRACK (blue): visible segments (gap 225°..315° is missing) ---
            ctx.strokeStyle = root.trackColor

            function strokeArcCW(startDeg, endDeg) {
                ctx.beginPath()
                ctx.arc(cx, cy, r, deg2rad(startDeg), deg2rad(endDeg), false) // CW
                ctx.stroke()
            }

            // Right-top leg: 315° -> 360°
            strokeArcCW(315, 360)
            // Bottom arc: 0° -> 180°
            strokeArcCW(0, 180)
            // Left-top short leg: 180° -> 225°
            strokeArcCW(180, 225)

            // --- PROGRESS (red): CW from 315° over up to 270° ---
            ctx.strokeStyle = root.progressColor

            var total = root.span * root.value   // degrees to cover, 0..270
            if (total > 0) {
                var remain = total

                // Segment 1: 315° -> 360° (max 45°)
                var take = Math.min(remain, 45)
                if (take > 0) strokeArcCW(315, 315 + take)
                remain -= take

                // Segment 2: 0° -> 180° (max 180°)
                if (remain > 0) {
                    take = Math.min(remain, 180)
                    if (take > 0) strokeArcCW(0, take)
                    remain -= take
                }

                // Segment 3: 180° -> 225° (max 45°)
                if (remain > 0) {
                    take = Math.min(remain, 45)
                    if (take > 0) strokeArcCW(180, 180 + take)
                }
            }

            // --- Handle (knob) at current angle (never inside the top gap) ---
            var a = valueToAngle(root.value)   // in [315..360) U [0..225]
            var hx = cx + Math.cos(deg2rad(a)) * r
            var hy = cy + Math.sin(deg2rad(a)) * r
            var knobRadius = Math.max(5, Math.min(8, root.arcWidth * 0.7))
            ctx.fillStyle = root.progressColor
            ctx.beginPath()
            ctx.arc(hx, hy, knobRadius, 0, Math.PI * 2, false)
            ctx.fill()
            // subtle outline for contrast
            ctx.strokeStyle = "white"
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.arc(hx, hy, knobRadius, 0, Math.PI * 2, false)
            ctx.stroke()

            ctx.restore()
        }

        // Redraw on state changes
        Connections {
            target: root
            onValueChanged: canvas.requestPaint()
            onTrackColorChanged: canvas.requestPaint()
            onProgressColorChanged: canvas.requestPaint()
            onArcWidthChanged: canvas.requestPaint()
            onWidthChanged: canvas.requestPaint()
            onHeightChanged: canvas.requestPaint()
        }

        // Interaction
        MouseArea {
            anchors.fill: parent
            enabled: root.interactive
            hoverEnabled: true

            function updateValue(mouse) {
                var ang = rad2deg(Math.atan2(mouse.y - root.cy, mouse.x - root.cx))
                root.value = angleToValue(ang)
                canvas.requestPaint()
            }

            onPressed: updateValue(mouse)
            onPositionChanged: if (pressed) updateValue(mouse)

            onWheel: (wheel)=> {
                var delta = (wheel.angleDelta && wheel.angleDelta.y) ? wheel.angleDelta.y : wheel.angleDelta
                var step = delta > 0 ? 0.01 : -0.01
                root.value = clamp01(root.value + step)
                canvas.requestPaint()
            }
        }
    }
}
