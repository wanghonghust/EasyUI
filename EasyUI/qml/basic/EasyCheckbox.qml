import QtQuick
import EasyUI

Item {
    id: root

    property bool checked: false
    property string text: ""
    property int size: EasyTheme.size.sizeNormal
    property bool enabled: true

    readonly property int computedBoxSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.boxSizeMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.boxSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.boxSizeLarge
        default:                        return EasyTheme.size.boxSizeNormal
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
    readonly property int computedSpacing: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.labelSpacingMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.labelSpacingSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.labelSpacingLarge
        default:                        return EasyTheme.size.labelSpacingNormal
        }
    }

    implicitWidth: box.width + (root.text.length > 0 ? computedSpacing + label.implicitWidth : 0)
    implicitHeight: Math.max(box.width, label.implicitHeight)
    opacity: root.enabled ? 1.0 : 0.45

    Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }

    Rectangle {
        id: box
        width: computedBoxSize
        height: computedBoxSize
        radius: EasyTheme.size.radiusSmall
        color: root.checked ? EasyTheme.color.primary : (hoverArea.containsMouse ? EasyTheme.color.hover : "transparent")
        border.color: root.checked ? EasyTheme.color.primary : (hoverArea.containsMouse ? EasyTheme.color.primary : EasyTheme.color.border)
        border.width: root.checked ? 0 : EasyTheme.size.borderWidth

        Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
        Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.fast } }

        Text {
            visible: root.checked
            anchors.centerIn: parent
            text: "✓"
            font.pixelSize: computedBoxSize * 0.65
            font.bold: true
            color: "white"
        }
    }

    Text {
        id: label
        visible: root.text.length > 0
        text: root.text
        font.pixelSize: computedFontSize
        font.family: EasyTheme.font.family
        color: root.enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
        Behavior on color { ColorAnimation { duration: EasyTheme.transition.normal } }
        x: box.width + computedSpacing
        y: (box.height - height) / 2
    }

    MouseArea {
        id: hoverArea
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
