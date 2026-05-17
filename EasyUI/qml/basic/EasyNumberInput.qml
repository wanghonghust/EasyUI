import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

/**
 * EasyNumberInput —— 数字输入框组件
 *
 * 属性：
 *   value        {real}       当前值，默认 0
 *   min          {real}       最小值，默认 0
 *   max          {real}       最大值，默认 100
 *   step         {real}       步进值，默认 1
 *   precision    {int}        小数精度，默认 0（整数）
 *   width        {int}        输入框宽度，默认 120
 *   size         {int}        控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *   enabled      {bool}       是否启用
 *   placeholder  {string}     占位文本
 */
Rectangle {
    id: root

    property real value: 0
    property real min: 0
    property real max: 100
    property real step: 1
    property int precision: 0  // 0 = 整数, 1+ = 小数位数
    property string placeholder: ""
    property bool showButtons: true
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
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge
        default:                        return EasyTheme.size.fontSizeNormal
        }
    }
    readonly property int computedBtnWidth: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 22
        case EasyTheme.size.sizeSmall:  return 24
        case EasyTheme.size.sizeLarge:  return 34
        default:                        return 28
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

    implicitWidth: showButtons ? 140 : 120
    implicitHeight: computedHeight
    radius: EasyTheme.size.radius
    color: enabled ? EasyTheme.color.card : EasyTheme.color.background
    border.color: inputField.activeFocus ? EasyTheme.color.accent : EasyTheme.color.cardBorder
    border.width: inputField.activeFocus ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        // 减少按钮
        Rectangle {
            id: decreaseBtn
            visible: root.showButtons
            Layout.preferredWidth: root.computedBtnWidth
            Layout.fillHeight: true
            radius: 7
            color: decreaseArea.containsMouse ? EasyTheme.color.menuHover : EasyTheme.color.transparent

            Text {
                anchors.centerIn: parent
                text: "−"
                font.pixelSize: root.computedFontSize + 2
                font.bold: true
                color: root.enabled && root.value > root.min
                       ? (decreaseArea.containsMouse ? EasyTheme.color.accent : EasyTheme.color.text)
                       : EasyTheme.color.placeholder
            }

            MouseArea {
                id: decreaseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.enabled && root.value > root.min
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.decrease()
            }
        }

        // 输入框
        TextInput {
            id: inputField
            Layout.fillWidth: true
            Layout.fillHeight: true
            leftPadding: root.showButtons ? 4 : root.computedPadding
            rightPadding: root.showButtons ? 4 : root.computedPadding

            text: root.precision === 0 ? Math.round(root.value).toString() : root.value.toFixed(root.precision)
            color: root.enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
            font.pixelSize: root.computedFontSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            selectByMouse: true
            selectionColor: EasyTheme.color.accent
            selectedTextColor: EasyTheme.color.white

            validator: DoubleValidator {
                bottom: root.min
                top: root.max
                decimals: root.precision
                notation: DoubleValidator.StandardNotation
            }

            onAccepted: {
                var val = parseFloat(text)
                if (!isNaN(val)) {
                    root.setValue(val)
                } else {
                    text = root.precision === 0 ? Math.round(root.value).toString() : root.value.toFixed(root.precision)
                }
            }

            onFocusChanged: {
                if (!focus) {
                    // 失焦时验证并更新
                    var val = parseFloat(text)
                    if (!isNaN(val)) {
                        root.setValue(val)
                    } else {
                        text = root.precision === 0 ? Math.round(root.value).toString() : root.value.toFixed(root.precision)
                    }
                }
            }

            Keys.onUpPressed: root.increase()
            Keys.onDownPressed: root.decrease()
        }

        // 增加按钮
        Rectangle {
            id: increaseBtn
            visible: root.showButtons
            Layout.preferredWidth: root.computedBtnWidth
            Layout.fillHeight: true
            radius: 7
            color: increaseArea.containsMouse ? EasyTheme.color.menuHover : EasyTheme.color.transparent

            Text {
                anchors.centerIn: parent
                text: "+"
                font.pixelSize: root.computedFontSize + 2
                font.bold: true
                color: root.enabled && root.value < root.max
                       ? (increaseArea.containsMouse ? EasyTheme.color.accent : EasyTheme.color.text)
                       : EasyTheme.color.placeholder
            }

            MouseArea {
                id: increaseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.enabled && root.value < root.max
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.increase()
            }
        }
    }

    // 公开方法
    function setValue(val) {
        val = Math.max(root.min, Math.min(root.max, val))
        if (root.precision > 0) {
            val = parseFloat(val.toFixed(root.precision))
        } else {
            val = Math.round(val)
        }
        if (val !== root.value) {
            root.value = val
        }
        inputField.text = root.precision === 0 ? Math.round(val).toString() : val.toFixed(root.precision)
    }

    function increase() {
        if (root.enabled && root.value < root.max) {
            setValue(root.value + root.step)
        }
    }

    function decrease() {
        if (root.enabled && root.value > root.min) {
            setValue(root.value - root.step)
        }
    }
}