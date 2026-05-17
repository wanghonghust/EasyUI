import QtQuick
import QtQuick.Controls.Basic
import EasyUI

Rectangle {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property string prefixIcon: ""
    property string suffixIcon: ""
    property int size: EasyTheme.size.sizeNormal
    property bool enabled: true
    property bool password: false
    property bool readOnly: false
    property bool clearable: false
    property int maxLength: -1

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
    readonly property int iconSize: computedFontSize + 2

    width: 220
    height: computedHeight
    radius: EasyTheme.size.radius
    color: root.enabled ? EasyTheme.color.card : EasyTheme.color.hover
    border.color: {
        if (input.activeFocus) return EasyTheme.color.primary
        if (_hoverArea.hovered) return Qt.darker(EasyTheme.color.border, 1.12)
        return EasyTheme.color.border
    }
    border.width: input.activeFocus ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth
    opacity: root.enabled ? 1.0 : 0.45

    Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
    Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
    Behavior on border.width { NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
    Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }

    // Hover tracker
    HoverHandler {
        id: _hoverArea
        enabled: root.enabled
    }

    // Prefix icon
    EasyIconFont {
        visible: root.prefixIcon !== ""
        icon: root.prefixIcon
        iconSize: root.iconSize
        color: EasyTheme.color.placeholder
        anchors {
            left: parent.left
            leftMargin: computedPadding
            verticalCenter: parent.verticalCenter
        }
    }

    TextInput {
        id: input
        anchors {
            left: root.prefixIcon !== "" ? prefixSpacer.right : parent.left
            leftMargin: root.prefixIcon !== "" ? 0 : computedPadding
            right: clearBtn.visible ? clearBtn.left : (root.suffixIcon !== "" ? suffixIconArea.left : parent.right)
            rightMargin: computedPadding
            top: parent.top
            bottom: parent.bottom
        }
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        font.family: EasyTheme.font.family
        font.pixelSize: computedFontSize
        color: root.enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
        Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
        enabled: root.enabled && !root.readOnly
        readOnly: root.readOnly
        echoMode: root.password ? TextInput.Password : TextInput.Normal
        maximumLength: root.maxLength > 0 ? root.maxLength : 32767
        selectionColor: EasyTheme.color.selection
        selectedTextColor: EasyTheme.color.text

        onAccepted: root.accepted()
        onTextChanged: root.textEdited(text)
    }

    Item {
        id: prefixSpacer
        visible: root.prefixIcon !== ""
        width: root.prefixIcon !== "" ? iconSize + 6 : 0
        height: 1
        anchors {
            left: parent.left
            leftMargin: computedPadding
            verticalCenter: parent.verticalCenter
        }
    }

    // Suffix icon
    EasyIconFont {
        id: suffixIconArea
        visible: root.suffixIcon !== ""
        icon: root.suffixIcon
        iconSize: root.iconSize
        color: EasyTheme.color.placeholder
        anchors {
            right: clearBtn.visible ? clearBtn.left : parent.right
            rightMargin: computedPadding
            verticalCenter: parent.verticalCenter
        }
    }

    // Clear button — only visible on hover
    Rectangle {
        id: clearBtn
        visible: root.clearable && root.enabled && input.text.length > 0 && _hoverArea.hovered && !root.readOnly
        width: iconSize
        height: iconSize
        radius: width / 2
        color: clearMouse.containsMouse ? EasyTheme.color.hover : "transparent"
        anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
        Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }

        EasyIconFont {
            anchors.centerIn: parent
            icon: EasyIcon.material.close
            iconSize: root.computedFontSize
            color: EasyTheme.color.placeholder
        }

        MouseArea {
            id: clearMouse
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: input.clear()
        }
    }

    Text {
        visible: input.text.length === 0 && !input.activeFocus
        anchors {
            left: root.prefixIcon !== "" ? prefixSpacer.right : parent.left
            leftMargin: root.prefixIcon !== "" ? 0 : computedPadding
            right: clearBtn.visible ? clearBtn.left : (root.suffixIcon !== "" ? suffixIconArea.left : parent.right)
            rightMargin: computedPadding
            verticalCenter: parent.verticalCenter
        }
        text: root.placeholder
        font.family: EasyTheme.font.family
        font.pixelSize: computedFontSize
        color: EasyTheme.color.placeholder
        elide: Text.ElideRight
        clip: true
    }

    signal accepted()
    signal textEdited(string text)
}
