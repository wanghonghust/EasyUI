import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

/**
 * ComponentSection —— 组件展示区块
 *
 * 用于 ComponentsPage 中每个组件类别的展示容器
 */
ColumnLayout {
    id: root

    property string title: ""
    default property alias content: container.children

    spacing: 16

    // 标题
    Text {
        text: root.title
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }

    // 内容容器
    EasyCard {
        Layout.fillWidth: true

        ColumnLayout {
            id: container
            width: parent.width
            implicitHeight: childrenRect.height
            height: implicitHeight
            spacing: 8
        }
    }
}
