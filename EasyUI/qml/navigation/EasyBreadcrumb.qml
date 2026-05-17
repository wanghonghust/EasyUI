import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

/**
 * EasyBreadcrumb —— 面包屑导航组件
 *
 * 属性：
 *   items        {list<var>}    面包屑项列表，如 [{text: "首页"}, {text: "组件库"}]
 *   currentIndex {int}          当前选中索引，默认最后一项
 *   separator    {string}       分隔符，默认 "/"
 *
 * 信号：
 *   itemClicked(int index)      点击某一项
 */
RowLayout {
    id: root

    property var items: []
    property int currentIndex: items.length - 1
    property string separator: "/"
    property color textColor: EasyTheme.color.text
    property color accentColor: EasyTheme.color.primary
    property color hoverColor: EasyTheme.color.primary

    spacing: 4

    signal itemClicked(int index)

    Repeater {
        model: root.items.length

        RowLayout {
            spacing: 4

            // 分隔符（第一项不显示）
            Text {
                visible: index > 0
                text: root.separator
                color: EasyTheme.color.placeholder
                font.pixelSize: 13
            }

            // 面包屑项
            Rectangle {
                id: itemRect
                implicitWidth: itemText.implicitWidth + 8
                implicitHeight: itemText.implicitHeight + 4
                radius: 4
                color: itemArea.containsMouse ? EasyTheme.color.hover : "transparent"

                property bool isActive: index === root.currentIndex

                Text {
                    id: itemText
                    anchors.centerIn: parent
                    text: {
                        var item = root.items[index]
                        if (item === undefined || item === null) return ""
                        if (typeof item === "string") return item
                        return item.text !== undefined ? item.text : String(item)
                    }
                    color: itemRect.isActive ? root.accentColor : (itemArea.containsMouse ? root.hoverColor : root.textColor)
                    font.pixelSize: 13
                    font.bold: itemRect.isActive
                }

                MouseArea {
                    id: itemArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: itemRect.isActive ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onClicked: {
                        if (!itemRect.isActive) {
                            root.currentIndex = index
                            root.itemClicked(index)
                        }
                    }
                }
            }
        }
    }
}
