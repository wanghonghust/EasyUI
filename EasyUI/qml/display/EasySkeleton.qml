import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI 1.0

/**
 * EasySkeleton —— 骨架屏加载占位
 *
 * 属性：
 *   rows       {int}       骨架行数，默认 4
 *   rowHeight  {int}       每行高度，默认 16
 *   spacing    {int}       行间距，默认 12
 *   lastWidth  {real}      最后一行宽度比例 (0~1)，默认 0.6
 *
 * 用法：
 *   EasySkeleton { rows: 6 }
 *   EasySkeleton { rows: 3; rowHeight: 20; spacing: 16 }
 */
Item {
    id: root

    property int rows: 4
    property int rowHeight: 16
    property int spacing: 12
    property real lastWidth: 0.6

    implicitWidth: parent ? parent.width : 200
    implicitHeight: rows * rowHeight + (rows - 1) * spacing

    Column {
        anchors.fill: parent
        spacing: root.spacing

        Repeater {
            model: root.rows

            delegate: Rectangle {
                width: index === root.rows - 1 ? parent.width * root.lastWidth : parent.width
                height: root.rowHeight
                radius: 4
                clip: true
                color: EasyTheme.isDark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.06)

                //  shimmer 动画
                Rectangle {
                    id: shimmer
                    width: parent.width * 0.5
                    height: parent.height
                    radius: parent.radius
                    color: EasyTheme.isDark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(1, 1, 1, 0.5)
                    opacity: 0.6

                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: true
                        PropertyAnimation {
                            from: -parent.width
                            to: parent.width
                            duration: 1200 + index * 150
                        }
                        PropertyAnimation {
                            from: parent.width
                            to: -parent.width
                            duration: 0
                        }
                    }
                }
            }
        }
    }
}
