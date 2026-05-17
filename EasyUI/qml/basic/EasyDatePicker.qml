import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

/**
 * EasyDatePicker —— 日期选择器组件
 *
 * 属性：
 *   selectedDate  {date}    选中的日期，默认 null
 *   placeholder   {string}  占位文字，默认 "选择日期"
 *   enabled       {bool}    是否可用，默认 true
 *   format        {string}  日期格式，默认 "yyyy-MM-dd"
 *   size          {int}     控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *
 * 信号：
 *   dateSelected(date date)  日期选中时触发
 */
Rectangle {
    id: root

    property var selectedDate: null
    property string placeholder: "选择日期"
    property bool enabled: true
    property string format: "yyyy-MM-dd"
    property int size: EasyTheme.size.sizeNormal
    property bool dropUpWhenNearBottom: true

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

    readonly property int computedRadius: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.radiusSmall
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.radiusSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.radiusLarge
        default:                        return 8
        }
    }

    width: 220
    height: computedHeight
    radius: computedRadius
    color: EasyTheme.color.card
    border.color: calendarPopup.visible ? EasyTheme.color.primary : (_hover.hovered ? Qt.darker(EasyTheme.color.border, 1.12) : EasyTheme.color.border)
    border.width: EasyTheme.size.borderWidth

    HoverHandler { id: _hover; enabled: root.enabled }

    Behavior on border.color {
        ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease }
    }

    // 日历弹窗尺寸
    property int calendarWidth: 308
    property int calendarHeight: 380

    // 获取在 Overlay 中的位置，用于判断弹出方向
    property var globalPos: root.mapToItem(Overlay.overlay, 0, 0)
    property real globalBottomY: globalPos.y + root.height
    property real overlayHeight: Overlay.overlay ? Overlay.overlay.height : 600

    // 判断是否应该向上弹出
    property bool shouldDropUp: {
        if (!dropUpWhenNearBottom) return false
        // 判断向下展开是否会超出 Overlay（窗口内容区域）
        return (globalBottomY + calendarHeight + 10) > overlayHeight
    }

    // 格式化日期显示
    function formatDate(date) {
        if (!date) return ""
        return Qt.formatDate(date, format)
    }

    function open() { calendarPopup.open() }
    function close() { calendarPopup.close() }

    // 显示选中的日期或占位文字
    Text {
        id: dateText
        anchors.left: parent.left
        anchors.leftMargin: computedPadding
        anchors.right: calendarIcon.left
        anchors.rightMargin: computedPadding
        anchors.verticalCenter: parent.verticalCenter
        text: root.selectedDate ? root.formatDate(root.selectedDate) : root.placeholder
        font.pixelSize: computedFontSize
        color: root.selectedDate ? EasyTheme.color.text : EasyTheme.color.placeholder
        Behavior on color { ColorAnimation { duration: 150 } }
        elide: Text.ElideRight
    }

    // 日历图标
    EasyIconFont {
        id: calendarIcon
        anchors.right: parent.right
        anchors.rightMargin: computedPadding
        anchors.verticalCenter: parent.verticalCenter
        icon: EasyIcon.material.calendar_month
        iconSize: computedFontSize + 2
        color: EasyTheme.color.placeholder
    }

    // 点击区域
    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            if (calendarPopup.visible) {
                calendarPopup.close()
            } else {
                calendarPopup.open()
            }
        }
    }

    // 日历弹窗
    Popup {
        id: calendarPopup
        y: root.shouldDropUp ? -(calendarHeight + 4) : (root.height + 4)
        width: calendarWidth
        height: calendarHeight
        padding: 0
        margins: 0
        modal: true
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        background: Rectangle {
            radius: 8
            color: EasyTheme.color.card
            border.width: EasyTheme.size.borderWidth
            border.color: EasyTheme.color.divider
        }

        // 日历内容
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: EasyTheme.size.paddingNormal
            spacing: 12

            // 头部：年月导航
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // 上一年
                Rectangle {
                    width: 32
                    height: 32
                    radius: EasyTheme.size.radiusSmall
                    color: mouseAreaPrevYear.containsMouse ? EasyTheme.color.buttonHover : EasyTheme.color.transparent
                    Text {
                        anchors.centerIn: parent
                        text: "\u00AB"  // «
                        font.pixelSize: EasyTheme.font.sizeBig
                        color: EasyTheme.color.text
                    }
                    MouseArea {
                        id: mouseAreaPrevYear
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendarView.decrementYear()
                    }
                }

                // 上一月
                Rectangle {
                    width: 32
                    height: 32
                    radius: EasyTheme.size.radiusSmall
                    color: mouseAreaPrevMonth.containsMouse ? EasyTheme.color.buttonHover : EasyTheme.color.transparent
                    Text {
                        anchors.centerIn: parent
                        text: "\u2039"  // ‹
                        font.pixelSize: EasyTheme.font.sizeBig
                        color: EasyTheme.color.text
                    }
                    MouseArea {
                        id: mouseAreaPrevMonth
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendarView.decrementMonth()
                    }
                }

                // 年月显示
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: calendarView.year + "  " + calendarView.monthName
                    font.pixelSize: EasyTheme.font.sizeBig
                    font.bold: true
                    color: EasyTheme.color.text
                }

                // 下一月
                Rectangle {
                    width: 32
                    height: 32
                    radius: EasyTheme.size.radiusSmall
                    color: mouseAreaNextMonth.containsMouse ? EasyTheme.color.buttonHover : EasyTheme.color.transparent
                    Text {
                        anchors.centerIn: parent
                        text: "\u203A"  // ›
                        font.pixelSize: EasyTheme.font.sizeBig
                        color: EasyTheme.color.text
                    }
                    MouseArea {
                        id: mouseAreaNextMonth
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendarView.incrementMonth()
                    }
                }

                // 下一年
                Rectangle {
                    width: 32
                    height: 32
                    radius: EasyTheme.size.radiusSmall
                    color: mouseAreaNextYear.containsMouse ? EasyTheme.color.buttonHover : EasyTheme.color.transparent
                    Text {
                        anchors.centerIn: parent
                        text: "\u00BB"  // »
                        font.pixelSize: EasyTheme.font.sizeBig
                        color: EasyTheme.color.text
                    }
                    MouseArea {
                        id: mouseAreaNextYear
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendarView.incrementYear()
                    }
                }
            }

            // 星期标题
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                property var weekDays: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                Repeater {
                    model: parent.weekDays
                    delegate: Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.pixelSize: EasyTheme.font.sizeSmall
                        font.bold: true
                        color: EasyTheme.color.placeholder
                    }
                }
            }

            // 日期网格
            GridLayout {
                id: calendarGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 2
                columnSpacing: 2

                Repeater {
                    id: dayRepeater
                    model: 42  // 6行 x 7列

                    delegate: Rectangle {
                        id: dayCell
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: EasyTheme.size.radiusSmall

                        property var dayData: calendarView.getDayData(index)
                        property bool isCurrentMonth: dayData ? dayData.isCurrentMonth : false
                        property bool isToday: dayData ? dayData.isToday : false
                        property bool isSelected: dayData ? dayData.isSelected : false
                        property int day: dayData ? dayData.day : 0
                        property bool isHovered: false

                        color: {
                            if (isSelected) return EasyTheme.color.primary
                            if (isToday) return EasyTheme.color.primary + "1A"  // 10% 透明度
                            if (isHovered && isCurrentMonth) return EasyTheme.color.buttonHover
                            return EasyTheme.color.transparent
                        }

                        border.color: isToday && !isSelected ? EasyTheme.color.primary : EasyTheme.color.transparent
                        border.width: isToday && !isSelected ? EasyTheme.size.borderWidth : 0

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.day > 0 ? dayCell.day : ""
                            font.pixelSize: EasyTheme.font.sizeMedium
                            font.bold: dayCell.isToday || dayCell.isSelected
                            color: {
                                if (dayCell.isSelected) return EasyTheme.color.white
                                if (!dayCell.isCurrentMonth) return EasyTheme.color.placeholder
                                return EasyTheme.color.text
                            }
                        }

                        MouseArea {
                            id: dayMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: dayCell.day > 0 && dayCell.isCurrentMonth
                            cursorShape: (dayCell.day > 0 && dayCell.isCurrentMonth) ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onContainsMouseChanged: {
                                dayCell.isHovered = containsMouse
                            }
                            onClicked: {
                                if (dayCell.dayData) {
                                    root.selectedDate = dayCell.dayData.date
                                    root.dateSelected(root.selectedDate)
                                    calendarPopup.close()
                                }
                            }
                        }
                    }
                }
            }

            // 底部按钮
            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 60
                    height: 30
                    radius: EasyTheme.size.radiusSmall
                    color: mouseAreaToday.containsMouse ? EasyTheme.color.buttonHover : EasyTheme.color.transparent
                    Text {
                        anchors.centerIn: parent
                        text: "今天"
                        font.pixelSize: EasyTheme.font.sizeMedium
                        color: EasyTheme.color.primary
                    }
                    MouseArea {
                        id: mouseAreaToday
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedDate = new Date()
                            calendarView.currentDate = new Date()
                            root.dateSelected(root.selectedDate)
                            calendarPopup.close()
                        }
                    }
                }

                Rectangle {
                    width: 50
                    height: 30
                    radius: EasyTheme.size.radiusSmall
                    color: mouseAreaClear.containsMouse ? EasyTheme.color.buttonHover : EasyTheme.color.transparent
                    Text {
                        anchors.centerIn: parent
                        text: "清除"
                        font.pixelSize: EasyTheme.font.sizeMedium
                        color: EasyTheme.color.placeholder
                    }
                    MouseArea {
                        id: mouseAreaClear
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedDate = null
                            calendarPopup.close()
                        }
                    }
                }
            }
        }
    }

    // 日历数据管理
    QtObject {
        id: calendarView

        property var currentDate: new Date()
        property int year: currentDate.getFullYear()
        property int month: currentDate.getMonth()
        property string monthName: {
            var names = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"]
            return names[month]
        }

        function decrementYear() {
            currentDate = new Date(year - 1, month, 1)
        }

        function incrementYear() {
            currentDate = new Date(year + 1, month, 1)
        }

        function decrementMonth() {
            var newMonth = month - 1
            var newYear = year
            if (newMonth < 0) {
                newMonth = 11
                newYear--
            }
            currentDate = new Date(newYear, newMonth, 1)
        }

        function incrementMonth() {
            var newMonth = month + 1
            var newYear = year
            if (newMonth > 11) {
                newMonth = 0
                newYear++
            }
            currentDate = new Date(newYear, newMonth, 1)
        }

        function getDayData(index) {
            // 获取当月第一天是星期几
            var firstDay = new Date(year, month, 1).getDay()
            // 获取当月天数
            var daysInMonth = new Date(year, month + 1, 0).getDate()
            // 获取上月天数（用于填充开头）
            var daysInPrevMonth = new Date(year, month, 0).getDate()

            var dayIndex = index - firstDay + 1

            if (index < firstDay) {
                // 上月的日期
                var prevDay = daysInPrevMonth - firstDay + index + 1
                return {
                    day: prevDay,
                    isCurrentMonth: false,
                    isToday: false,
                    isSelected: false,
                    date: new Date(year, month - 1, prevDay)
                }
            } else if (dayIndex > daysInMonth) {
                // 下月的日期
                var nextDay = dayIndex - daysInMonth
                return {
                    day: nextDay,
                    isCurrentMonth: false,
                    isToday: false,
                    isSelected: false,
                    date: new Date(year, month + 1, nextDay)
                }
            } else {
                // 当月的日期
                var date = new Date(year, month, dayIndex)
                var today = new Date()
                var isToday = date.toDateString() === today.toDateString()
                var isSelected = root.selectedDate &&
                    date.toDateString() === root.selectedDate.toDateString()

                return {
                    day: dayIndex,
                    isCurrentMonth: true,
                    isToday: isToday,
                    isSelected: isSelected,
                    date: date
                }
            }
        }
    }

    signal dateSelected(var date)
}
