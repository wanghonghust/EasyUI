import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Effects
import EasyUI

/**
 * EasyDrawer —— 抽屉面板组件
 *
 * 属性：
 *   drawerWidth    {real}    抽屉宽度，默认 320
 *   drawerHeight   {real}    抽屉高度，默认 -1（自动填满父容器）
 *   headerTitle    {string}  标题文字，默认 ""
 *   titleIcon      {string}  标题图标（EasyIcon.material 常量），默认 EasyIcon.material.info
 *   showClose      {bool}    是否显示关闭按钮，默认 true
 *   showHeader     {bool}    是否显示标题栏，默认 true
 *   drawerEdge     {Edge}    弹出边，默认 Qt.RightEdge
 *   accentStart    {color}   强调色起始，默认 #6366f1
 *   accentEnd      {color}   强调色结束，默认 #818cf8
 *
 * 插槽：
 *   default         放入任意子元素作为内容
 *
 * 信号：
 *   opened()        抽屉完全打开
 *   closed()        抽屉完全关闭
 */
Drawer {
    id: drawer

    // ── 公开属性 ──────────────────────────────────────────────
    property real   drawerWidth:  320
    property real   drawerHeight: -1
    property string headerTitle:  ""
    property string titleIcon:    EasyIcon.material.info
    property bool   showClose:    true
    property bool   showHeader:   true
    property int   drawerEdge:   Qt.RightEdge
    property color  accentStart:  "#6366f1"
    property color  accentEnd:    "#818cf8"

    // enabled 继承自 Popup，FINAL 不可覆盖

    // 内容插槽
    default property alias content: _contentCol.data

    // ── 基础设置 ──────────────────────────────────────────────
    edge:   drawerEdge
    modal:  true
    dim:    true

    // 根据弹出方向设置尺寸
    // 左/右：宽度=drawerWidth，高度=窗口高度
    // 上/下：宽度=窗口宽度，高度=drawerHeight或默认值
    width: {
        if (edge === Qt.TopEdge || edge === Qt.BottomEdge) {
            var appWin = ApplicationWindow.window
            return appWin ? appWin.width : 800
        }
        return drawerWidth
    }

    height: {
        if (edge === Qt.LeftEdge || edge === Qt.RightEdge) {
            var appWin = ApplicationWindow.window
            return appWin ? appWin.height : 500
        }
        // 顶部/底部：使用 drawerHeight 或默认值
        return drawerHeight > 0 ? drawerHeight : 300
    }

    // ── 背景与阴影 ────────────────────────────────────────────
    background: Rectangle {
        anchors.fill: parent
        color:      EasyTheme.color.card
        border.color: EasyTheme.color.border
        border.width: 1
        radius: 2
    }

    // ── 进出场动画 ────────────────────────────────────────────
    // 使用 Drawer 内置的 position 动画，默认已有平滑过渡效果

    // ── 内容区 ────────────────────────────────────────────────
    contentItem: Item {
        width:  parent.width
        height: parent.height

        // 标题栏
        Rectangle {
            id: headerRect
            visible: drawer.showHeader
            y: 0
            width:   parent.width
            height:  60
            color:   "transparent"

            Rectangle {
                id: _iconBadge
                anchors.left:           parent.left
                anchors.leftMargin:     16
                anchors.verticalCenter: parent.verticalCenter
                width:  36
                height: 36
                radius: 10
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: drawer.accentStart }
                    GradientStop { position: 1.0; color: drawer.accentEnd   }
                }
                EasyIconFont {
                    anchors.centerIn: parent
                    icon: drawer.titleIcon
                    iconSize: 18
                    color: "white"
                }
            }

            Label {
                anchors.left:           _iconBadge.right
                anchors.leftMargin:     12
                anchors.verticalCenter: parent.verticalCenter
                text:           drawer.headerTitle
                font.pixelSize: 16
                font.bold:      true
                color:          EasyTheme.color.text
            }

            Rectangle {
                visible:          drawer.showClose
                anchors.right:    parent.right
                anchors.rightMargin:    16
                anchors.verticalCenter: parent.verticalCenter
                width:  32
                height: 32
                radius: 16
                color: _closeArea.containsMouse ? EasyTheme.color.buttonHover : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
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
                    onClicked:    drawer.close()
                }
            }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: EasyTheme.color.border
            }
        }

        // 可滚动内容区
        Flickable {
            id: _flickable
            y: drawer.showHeader ? 60 : 0
            width:  parent.width
            height: parent.height - (drawer.showHeader ? 60 : 0)
            clip:   true
            contentWidth:  width
            contentHeight: _contentCol.childrenRect.height + 32
            flickableDirection: Flickable.VerticalFlick

            ScrollBar.vertical: EasyScrollBar { }

            // 内容区：用户可自由布局
            Item {
                id: _contentCol
                x: 16
                y: 16
                width: _flickable.width - 32
                height: childrenRect.height
            }
        }
    }

    // ── 信号处理 ──────────────────────────────────────────────
    // 注意：T.Drawer 已有 opened/closed 信号，此处覆盖以添加自定义行为
    onOpened: {
        // 抽屉完全打开后的回调
    }
    onClosed: {
        // 抽屉完全关闭后的回调
    }
}
