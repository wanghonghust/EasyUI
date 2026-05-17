import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: root

    property color textPrimary: EasyTheme.color.text
    property color textSecondary: EasyTheme.color.secondary
    property color accentColor: EasyTheme.color.primary


    function changeType(changeText) {
        return String(changeText).indexOf("-") === 0 ? "error" : "success"
    }

    function trendData() {
        switch (trendSelector.currentIndex) {
        case 0:
            return [22, 28, 25, 32, 30, 38, 36]
        case 2:
            return [18, 22, 26, 31, 36, 40, 45, 48, 52, 57, 61, 66]
        default:
            return [30, 45, 35, 55, 40, 65, 50, 75, 60, 85, 70, 90]
        }
    }

    property var deviceStats: [
        {
            "label": "桌面端",
            "value": 35,
            "color": "#6366f1"
        },
        {
            "label": "移动端",
            "value": 25,
            "color": "#10b981"
        },
        {
            "label": "平板",
            "value": 20,
            "color": "#f59e0b"
        },
        {
            "label": "其他",
            "value": 20,
            "color": "#ec4899"
        }
    ]

    ListModel {
        id: statsModel

        ListElement {
            title: "总收入"
            value: "¥128,430"
            change: "+12.5%"
            icon: "💰"
            color: "#6366f1"
            progress: 82
            description: "较上月增长 14,230 元"
        }
        ListElement {
            title: "活跃用户"
            value: "8,549"
            change: "+8.2%"
            icon: "👥"
            color: "#10b981"
            progress: 68
            description: "近 7 日活跃度持续提升"
        }
        ListElement {
            title: "订单数量"
            value: "1,284"
            change: "-2.4%"
            icon: "📦"
            color: "#f59e0b"
            progress: 46
            description: "需关注周末转化表现"
        }
        ListElement {
            title: "转化率"
            value: "3.24%"
            change: "+0.8%"
            icon: "📈"
            color: "#ec4899"
            progress: 74
            description: "落地页优化带来正向反馈"
        }
    }

    ListModel {
        id: recentActivityModel

        ListElement {
            user: "张三"
            action: "完成了订单 #1234"
            time: "2分钟前"
            avatar: "Z"
            color: "#6366f1"
        }
        ListElement {
            user: "李四"
            action: "注册了新账户"
            time: "15分钟前"
            avatar: "L"
            color: "#10b981"
        }
        ListElement {
            user: "王五"
            action: "支付了 ¥2,499"
            time: "32分钟前"
            avatar: "W"
            color: "#f59e0b"
        }
        ListElement {
            user: "赵六"
            action: "评论了产品"
            time: "1小时前"
            avatar: "Z"
            color: "#ec4899"
        }
        ListElement {
            user: "钱七"
            action: "更新了个人资料"
            time: "2小时前"
            avatar: "Q"
            color: "#8b5cf6"
        }
    }

    ListModel {
        id: quickActionModel

        ListElement {
            icon: "➕"
            title: "新建订单"
            description: "快速创建新的销售订单"
            primary: true
        }
        ListElement {
            icon: "📧"
            title: "发送邮件"
            description: "向客户推送营销通知"
            primary: false
        }
        ListElement {
            icon: "📄"
            title: "生成报告"
            description: "导出本周运营数据概览"
            primary: false
        }
        ListElement {
            icon: "⚙️"
            title: "系统设置"
            description: "管理权限、通知与集成配置"
            primary: false
        }
    }

    Rectangle {
        anchors.fill: parent
        color: EasyTheme.color.background
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.vertical: EasyScrollBar { }
        contentWidth: scrollContent.width
        contentHeight: scrollContent.height

        Item {
            id: scrollContent
            implicitWidth: scrollView.availableWidth > 0 ? scrollView.availableWidth : root.width
            implicitHeight: pageColumn.implicitHeight + 48
            width: implicitWidth
            height: implicitHeight

            Column {
                id: pageColumn
                x: 24
                y: 24
                width: Math.max(scrollContent.width - 48, 320)
                spacing: 18


                EasyCard {
                    cardWidth: pageColumn.width
                    cardPadding: 24
                    shadowBlur: 14

                    Column {
                        width: parent.width
                        spacing: 18

                        EasyBreadcrumb {
                            items: [
                                {
                                    "text": "首页"
                                },
                                {
                                    "text": "总览"
                                },
                                {
                                    "text": "运营仪表板"
                                }
                            ]
                            currentIndex: 2
                        }

                        RowLayout {
                            width: parent.width
                            spacing: 16

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "EasyUI 数据总览"
                                    color: root.textPrimary
                                    font.pixelSize: 30
                                    font.bold: true
                                }

                                Text {
                                    text: "统一使用 EasyUI 组件重构首页，保留关键业务信息，同时让交互和视觉语言保持一致。"
                                    color: root.textSecondary
                                    font.pixelSize: 14
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                            }

                            Column {
                                spacing: 10

                                EasyAvatar {
                                    anchors.right: parent.right
                                    size: 48
                                    text: "EA"
                                    borderWidth: 0
                                }

                                EasyBadge {
                                    anchors.right: parent.right
                                    text: "在线"
                                    type: "success"
                                }
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: 10

                            EasyTag {
                                text: "实时监控"
                                type: "primary"
                            }
                            EasyTag {
                                text: "自动报表"
                                type: "success"
                            }
                            EasyTag {
                                text: "设备画像"
                                type: "warning"
                            }
                            EasyTag {
                                text: "客户动态"
                                type: "primary"
                            }
                        }

                        RowLayout {
                            width: parent.width
                            spacing: 12

                            EasySearchInput {
                                Layout.fillWidth: true
                                placeholder: "搜索项目、用户或订单"
                            }

                            EasySegmented {
                                id: headerSelector
                                options: [
                                    {
                                        "text": "今天"
                                    },
                                    {
                                        "text": "本周"
                                    },
                                    {
                                        "text": "本月"
                                    }
                                ]
                                currentIndex: 1
                            }

                            EasyButton {
                                text: "导出报表"
                                primary: false
                            }

                            EasyButton {
                                text: "新建任务"
                                primary: true
                            }
                        }
                    }
                }

                Flow {
                    id: statsFlow
                    width: pageColumn.width
                    spacing: 16

                    property int columns: width >= 1320 ? 4 : (width >= 780 ? 2 : 1)
                    property real itemWidth: (width - (columns - 1) * spacing) / columns

                    Repeater {
                        model: statsModel

                        delegate: EasyCard {
                            readonly property color statColor: color

                            cardWidth: statsFlow.itemWidth
                            cardPadding: 20
                            shadowBlur: 10

                            Column {
                                width: parent.width
                                spacing: 14

                                RowLayout {
                                    width: parent.width
                                    spacing: 12

                                    Rectangle {
                                        width: 46
                                        height: 46
                                        radius: 14
                                        color: Qt.alpha(statColor, 0.14)

                                        Text {
                                            anchors.centerIn: parent
                                            text: icon
                                            font.pixelSize: 22
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    EasyTag {
                                        text: change
                                        type: root.changeType(change)
                                    }
                                }

                                Text {
                                    text: value
                                    color: root.textPrimary
                                    font.pixelSize: 28
                                    font.bold: true
                                }

                                Text {
                                    text: title
                                    color: root.textSecondary
                                    font.pixelSize: 14
                                }

                                EasyProgress {
                                    width: parent.width
                                    value: progress
                                    showText: true
                                }

                                Text {
                                    width: parent.width
                                    text: description
                                    color: root.textSecondary
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }

                Flow {
                    id: analysisFlow
                    width: pageColumn.width
                    spacing: 16

                    property bool stacked: width < 1024
                    property real sideWidth: stacked ? width : 320
                    property real mainWidth: stacked ? width : width - sideWidth - spacing

                    EasyCard {
                        cardWidth: analysisFlow.mainWidth
                        cardPadding: 24
                        shadowBlur: 12

                        Column {
                            width: parent.width
                            spacing: 18

                            RowLayout {
                                width: parent.width
                                spacing: 12

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: "收入趋势"
                                        color: root.textPrimary
                                        font.pixelSize: 20
                                        font.bold: true
                                    }

                                    Text {
                                        text: "过去阶段的订单收入趋势变化，支持快速切换周期查看。"
                                        color: root.textSecondary
                                        font.pixelSize: 13
                                    }
                                }

                                EasySegmented {
                                    id: trendSelector
                                    options: [
                                        {
                                            "text": "本周"
                                        },
                                        {
                                            "text": "本月"
                                        },
                                        {
                                            "text": "本年"
                                        }
                                    ]
                                    currentIndex: 1
                                    onCurrentIndexChanged: trendCanvas.requestPaint()
                                }
                            }

                            Canvas {
                                id: trendCanvas
                                width: parent.width
                                height: 280

                                onWidthChanged: requestPaint()
                                onHeightChanged: requestPaint()

                                onPaint: {
                                    var ctx = getContext("2d")
                                    var data = root.trendData()
                                    var w = width
                                    var h = height
                                    var leftPadding = 20
                                    var bottomPadding = 28
                                    var topPadding = 16
                                    var chartWidth = w - leftPadding * 2
                                    var chartHeight = h - topPadding - bottomPadding
                                    var maxVal = 100
                                    var stepX = data.length > 1 ? chartWidth / (data.length - 1) : chartWidth

                                    ctx.clearRect(0, 0, w, h)

                                    ctx.strokeStyle = Qt.alpha(EasyTheme.color.border, 0.8)
                                    ctx.lineWidth = 1
                                    for (var i = 0; i < 5; ++i) {
                                        var gridY = topPadding + chartHeight * i / 4
                                        ctx.beginPath()
                                        ctx.moveTo(leftPadding, gridY)
                                        ctx.lineTo(w - leftPadding, gridY)
                                        ctx.stroke()
                                    }

                                    var gradient = ctx.createLinearGradient(0, topPadding, 0, h - bottomPadding)
                                    gradient.addColorStop(0, Qt.alpha(root.accentColor, 0.35))
                                    gradient.addColorStop(1, Qt.alpha(root.accentColor, 0.02))

                                    ctx.beginPath()
                                    for (var j = 0; j < data.length; ++j) {
                                        var x = leftPadding + j * stepX
                                        var y = topPadding + chartHeight - (data[j] / maxVal) * chartHeight
                                        if (j === 0)
                                            ctx.moveTo(x, y)
                                        else
                                            ctx.lineTo(x, y)
                                    }
                                    ctx.lineTo(w - leftPadding, h - bottomPadding)
                                    ctx.lineTo(leftPadding, h - bottomPadding)
                                    ctx.closePath()
                                    ctx.fillStyle = gradient
                                    ctx.fill()

                                    ctx.beginPath()
                                    ctx.strokeStyle = root.accentColor
                                    ctx.lineWidth = 3
                                    for (var k = 0; k < data.length; ++k) {
                                        var lineX = leftPadding + k * stepX
                                        var lineY = topPadding + chartHeight - (data[k] / maxVal) * chartHeight
                                        if (k === 0)
                                            ctx.moveTo(lineX, lineY)
                                        else
                                            ctx.lineTo(lineX, lineY)
                                    }
                                    ctx.stroke()

                                    for (var m = 0; m < data.length; ++m) {
                                        var pointX = leftPadding + m * stepX
                                        var pointY = topPadding + chartHeight - (data[m] / maxVal) * chartHeight
                                        ctx.beginPath()
                                        ctx.arc(pointX, pointY, 4, 0, Math.PI * 2)
                                        ctx.fillStyle = root.accentColor
                                        ctx.fill()
                                        ctx.lineWidth = 2
                                        ctx.strokeStyle = EasyTheme.color.card
                                        ctx.stroke()
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        width: analysisFlow.sideWidth
                        spacing: 16

                        EasyCard {
                            cardWidth: parent.width
                            cardPadding: 20
                            shadowBlur: 10

                            Column {
                                width: parent.width
                                spacing: 16

                                Text {
                                    text: "设备分布"
                                    color: root.textPrimary
                                    font.pixelSize: 18
                                    font.bold: true
                                }

                                Canvas {
                                    id: deviceCanvas
                                    width: parent.width
                                    height: 180

                                    onWidthChanged: requestPaint()
                                    onHeightChanged: requestPaint()

                                    onPaint: {
                                        var ctx = getContext("2d")
                                        var centerX = width / 2
                                        var centerY = height / 2
                                        var radius = Math.min(width, height) / 2 - 16
                                        var innerRadius = radius * 0.62
                                        var startAngle = -Math.PI / 2

                                        ctx.clearRect(0, 0, width, height)

                                        for (var i = 0; i < root.deviceStats.length; ++i) {
                                            var segment = root.deviceStats[i]
                                            var sliceAngle = (segment.value / 100) * Math.PI * 2

                                            ctx.beginPath()
                                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + sliceAngle)
                                            ctx.arc(centerX, centerY, innerRadius, startAngle + sliceAngle, startAngle, true)
                                            ctx.closePath()
                                            ctx.fillStyle = segment.color
                                            ctx.fill()

                                            startAngle += sliceAngle
                                        }

                                        ctx.fillStyle = root.textPrimary
                                        ctx.font = "bold 22px sans-serif"
                                        ctx.textAlign = "center"
                                        ctx.textBaseline = "middle"
                                        ctx.fillText("100%", centerX, centerY - 8)

                                        ctx.fillStyle = root.textSecondary
                                        ctx.font = "12px sans-serif"
                                        ctx.fillText("访问占比", centerX, centerY + 18)
                                    }
                                }

                                Repeater {
                                    model: root.deviceStats

                                    delegate: RowLayout {
                                        width: parent.width
                                        spacing: 10

                                        Rectangle {
                                            width: 10
                                            height: 10
                                            radius: 5
                                            color: modelData.color
                                        }

                                        Text {
                                            text: modelData.label
                                            color: root.textSecondary
                                            font.pixelSize: 13
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: modelData.value + "%"
                                            color: root.textPrimary
                                            font.pixelSize: 13
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }

                        EasyCard {
                            cardWidth: parent.width
                            cardPadding: 20
                            shadowBlur: 10

                            Column {
                                width: parent.width
                                spacing: 14

                                Text {
                                    text: "运营状态"
                                    color: root.textPrimary
                                    font.pixelSize: 18
                                    font.bold: true
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 12

                                    EasyBadge {
                                        text: "稳定"
                                        type: "success"
                                    }

                                    Text {
                                        text: "消息投递正常，接口延迟 148ms"
                                        color: root.textSecondary
                                        font.pixelSize: 13
                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                    }
                                }

                                EasyProgress {
                                    width: parent.width
                                    value: 84
                                    showText: true
                                }

                                Text {
                                    width: parent.width
                                    text: "今日任务完成度 84%，其中自动化报表与客户回访表现最佳。"
                                    color: root.textSecondary
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }

                Flow {
                    id: bottomFlow
                    width: pageColumn.width
                    spacing: 16

                    property bool stacked: width < 1024
                    property real sideWidth: stacked ? width : 360
                    property real mainWidth: stacked ? width : width - sideWidth - spacing

                    EasyCard {
                        cardWidth: bottomFlow.mainWidth
                        cardPadding: 24
                        shadowBlur: 12

                        Column {
                            width: parent.width
                            spacing: 16

                            RowLayout {
                                width: parent.width
                                spacing: 12

                                Text {
                                    text: "最近活动"
                                    color: root.textPrimary
                                    font.pixelSize: 20
                                    font.bold: true
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                EasyButton {
                                    text: "查看全部"
                                    primary: false
                                }
                            }

                            ListView {
                                width: parent.width
                                height: 270
                                clip: true
                                spacing: 10
                                model: recentActivityModel

                                delegate: EasyCard {
                                    cardWidth: ListView.view.width
                                    cardPadding: 14
                                    shadowBlur: 4

                                    RowLayout {
                                        width: parent.width
                                        spacing: 12

                                        EasyAvatar {
                                            size: 40
                                            text: avatar
                                            borderWidth: 0
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Text {
                                                text: user
                                                color: root.textPrimary
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Text {
                                                text: action
                                                color: root.textSecondary
                                                font.pixelSize: 13
                                                wrapMode: Text.Wrap
                                                Layout.fillWidth: true
                                            }
                                        }

                                        Text {
                                            text: time
                                            color: root.textSecondary
                                            font.pixelSize: 12
                                        }
                                    }
                                }
                            }
                        }
                    }

                    EasyCard {
                        cardWidth: bottomFlow.sideWidth
                        cardPadding: 24
                        shadowBlur: 12

                        Column {
                            width: parent.width
                            spacing: 14

                            Text {
                                text: "快速操作"
                                color: root.textPrimary
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Text {
                                width: parent.width
                                text: "将高频操作收拢到 EasyUI 风格的操作入口中，方便演示和后续继续扩展。"
                                color: root.textSecondary
                                font.pixelSize: 13
                                wrapMode: Text.Wrap
                            }

                            Repeater {
                                model: quickActionModel

                                delegate: EasyCard {
                                    readonly property bool actionPrimary: primary

                                    cardWidth: parent.width
                                    cardPadding: 14
                                    shadowBlur: 4

                                    RowLayout {
                                        width: parent.width
                                        spacing: 12

                                        Rectangle {
                                            width: 38
                                            height: 38
                                            radius: 12
                                            color: Qt.alpha(root.accentColor, 0.12)

                                            Text {
                                                anchors.centerIn: parent
                                                text: icon
                                                font.pixelSize: 18
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Text {
                                                text: title
                                                color: root.textPrimary
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Text {
                                                text: description
                                                color: root.textSecondary
                                                font.pixelSize: 12
                                                wrapMode: Text.Wrap
                                                Layout.fillWidth: true
                                            }
                                        }

                                        EasyButton {
                                            text: "执行"
                                            primary: actionPrimary
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
