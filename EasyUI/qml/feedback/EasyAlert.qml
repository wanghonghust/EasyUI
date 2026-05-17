import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI 1.0

/**
 * EasyAlert —— 提示警告框
 *
 * 用法：
 *   // 基础用法
 *   EasyAlert { text: "这是一条普通提示信息" }
 *   EasyAlert { type: "success"; title: "操作成功"; text: "数据已保存" }
 *   EasyAlert { type: "warning"; text: "请注意，此操作不可撤销" }
 *   EasyAlert { type: "error"; text: "出错了"; closable: false }
 *
 *   // 带边框
 *   EasyAlert { type: "warning"; text: "带边框强调"; showBorder: true }
 *
 * 属性：
 *   type        {string}  类型："info"（默认）, "success", "warning", "error"
 *   title       {string}  标题，可选
 *   text        {string}  内容文字
 *   closable    {bool}    是否可关闭，默认 true
 *   showIcon    {bool}    是否显示图标，默认 true
 *   showBorder  {bool}    是否显示四周类型色边框，默认 false
 *
 * 信号：
 *   closed()              关闭时触发
 */
Rectangle {
    id: root

    property string type: "info"
    property string title: ""
    property string text: ""
    property bool closable: true
    property bool showIcon: true
    property bool showBorder: false

    signal closed()

    // 根据类型获取主题色
    property color typeColor: {
        switch (type) {
            case "success": return EasyTheme.color.success
            case "warning": return EasyTheme.color.warning
            case "error":   return EasyTheme.color.colorError
            default:        return EasyTheme.color.info
        }
    }

    // 背景色：类型色 + 低透明度
    property color bgColor: Qt.rgba(typeColor.r, typeColor.g, typeColor.b, EasyTheme.isDark ? 0.15 : 0.08)

    radius: EasyTheme.size.radius
    color: bgColor
    border.color: root.showBorder
        ? Qt.rgba(root.typeColor.r, root.typeColor.g, root.typeColor.b, EasyTheme.isDark ? EasyTheme.size.borderWidth : 0.35)
        : "transparent"
    border.width: root.showBorder ? EasyTheme.size.borderWidth : 0
    implicitHeight: contentLayout.implicitHeight + 24
    Layout.fillWidth: true

    // — Shadow —
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: EasyTheme.color.shadow
        shadowOpacity: EasyTheme.elevation.shadowOpacity(EasyTheme.elevation.low)
        shadowBlur: 0.4
        shadowHorizontalOffset: 0
        shadowVerticalOffset: EasyTheme.elevation.shadowOffsetY(EasyTheme.elevation.low)
    }

    RowLayout {
        id: contentLayout
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 10

        // — 图标 —
        EasyIconFont {
            visible: root.showIcon
            icon: {
                switch (type) {
                    case "success": return EasyIcon.material.check_circle
                    case "warning": return EasyIcon.material.warning
                    case "error":   return EasyIcon.material.error
                    default:        return EasyIcon.material.info
                }
            }
            iconSize: 20
            color: root.typeColor
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 2
        }

        // — 内容区 —
        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true

            Text {
                visible: title !== ""
                text: root.title
                font.pixelSize: 13
                font.bold: true
                color: EasyTheme.color.text
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Text {
                text: root.text
                font.pixelSize: 13
                color: EasyTheme.color.text
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }

        // — 关闭按钮 —
        Rectangle {
            visible: closable
            width: 22
            height: 22
            radius: 11
            color: closeArea.containsMouse
                ? (EasyTheme.isDark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.06))
                : "transparent"
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 10

            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }

            EasyIconFont {
                anchors.centerIn: parent
                icon: EasyIcon.material.close
                iconSize: 14
                color: EasyTheme.color.secondary
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    mouse.accepted = true
                    root.closed()
                }
            }
        }
    }
}
