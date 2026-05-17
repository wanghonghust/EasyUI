import QtQuick
import QtQuick.Layouts
import EasyUI

/**
 * EasyRate —— 评分组件
 *
 * 属性：
 *   value        {real}         当前评分值，默认 0
 *   max          {int}          最大评分，默认 5
 *   allowHalf    {bool}         是否允许半星，默认 false
 *   readonly     {bool}         是否只读，默认 false
 *   showValue    {bool}         是否显示分数，默认 true
 *   size         {int}          图标大小，默认 24
 *   activeColor  {color}        激活颜色
 *   inactiveColor{color}        未激活颜色
 */
RowLayout {
    id: root

    property real value: 0
    property int max: 5
    property bool allowHalf: false
    property bool readonly: false
    property bool showValue: true
    property int size: 24
    property color activeColor: EasyTheme.color.accent
    property color inactiveColor: EasyTheme.color.placeholder

    spacing: 4

    property real _previewValue: -1
    property real _displayValue: _previewValue >= 0 ? _previewValue : value

    // Delayed reset: only clear preview when mouse has truly left all stars
    Timer {
        id: resetTimer
        interval: 100
        onTriggered: root._previewValue = -1
    }

    Repeater {
        model: root.max

        delegate: StarItem {
            size: root.size
            index: modelData
            value: root._displayValue
            allowHalf: root.allowHalf
            activeColor: root.activeColor
            inactiveColor: root.inactiveColor
            readonly: root.readonly
            onStarClicked: (val) => root.setValue(val)
            onStarHovered: (val) => { resetTimer.stop(); root._previewValue = val }
            onStarExited: resetTimer.restart()
        }
    }

    Text {
        visible: root.showValue
        text: root.allowHalf ? root.value.toFixed(1) : root.value + "/" + root.max
        font.pixelSize: 13
        font.bold: true
        color: root.value > 0 ? root.activeColor : root.inactiveColor
    }

    function setValue(val) {
        val = Math.max(0, Math.min(root.max, val))
        if (root.allowHalf)
            val = Math.round(val * 2) / 2
        else
            val = Math.round(val)
        if (val !== root.value)
            root.value = val
    }

    function increase() {
        setValue(root.value + (root.allowHalf ? 0.5 : 1))
    }

    function decrease() {
        setValue(root.value - (root.allowHalf ? 0.5 : 1))
    }
}
