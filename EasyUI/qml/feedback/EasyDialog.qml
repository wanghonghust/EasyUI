import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

/**
 * EasyDialog —— 通用卡片式对话框
 *
 * 属性说明：
 *   headerTitle    {string}  标题文字，默认 ""（避开 Dialog 自带的 FINAL title 属性）
 *   titleIcon      {string}  标题左侧图标（EasyIcon.material 常量），默认 EasyIcon.material.info
 *   confirmText    {string}  确认按钮文字，默认 "确认"
 *   cancelText     {string}  取消按钮文字，默认 "取消"，空字符串时隐藏取消按钮
 *   dialogWidth    {real}    对话框宽度，默认 440
 *   dialogHeight   {real}    对话框高度，默认 -1（自动）
 *   maxHeight      {real}    最大总高度，默认 -1（不限制），超过时内容区滚动
 *   contentMaxH    {real}    内容区最大高度（供旧版兼容），默认 480
 *   contentMinH    {real}    内容区最小高度，默认 60
 *   accentStart    {color}   渐变起始色，默认 #6366f1
 *   accentEnd      {color}   渐变结束色，默认 #818cf8
 *   showClose      {bool}    是否显示右上角关闭按钮，默认 true
 *
 * 插槽：
 *   default         放入任意子元素作为内容，将显示在可滚动的内容区域内
 *
 * 信号：
 *   accepted()     点击确认按钮
 *   rejected()     点击取消 / 关闭按钮
 */
Dialog {
    id: root

    property string headerTitle: ""
    property string titleIcon:   EasyIcon.material.info
    property string confirmText: "确认"
    property string cancelText:  "取消"
    property real   dialogWidth: 440
    property real   dialogHeight: -1
    property real   maxHeight: -1
    property real   contentMinH: 60
    property color  accentStart: "#6366f1"
    property color  accentEnd:   "#818cf8"
    property bool   showClose:   true

    default property alias content: _innerCol.data

    modal:       true
    dim:         true
    closePolicy: Popup.CloseOnEscape
    parent:      Overlay.overlay
    width:       dialogWidth

    x: Math.round(((parent ? parent.width : 0) - width) / 2)
    y: Math.round(((parent ? parent.height : 0) - height) / 2)

    readonly property real _effectiveMaxH: {
        if (root.maxHeight > 0) return root.maxHeight
        if (root.maxHeight === 0) return 99999
        return parent ? parent.height * 0.8 : 560
    }

    readonly property real _autoHeight: {
        var footerH = root.confirmText.length > 0 || root.cancelText.length > 0 ? 64 : 0
        var contentH = _innerCol.implicitHeight
        var minContent = root.contentMinH + _innerCol.topPadding + _innerCol.bottomPadding
        contentH = Math.max(contentH, minContent)
        var total = 60 + contentH + footerH
        return Math.min(total, _effectiveMaxH)
    }

    height: dialogHeight > 0 ? dialogHeight : _autoHeight

    background: Rectangle {
        color:        EasyTheme.color.card
        radius:       EasyTheme.size.radiusXLarge
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: EasyTheme.color.shadow
            shadowOpacity: EasyTheme.elevation.shadowOpacity(EasyTheme.elevation.medium)
            shadowBlur: 0.5
            shadowHorizontalOffset: 0
            shadowVerticalOffset: EasyTheme.elevation.shadowOffsetY(EasyTheme.elevation.medium)
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: EasyTheme.transition.slow; easing.type: EasyTheme.transition.ease }
        NumberAnimation { property: "scale"; from: 0.92; to: 1; duration: EasyTheme.transition.slow; easing.type: EasyTheme.transition.ease }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: EasyTheme.transition.normal; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1; to: 0.92; duration: EasyTheme.transition.normal; easing.type: Easing.InCubic }
    }

    header: Rectangle {
        width:  parent ? parent.width : root.dialogWidth
        height: 60
        color:  "transparent"
        radius: EasyTheme.size.radiusXLarge

        Rectangle {
            id: _iconBadge
            anchors.left:           parent.left
            anchors.leftMargin:     20
            anchors.verticalCenter: parent.verticalCenter
            width:  36
            height: 36
            radius: EasyTheme.size.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: EasyTheme.color.primary }
                GradientStop { position: 1.0; color: EasyTheme.color.primaryLight }
            }
            EasyIconFont {
                anchors.centerIn: parent
                icon: root.titleIcon
                iconSize: 18
                color: "white"
            }
        }

        Label {
            anchors.left:           _iconBadge.right
            anchors.leftMargin:     12
            anchors.verticalCenter: parent.verticalCenter
            text:           root.headerTitle
            font.pixelSize: 16
            font.bold:      true
            font.family:    EasyTheme.font.family
            color:          EasyTheme.color.text
        }

        Rectangle {
            visible:             root.showClose
            anchors.right:          parent.right
            anchors.rightMargin:    16
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            radius: 15
            color: _closeArea.containsMouse ? EasyTheme.color.buttonHover : "transparent"

            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }

            EasyIconFont {
                anchors.centerIn: parent
                icon: EasyIcon.material.close
                iconSize: 16
                color: EasyTheme.color.placeholder
            }

            MouseArea {
                id: _closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.reject()
            }
        }
    }

    contentItem: ScrollView {
        id: _flick
        clip: true
        contentWidth: availableWidth
        ScrollBar.vertical: EasyScrollBar { }
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            id: _innerCol
            width: _flick.availableWidth - 30
            x: 15
            topPadding: 16
            bottomPadding: 16
            spacing: 6
        }
    }

    footer: Rectangle {
        id: footer_
        visible: root.confirmText.length > 0 || root.cancelText.length > 0
        width:  parent ? parent.width : root.dialogWidth
        height: footer_.visible ? 64 : 0
        color:  "transparent"
        radius: EasyTheme.size.radiusXLarge

        Row {
            anchors.right:          parent.right
            anchors.margins:    20
            anchors.verticalCenter: parent.verticalCenter
            spacing: EasyTheme.size.paddingNormal

            EasyButton {
                visible: root.cancelText.length > 0
                text:    root.cancelText
                primary: false
                onClicked: root.reject()
            }

            EasyButton {
                visible: root.confirmText.length > 0
                text:    root.confirmText
                primary: true
                onClicked: root.accept()
            }
        }
    }
}