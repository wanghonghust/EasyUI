import QtQuick
import EasyUI

/**
 * EasyDivider —— 分隔线组件
 *
 * 属性：
 *   orientation    {int}     方向：Qt.Horizontal / Qt.Vertical，默认 Horizontal
 *   length         {real}    长度，默认 parent.width 或 parent.height
 *   thickness      {real}    粗细，默认 1
 *   margin         {real}    边距，默认 0
 */
Rectangle {
    id: root

    property int orientation: Qt.Horizontal
    property real length: orientation === Qt.Horizontal ? parent.width : parent.height
    property real thickness: 1
    property real margin: 0

    color: EasyTheme.color.divider

    width: orientation === Qt.Horizontal ? length - margin * 2 : thickness
    height: orientation === Qt.Horizontal ? thickness : length - margin * 2
}
