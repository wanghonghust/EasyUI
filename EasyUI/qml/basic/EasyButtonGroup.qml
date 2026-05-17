import QtQuick
import QtQuick.Layouts
import EasyUI

/**
 * EasyButtonGroup —— 按钮组控件
 *
 * 属性：
 *   buttons        {list<string>}  按钮文字列表，默认 []
 *   currentIndex   {int}           单选模式当前选中索引，默认 -1（无选中）
 *                                  exclusive=false 时此属性只读（反映最后点击项）
 *   currentIndices {list<int>}     多选模式当前选中索引列表（exclusive=false 时有效）
 *   exclusive      {bool}          是否互斥（单选），默认 true
 *   enabled        {bool}          是否可用，默认 true
 *   equalWidth     {bool}          是否均分宽度，默认 true
 *
 * 信号：
 *   clicked(int index)             点击某按钮时触发（选中前触发，可获取 index）
 *   currentIndexChanged            单选模式选中变化
 *   currentIndicesChanged          多选模式选中变化
 */
Rectangle {
    id: root

    // ── 公开属性 ──────────────────────────────────────────────
    property var    buttons:        []
    property int    currentIndex:   -1
    property var    currentIndices: []
    property bool   exclusive:      true
    property bool   enabled:        true
    property bool   equalWidth:     true

    // ── 信号 ──────────────────────────────────────────────────
    signal clicked(int index)

    // ── 内部工具函数 ──────────────────────────────────────────
    function isSelected(index) {
        if (root.exclusive) {
            return root.currentIndex === index
        } else {
            return root.currentIndices.indexOf(index) !== -1
        }
    }

    function toggleIndex(index) {
        if (root.exclusive) {
            root.currentIndex = index
        } else {
            var arr = root.currentIndices.slice()
            var pos = arr.indexOf(index)
            if (pos !== -1) {
                arr.splice(pos, 1)
            } else {
                arr.push(index)
            }
            root.currentIndices = arr
            // 同步 currentIndex（最后操作项）
            root.currentIndex = index
        }
    }

    // ── 外观 ──────────────────────────────────────────────────
    color:         EasyTheme.color.card
    border.color:  EasyTheme.color.border
    border.width: EasyTheme.size.borderWidth
    radius:        6
    implicitHeight: 32
    clip:          true          // 裁剪内部按钮背景，防止溢出圆角

    Layout.fillWidth:        true
    Layout.preferredWidth:   250

    // ── 内部按钮行 ────────────────────────────────────────────
    Row {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.buttons

            Item {
                id: btn

                // 均分宽度 or 按内容自适应
                width:  root.equalWidth
                        ? root.width / root.buttons.length
                        : (btnText.implicitWidth + 24)
                height: parent.height

                // ── 按钮背景 ──────────────────────────────────
                // 首尾按钮需要对应方向的圆角，与容器 radius 保持一致
                Rectangle {
                    id: btnBg
                    anchors.fill: parent

                    // 利用 topLeft/topRight/bottomLeft/bottomRight 四角独立控制
                    // 第一个按钮：左侧两角有圆角；最后一个按钮：右侧两角有圆角；中间按钮：无圆角
                    topLeftRadius:     index === 0 ? root.radius : 0
                    bottomLeftRadius:  index === 0 ? root.radius : 0
                    topRightRadius:    index === root.buttons.length - 1 ? root.radius : 0
                    bottomRightRadius: index === root.buttons.length - 1 ? root.radius : 0

                    color: {
                        var selected = root.isSelected(index)
                        if (!root.enabled) {
                            return selected
                                ? Qt.darker(EasyTheme.color.primary, 1.3)
                                : "transparent"
                        }
                        if (selected) {
                            return btnMouseArea.containsMouse
                                ? Qt.lighter(EasyTheme.color.primary, 1.1)
                                : EasyTheme.color.primary
                        }
                        return btnMouseArea.containsMouse
                            ? EasyTheme.color.buttonHover
                            : "transparent"
                    }

                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                // ── 右侧分割线（最后一项不画）─────────────────
                Rectangle {
                    visible:        index < root.buttons.length - 1
                    anchors.right:  parent.right
                    width:          1
                    height:         parent.height
                    color:          EasyTheme.color.border
                }

                // ── 文字 ──────────────────────────────────────
                Text {
                    id: btnText
                    anchors.centerIn: parent
                    text:             modelData
                    font.pixelSize:   13
                    font.bold:        root.isSelected(index)
                    color: {
                        if (!root.enabled) {
                            return root.isSelected(index)
                                ? "white"
                                : EasyTheme.color.placeholder
                        }
                        return root.isSelected(index)
                            ? "white"
                            : EasyTheme.color.text
                    }

                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                // ── 鼠标区域 ──────────────────────────────────
                MouseArea {
                    id:           btnMouseArea
                    anchors.fill: parent
                    enabled:      root.enabled
                    hoverEnabled: true
                    cursorShape:  root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor

                    onClicked: function(mouse) {
                        root.clicked(index)
                        root.toggleIndex(index)
                    }
                }

                // ── 点击缩放动画 ──────────────────────────────
                scale: btnMouseArea.containsPress ? 0.96 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
        }
    }
}
