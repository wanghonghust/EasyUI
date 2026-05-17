import QtQuick
import QtQuick.Controls.Basic
import EasyUI

Item {
    id: root

    enum ChartType {
        Line = 0,
        Bar = 1,
        Pie = 2,
        Donut = 3
    }

    // ── Public properties ──
    property int chartType: EasyChart.ChartType.Line
    property var dataPoints: [] // Line/Bar: [{label, value}]Pie/Donut: [{label, value, color}]
    property bool showGrid: true
    property bool showLabels: false
    property bool showLegend: false
    property bool animated: true
    property int animationDuration: 600
    property real lineWidth: 3
    property real pointRadius: 4
    property real barSpacing: 0.3 // 0-1
    property real donutHoleRatio: 0.62
    property color accentColor: EasyTheme.color.primary
    property color gridColor: EasyTheme.color.border
    property color labelColor: EasyTheme.color.text
    property color fillStartColor: Qt.rgba(accentColor.r, accentColor.g,
                                           accentColor.b, 0.35)
    property color fillEndColor: Qt.rgba(accentColor.r, accentColor.g,
                                         accentColor.b, 0.02)
    property string centerText: ""
    property string centerSubText: ""
    property real fontScale: 1.0 // Dynamic font scaling (e.g., from ThemeSettings)

    implicitWidth: 400
    implicitHeight: 280

    onDataPointsChanged: {
        if (animated)
            animProgress = 0
        canvas.requestPaint()
        if (animated)
            animStart()
    }
    onChartTypeChanged: {
        if (animated)
            animProgress = 0
        canvas.requestPaint()
        if (animated)
            animStart()
    }
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onAccentColorChanged: canvas.requestPaint()

    // ── Animation ──
    property real animProgress: animated ? 1 : 1
    NumberAnimation {
        id: anim
        target: root
        property: "animProgress"
        from: 0
        to: 1
        duration: animationDuration
        easing.type: Easing.OutCubic
        running: false
    }
    function animStart() {
        if (animated) {
            animProgress = 0
            anim.restart()
        }
    }

    // ── Legend ──
    Rectangle {
        id: legendArea
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: showLegend ? Math.min(flow.implicitHeight + 12, 80) : 0
        color: "transparent"
        visible: height > 0
        clip: true
        Behavior on height {
            NumberAnimation {
                duration: 200
            }
        }

        Flow {
            id: flow
            anchors {
                fill: parent
                margins: 6
            }
            spacing: 12
            Repeater {
                model: root.dataPoints || []
                delegate: Row {
                    spacing: 4
                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        anchors.verticalCenter: parent.verticalCenter
                        color: modelData.color !== undefined ? modelData.color : root.accentColor
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: (modelData.label || "") + "  "
                              + (modelData.value !== undefined ? modelData.value : "")
                        font.pixelSize: Math.max(
                                            10,
                                            EasyTheme.size.fontSizeMini * root.fontScale)
                        color: root.labelColor
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    // ── Canvas ──
    Canvas {
        id: canvas
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: legendArea.top
        }
        renderStrategy: Canvas.Threaded

        readonly property real padL: 16
        readonly property real padR: 16
        readonly property real padT: 12
        readonly property real padB: showGrid ? 28 : 16

        onPaint: {
            var ctx = getContext("2d")
            var w = width, h = height
            ctx.clearRect(0, 0, w, h)

            if (!root.dataPoints || root.dataPoints.length === 0) {
                ctx.fillStyle = EasyTheme.color.placeholder
                ctx.font = (12 * root.fontScale) + "px sans-serif"
                ctx.textAlign = "center"
                ctx.fillText("No data", w / 2, h / 2)
                return
            }

            switch (root.chartType) {
            case EasyChart.ChartType.Line:
                drawLineChart(ctx, w, h)
                break
            case EasyChart.ChartType.Bar:
                drawBarChart(ctx, w, h)
                break
            case EasyChart.ChartType.Pie:
                drawPieChart(ctx, w, h, false)
                break
            case EasyChart.ChartType.Donut:
                drawPieChart(ctx, w, h, true)
                break
            }
        }

        function drawLineChart(ctx, w, h) {
            var dp = root.dataPoints
            var cx = padL, cw = w - padL - padR, cy = padT, ch = h - padT - padB
            var values = dp.map(function (d) {
                return d.value !== undefined ? d.value : d
            })
            var maxV = Math.max.apply(null, values.concat([1]))
            var stepX = cw / Math.max(1, dp.length - 1)
            var progress = root.animProgress

            ctx.save()
            ctx.beginPath()
            ctx.rect(cx, cy, cw, ch)
            ctx.clip()

            // grid
            if (showGrid) {
                var gridLines = 4
                ctx.strokeStyle = Qt.rgba(gridColor.r, gridColor.g,
                                          gridColor.b, 0.6)
                ctx.lineWidth = 1
                for (var i = 0; i <= gridLines; i++) {
                    var y = cy + (ch / gridLines) * i
                    ctx.beginPath()
                    ctx.moveTo(cx, y)
                    ctx.lineTo(cx + cw, y)
                    ctx.stroke()
                    ctx.fillStyle = root.labelColor
                    ctx.font = (10 * root.fontScale) + "px sans-serif"
                    ctx.textAlign = "right"
                    ctx.fillText(Math.round(maxV * (1 - i / gridLines)),
                                 cx - 4, y + 4)
                }
            }

            // fill
            ctx.beginPath()
            ctx.moveTo(cx, cy + ch)
            for (i = 0; i < dp.length; i++) {
                var v = (dp[i].value !== undefined ? dp[i].value : dp[i]) * progress
                ctx.lineTo(cx + i * stepX, cy + ch - (v / maxV) * ch)
            }
            ctx.lineTo(cx + (dp.length - 1) * stepX, cy + ch)
            ctx.closePath()
            var grad = ctx.createLinearGradient(0, cy, 0, cy + ch)
            grad.addColorStop(0, fillStartColor)
            grad.addColorStop(1, fillEndColor)
            ctx.fillStyle = grad
            ctx.fill()

            // line
            ctx.beginPath()
            for (i = 0; i < dp.length; i++) {
                v = (dp[i].value !== undefined ? dp[i].value : dp[i]) * progress
                var px = cx + i * stepX, py = cy + ch - (v / maxV) * ch
                if (i === 0)
                    ctx.moveTo(px, py)
                else
                    ctx.lineTo(px, py)
            }
            ctx.strokeStyle = root.accentColor
            ctx.lineWidth = root.lineWidth
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            ctx.stroke()

            // points
            for (i = 0; i < dp.length; i++) {
                v = (dp[i].value !== undefined ? dp[i].value : dp[i]) * progress
                px = cx + i * stepX
                py = cy + ch - (v / maxV) * ch
                ctx.beginPath()
                ctx.arc(px, py, pointRadius, 0, Math.PI * 2)
                ctx.fillStyle = root.accentColor
                ctx.fill()
                ctx.strokeStyle = EasyTheme.color.card
                ctx.lineWidth = 2
                ctx.stroke()
            }
            ctx.restore()

            // x labels
            if (showLabels && dp[0] && dp[0].label !== undefined) {
                ctx.fillStyle = root.labelColor
                ctx.font = (10 * root.fontScale) + "px sans-serif"
                ctx.textAlign = "center"
                for (i = 0; i < dp.length; i++) {
                    ctx.fillText(String(dp[i].label), cx + i * stepX,
                                 cy + ch + 16)
                }
            }
        }

        function drawBarChart(ctx, w, h) {
            var dp = root.dataPoints
            var cx = padL, cw = w - padL - padR, cy = padT, ch = h - padT - padB
            var values = dp.map(function (d) {
                return d.value !== undefined ? d.value : d
            })
            var maxV = Math.max.apply(null, values.concat([1]))
            var count = dp.length
            var totalGap = cw * root.barSpacing
            var barW = count > 0 ? (cw - totalGap) / count : 0
            var gapW = count > 1 ? totalGap / (count - 1) : 0
            var progress = root.animProgress

            ctx.save()
            ctx.beginPath()
            ctx.rect(cx, cy, cw, ch)
            ctx.clip()

            if (showGrid) {
                var gridLines = 4
                ctx.strokeStyle = Qt.rgba(gridColor.r, gridColor.g,
                                          gridColor.b, 0.6)
                ctx.lineWidth = 1
                for (var i = 0; i <= gridLines; i++) {
                    var y = cy + (ch / gridLines) * i
                    ctx.beginPath()
                    ctx.moveTo(cx, y)
                    ctx.lineTo(cx + cw, y)
                    ctx.stroke()
                    ctx.fillStyle = root.labelColor
                    ctx.font = (10 * root.fontScale) + "px sans-serif"
                    ctx.textAlign = "right"
                    ctx.fillText(Math.round(maxV * (1 - i / gridLines)),
                                 cx - 4, y + 4)
                }
            }

            for (i = 0; i < count; i++) {
                var val = values[i] * progress
                var barH = (val / maxV) * ch
                var bx = cx + i * (barW + gapW)
                var by = cy + ch - barH
                ctx.fillStyle = dp[i].color !== undefined ? dp[i].color : root.accentColor
                ctx.beginPath()
                // 手动绘制顶部圆角矩形 (Qt Canvas 不支持 roundRect)
                var rr = 4; var bx2 = bx + barW; var by2 = by + barH
                ctx.moveTo(bx + rr, by)
                ctx.lineTo(bx2 - rr, by)
                ctx.arcTo(bx2, by, bx2, by + rr, rr)
                ctx.lineTo(bx2, by2)
                ctx.lineTo(bx, by2)
                ctx.lineTo(bx, by + rr)
                ctx.arcTo(bx, by, bx + rr, by, rr)
                ctx.closePath()
                ctx.fill()
            }
            ctx.restore()

            if (showLabels) {
                ctx.fillStyle = root.labelColor
                ctx.font = (10 * root.fontScale) + "px sans-serif"
                ctx.textAlign = "center"
                for (i = 0; i < count; i++) {
                    ctx.fillText(String(dp[i].label || ""),
                                 cx + i * (barW + gapW) + barW / 2,
                                 cy + ch + 16)
                }
            }
        }

        function drawPieChart(ctx, w, h, isDonut) {
            var dp = root.dataPoints
            var total = dp.reduce(function (s, d) {
                return s + d.value
            }, 0) || 1
            var cx3 = w / 2, cy3 = h / 2
            var outerR = Math.min(w, h) / 2 - 16
            var innerR = isDonut ? outerR * root.donutHoleRatio : 0
            var startAngle = -Math.PI / 2
            var progress = root.animProgress
            var defaultColors = ["#6366f1", "#10b981", "#f59e0b", "#ec4899", "#8b5cf6", "#06b6d4", "#f97316", "#84cc16"]

            ctx.save()
            for (var i = 0; i < dp.length; i++) {
                var sliceAngle = (dp[i].value / total) * Math.PI * 2 * progress
                ctx.beginPath()
                ctx.moveTo(cx3 + innerR * Math.cos(startAngle),
                           cy3 + innerR * Math.sin(startAngle))
                ctx.arc(cx3, cy3, outerR, startAngle, startAngle + sliceAngle)
                if (isDonut) {
                    ctx.arc(cx3, cy3, innerR, startAngle + sliceAngle,
                            startAngle, true)
                } else {
                    ctx.lineTo(cx3, cy3)
                }
                ctx.closePath()
                ctx.fillStyle = dp[i].color
                        || defaultColors[i % defaultColors.length]
                ctx.fill()

                if (showLabels) {
                    var midAngle = startAngle + sliceAngle / 2
                    var lx = cx3 + (outerR * 0.7) * Math.cos(midAngle)
                    var ly = cy3 + (outerR * 0.7) * Math.sin(midAngle)
                    ctx.fillStyle = "#ffffff"
                    ctx.font = "bold " + (11 * root.fontScale) + "px sans-serif"
                    ctx.textAlign = "center"
                    ctx.fillText(Math.round(dp[i].value / total * 100) + "%",
                                 lx, ly + 4)
                }
                startAngle += sliceAngle
            }

            if (isDonut && root.centerText) {
                ctx.fillStyle = root.labelColor
                ctx.font = "bold " + (Math.max(
                                          18,
                                          22 * root.fontScale)) + "px sans-serif"
                ctx.textAlign = "center"
                ctx.fillText(root.centerText, cx3,
                             cy3 - (root.centerSubText ? 6 : 0))
                if (root.centerSubText) {
                    ctx.font = (Math.max(10,
                                         12 * root.fontScale)) + "px sans-serif"
                    ctx.fillStyle = EasyTheme.color.secondary
                    ctx.fillText(root.centerSubText, cx3, cy3 + 18)
                }
            }
            ctx.restore()
        }
    }

    Component.onCompleted: {
        if (animated)
            animStart()
    }
}
