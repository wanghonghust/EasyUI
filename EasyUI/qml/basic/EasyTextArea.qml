import QtQuick
import QtQuick.Controls.Basic
import EasyUI

Rectangle {
    id: root

    property alias text: textArea.text
    property string placeholder: ""
    property bool enabled: true
    property bool readOnly: false
    property int maxLength: -1
    property bool showCount: false
    property int size: EasyTheme.size.sizeNormal
    property bool clearable: false

    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge
        default:                        return EasyTheme.size.fontSizeNormal
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

    implicitHeight: 120
    implicitWidth: 260
    radius: EasyTheme.size.radius
    color: EasyTheme.color.card
    border.color: {
        if (textArea.activeFocus) return EasyTheme.color.primary
        if (_hover.hovered) return Qt.darker(EasyTheme.color.border, 1.12)
        return EasyTheme.color.border
    }
    border.width: textArea.activeFocus ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth
    opacity: root.enabled ? 1.0 : 0.45

    HoverHandler { id: _hover; enabled: root.enabled }

    Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
    Behavior on border.width { NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
    Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }

    ScrollView {
        id: scrollView
        anchors {
            left: parent.left
            right: clearBtn.visible ? clearBtn.left : parent.right
            top: parent.top
            bottom: parent.bottom
            margins: computedPadding
        }

        ScrollBar.vertical: EasyScrollBar { }

        TextArea {
            id: textArea
            font.pixelSize: root.computedFontSize
            font.family: EasyTheme.font.family
            color: root.enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
            wrapMode: TextArea.Wrap
            readOnly: root.readOnly
            enabled: root.enabled
            selectByMouse: true
            selectionColor: EasyTheme.color.selection
            selectedTextColor: EasyTheme.color.text
            placeholderText: root.placeholder
            placeholderTextColor: EasyTheme.color.placeholder
            padding: 0

            onEditingFinished: root.accepted()
            onTextChanged: {
                if (root.maxLength > 0 && length > root.maxLength)
                    remove(root.maxLength, length)
            }
        }
    }

    // Clear button
    EasyButton {
        id: clearBtn
        visible: root.clearable && root.enabled && textArea.length > 0 && !root.readOnly
        icon: EasyIcon.material.close
        round: true
        primary: false
        size: root.size
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 6
        onClicked: textArea.clear()
    }

    // Character count
    Text {
        visible: showCount && maxLength > 0
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 6
        font.pixelSize: 11
        color: EasyTheme.color.secondary
        text: textArea.length + " / " + root.maxLength
    }

    // Disabled cursor
    MouseArea {
        anchors.fill: parent
        visible: !root.enabled
        enabled: !root.enabled
        cursorShape: Qt.ForbiddenCursor
    }

    signal accepted()
}
