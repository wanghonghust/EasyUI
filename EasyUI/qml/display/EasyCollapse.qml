import QtQuick
import QtQuick.Layouts
import EasyUI

/**
 * EasyCollapse —— 折叠面板组件（简洁风格）
 *
 * 属性：
 *   title           {string}  面板标题，默认 ""
 *   isExpanded      {bool}    是否展开，默认 false
 *   enabled         {bool}    是否可用，默认 true
 *
 * 信号：
 *   toggled(bool isExpanded)  展开状态变化（用户点击触发）
 *
 * 使用方式：
 *   EasyCollapse {
 *       title: "标题"
 *       isExpanded: true
 *       // 内容放在这里
 *       Text { text: "内容" }
 *   }
 */
ColumnLayout {
    id: root

    property string title:      ""
    property bool   isExpanded: false
    property bool   enabled:    true

    signal toggled(bool isExpanded)

    default property alias content: contentArea.children

    Layout.fillWidth: true
    spacing: 0

    // ── 头部区域 ──────────────────────────────────────────────
    Rectangle {
        Layout.fillWidth: true
        height: 48
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 14
                color: root.enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color { ColorAnimation { duration: 150 } }
                elide: Text.ElideRight
            }

            EasyIconFont {
                icon: root.isExpanded ? EasyIcon.material.keyboard_arrow_up : EasyIcon.material.keyboard_arrow_down
                iconSize: 20
                color: EasyTheme.color.placeholder
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.enabled
            hoverEnabled: true
            cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            onClicked: {
                root.isExpanded = !root.isExpanded
                root.toggled(root.isExpanded)
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: EasyTheme.color.border
        }
    }

    // ── 内容区域 ──────────────────────────────────────────────
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: root.isExpanded ? contentArea.implicitHeight : 0
        Layout.topMargin: root.isExpanded ? 12 : 0
        Layout.bottomMargin: root.isExpanded ? 16 : 0
        clip: true
        color: "transparent"

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Behavior on Layout.topMargin {
            NumberAnimation { duration: 200 }
        }

        Behavior on Layout.bottomMargin {
            NumberAnimation { duration: 200 }
        }

        ColumnLayout {
            id: contentArea
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8
        }
    }
}
