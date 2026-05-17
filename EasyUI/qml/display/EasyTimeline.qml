import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI 1.0

/**
 * EasyTimeline —— 时间线组件
 *
 * 属性：
 *   items      {list}        时间线数据，每项为 {title, time, description, color, icon}
 *   dotSize    {int}         节点圆点大小，默认 12
 *   lineWidth  {int}         连线宽度，默认 2
 *
 * 用法：
 *   EasyTimeline {
 *       items: [
 *           { "title": "创建项目", "time": "2024-01-01", "description": "项目初始化", "color": "#67c23a" },
 *           { "title": "开发阶段", "time": "2024-02-15", "description": "核心功能开发", "color": "#409eff" }
 *       ]
 *   }
 */
Item {
    id: root

    property var items: []
    property int dotSize: 12
    property int lineWidth: 2

    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    Column {
        id: content
        width: parent.width
        spacing: 0

        Repeater {
            model: root.items

            delegate: Item {
                id: itemRoot
                width: content.width
                implicitHeight: Math.max(36, bodyColumn.implicitHeight + 20)

                property bool isLast: index === root.items.length - 1

                // 左侧连线
                Rectangle {
                    x: root.dotSize / 2 - root.lineWidth / 2
                    y: root.dotSize
                    width: root.lineWidth
                    height: isLast ? 0 : itemRoot.implicitHeight - root.dotSize
                    color: modelData.color || EasyTheme.color.border
                }

                // 节点圆点
                Rectangle {
                    x: 0
                    y: 10
                    width: root.dotSize
                    height: root.dotSize
                    radius: root.dotSize / 2
                    color: modelData.color || EasyTheme.color.primary

                    // 内圈白点
                    Rectangle {
                        anchors.centerIn: parent
                        width: root.dotSize * 0.4
                        height: root.dotSize * 0.4
                        radius: width / 2
                        color: "white"
                    }
                }

                // 内容
                Column {
                    id: bodyColumn
                    x: root.dotSize + 16
                    width: parent.width - x - 8
                    spacing: 4
                    topPadding: 6
                    bottomPadding: 14

                    RowLayout {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: modelData.title || ""
                            font.pixelSize: 14
                            font.bold: true
                            color: EasyTheme.color.text
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.time || ""
                            font.pixelSize: 11
                            color: EasyTheme.color.placeholder
                        }
                    }

                    Text {
                        text: modelData.description || ""
                        font.pixelSize: 12
                        color: EasyTheme.color.secondary
                        wrapMode: Text.Wrap
                        width: parent.width
                        visible: modelData.description !== undefined && modelData.description !== ""
                    }
                }
            }
        }
    }
}
