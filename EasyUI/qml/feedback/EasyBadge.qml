import QtQuick
import EasyUI

/**
 * EasyBadge —— 徽标组件
 *
 * 属性：
 *   text           {string}  显示文字/数字
 *   type           {string}  类型：primary/success/warning/error，默认 primary
 *   dot            {bool}    是否为圆点模式（无文字），默认 false
 *   size           {int}     控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 */
Rectangle {
    id: root

    property string text: ""
    property string type: "primary"  // primary, success, warning, error
    property bool dot: false
    property int size: EasyTheme.size.sizeNormal

    // 根据 size 计算控件尺寸
    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.badgeHeightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.badgeHeightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.badgeHeightLarge
        default:                        return EasyTheme.size.badgeHeightNormal
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.fontSizeMini - 1
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall - 2
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge - 3
        default:                        return EasyTheme.size.fontSizeNormal - 3
        }
    }

    width: dot ? computedHeight * 0.4 : Math.max(computedHeight, textLabel.implicitWidth + computedHeight * 0.6)
    height: dot ? computedHeight * 0.4 : computedHeight
    radius: dot ? height / 2 : height / 2

    color: {
        switch(type) {
            case "success": return EasyTheme.color.success
            case "warning": return EasyTheme.color.warning
            case "error":   return EasyTheme.color.colorError
            default:        return EasyTheme.color.primary
        }
    }

    // 文字
    Text {
        id: textLabel
        visible: !root.dot && root.text.length > 0
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: computedFontSize
        font.bold: true
        color: "white"
    }
}
