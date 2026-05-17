import QtQuick
import EasyUI

/**
 * EasyToggle —— 切换按钮组件
 *
 * 属性：
 *   checked        {bool}    是否选中，默认 false
 *   text           {string}  标签文字，默认 ""
 *   size           {int}     控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *   enabled        {bool}    是否可用，默认 true
 *
 * 信号：
 *   toggled(bool)            状态变化
 */
Rectangle {
    id: root

    property bool checked: false
    property string text: ""
    property int size: EasyTheme.size.sizeNormal
    property bool enabled: true

    // 根据 size 计算控件尺寸
    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.heightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.heightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.heightLarge
        default:                        return EasyTheme.size.heightNormal
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
    readonly property int computedPadding: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.btnPaddingMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.btnPaddingSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.btnPaddingLarge
        default:                        return EasyTheme.size.btnPaddingNormal
        }
    }

    // 宽度：自适应内容
    width: root.text.length > 0
           ? txtMetrics.width + computedPadding * 2
           : computedHeight
    implicitWidth: width
    height: computedHeight
    radius: computedHeight / 2

    // 颜色
    color: {
        if (!root.enabled)
            return root.checked ? Qt.darker(EasyTheme.color.primary, 1.3) : EasyTheme.color.card
        if (mouseArea.containsMouse)
            return root.checked ? Qt.lighter(EasyTheme.color.primary, 1.1) : EasyTheme.color.buttonHover
        return root.checked ? EasyTheme.color.primary : EasyTheme.color.card
    }
    border.color: root.checked ? "transparent" : EasyTheme.color.border
    border.width: root.checked ? 0 : EasyTheme.size.borderWidth

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    // 文字度量
    TextMetrics {
        id: txtMetrics
        text: root.text
        font.pixelSize: computedFontSize
    }

    // 文字
    Text {
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: computedFontSize
        font.bold: root.checked
        color: root.checked ? "white" : EasyTheme.color.text
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // 点击区域
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        enabled: root.enabled
        onClicked: {
            if (root.enabled) {
                root.checked = !root.checked
                root.toggled(root.checked)
            }
        }
    }

    // 点击动画效果
    scale: mouseArea.containsPress ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: 100 } }

    signal toggled(bool checked)
}
