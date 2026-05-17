import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI 1.0

/**
 * EasyContextMenu —— 通用右键菜单，定位基于 Overlay.overlay（窗口全局坐标）
 *
 * 用法：
 *   EasyContextMenu { id: myMenu }
 *   onClicked: mouse => {
 *       var pos = mapToItem(Overlay.overlay, mouse.x, mouse.y)
 *       myMenu.popup(pos.x, pos.y, [
 *           { text: "复制", icon: EasyIcon.material.content_copy, action: ... },
 *           { separator: true },
 *           { text: "删除", icon: EasyIcon.material.delete_outline, enabled: canDelete, action: ... }
 *       ])
 *   }
 */
Popup {
    id: root

    parent: Overlay.overlay

    property var model: []

    width: 196
    padding: 8
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function popup(x, y, items) {
        root.model = items || []
        var pw = Overlay.overlay ? Overlay.overlay.width : 0
        var ph = Overlay.overlay ? Overlay.overlay.height : 0
        root.x = Math.min(x, pw - width - 4)
        root.y = Math.min(y, ph - implicitHeight - 4)
        open()
    }

    background: Rectangle {
        radius: EasyTheme.size.radius
        color: EasyTheme.color.card
        border.width: EasyTheme.size.borderWidth
        border.color: EasyTheme.color.divider
    }

    Column {
        id: menuCol
        spacing: 2
        width: root.width - root.padding * 2

        Repeater {
            model: root.model

            delegate: Rectangle {
                id: menuRow
                width: menuCol.width
                height: modelData.separator ? 9 : 36
                radius: 6
                color: modelData.separator ? "transparent"
                    : (menuHover.containsMouse ? EasyTheme.color.menuHover : "transparent")

                property bool isSep: modelData.separator || false
                Behavior on color { ColorAnimation { duration: 120 } }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 16
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: EasyTheme.color.divider
                    opacity: 0.5
                    visible: menuRow.isSep
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8
                    visible: !menuRow.isSep
                    opacity: modelData.enabled !== false ? 1.0 : 0.35

                    EasyIconFont {
                        icon: modelData.icon || ""
                        iconSize: 18
                        color: EasyTheme.color.text
                        visible: modelData.icon !== undefined && modelData.icon !== ""
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.text || ""
                        font.pixelSize: 13
                        color: EasyTheme.color.text
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: menuHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: menuRow.isSep || modelData.enabled === false
                        ? Qt.ArrowCursor : Qt.PointingHandCursor
                    enabled: !menuRow.isSep && modelData.enabled !== false
                    onClicked: {
                        root.close()
                        if (modelData.action) modelData.action()
                    }
                }
            }
        }
    }
}
