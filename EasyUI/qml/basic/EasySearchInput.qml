import QtQuick
import QtQuick.Controls.Basic
import EasyUI

/**
 * EasySearchInput —— 搜索输入框
 *
 * 属性：
 *   text           {string}      搜索内容
 *   placeholder    {string}      占位提示文字，默认 "搜索"
 *   width          {real}        宽度，默认 240
 *   size           {int}         控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *   enabled        {bool}        是否可用，默认 true
 *   clearable      {bool}        是否显示清除按钮，默认 true
 *
 * 信号：
 *   search(string)            搜索触发（回车或点击搜索图标）
 *   cleared()                 清除触发
 */
Rectangle {
    id: root

    property alias text: searchInput.text
    property string placeholder: "搜索"
    property int size: EasyTheme.size.sizeNormal
    property bool enabled: true
    property bool clearable: true

    // 根据 size 计算控件尺寸
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

    width: 240
    height: computedHeight
    radius: EasyTheme.size.radius
    color: EasyTheme.color.card
    border.color: searchInput.activeFocus ? EasyTheme.color.primary : (_hover.hovered ? Qt.darker(EasyTheme.color.border, 1.12) : EasyTheme.color.border)
    border.width: searchInput.activeFocus ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth

    HoverHandler { id: _hover; enabled: root.enabled }

    Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: computedPadding
        anchors.rightMargin: computedPadding
        spacing: 8

        // 搜索图标
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "🔍"
            font.pixelSize: computedFontSize
            visible: searchInput.text === "" || !clearable
            opacity: 0.6
        }

        // 输入框
        TextInput {
            id: searchInput
            anchors.verticalCenter: parent.verticalCenter
            width: root.width - 68
            height: parent.height
            verticalAlignment: TextInput.AlignVCenter
            font.pixelSize: computedFontSize
            color: root.enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
            enabled: root.enabled
            selectByMouse: true

            // 占位文字
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.placeholder
                font.pixelSize: computedFontSize
                color: EasyTheme.color.placeholder
                visible: searchInput.text === "" && !searchInput.activeFocus
            }

            onAccepted: root.search(searchInput.text)

            MouseArea{
                anchors.fill: parent
                cursorShape:  Qt.IBeamCursor
                enabled: false
            }

        }

        // 清除按钮
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            radius: 10
            color: "transparent"
            visible: clearable && searchInput.text !== ""
            opacity: 0.6

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    searchInput.text = ""
                    root.cleared()
                }
            }

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 10
                color: EasyTheme.color.secondary
            }
        }
    }

    // 禁用时显示禁止光标（正常状态下 TextInput 自带 IBeam 光标）
    MouseArea {
        anchors.fill: parent
        visible: !root.enabled
        enabled: !root.enabled
        cursorShape:  Qt.ForbiddenCursor
    }

    signal search(string text)
    signal cleared()
}
