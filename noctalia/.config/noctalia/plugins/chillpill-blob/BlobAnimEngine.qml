/*
 * BlobAnimEngine – Animation engine for the organic blob pill shape.
 *
 * Defines a pill shape as 6 cubic Bezier segments and animates each
 * control point with 3 overlapping sine waves at different frequencies
 * to create organic, breathing movement.
 *
 * Instantiated once in BlobBar.qml (not a singleton, to avoid module
 * registration issues in plugin context).
 *
 * The magic number 0.552 (≈ 4*(√2−1)/3) is the Bezier control point
 * distance that best approximates a circle arc.
 */

import QtQuick

QtObject {
    id: engine

    // === Animation State ===
    property real time: 0
    property real animSpeed: 0.8

    // === Pill Dimensions (updated by BlobBar based on content width) ===
    property real pillWidth: 380
    property real pillHeight: 40
    property real pillRadius: pillHeight / 2

    // === Wobble Parameters ===
    property real blobIntensity: 0.6
    property real maxAmplitude: 3.5 * blobIntensity

    // Center offset for coordinate system (includes padding for wobble overflow)
    property real cx: pillWidth / 2 + 10
    property real cy: pillHeight / 2 + 10

    // === Animation Timer (~60fps) ===
    property var _timer: Timer {
        interval: 16
        running: engine.animSpeed > 0
        repeat: true
        onTriggered: engine.time += 0.016 * engine.animSpeed
    }

    // === Multi-frequency wobble function ===
    // Sums 3 sine waves with different frequencies/phases per control point
    // for organic, non-repetitive movement.
    //   base: the static position of this control point
    //   idx:  unique index per point (offsets the phase)
    //   axis: 0 for X, 1 for Y (different phase offset per axis)
    function w(base, idx, axis) {
        var t = engine.time;
        var amp = engine.maxAmplitude;
        var s1 = amp * Math.sin(t * 1.1 + idx * 0.73 + axis * 2.1);
        var s2 = amp * 0.5 * Math.sin(t * 2.3 + idx * 1.37 + axis * 0.8);
        var s3 = amp * 0.25 * Math.sin(t * 0.7 + idx * 2.17 + axis * 1.5);
        return base + s1 + s2 + s3;
    }

    // ===================================================================
    // PATH DEFINITION: 6 cubic Bezier segments forming a rounded pill
    // ===================================================================
    //
    //  Segment layout:
    //
    //       start ──── Seg1 (top edge) ──── s1_e
    //         │                                │
    //       Seg6                             Seg2
    //    (left cap                        (right cap
    //       top)                            top)
    //         │                                │
    //       s5_e ──── Seg4 (bottom edge) ── s3_e
    //         │                                │
    //       Seg5                             Seg3
    //    (left cap                        (right cap
    //     bottom)                          bottom)
    //

    // === Start Point (top of left endcap → top edge) ===
    readonly property real startX: w(cx - pillWidth / 2 + pillRadius, 0, 0)
    readonly property real startY: w(cy - pillHeight / 2, 0, 1)

    // === Segment 1: Top edge (left → right) ===
    readonly property real s1_c1x: w(cx - pillWidth / 6, 1, 0)
    readonly property real s1_c1y: w(cy - pillHeight / 2, 1, 1)
    readonly property real s1_c2x: w(cx + pillWidth / 6, 2, 0)
    readonly property real s1_c2y: w(cy - pillHeight / 2, 2, 1)
    readonly property real s1_ex: w(cx + pillWidth / 2 - pillRadius, 3, 0)
    readonly property real s1_ey: w(cy - pillHeight / 2, 3, 1)

    // === Segment 2: Right endcap – top half (curving right and down) ===
    readonly property real s2_c1x: w(cx + pillWidth / 2 - pillRadius + pillRadius * 0.552, 4, 0)
    readonly property real s2_c1y: w(cy - pillHeight / 2, 4, 1)
    readonly property real s2_c2x: w(cx + pillWidth / 2, 5, 0)
    readonly property real s2_c2y: w(cy - pillRadius * 0.552, 5, 1)
    readonly property real s2_ex: w(cx + pillWidth / 2, 6, 0)
    readonly property real s2_ey: w(cy, 6, 1)

    // === Segment 3: Right endcap – bottom half (curving down and left) ===
    readonly property real s3_c1x: w(cx + pillWidth / 2, 7, 0)
    readonly property real s3_c1y: w(cy + pillRadius * 0.552, 7, 1)
    readonly property real s3_c2x: w(cx + pillWidth / 2 - pillRadius + pillRadius * 0.552, 8, 0)
    readonly property real s3_c2y: w(cy + pillHeight / 2, 8, 1)
    readonly property real s3_ex: w(cx + pillWidth / 2 - pillRadius, 9, 0)
    readonly property real s3_ey: w(cy + pillHeight / 2, 9, 1)

    // === Segment 4: Bottom edge (right → left) ===
    readonly property real s4_c1x: w(cx + pillWidth / 6, 10, 0)
    readonly property real s4_c1y: w(cy + pillHeight / 2, 10, 1)
    readonly property real s4_c2x: w(cx - pillWidth / 6, 11, 0)
    readonly property real s4_c2y: w(cy + pillHeight / 2, 11, 1)
    readonly property real s4_ex: w(cx - pillWidth / 2 + pillRadius, 12, 0)
    readonly property real s4_ey: w(cy + pillHeight / 2, 12, 1)

    // === Segment 5: Left endcap – bottom half (curving left and up) ===
    readonly property real s5_c1x: w(cx - pillWidth / 2 + pillRadius - pillRadius * 0.552, 13, 0)
    readonly property real s5_c1y: w(cy + pillHeight / 2, 13, 1)
    readonly property real s5_c2x: w(cx - pillWidth / 2, 14, 0)
    readonly property real s5_c2y: w(cy + pillRadius * 0.552, 14, 1)
    readonly property real s5_ex: w(cx - pillWidth / 2, 15, 0)
    readonly property real s5_ey: w(cy, 15, 1)

    // === Segment 6: Left endcap – top half (curving up and right, closes path) ===
    readonly property real s6_c1x: w(cx - pillWidth / 2, 16, 0)
    readonly property real s6_c1y: w(cy - pillRadius * 0.552, 16, 1)
    readonly property real s6_c2x: w(cx - pillWidth / 2 + pillRadius - pillRadius * 0.552, 17, 0)
    readonly property real s6_c2y: w(cy - pillHeight / 2, 17, 1)
    readonly property real s6_ex: w(cx - pillWidth / 2 + pillRadius, 18, 0)
    readonly property real s6_ey: w(cy - pillHeight / 2, 18, 1)
}
