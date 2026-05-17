import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

/**
 * TimePicker —— 时间选择器（输入框样式）
 *
 * 属性：
 *   hour            {int}     小时 (0-23)，默认 0
 *   minute          {int}     分钟 (0-59)，默认 0
 *   second          {int}     秒 (0-59)，默认 0
 *   enabled         {bool}    是否可用，默认 true
 *   showSeconds     {bool}    是否显示秒，默认 true
 *   size            {int}     控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *
 * 信号：
 *   timeChanged(int hour, int minute, int second)  时间变化
 */
Rectangle {
    id: root

    // ── 公开属性 ──────────────────────────────────────────────
    property int  hour:        0
    property int  minute:      0
    property int  second:      0
    property bool enabled:     true
    property bool showSeconds: true
    property int size: EasyTheme.size.sizeNormal

    // 根据 size 计算控件尺寸
    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.heightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.heightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.heightLarge
        default:                        return EasyTheme.size.heightNormal
        }
    }
    readonly property int computedPadding: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.paddingMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.paddingSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.paddingLarge
        default:                        return EasyTheme.size.paddingNormal
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge
        default:                        return EasyTheme.size.fontSizeNormal
        }
    }
    readonly property int computedPopupHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 180
        case EasyTheme.size.sizeSmall:  return 220
        case EasyTheme.size.sizeLarge:  return 300
        default:                        return 260
        }
    }
    readonly property int computedWheelItemHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 28
        case EasyTheme.size.sizeSmall:  return 34
        case EasyTheme.size.sizeLarge:  return 48
        default:                        return 40
        }
    }
    readonly property int computedPopupWidth: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 200
        case EasyTheme.size.sizeSmall:  return 230
        case EasyTheme.size.sizeLarge:  return 300
        default:                        return 260
        }
    }
    readonly property int computedPopupWidthNoSeconds: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 150
        case EasyTheme.size.sizeSmall:  return 170
        case EasyTheme.size.sizeLarge:  return 230
        default:                        return 200
        }
    }

    // ── 信号 ──────────────────────────────────────────────────
    signal timeChanged(int hour, int minute, int second)

    // ── 外观 ──────────────────────────────────────────────────
    implicitWidth:  140 + (root.showSeconds ? 50 : 0)
    implicitHeight: computedHeight
    radius:         6
    color:          EasyTheme.color.card
    border.color:   timePopup.visible ? EasyTheme.color.primary : EasyTheme.color.divider
    border.width:    EasyTheme.size.borderWidth

    // ── 输入框区域 ────────────────────────────────────────────
    RowLayout {
        anchors.fill:       parent
        anchors.leftMargin: root.computedPadding
        anchors.rightMargin: root.computedPadding
        spacing:            4

        // 时钟图标
        EasyIconFont {
            icon: EasyIcon.material.schedule
            iconSize: root.computedFontSize + 2
            color: EasyTheme.color.placeholder
        }

        // 时间显示（可编辑）
        Text {
            id: timeDisplay
            Layout.fillWidth: true
            text: {
                var h = String(root.hour).padStart(2, '0')
                var m = String(root.minute).padStart(2, '0')
                var s = String(root.second).padStart(2, '0')
                return root.showSeconds ? (h + ":" + m + ":" + s) : (h + ":" + m)
            }
            font.pixelSize: root.computedFontSize
            color: root.enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    // ── 点击打开弹窗 ──────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        enabled:      root.enabled
        hoverEnabled: true
        cursorShape:  root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor

        onClicked: {
            timePopup.open()
        }
    }

    // ── 时间选择弹窗 ──────────────────────────────────────────
    Popup {
        id: timePopup
        x: 0
        width: root.showSeconds ? root.computedPopupWidth : root.computedPopupWidthNoSeconds
        height: root.computedPopupHeight
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property bool calculatedDropUp: false
        readonly property int popupHeight: root.computedPopupHeight

        // 定时器持续检查位置
        Timer {
            id: positionTimer
            interval: 50
            running: timePopup.visible
            repeat: true
            onTriggered: timePopup.updateDropDirection()
        }

        // 更新弹出方向
        function updateDropDirection() {
            // 获取组件在窗口中的相对位置
            var posInWindow = root.mapToItem(null, 0, root.height)
            var bottomInWindow = posInWindow.y

            // 获取窗口高度
            var windowContentHeight = root.Window.height || root.parent.height || 600

            // 判断向下展开是否会超出窗口底部
            calculatedDropUp = (bottomInWindow + popupHeight + 10) > windowContentHeight
        }

        // 打开时初始化计算
        onAboutToShow: updateDropDirection()

        y: calculatedDropUp ? -(popupHeight + 4) : (root.height + 4)

        background: Rectangle {
            radius: 8
            color: EasyTheme.color.card
            border.width: EasyTheme.size.borderWidth
            border.color: EasyTheme.color.divider
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.computedPadding
            spacing: root.computedPadding

            // 标题
            Text {
                text: "选择时间"
                font.pixelSize: root.computedFontSize + 2
                font.bold: true
                color: EasyTheme.color.text
            }

            // 滚轮选择区（水平居中）
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                spacing: root.computedPadding / 2

                // 小时
                TimeWheel {
                    id: hourWheel
                    Layout.preferredWidth: root.computedWheelItemHeight * 1.5
                    Layout.fillHeight: true
                    model: 24
                    currentIndex: root.hour
                    onCurrentIndexChanged: {
                        root.hour = currentIndex
                        root.timeChanged(root.hour, root.minute, root.second)
                    }
                }

                Text {
                    text: ":"
                    font.pixelSize: root.computedFontSize + 2
                    font.bold: true
                    color: EasyTheme.color.text
                }

                // 分钟
                TimeWheel {
                    id: minuteWheel
                    Layout.preferredWidth: root.computedWheelItemHeight * 1.5
                    Layout.fillHeight: true
                    model: 60
                    currentIndex: root.minute
                    onCurrentIndexChanged: {
                        root.minute = currentIndex
                        root.timeChanged(root.hour, root.minute, root.second)
                    }
                }

                // 秒（可选）
                Text {
                    visible: root.showSeconds
                    text: ":"
                    font.pixelSize: root.computedFontSize + 2
                    font.bold: true
                    color: EasyTheme.color.text
                }

                TimeWheel {
                    id: secondWheel
                    visible: root.showSeconds
                    Layout.preferredWidth: root.computedWheelItemHeight * 1.5
                    Layout.fillHeight: true
                    model: 60
                    currentIndex: root.second
                    onCurrentIndexChanged: {
                        root.second = currentIndex
                        root.timeChanged(root.hour, root.minute, root.second)
                    }
                }
            }

            // 底部按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: root.computedPadding / 2

                Item { Layout.fillWidth: true }

                EasyButton {
                    text: "取消"
                    primary: false
                    size: root.size
                    onClicked: timePopup.close()
                }

                EasyButton {
                    text: "确定"
                    primary: true
                    size: root.size
                    onClicked: timePopup.close()
                }
            }
        }
    }

    // ── 内部组件：时间滚轮 ────────────────────────────────────
    component TimeWheel: Rectangle {
        id: wheel

        property int model: 24
        property int currentIndex: 0

        radius: 6
        color: EasyTheme.color.card
        border.color: EasyTheme.color.divider
        border.width: EasyTheme.size.borderWidth
        clip: true

        // 当前选中高亮背景
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: listView.contentY + listView.height / 2 - root.computedWheelItemHeight / 2
            width: parent.width - 8
            height: root.computedWheelItemHeight
            radius: 4
            color: EasyTheme.color.primary
            opacity: 0.1
        }

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 4
            clip: true
            model: wheel.model
            currentIndex: wheel.currentIndex
            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: height / 2 - root.computedWheelItemHeight / 2
            preferredHighlightEnd: height / 2 + root.computedWheelItemHeight / 2

            delegate: Item {
                width: listView.width
                height: root.computedWheelItemHeight

                // 判断是否是当前选中项（通过计算与视图中线的距离）
                property bool isCurrent: {
                    var centerY = listView.contentY + listView.height / 2
                    var itemCenterY = index * root.computedWheelItemHeight + root.computedWheelItemHeight / 2
                    return Math.abs(centerY - itemCenterY) < root.computedWheelItemHeight / 2
                }

                // 计算与中心的距离用于颜色渐变
                property real distToCenter: {
                    var centerY = listView.contentY + listView.height / 2
                    var itemCenterY = index * root.computedWheelItemHeight + root.computedWheelItemHeight / 2
                    return Math.abs(centerY - itemCenterY)
                }

                Text {
                    anchors.centerIn: parent
                    text: String(index).padStart(2, '0')
                    font.pixelSize: root.computedFontSize
                    font.bold: parent.isCurrent
                    color: {
                        if (parent.distToCenter < root.computedWheelItemHeight / 2) return EasyTheme.color.primary
                        if (parent.distToCenter < root.computedWheelItemHeight * 1.5) return EasyTheme.color.text
                        return EasyTheme.color.placeholder
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        wheel.currentIndex = index
                        listView.positionViewAtIndex(index, ListView.Center)
                    }
                }
            }

            onCurrentIndexChanged: {
                wheel.currentIndex = currentIndex
            }

            Component.onCompleted: {
                positionViewAtIndex(wheel.currentIndex, ListView.Center)
            }
        }

        // 上下渐变遮罩
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.computedWheelItemHeight * 0.5
            gradient: Gradient {
                GradientStop { position: 0; color: EasyTheme.color.background }
                GradientStop { position: 1; color: "transparent" }
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.computedWheelItemHeight * 0.5
            gradient: Gradient {
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 1; color: EasyTheme.color.background }
            }
        }
    }
}
