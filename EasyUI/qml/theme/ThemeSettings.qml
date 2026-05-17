pragma Singleton

import QtQuick
import QtCore
import EasyUI 1.0

/**
 * ThemeSettings —— 主题设置管理（单例）
 *
 * 持久化存储用户的主题偏好，包括：
 * - 深色模式
 * - 主题色
 * - 圆角大小
 * - 字体大小
 *
 * 使用方式：
 *   ThemeSettings.isDark          // 获取深色模式状态
 *   ThemeSettings.primaryColor    // 获取主题色
 *   ThemeSettings.cornerRadius    // 获取圆角大小
 *   ThemeSettings.fontSize        // 获取字体大小
 *   ThemeSettings.setDarkMode(true/false)
 *   ThemeSettings.setPrimaryColor("#528bff")
 *   ThemeSettings.setCornerRadius(8)
 *   ThemeSettings.setFontSize(14)
 *   ThemeSettings.resetToDefaults()
 */
QtObject {
    id: root

    // Settings 存储
    property Settings settings: Settings {
        property bool isDark: false
        property string primaryColor: "#4f6ef7"
        property int cornerRadius: 8
        property int fontSize: 14
    }

    // 供外部访问的属性（直接读写，绑定到 Settings）
    property bool isDark: false
    property string primaryColor: "#4f6ef7"
    property int cornerRadius: 8
    property int fontSize: 14

    Component.onCompleted: {
        isDark = settings.isDark
        primaryColor = settings.primaryColor
        cornerRadius = settings.cornerRadius
        fontSize = settings.fontSize
    }

    // 设置深色模式
    function setDarkMode(enabled) {
        if (isDark === enabled) return
        isDark = enabled
        settings.isDark = enabled
        themeSettingsChanged()
    }

    // 设置主题色
    function setPrimaryColor(color) {
        if (primaryColor === color) return
        primaryColor = color
        settings.primaryColor = color
        themeSettingsChanged()
    }

    // 设置圆角
    function setCornerRadius(radius) {
        if (cornerRadius === radius) return
        cornerRadius = radius
        settings.cornerRadius = radius
        themeSettingsChanged()
    }

    // 设置字体大小
    function setFontSize(size) {
        if (fontSize === size) return
        fontSize = size
        settings.fontSize = size
        themeSettingsChanged()
    }

    // 重置为默认
    function resetToDefaults() {
        isDark = false
        primaryColor = "#4f6ef7"
        cornerRadius = 8
        fontSize = 14
        settings.isDark = false
        settings.primaryColor = "#4f6ef7"
        settings.cornerRadius = 8
        settings.fontSize = 14
        themeSettingsChanged()
    }

    // 信号：当设置变更时发出
    signal themeSettingsChanged()
}
