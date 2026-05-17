import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

/**
 * EasySegmented —— 分段控制器组件
 *
 * 属性：
 *   options      {list<var>}    选项列表，如 [{text: "日"}, {text: "周"}]
 *   currentIndex {int}          当前选中索引，默认 0
 *   exclusive    {bool}         是否单选，默认 true
 *   currentIndices{list<int>}   多选时的选中索引列表
 *   size         {int}          控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *
 * 信号：
 *   clicked(int index)          点击某项
 */
Rectangle {
    id: root

    property var options: []
    property int currentIndex: 0
    property bool exclusive: true
    property var currentIndices: []
    property int size: EasyTheme.size.sizeNormal

    // 根据 size 计算控件尺寸
    readonly property int computedItemHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 22
        case EasyTheme.size.sizeSmall:  return 26
        case EasyTheme.size.sizeLarge:  return 38
        default:                        return 32
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge
        default:                        return EasyTheme.size.fontSizeNormal
        }
    }
    readonly property int computedPadding: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 12
        case EasyTheme.size.sizeSmall:  return 14
        case EasyTheme.size.sizeLarge:  return 20
        default:                        return 16
        }
    }

    property int itemMinWidth: 60

    implicitWidth: rowLayout.implicitWidth + computedPadding
    implicitHeight: computedItemHeight + 8
    radius: EasyTheme.size.radius
    color: EasyTheme.color.card
    border.color: EasyTheme.color.cardBorder
    border.width: EasyTheme.size.borderWidth

    signal clicked(int index)

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.options.length

            Rectangle {
                id: segmentItem
                Layout.preferredHeight: root.computedItemHeight
                Layout.preferredWidth: Math.max(root.itemMinWidth, itemText.implicitWidth + root.computedPadding)
                radius: 6

                property bool isSelected: root.exclusive ? index === root.currentIndex : root.currentIndices.indexOf(index) >= 0

                color: isSelected ? EasyTheme.color.primary : (segmentArea.containsMouse ? EasyTheme.color.menuHover : EasyTheme.color.transparent)

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    id: itemText
                    anchors.centerIn: parent
                    text: root.options[index] ? root.options[index].text : ""
                    font.pixelSize: root.computedFontSize
                    font.bold: isSelected
                    color: isSelected
                          ? EasyTheme.color.accentText
                          : (segmentArea.containsMouse ? EasyTheme.color.primary : EasyTheme.color.text)
                }

                MouseArea {
                    id: segmentArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.clicked(index)

                        if (root.exclusive) {
                            // 单选模式
                            if (root.currentIndex !== index) {
                                root.currentIndex = index
                            }
                        } else {
                            // 多选模式
                            var idx = root.currentIndices.indexOf(index)
                            var newIndices = root.currentIndices.slice()
                            if (idx >= 0) {
                                // 取消选中
                                newIndices.splice(idx, 1)
                            } else {
                                // 选中
                                newIndices.push(index)
                            }
                            root.currentIndices = newIndices
                        }
                    }
                }
            }
        }
    }

    // 公开方法
    function setSelected(index) {
        if (root.exclusive) {
            root.currentIndex = index
        } else {
            var idx = root.currentIndices.indexOf(index)
            if (idx < 0) {
                var newIndices = root.currentIndices.slice()
                newIndices.push(index)
                root.currentIndices = newIndices
            }
        }
    }

    function toggleSelected(index) {
        if (!root.exclusive) {
            var newIndices = root.currentIndices.slice()
            var idx = newIndices.indexOf(index)
            if (idx >= 0) {
                newIndices.splice(idx, 1)
            } else {
                newIndices.push(index)
            }
            root.currentIndices = newIndices
        }
    }

    function clearSelection() {
        if (root.exclusive) {
            root.currentIndex = -1
        } else {
            root.currentIndices = []
        }
    }

    function getSelectedText() {
        if (root.exclusive) {
            return root.currentIndex >= 0 ? root.options[root.currentIndex].text : ""
        } else {
            return root.currentIndices.map(function(idx) { return root.options[idx].text })
        }
    }
}
