/*
 * BlobShape – Renders the animated pill shape using QML Shape / ShapePath.
 *
 * Reads animated Bezier control points from a BlobAnimEngine instance
 * (passed via the `engine` property) and renders them as a filled shape
 * with anti-aliasing.
 *
 * Colors are bound to Noctalia's Color singleton so they automatically
 * update when the color scheme, wallpaper, or dark/light mode changes.
 */

import QtQuick
import QtQuick.Shapes
import qs.Commons

Shape {
    id: blobShape

    // The animation engine instance (set by BlobBar)
    required property QtObject engine

    // === NOCTALIA THEMED COLORS ===
    property color blobColor: Qt.alpha(Color.mSurface, 0.92)
    property color borderColor: Qt.alpha(Color.mOutline, 0.3)

    // Smooth color transitions when theme changes
    Behavior on blobColor {
        ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
    }
    Behavior on borderColor {
        ColorAnimation { duration: Style.animationSlowest; easing.type: Easing.OutCubic }
    }

    // Anti-aliasing via multisampling
    layer.enabled: true
    layer.samples: 4

    ShapePath {
        id: mainPath
        fillColor: blobShape.blobColor
        strokeColor: blobShape.borderColor
        strokeWidth: Style.borderS

        startX: blobShape.engine.startX
        startY: blobShape.engine.startY

        // Segment 1: Top edge
        PathCubic {
            control1X: blobShape.engine.s1_c1x; control1Y: blobShape.engine.s1_c1y
            control2X: blobShape.engine.s1_c2x; control2Y: blobShape.engine.s1_c2y
            x: blobShape.engine.s1_ex; y: blobShape.engine.s1_ey
        }

        // Segment 2: Right endcap – top
        PathCubic {
            control1X: blobShape.engine.s2_c1x; control1Y: blobShape.engine.s2_c1y
            control2X: blobShape.engine.s2_c2x; control2Y: blobShape.engine.s2_c2y
            x: blobShape.engine.s2_ex; y: blobShape.engine.s2_ey
        }

        // Segment 3: Right endcap – bottom
        PathCubic {
            control1X: blobShape.engine.s3_c1x; control1Y: blobShape.engine.s3_c1y
            control2X: blobShape.engine.s3_c2x; control2Y: blobShape.engine.s3_c2y
            x: blobShape.engine.s3_ex; y: blobShape.engine.s3_ey
        }

        // Segment 4: Bottom edge
        PathCubic {
            control1X: blobShape.engine.s4_c1x; control1Y: blobShape.engine.s4_c1y
            control2X: blobShape.engine.s4_c2x; control2Y: blobShape.engine.s4_c2y
            x: blobShape.engine.s4_ex; y: blobShape.engine.s4_ey
        }

        // Segment 5: Left endcap – bottom
        PathCubic {
            control1X: blobShape.engine.s5_c1x; control1Y: blobShape.engine.s5_c1y
            control2X: blobShape.engine.s5_c2x; control2Y: blobShape.engine.s5_c2y
            x: blobShape.engine.s5_ex; y: blobShape.engine.s5_ey
        }

        // Segment 6: Left endcap – top (closes path back to start)
        PathCubic {
            control1X: blobShape.engine.s6_c1x; control1Y: blobShape.engine.s6_c1y
            control2X: blobShape.engine.s6_c2x; control2Y: blobShape.engine.s6_c2y
            x: blobShape.engine.s6_ex; y: blobShape.engine.s6_ey
        }
    }
}
