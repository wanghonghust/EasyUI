import QtQuick
import EasyUI

Item {
    id: root

    property bool checked: false
    property string text: ""
    property var value: null
    property var group: null
    property int size: EasyTheme.size.sizeNormal
    property bool enabled: true

    readonly property int computedCircleSize: {
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

    implicitWidth: circle.width + (root.text.length > 0 ? computedSpacing + label.implicitWidth : 0)
    implicitHeight: Math.max(circle.height, label.implicitHeight)
    opacity: root.enabled ? 1.0 : 0.45

    Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }

    Component.onCompleted: {
        if (root.group) root.group.registerRadio(root)
    }
    Component.onDestruction: {
        if (root.group) root.group.unregisterRadio(root)
    }

    Rectangle {
        id: circle
        width: computedCircleSize
        height: computedCircleSize
        radius: width / 2
        color: hoverArea.containsMouse && !root.checked ? EasyTheme.color.hover : "transparent"
        border.color: root.checked ? EasyTheme.color.primary : (hoverArea.containsMouse ? EasyTheme.color.primary : EasyTheme.color.border)
        border.width: root.checked ? computedCircleSize * 0.28 : EasyTheme.size.borderWidth

        Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
        Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.fast } }
        Behavior on border.width { NumberAnimation { duration: EasyTheme.transition.fast } }

        Rectangle {
            id: dot
            visible: root.checked
            anchors.centerIn: parent
            width: Math.round(parent.width * 0.4)
            height: width
            radius: width / 2
            color: EasyTheme.color.primary
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
        x: circle.width + computedSpacing
        y: (circle.height - height) / 2
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: function(mouse) {
            if (root.group) {
                root.group.onRadioClicked(root)
            } else {
                root.checked = !root.checked
            }
            root.clicked()
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
            event.accepted = true
            if (root.group) root.group.onRadioClicked(root)
            else root.checked = !root.checked
            root.clicked()
        }
    }

    signal clicked()
}
