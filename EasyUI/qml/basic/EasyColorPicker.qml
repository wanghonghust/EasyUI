import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

/**
 * EasyColorPicker —— 颜色选择器组件（支持透明度）
 *
 * 属性：
 *   currentColor    {string}    当前颜色值（#AARRGGBB），默认 "#FF528bff"
 *   placeholder     {string}    占位文字，默认 "选择颜色"
 *   enabled         {bool}      是否可用，默认 true
 *   clearable       {bool}      是否可清除，默认 false
 *   size            {int}       控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *   presetColors    {var}       预设颜色列表，默认内置12色
 *
 * 信号：
 *   colorSelected(string color)   颜色选中时触发
 *   cleared()                      清除时触发
 */
Rectangle {
    id: root

    property string currentColor: "#FF4f6ef7"
    property string placeholder: "选择颜色"
    property bool enabled: true
    property bool clearable: false
    property int size: EasyTheme.size.sizeNormal
    property var presetColors: [
        "#FFef4444", "#FFf97316", "#FFf59e0b", "#FF84cc16",
        "#FF22c55e", "#FF14b8a6", "#FF06b6d4", "#FF3b82f6",
        "#FF6366f1", "#FF8b5cf6", "#FFd946ef", "#FFec4899"
    ]

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

    signal colorSelected(string color)
    signal cleared()

    width: 220
    height: computedHeight
    radius: EasyTheme.size.radius
    color: root.enabled ? EasyTheme.color.card : EasyTheme.color.hover
    border.color: colorPopup.visible ? EasyTheme.color.primary : (_hover.hovered ? Qt.darker(EasyTheme.color.border, 1.12) : EasyTheme.color.border)
    border.width: colorPopup.visible ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth
    opacity: root.enabled ? 1.0 : 0.45

    HoverHandler { id: _hover; enabled: root.enabled }

    Behavior on border.color {
        ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease }
    }
    Behavior on border.width {
        NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease }
    }
    Behavior on opacity {
        NumberAnimation { duration: EasyTheme.transition.fast }
    }
    Behavior on color {
        ColorAnimation { duration: EasyTheme.transition.fast }
    }

    property int panelWidth: 360

    function hexToRgb(hex) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            a: parseInt(result[1], 16),
            r: parseInt(result[2], 16),
            g: parseInt(result[3], 16),
            b: parseInt(result[4], 16)
        } : { a: 255, r: 0, g: 0, b: 0 }
    }

    function rgbToHsv(r, g, b) {
        r /= 255; g /= 255; b /= 255;
        var max = Math.max(r, g, b), min = Math.min(r, g, b);
        var h, s, v = max;
        var d = max - min;
        s = max === 0 ? 0 : d / max;
        if (max === min) {
            h = 0;
        } else {
            switch (max) {
            case r: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
            }
            h /= 6;
        }
        return { h: h, s: s, v: v }
    }

    function hsvToRgb(h, s, v) {
        var r, g, b;
        var i = Math.floor(h * 6);
        var f = h * 6 - i;
        var p = v * (1 - s);
        var q = v * (1 - f * s);
        var t = v * (1 - (1 - f) * s);
        switch (i % 6) {
        case 0: r = v; g = t; b = p; break;
        case 1: r = q; g = v; b = p; break;
        case 2: r = p; g = v; b = t; break;
        case 3: r = p; g = q; b = v; break;
        case 4: r = t; g = p; b = v; break;
        case 5: r = v; g = p; b = q; break;
        }
        return { r: Math.round(r * 255), g: Math.round(g * 255), b: Math.round(b * 255) }
    }

    function rgb2hex(r, g, b, a) {
        return "#" + [a, r, g, b].map(function (x) {
            return x.toString(16).padStart(2, '0');
        }).join('');
    }

    function isValidColor(color) {
        return /^#[0-9A-Fa-f]{8}$/.test(color);
    }

    Text {
        id: colorText
        anchors.left: parent.left
        anchors.leftMargin: root.computedPadding
        anchors.right: colorPreview.left
        anchors.rightMargin: root.computedPadding
        anchors.verticalCenter: parent.verticalCenter
        text: root.currentColor
        font.pixelSize: root.computedFontSize
        font.family: EasyTheme.font.family
        color: root.currentColor ? EasyTheme.color.text : EasyTheme.color.placeholder
        Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
        elide: Text.ElideRight
    }

    Rectangle {
        id: colorPreview
        anchors.right: clearBtn.visible ? clearBtn.left : dropIcon.left
        anchors.rightMargin: root.computedPadding
        anchors.verticalCenter: parent.verticalCenter
        width: root.computedHeight * 0.44
        height: width
        radius: width / 2
        border.color: EasyTheme.color.border
        border.width: EasyTheme.size.borderWidth

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            clip: true
            color: root.currentColor
        }
    }

    Item {
        id: clearBtn
        visible: root.clearable && root.enabled && root.currentColor !== ""
        anchors.right: dropIcon.left
        anchors.rightMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        width: clearIcon.iconSize + 8
        height: width
        z: 1

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: clearBtnHover.hovered ? EasyTheme.color.hover : "transparent"
            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
        }

        EasyIconFont {
            id: clearIcon
            anchors.centerIn: parent
            icon: EasyIcon.material.close
            iconSize: root.computedFontSize
            color: clearBtnHover.hovered ? EasyTheme.color.text : EasyTheme.color.placeholder
            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
        }

        HoverHandler { id: clearBtnHover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.currentColor = ""
                root.cleared()
            }
        }
    }

    EasyIconFont {
        id: dropIcon
        anchors.right: parent.right
        anchors.rightMargin: root.computedPadding
        anchors.verticalCenter: parent.verticalCenter
        icon: colorPopup.visible ? EasyIcon.material.keyboard_arrow_up : EasyIcon.material.keyboard_arrow_down
        iconSize: 20
        color: EasyTheme.color.placeholder
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            if (colorPopup.visible) {
                colorPopup.close()
            } else {
                colorPopup.open()
            }
        }
    }

    Popup {
        id: colorPopup
        y: root.height + 4
        width: panelWidth
        height: popupContent.implicitHeight + EasyTheme.size.paddingLarge * 2
        padding: 0
        margins: 0
        modal: true
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        background: Rectangle {
            radius: EasyTheme.size.radiusLarge
            color: EasyTheme.color.card
            border.width: EasyTheme.size.borderWidth
            border.color: EasyTheme.color.divider

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: EasyTheme.color.shadow
                shadowOpacity: EasyTheme.elevation.shadowOpacity(EasyTheme.elevation.medium)
                shadowBlur: 0.4
                shadowHorizontalOffset: 0
                shadowVerticalOffset: EasyTheme.elevation.shadowOffsetY(EasyTheme.elevation.medium)
            }
        }

        ColumnLayout {
            id: popupContent
            anchors.fill: parent
            anchors.margins: EasyTheme.size.paddingLarge
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                EasyInput {
                    id: hexInput
                    Layout.fillWidth: true
                    text: root.currentColor
                    placeholder: "#AARRGGBB"
                    onAccepted: {
                        var color = text.trim().toUpperCase()
                        if (isValidColor(color)) {
                            root.currentColor = color
                            root.colorSelected(color)
                            colorPopup.close()
                        } else {
                            text = root.currentColor
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: EasyTheme.size.radiusSmall
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        radius: EasyTheme.size.radiusSmall
                        color: root.currentColor
                        border.color: EasyTheme.color.border
                        border.width: EasyTheme.size.borderWidth
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Rectangle {
                    id: satBrightArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 160
                    radius: EasyTheme.size.radiusSmall
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: {
                            var rgb = hsvToRgb(currentHue, 1.0, 1.0)
                            Qt.rgba(rgb.r / 255, rgb.g / 255, rgb.b / 255, 1.0)
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#ffffff" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: "#000000" }
                        }
                    }

                    Rectangle {
                        id: selector
                        width: 16
                        height: 16
                        radius: 8
                        border.color: "white"
                        border.width: 2
                        x: satBrightArea.width * satValue - 8
                        y: satBrightArea.height * (1 - brightValue) - 8

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: parent.radius - 2
                            color: "transparent"
                            border.color: "#88000000"
                            border.width: 1
                        }
                    }

                    MouseArea {
                        id: selectorArea
                        anchors.fill: parent
                        drag.target: selector
                        drag.axis: Drag.XAndYAxis
                        drag.minimumX: -selector.width / 2
                        drag.maximumX: parent.width - selector.width / 2
                        drag.minimumY: -selector.height / 2
                        drag.maximumY: parent.height - selector.height / 2
                        drag.filterChildren: true

                        onPressed: {
                            var newX = Math.max(0, Math.min(mouseX, parent.width))
                            var newY = Math.max(0, Math.min(mouseY, parent.height))
                            satValue = newX / parent.width
                            brightValue = 1 - newY / parent.height
                            updateColorFromSb()
                        }

                        onPositionChanged: {
                            if (drag.active) {
                                var sx = (selector.x + selector.width / 2) / parent.width
                                var sy = 1 - (selector.y + selector.height / 2) / parent.height
                                satValue = Math.max(0, Math.min(1, sx))
                                brightValue = Math.max(0, Math.min(1, sy))
                                updateColorFromSb()
                            }
                        }
                    }
                }

                Rectangle {
                    id: hueSlider
                    Layout.preferredWidth: 14
                    Layout.fillHeight: true
                    radius: EasyTheme.size.radiusSmall
                    clip: true
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "#ff0000" }
                        GradientStop { position: 0.167; color: "#ffff00" }
                        GradientStop { position: 0.333; color: "#00ff00" }
                        GradientStop { position: 0.5; color: "#00ffff" }
                        GradientStop { position: 0.667; color: "#0000ff" }
                        GradientStop { position: 0.833; color: "#ff00ff" }
                        GradientStop { position: 1.0; color: "#ff0000" }
                    }
                    border.color: EasyTheme.color.border
                    border.width: EasyTheme.size.borderWidth

                    MouseArea {
                        id: hueClickArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onPressed: {
                            var h = Math.max(0, Math.min(1, mouseY / parent.height))
                            currentHue = h
                            updateColorFromSb()
                        }
                    }

                    Rectangle {
                        id: hueIndicator
                        width: parent.width + 6
                        height: 6
                        x: -3
                        radius: 3
                        color: "white"
                        border.color: "#333333"
                        border.width: EasyTheme.size.borderWidth
                        y: hueSlider.height * currentHue - 3

                        MouseArea {
                            id: hueMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            drag.target: parent
                            drag.axis: Drag.YAxis
                            drag.minimumY: -3
                            drag.maximumY: hueSlider.height - 3

                            onPositionChanged: {
                                if (drag.active) {
                                    var h = (hueIndicator.y + 3) / hueSlider.height
                                    currentHue = Math.max(0, Math.min(1, h))
                                    updateColorFromSb()
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "透明度"
                    font.pixelSize: EasyTheme.font.sizeSmall
                    font.family: EasyTheme.font.family
                    color: EasyTheme.color.secondary
                    Layout.preferredWidth: 40
                }

                Item {
                    id: alphaSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 2
                        anchors.bottomMargin: 2
                        radius: 7
                        clip: true

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                var cs = 7
                                for (var x = 0; x < width; x += cs * 2) {
                                    for (var y = 0; y < height; y += cs * 2) {
                                        ctx.fillStyle = "#e0e0e0"
                                        ctx.fillRect(x + cs, y, cs, cs)
                                        ctx.fillRect(x, y + cs, cs, cs)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: Qt.hsla(currentHue, satValue, brightValue, 1.0) }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: {
                                var a = Math.max(0, Math.min(1, mouseX / parent.width))
                                currentAlpha = a
                                updateColorFromSb()
                            }
                        }
                    }

                    Rectangle {
                        id: alphaIndicator
                        width: 8
                        height: 14
                        y: 2
                        radius: 2
                        color: "white"
                        border.color: "#333333"
                        border.width: 2
                        x: Math.max(-4, Math.min(alphaSlider.width - 4, (alphaSlider.width - 8) * currentAlpha))

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            drag.target: alphaIndicator
                            drag.axis: Drag.XAxis
                            drag.minimumX: -4
                            drag.maximumX: alphaSlider.width - 4
                            preventStealing: true

                            onPositionChanged: {
                                if (drag.active) {
                                    var a = (alphaIndicator.x + 4) / alphaSlider.width
                                    currentAlpha = Math.max(0, Math.min(1, a))
                                    updateColorFromSb()
                                }
                            }
                        }
                    }
                }

                Text {
                    text: Math.round(currentAlpha * 100) + "%"
                    font.pixelSize: EasyTheme.font.sizeSmall
                    font.family: EasyTheme.font.family
                    color: EasyTheme.color.secondary
                    Layout.preferredWidth: 36
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: root.presetColors

                    Rectangle {
                        required property string modelData
                        width: 20
                        height: 20
                        radius: 4
                        color: modelData
                        border.color: modelData === root.currentColor ? EasyTheme.color.primary : EasyTheme.color.border
                        border.width: modelData === root.currentColor ? 2 : 1

                        Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.fast } }
                        Behavior on border.width { NumberAnimation { duration: EasyTheme.transition.fast } }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                root.currentColor = modelData
                                var rgba = hexToRgb(modelData)
                                currentAlpha = rgba.a / 255
                                currentR = rgba.r
                                currentG = rgba.g
                                currentB = rgba.b
                                var hsv = rgbToHsv(rgba.r, rgba.g, rgba.b)
                                currentHue = hsv.h
                                satValue = hsv.s
                                brightValue = hsv.v
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Item { Layout.fillWidth: true }

                EasyButton {
                    text: "取消"
                    primary: false
                    size: EasyTheme.size.sizeSmall
                    onClicked: colorPopup.close()
                }

                EasyButton {
                    text: "确定"
                    primary: true
                    size: EasyTheme.size.sizeSmall
                    onClicked: {
                        root.colorSelected(root.currentColor)
                        colorPopup.close()
                    }
                }
            }
        }
    }

    property real currentHue: 0.6
    property real satValue: 0.8
    property real brightValue: 0.6
    property real currentAlpha: 1.0
    property int currentR: 82
    property int currentG: 139
    property int currentB: 255

    Component.onCompleted: {
        var rgba = hexToRgb(currentColor)
        currentAlpha = rgba.a / 255
        currentR = rgba.r
        currentG = rgba.g
        currentB = rgba.b
        var hsv = rgbToHsv(rgba.r, rgba.g, rgba.b)
        currentHue = hsv.h
        satValue = hsv.s
        brightValue = hsv.v
    }

    function updateColorFromSb() {
        var rgb = hsvToRgb(currentHue, satValue, brightValue)
        currentR = rgb.r
        currentG = rgb.g
        currentB = rgb.b
        root.currentColor = rgb2hex(rgb.r, rgb.g, rgb.b, Math.round(currentAlpha * 255))
    }

    onCurrentColorChanged: {
        if (!colorPopup.visible) {
            var rgba = hexToRgb(currentColor)
            currentAlpha = rgba.a / 255
            currentR = rgba.r
            currentG = rgba.g
            currentB = rgba.b
            var hsv = rgbToHsv(rgba.r, rgba.g, rgba.b)
            currentHue = hsv.h
            satValue = hsv.s
            brightValue = hsv.v
        }
    }
}
