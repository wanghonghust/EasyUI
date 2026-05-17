import QtQuick
import QtQuick.Layouts
import EasyUI

/**
 * EasyProgress — 进度条/环形进度组件
 *
 * 属性：
 *   value        {real}  当前值 (0-100)，默认 0
 *   barHeight    {real}  线性高度，默认 8
 *   circular     {bool}  环形模式，默认 false
 *   circleSize   {int}   环形直径，默认 80
 *   strokeWidth  {int}   环形线宽，默认 6
 *   showText     {bool}  显示百分比文字，默认 false
 */
Item {
    id: root

    property real value: 0
    property real barHeight: 8
    property bool circular: false
    property int circleSize: 80
    property int strokeWidth: 6
    property bool showText: false

    // Linear mode
    implicitWidth: circular ? circleSize : 200
    implicitHeight: circular ? circleSize : barHeight

    Loader {
        anchors.fill: parent
        sourceComponent: circular ? circleComponent : lineComponent
    }

    // ── Linear bar ──
    Component {
        id: lineComponent
        RowLayout {
            spacing: 8
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.barHeight
                Layout.alignment: Qt.AlignVCenter
                radius: root.barHeight / 2
                color: EasyTheme.color.border
                Rectangle {
                    width: Math.max(height, Math.min(parent.width, (root.value / 100) * parent.width))
                    height: parent.height
                    radius: parent.radius
                    color: EasyTheme.color.primary
                    Behavior on width { NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
                }
            }
            Text {
                Layout.preferredWidth: root.showText ? 36 : 0
                visible: root.showText
                text: Math.round(root.value) + "%"
                font.pixelSize: 12
                color: EasyTheme.color.text
            }
        }
    }

    // ── Circular ring ──
    Component {
        id: circleComponent
        Item {
            Canvas {
                id: ringCanvas
                anchors.fill: parent
                antialiasing: true

                property real pct: root.value / 100.0

                onPctChanged: requestPaint()
                onWidthChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    var sz = width
                    var cx = sz / 2
                    var cy = sz / 2
                    var r = (sz - root.strokeWidth) / 2
                    var sw = root.strokeWidth

                    ctx.clearRect(0, 0, sz, sz)

                    // Background ring
                    ctx.beginPath()
                    ctx.arc(cx, cy, r, 0, Math.PI * 2)
                    ctx.lineWidth = sw
                    ctx.strokeStyle = EasyTheme.color.border
                    ctx.stroke()

                    // Foreground arc (clockwise from top)
                    if (pct > 0) {
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * pct)
                        ctx.lineWidth = sw
                        ctx.strokeStyle = pct >= 1.0 ? EasyTheme.color.success : EasyTheme.color.primary
                        ctx.lineCap = "round"
                        ctx.stroke()
                    }
                }
            }

            // Center text
            Text {
                anchors.centerIn: parent
                visible: root.showText
                text: Math.round(root.value) + "%"
                font.pixelSize: root.circleSize / 5
                font.bold: true
                color: EasyTheme.color.text
            }
        }
    }
}
