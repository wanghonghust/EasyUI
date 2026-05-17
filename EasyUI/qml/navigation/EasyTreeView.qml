import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI 1.0

/**
 * EasyTreeView —— 树形视图
 *
 * 属性：
 *   model        {list}        树形数据，每项支持 label / icon / children
 *   indent       {int}         每层缩进像素，默认 24
 *   rowHeight    {int}         每行高度，默认 32
 *
 * 信号：
 *   nodeClicked(var node)       节点点击
 *
 * 用法：
 *   EasyTreeView {
 *       model: [
 *           { "label": "文件夹1", "icon": EasyIcon.material.folder, "children": [
 *               { "label": "文件1", "icon": EasyIcon.material.description },
 *               { "label": "文件2", "icon": EasyIcon.material.image }
 *           ]},
 *           { "label": "文件夹2", "icon": EasyIcon.material.folder_open }
 *       ]
 *       onNodeClicked: (node) => console.log(node.label)
 *   }
 */
Item {
    id: root

    property var model: []
    property int indent: 24
    property int rowHeight: 32
    property int tooltipDelay: 600
    property bool tooltipEnabled: true

    signal nodeClicked(var node)
    signal nodeRightClicked(var node, point mousePos)
    signal emptyAreaRightClicked(point mousePos)

    // 展开状态 {"0": true, "0_1": false, ...}
    property var _expanded: ({})
    property string _selectedKey: ""

    clip: true

    Flickable {
        id: _flickable
        anchors.fill: parent
        contentHeight: column.height
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: EasyScrollBar { }

        // 空白区域右键
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            z: -1
            onClicked: mouse => {
                // 只在空白区域触发（不覆盖节点上的右键）
                root.emptyAreaRightClicked({ x: mouse.x, y: mouse.y })
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: 1
            topPadding: 4
            bottomPadding: 4
        }
    }

    // ── 自定义提示弹出框 ──
    Popup {
        id: _tooltipPopup
        padding: 8
        closePolicy: Popup.NoAutoClose
        width: Math.min(_tooltipContent.implicitWidth + 20, 380)
        height: _tooltipContent.implicitHeight + 16

        contentItem: Text {
            id: _tooltipContent
            text: ""
            font.pixelSize: 12
            color: "#ffffff"
            elide: Text.ElideMiddle
            maximumLineCount: 3
            wrapMode: Text.WrapAnywhere
        }

        background: Rectangle {
            color: EasyTheme.isDark ? Qt.rgba(0.2, 0.2, 0.22, 0.95) : Qt.rgba(0.25, 0.25, 0.27, 0.95)
            radius: 7
            border.color: EasyTheme.isDark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
        }

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 100
                easing.type: Easing.InCubic
            }
        }
    }

    Timer {
        id: _tooltipTimer
        interval: root.tooltipDelay
        repeat: false
        property var _pendingNode: null
        property real _rootX: 0
        property real _rootY: 0
        onTriggered: {
            if (_pendingNode && root.tooltipEnabled) {
                var text = _pendingNode.path || _pendingNode.label
                if (text) {
                    _tooltipContent.text = text
                    _tooltipPopup.x = Math.max(2, Math.min(_rootX + 10, root.width - _tooltipPopup.width - 2))
                    _tooltipPopup.y = _rootY - _tooltipPopup.height - 6
                    if (_tooltipPopup.y < 2)
                        _tooltipPopup.y = _rootY + root.rowHeight + 4
                    _tooltipPopup.open()
                }
            }
            _pendingNode = null
        }
    }

    Component {
        id: nodeComponent

        Rectangle {
            id: row
            width: column.width
            height: root.rowHeight
            radius: 4
            color: {
                if (root._selectedKey === nodeKey)
                    return Qt.rgba(EasyTheme.color.primary.r, EasyTheme.color.primary.g, EasyTheme.color.primary.b, 0.2)
                if (area.containsMouse)
                    return EasyTheme.isDark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.03)
                return "transparent"
            }

            property var nodeData: null
            property int nodeDepth: 0
            property string nodeKey: ""

            // 行级交互（先定义，使 RowLayout 中的箭头 MouseArea 优先接收点击）
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root._selectedKey = nodeKey
                    root.nodeClicked(nodeData)
                }
                onEntered: {
                    _tooltipTimer.stop()
                    _tooltipTimer._pendingNode = nodeData
                    var pos = area.mapToItem(root, area.mouseX, area.mouseY)
                    _tooltipTimer._rootX = pos.x
                    _tooltipTimer._rootY = pos.y
                    _tooltipTimer.start()
                }
                onExited: {
                    _tooltipTimer.stop()
                    _tooltipTimer._pendingNode = null
                    _tooltipPopup.close()
                }
                onPositionChanged: (mouse) => {
                    var pos = area.mapToItem(root, mouse.x, mouse.y)
                    _tooltipTimer._rootX = pos.x
                    _tooltipTimer._rootY = pos.y
                    if (_tooltipPopup.opened) {
                        _tooltipPopup.x = Math.max(2, Math.min(pos.x + 10, root.width - _tooltipPopup.width - 2))
                        _tooltipPopup.y = pos.y - _tooltipPopup.height - 6
                        if (_tooltipPopup.y < 2)
                            _tooltipPopup.y = pos.y + root.rowHeight + 4
                    }
                }
            }

            // 右键
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: mouse => {
                    root._selectedKey = nodeKey
                    var pos = mapToItem(root, mouse.x, mouse.y)
                    root.nodeRightClicked(nodeData, { x: pos.x, y: pos.y })
                }
            }

            RowLayout {
                x: 8 + root.indent * nodeDepth
                y: 0
                width: parent.width - x - 8
                height: parent.height
                spacing: 4

                // 展开/折叠箭头
                Item {
                    width: 20
                    height: 20
                    visible: nodeData.children !== undefined

                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: root._expanded[nodeKey]
                            ? EasyIcon.material.keyboard_arrow_down
                            : EasyIcon.material.keyboard_arrow_right
                        iconSize: 18
                        color: EasyTheme.color.text
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root._expanded[nodeKey] = !root._expanded[nodeKey]
                            root._rebuild()
                        }
                    }
                }

                // 占位（无子节点时对齐）
                Item {
                    width: 20
                    height: 1
                    visible: nodeData.children === undefined
                }

                // 节点图标
                EasyIconFont {
                    visible: nodeData.icon !== undefined && nodeData.icon !== ""
                    icon: nodeData.icon || ""
                    iconSize: 18
                    color: isExpandable(nodeData)
                        ? EasyTheme.color.primary
                        : EasyTheme.color.text
                }

                // 标签
                Text {
                    text: nodeData.label || ""
                    font.pixelSize: 13
                    color: EasyTheme.color.text
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                    Layout.fillWidth: true
                }
            }
        }
    }

    function isExpandable(node) {
        return node.children !== undefined
    }

    function _rebuild() {
        // 清空 Column
        var children = column.children
        for (var i = children.length - 1; i >= 0; i--) {
            if (children[i].nodeDepth !== undefined) {
                children[i].destroy()
            }
        }
        _appendNodes(root.model, 0, "")
    }

    function _appendNodes(nodes, depth, prefix) {
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i]
            var key = prefix + i
            nodeComponent.createObject(column, {
                nodeData: node,
                nodeDepth: depth,
                nodeKey: key
            })
            if (node.children && node.children.length > 0 && root._expanded[key]) {
                _appendNodes(node.children, depth + 1, key + "_")
            }
        }
    }

    onModelChanged: _rebuild()
    Component.onCompleted: _rebuild()
}
