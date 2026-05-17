import QtQuick
import QtQuick.Effects
import EasyUI

Rectangle {
    id: root

    property bool checked: false
    property bool enabled: true
    property int size: EasyTheme.size.sizeNormal
    property string activeText: ""
    property string inactiveText: ""

    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.switchHeightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.switchHeightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.switchHeightLarge
        default:                        return EasyTheme.size.switchHeightNormal
        }
    }
    readonly property int computedThumbSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.switchThumbMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.switchThumbSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.switchThumbLarge
        default:                        return EasyTheme.size.switchThumbNormal
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

    readonly property bool __hasText: activeText.length > 0 || inactiveText.length > 0
    readonly property real __textPadding: computedHeight * 0.55
    readonly property real __thumbMargin: 3

    width: {
        if (!__hasText) return computedHeight * 1.8
        var maxText = Math.max(activeTextMetrics.width, inactiveTextMetrics.width)
        return Math.max(computedHeight * 1.8, maxText + computedHeight + __textPadding * 2)
    }
    height: computedHeight
    radius: height / 2

    // Track color
    color: {
        if (!root.enabled) return EasyTheme.color.divider
        return root.checked ? EasyTheme.color.primary : EasyTheme.color.divider
    }
    opacity: root.enabled ? 1.0 : 0.45

    Behavior on color { ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
    Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }

    TextMetrics { id: activeTextMetrics; font.pixelSize: computedFontSize; text: root.activeText }
    TextMetrics { id: inactiveTextMetrics; font.pixelSize: computedFontSize; text: root.inactiveText }

    Text {
        text: root.activeText
        font.pixelSize: computedFontSize
        color: "white"
        opacity: root.checked ? 1 : 0
        anchors {
            left: parent.left
            leftMargin: __textPadding
            verticalCenter: parent.verticalCenter
        }
        Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }
    }

    Text {
        text: root.inactiveText
        font.pixelSize: computedFontSize
        color: EasyTheme.color.placeholder
        opacity: !root.checked ? 1 : 0
        anchors {
            right: parent.right
            rightMargin: __textPadding
            verticalCenter: parent.verticalCenter
        }
        Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }
    }

    // Thumb with shadow
    Rectangle {
        id: thumb
        width: computedThumbSize
        height: computedThumbSize
        radius: height / 2
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? (parent.width - width - __thumbMargin) : __thumbMargin

        Behavior on x {
            NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.15
            shadowBlur: 0.5
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 1
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }

    signal toggled(bool checked)
}
