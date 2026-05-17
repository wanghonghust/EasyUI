pragma Singleton

import QtQuick
import EasyUI 1.0

QtObject {
    id: root

    property bool isDark: ThemeSettings.isDark

    // ==================== Color ====================
    property QtObject color: QtObject {
        readonly property color white: "white"
        readonly property color black: "black"
        readonly property color transparent: "transparent"

        // Background & Card
        readonly property color background: isDark ? "#111116" : "#f7f8fc"
        readonly property color card: isDark ? "#1a1a22" : "#ffffff"
        readonly property color cardBorder: isDark ? "#12ffffff" : "#0f000000"
        readonly property color tableStrip: isDark ? "#18181e" : "#fafafe"

        // Text
        readonly property color text: isDark ? "#e0e0e6" : "#1a1d29"
        readonly property color placeholder: isDark ? "#838390" : "#6e7188"
        readonly property color secondary: isDark ? "#94949c" : "#5b6071"

        // Primary
        property color primary: ThemeSettings.primaryColor
        readonly property color primaryDark: {
            var c = primary; return Qt.darker(c, 1.15)
        }
        readonly property color primaryLight: {
            var c = primary; return Qt.lighter(c, 1.12)
        }
        readonly property color primaryBg: {
            var c = primary
            return Qt.rgba(c.r, c.g, c.b, isDark ? 0.15 : 0.08)
        }
        readonly property color primaryBorder: {
            var c = primary
            return Qt.rgba(c.r, c.g, c.b, isDark ? 0.25 : 0.18)
        }

        // Accent
        readonly property color accent: "#6366f1"
        readonly property color accentText: "#ffffff"

        // Border & Divider
        readonly property color border: isDark ? "#2c2c38" : "#e2e4eb"
        readonly property color divider: isDark ? "#262630" : "#eaecf2"
        readonly property color windowBorder: isDark ? "#222230" : "#e2e4eb"

        // Hover & Interaction
        readonly property color hover: isDark ? "#26262e" : "#ededf3"
        readonly property color buttonHover: isDark ? "#2c2c38" : "#e2e5f0"
        readonly property color menuHover: isDark ? "#2a2a34" : "#e8eaf2"
        readonly property color menuActiveText: "white"

        // Title bar
        readonly property color miniMaxBtnHover: isDark ? "#14ffffff" : "#0d000000"
        readonly property color closeBtnHover: "#e5525e"

        // Shadow & Overlay
        readonly property color shadow: "#000000"
        readonly property color overlay: isDark ? "#59000000" : "#4c000000"
        readonly property color overlayLight: isDark ? "#1e000000" : "#14000000"

        // Scrollbar
        readonly property color scrollBar: isDark ? "#62626e" : "#c4c6ce"

        // Status
        readonly property color success: "#22c55e"
        readonly property color warning: "#f59e0b"
        readonly property color colorError: "#ef4444"
        readonly property color info: "#6366f1"

        // Selection
        readonly property color selection: {
            var c = primary
            return Qt.rgba(c.r, c.g, c.b, isDark ? 0.22 : 0.12)
        }
    }

    // ==================== Elevation / Shadow ====================
    property QtObject elevation: QtObject {
        readonly property int none: 0
        readonly property int low: 1
        readonly property int medium: 2
        readonly property int high: 3

        function shadowOpacity(level) {
            if (level === elevation.low) return isDark ? 0.15 : 0.06
            if (level === elevation.medium) return isDark ? 0.22 : 0.10
            if (level === elevation.high) return isDark ? 0.30 : 0.15
            return 0
        }
        function shadowBlur(level) {
            if (level === elevation.low) return 8
            if (level === elevation.medium) return 16
            if (level === elevation.high) return 24
            return 0
        }
        function shadowOffsetY(level) {
            if (level === elevation.low) return 2
            if (level === elevation.medium) return 4
            if (level === elevation.high) return 8
            return 0
        }
    }

    // ==================== Transition ====================
    property QtObject transition: QtObject {
        readonly property int instant: 80
        readonly property int fast: 120
        readonly property int normal: 200
        readonly property int slow: 300
        readonly property int slowest: 500
        readonly property var ease: Easing.OutCubic
    }

    // ==================== Markdown ====================
    property QtObject markdown: QtObject {
        property QtObject heading: QtObject {
            readonly property int h1Size: root.font.sizeBig + 8
            readonly property int h2Size: root.font.sizeBig + 4
            readonly property int h3Size: root.font.sizeBig
            readonly property int h4Size: root.font.sizeNormal + 2
            readonly property int h5Size: root.font.sizeNormal
            readonly property int h6Size: root.font.sizeSmall
            readonly property bool bold: true
            readonly property color color: root.color.text
        }

        property QtObject paragraph: QtObject {
            readonly property int size: root.font.sizeNormal
            readonly property color color: root.color.text
        }

        property QtObject code: QtObject {
            readonly property color bgColor: isDark ? "#1a1a24" : "#f5f5f5"
            readonly property color textColor: isDark ? "#c0c4cc" : "#333333"
            readonly property string fontFamily: "Consolas, Monaco, monospace"
            readonly property int radius: 6
            readonly property int fontSize: root.font.sizeSmall
        }

        property QtObject quote: QtObject {
            readonly property color bgColor: isDark ? "#1a1a20" : "#f9f9fb"
            readonly property color borderColor: root.color.primary
            readonly property color textColor: isDark ? "#94949c" : "#666670"
        }

        property QtObject list: QtObject {
            readonly property color bulletColor: root.color.primary
            readonly property color textColor: root.color.text
        }

        property QtObject link: QtObject {
            readonly property color color: root.color.primary
            readonly property bool underline: true
        }

        property QtObject image: QtObject {
            readonly property int maxWidth: 400
            readonly property int borderRadius: 8
        }

        property QtObject table: QtObject {
            readonly property color bgColor: isDark ? "#1a1a22" : "#f0f0f5"
            readonly property color headerBgColor: isDark ? "#242430" : "#e4e5ec"
            readonly property color borderColor: root.color.divider
            readonly property color headerTextColor: root.color.text
            readonly property color cellTextColor: root.color.text
            readonly property color stripeColor: isDark ? "#1e1e26" : "#ededf2"
            readonly property int radius: 6
            readonly property int cellPadding: 8
        }
    }

    // ==================== Font ====================
    property QtObject font: QtObject {
        readonly property int sizeMini: 10
        readonly property int sizeSmall: 12
        readonly property int sizeMedium: 13
        property int sizeNormal: ThemeSettings.fontSize
        readonly property int sizeLarge: 15
        readonly property int sizeBig: 16

        readonly property string family: "Microsoft YaHei, Segoe UI, sans-serif"

        readonly property FontMetrics fontMetrics: FontMetrics {
            font.family: root.font.family
            font.pixelSize: root.font.sizeNormal
        }

        property QtObject lineHeight: QtObject {
            readonly property real tight: 1.2
            readonly property real normal: 1.5
            readonly property real loose: 1.7
        }
    }

    // ==================== Size ====================
    property QtObject size: QtObject {
        property int radius: ThemeSettings.cornerRadius
        readonly property int radiusSmall: 4
        readonly property int radiusLarge: 12
        readonly property int radiusXLarge: 16

        readonly property int sizeMini: 0
        readonly property int sizeSmall: 1
        readonly property int sizeNormal: 2
        readonly property int sizeLarge: 3

        readonly property int heightMini: 24
        readonly property int heightSmall: 28
        readonly property int heightNormal: 36
        readonly property int heightLarge: 44

        readonly property int padding: paddingNormal
        readonly property int paddingMini: 8
        readonly property int paddingSmall: 10
        readonly property int paddingNormal: 12
        readonly property int paddingLarge: 14

        readonly property int fontSizeMini: 10
        readonly property int fontSizeSmall: 12
        readonly property int fontSizeNormal: 14
        readonly property int fontSizeLarge: 16

        readonly property int boxSizeMini: 14
        readonly property int boxSizeSmall: 16
        readonly property int boxSizeNormal: 18
        readonly property int boxSizeLarge: 22

        readonly property int labelSpacingMini: 6
        readonly property int labelSpacingSmall: 7
        readonly property int labelSpacingNormal: 8
        readonly property int labelSpacingLarge: 10

        readonly property int switchHeightMini: 18
        readonly property int switchHeightSmall: 22
        readonly property int switchHeightNormal: 24
        readonly property int switchHeightLarge: 28

        readonly property int switchThumbMini: 14
        readonly property int switchThumbSmall: 18
        readonly property int switchThumbNormal: 20
        readonly property int switchThumbLarge: 24

        readonly property int tagHeightMini: 20
        readonly property int tagHeightSmall: 22
        readonly property int tagHeightNormal: 24
        readonly property int tagHeightLarge: 28

        readonly property int tagCloseBtnMini: 12
        readonly property int tagCloseBtnSmall: 13
        readonly property int tagCloseBtnNormal: 14
        readonly property int tagCloseBtnLarge: 16

        readonly property int badgeHeightMini: 16
        readonly property int badgeHeightSmall: 18
        readonly property int badgeHeightNormal: 20
        readonly property int badgeHeightLarge: 24

        readonly property int optionHeightMini: 24
        readonly property int optionHeightSmall: 28
        readonly property int optionHeightNormal: 32
        readonly property int optionHeightLarge: 40

        readonly property int btnPaddingMini: 12
        readonly property int btnPaddingSmall: 16
        readonly property int btnPaddingNormal: 20
        readonly property int btnPaddingLarge: 24
        readonly property int borderWidth: 1
        readonly property int borderWidthActive: 2
    }

    // ==================== Icon ====================
    property QtObject icon: QtObject {
        readonly property url minimize: isDark ? "../../res/icons/dark/minimize.png" : "../../res/icons/light/minimize.png"
        readonly property url maximize: isDark ? "../../res/icons/dark/maximize.png" : "../../res/icons/light/maximize.png"
        readonly property url maximizeRestore: isDark ? "../../res/icons/dark/maximize1.png" : "../../res/icons/light/maximize1.png"
        readonly property url close: isDark ? "../../res/icons/dark/close.png" : "../../res/icons/light/close.png"
        readonly property url themeDark: isDark ? "../../res/icons/dark/dark.png" : "../../res/icons/light/dark.png"
        readonly property url themeLight: isDark ? "../../res/icons/dark/light.png" : "../../res/icons/light/light.png"
        readonly property url theme: isDark ? themeDark : themeLight
        readonly property url settings: isDark ? "../../res/icons/dark/settings.png" : "../../res/icons/light/settings.png"
        readonly property url arrowUp: isDark ? "../../res/icons/dark/arrow-up.png" : "../../res/icons/light/arrow-up.png"
        readonly property url arrowDown: isDark ? "../../res/icons/dark/arrow-down.png" : "../../res/icons/light/arrow-down.png"
        readonly property url arrowRight: arrowDown
        readonly property url arrowLeft: arrowDown
    }

    // ==================== Animation (back-compat) ====================
    property QtObject animation: QtObject {
        readonly property int durationFast: 100
        readonly property int durationNormal: 150
        readonly property int durationSlow: 300
        readonly property int durationVerySlow: 500
        readonly property int stagger: 50
    }

    // ==================== Opacity (back-compat) ====================
    property QtObject opacity: QtObject {
        readonly property real shadow: isDark ? 0.3 : 0.12
    }
}