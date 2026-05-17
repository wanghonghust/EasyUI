import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

/**
 * EasySelect —— 选择器组件
 *
 * 属性：
 *   options        {list<string>}  选项列表，默认 []
 *   currentIndex  {int}            当前选中索引，默认 -1（无选中）
 *   placeholder   {string}         未选中时的占位文字，默认 "请选择"
 *   enabled       {bool}           是否可用，默认 true
 *   size          {int}            控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *   maxDropDownHeight {int}        下拉菜单最大高度，默认 200
 *   dropUpWhenNearBottom {bool}    靠近底部时向上弹出，默认 true
 *
 * 信号：
 *   currentIndexChanged(int index)  选中索引变化
 */
Rectangle {
    id: root

    property var options: []
    property int currentIndex: -1
    property string placeholder: "请选择"
    property bool enabled: true
    property int size: EasyTheme.size.sizeNormal
    property int maxDropDownHeight: 200
    property bool dropUpWhenNearBottom: true
    property bool clearable: false

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
        case EasyTheme.size.sizeMini:   return 8
        case EasyTheme.size.sizeSmall:  return 10
        case EasyTheme.size.sizeLarge:  return 14
        default:                        return 12
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
    readonly property int computedOptionHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.optionHeightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.optionHeightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.optionHeightLarge
        default:                        return EasyTheme.size.optionHeightNormal
        }
    }

    width: 220
    height: computedHeight
    radius: EasyTheme.size.radius
    color: EasyTheme.color.card
    border.color: menu.visible ? EasyTheme.color.primary : (_hover.hovered ? Qt.darker(EasyTheme.color.border, 1.12) : EasyTheme.color.border)
    border.width: menu.visible ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth

    HoverHandler { id: _hover; enabled: root.enabled }

    Behavior on border.color {
        ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease }
    }
    Behavior on border.width {
        NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease }
    }

    // 计算下拉菜单高度
    property int dropDownHeight: Math.min(
        options.length * computedOptionHeight + 20,  // 选项总高度 + padding
        root.maxDropDownHeight
    )

    // 获取在 Overlay 中的位置，用于判断弹出方向
    property var globalPos: root.mapToItem(Overlay.overlay, 0, 0)
    property real globalBottomY: globalPos.y + root.height
    property real overlayHeight: Overlay.overlay ? Overlay.overlay.height : 600

    // 判断是否应该向上弹出
    property bool shouldDropUp: {
        if (!dropUpWhenNearBottom) return false
        // 判断向下展开是否会超出 Overlay（窗口内容区域）
        return (globalBottomY + dropDownHeight + 10) > overlayHeight
    }

    // 显示当前选中值或占位文字
    Text {
        id: selectedText
        anchors.left: parent.left
        anchors.leftMargin: computedPadding
        anchors.right: clearSelectBtn.visible ? clearSelectBtn.left : arrowIcon.left
        anchors.rightMargin: computedPadding
        anchors.verticalCenter: parent.verticalCenter
        text: root.currentIndex >= 0 ? root.options[root.currentIndex] : root.placeholder
        font.pixelSize: computedFontSize
        color: root.currentIndex >= 0 ? EasyTheme.color.text : EasyTheme.color.placeholder
        Behavior on color { ColorAnimation { duration: 150 } }
        elide: Text.ElideRight
    }

    // Clear button
    EasyButton {
        id: clearSelectBtn
        visible: root.clearable && root.enabled && root.currentIndex >= 0
        icon: EasyIcon.material.close
        round: true
        primary: false
        size: root.size <= EasyTheme.size.sizeSmall ? EasyTheme.size.sizeMini : EasyTheme.size.sizeSmall
        anchors { right: arrowIcon.left; rightMargin: 2; verticalCenter: parent.verticalCenter }
        onClicked: {
            root.currentIndex = -1
            root.currentIndexChanged(-1)
        }
    }

    // 下拉箭头
    EasyIconFont {
        id: arrowIcon
        anchors.right: parent.right
        anchors.rightMargin: computedPadding
        anchors.verticalCenter: parent.verticalCenter
        icon: menu.visible ? EasyIcon.material.keyboard_arrow_up : EasyIcon.material.keyboard_arrow_down
        iconSize: 20
        color: EasyTheme.color.placeholder
    }

    // 点击区域
    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            if (menu.visible) {
                menu.close();
            } else {
                menu.open();
            }
        }
    }

    // 菜单
    Popup {
        id: menu
        width: root.width
        height: dropDownHeight
        padding: 2
        clip: true

        property bool calculatedDropUp: false

        // 定时器持续检查位置
        Timer {
            id: positionTimer
            interval: 50  // 50ms 检查一次
            running: menu.visible
            repeat: true
            onTriggered: menu.updateDropDirection()
        }

        // 更新弹出方向
        function updateDropDirection() {
            // 获取组件在窗口中的相对位置
            var posInWindow = root.mapToItem(null, 0, root.height)
            var bottomInWindow = posInWindow.y

            // 获取窗口内容高度
            var windowContentHeight = root.Window.height || root.parent.height || 600

            // 判断向下展开是否会超出窗口底部
            calculatedDropUp = (bottomInWindow + dropDownHeight + 10) > windowContentHeight
        }

        // 打开时初始化计算
        onAboutToShow: updateDropDirection()

        y: calculatedDropUp ? -(dropDownHeight + 4) : (root.height + 4)

        background: Rectangle {
            radius: EasyTheme.size.radius
            color: EasyTheme.color.card
            border.width: 1
            border.color: EasyTheme.color.border

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: EasyTheme.color.shadow
                shadowOpacity: EasyTheme.elevation.shadowOpacity(EasyTheme.elevation.low)
                shadowBlur: 0.4
                shadowHorizontalOffset: 0
                shadowVerticalOffset: EasyTheme.elevation.shadowOffsetY(EasyTheme.elevation.low)
            }
        }

        ListView {
            id: contentItem
            anchors.fill: parent
            spacing: 2
            clip: true
            model: options
            ScrollBar.vertical: EasyScrollBar { }
            delegate: Rectangle {
                width: contentItem.width
                height: computedOptionHeight
                radius: EasyTheme.size.radiusSmall
                color: mouseArea.containsMouse ? EasyTheme.color.menuHover : "transparent"

                Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }

                Text {
                    text: modelData
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    font.pixelSize: computedFontSize
                    color: EasyTheme.color.text
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: mouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = index;
                        menu.close();
                    }
                }
            }
        }
    }
}
