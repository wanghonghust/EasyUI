import QtQuick
import EasyUI

/**
 * EasyAvatar —— 头像组件
 *
 * 属性：
 *   source        {url}       图片地址
 *   text          {string}    文字（当无图片时显示）
 *   size          {real}      尺寸，默认 40
 *   shape         {string}    形状："circle"(圆形), "square"(圆角方形)，默认 "circle"
 *   borderColor   {color}     边框颜色，默认适配深色/浅色模式
 *   borderWidth   {real}      边框宽度，默认 1
 *
 * 颜色：
 *   根据 text 自动生成背景色
 */
Rectangle {
    id: root

    property url source: ""
    property string text: ""
    property real size: 40
    property string shape: "circle"  // circle, square
    property color borderColor: EasyTheme.isDark ? "#555555" : "#c0c0c0"
    property real borderWidth: 1

    // 自动生成背景色（基于文字）
    property color autoColor: {
        if (!text)
            return EasyTheme.color.primary

        // 基于文字的哈希值选择颜色（深色模式用更亮的颜色，浅色模式用标准颜色）
        var colors = EasyTheme.isDark ? [
            "#ff6b6b", "#ff8a80", "#ea80fc", "#b388ff",
            "#8c9eff", "#82b1ff", "#80d8ff", "#84ffff",
            "#a7ffeb", "#b9f6ca", "#ccff90", "#f4ff81",
            "#ffd180", "#ff9e80", "#bcaaa4", "#b0bec5"
        ] : [
            "#f44336", "#e91e63", "#9c27b0", "#673ab7",
            "#3f51b5", "#2196f3", "#03a9f4", "#00bcd4",
            "#009688", "#4caf50", "#8bc34a", "#cddc39",
            "#ff9800", "#ff5722", "#795548", "#607d8b"
        ]

        var hash = 0
        for (var i = 0; i < text.length; i++) {
            hash = ((hash << 5) - hash) + text.charCodeAt(i)
            hash = hash & hash
        }

        return colors[Math.abs(hash) % colors.length]
    }
    
    // 根据背景色亮度计算文字颜色（黑或白）
    function getContrastColor(bgColor) {
        // 计算亮度 (YIQ 公式)
        var r = bgColor.r * 255
        var g = bgColor.g * 255
        var b = bgColor.b * 255
        var brightness = (r * 299 + g * 587 + b * 114) / 1000
        return brightness > 128 ? "#333333" : "white"
    }

    width: size
    height: size
    radius: shape === "circle" ? size / 2 : 8
    color: source != "" ? "transparent" : autoColor
    border.color: borderColor
    border.width: borderWidth

    // 图片（用 Rectangle 裁剪实现圆角）
    Rectangle {
        id: imageContainer
        anchors.fill: parent
        radius: parent.radius
        clip: true
        visible: root.source !== ""

        Image {
            id: avatarImage
            anchors.fill: parent
            source: root.source
            fillMode: Image.PreserveAspectCrop
            
            // 处理加载错误
            onStatusChanged: {
                if (status === Image.Error) {
                    console.warn("Avatar image load failed:", root.source)
                }
            }
        }

        // 加载中占位
        Rectangle {
            anchors.fill: parent
            color: EasyTheme.isDark ? "#2d2d2d" : "#e0e0e0"
            visible: avatarImage.status === Image.Loading
            
            // 加载动画指示器
            Text {
                anchors.centerIn: parent
                text: "..."
                font.pixelSize: root.size * 0.3
                color: EasyTheme.color.placeholder
            }
        }
        
        // 加载失败时显示文字
        Rectangle {
            anchors.fill: parent
            color: autoColor
            visible: root.source.toString() !== "" && avatarImage.status === Image.Error
            
            Text {
                anchors.centerIn: parent
                text: getInitials(root.text)
                font.pixelSize: root.size * 0.4
                font.bold: true
                color: root.getContrastColor(parent.color)
            }
        }
    }

    // 文字（无图片时显示）
    Text {
        anchors.centerIn: parent
        text: getInitials(root.text)
        font.pixelSize: root.size * 0.4
        font.bold: true
        color: root.getContrastColor(root.color)
        visible: root.source == "" && root.text != ""
    }

    // 获取首字母
    function getInitials(str) {
        if (!str)
            return "?"

        var parts = str.trim().split(/\s+/)
        if (parts.length === 1) {
            return parts[0].charAt(0).toUpperCase()
        } else {
            return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
        }
    }
}
