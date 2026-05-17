import QtQuick
import QtQuick.Controls.Basic
import EasyUI


/**
 * EasyTooltip —— 工具提示（包装组件）
 *
 * 用法：将需要提示的元素包裹在 EasyTooltip 中
 *
 * 属性：
 *   text        {string}  提示文字
 *   delay       {int}     显示延迟(ms)，默认 500
 *   placement   {string}  位置，可选 "top", "bottom", "left", "right"，默认 "top"
 *
 * 示例：
 *   EasyTooltip {
 *       text: "这是提示"
 *       EasyButton { ... }
 *   }
 */
Item {
    id: root
    clip: false

    property string text: ""
    property int delay: 500
    property string placement: "top"

    // 尺寸跟随目标元素（第一个子元素）
    property var target: (children.length > 0) ? children[0] : null
    implicitWidth: (target
                    && target.implicitWidth > 0) ? target.implicitWidth : 120
    implicitHeight: (target
                     && target.implicitHeight > 0) ? target.implicitHeight : 32

    // 使用 Qt 原生 ToolTip
    ToolTip {
        id: tooltip
        text: root.text
        delay: root.delay
        timeout: 5000 // 5秒后自动隐藏

        // 位置设置
        x: tooltipCalcX()
        y: tooltipCalcY()

        // 样式
        contentItem: Text {
            text: tooltip.text
            font.pixelSize: 12
            color: "#ffffff"
            wrapMode: Text.Wrap
        }

        background: Rectangle {
            color: EasyTheme.isDark ? "#2d2d2d" : "#1a1a1a"
            radius: 6
            border.width: EasyTheme.size.borderWidth
            border.color: EasyTheme.isDark ? "#4a4a4a" : "#333333"
        }

        // 当可见时重新计算位置（因为尺寸可能变化）
        onVisibleChanged: {
            if (visible) {
                x = tooltipCalcX()
                y = tooltipCalcY()
            }
        }
    }

    // 计算 tooltip X 坐标
    function tooltipCalcX() {
        if (!root.target)
            return 0
        var tw = tooltip.width || 80
        switch (root.placement) {
        case "left":
            return root.target.x - tw - 8
        case "right":
            return root.target.x + root.target.width + 8
        default:
            return root.target.x + (root.target.width - tw) / 2
        }
    }

    // 计算 tooltip Y 坐标
    function tooltipCalcY() {
        if (!root.target)
            return 0
        var th = tooltip.height || 30
        switch (root.placement) {
        case "bottom":
            return root.target.y + root.target.height + 8
        case "left":
        case "right":
            return root.target.y + root.target.height / 2 - th / 2
        default:
            return root.target.y - th - 8
        }
    }

    // 使用 HoverHandler 监听鼠标悬停，不影响子元素的 MouseArea
    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered && root.text) {
                tooltip.open()
            } else {
                tooltip.close()
            }
        }
    }
}
