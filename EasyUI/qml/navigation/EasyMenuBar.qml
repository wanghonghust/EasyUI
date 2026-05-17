import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI 1.0

Rectangle {
    id: menuBar

    property int menuWidth: 160
    property int collapsedWidth: 50
    property var menus: []
    property string activePath: ""
    property bool expandAll: false
    property bool collapsed: false
    property bool hoverExpand: false  // 悬停时自动展开
    property int popupMenuWidth: 160  // 弹出菜单宽度

    property string searchText: ""
    property bool searchable: true

    signal itemClicked(var item)
    signal collapseChanged(bool collapsed)

    width: collapsed ? collapsedWidth : menuWidth
    color: "transparent"

    // Check if a menu item or any of its children matches search
    function matchesSearch(item) {
        if (searchText === "") return true
        var q = searchText.toLowerCase()
        if (item.title && item.title.toLowerCase().indexOf(q) >= 0) return true
        if (item.children) {
            for (var i = 0; i < item.children.length; i++) {
                if (matchesSearch(item.children[i])) return true
            }
        }
        return false
    }

    // 宽度切换动画
    Behavior on width {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    // ========== 弹出菜单组件 ==========
    Popup {
        id: popupMenu
        width: menuBar.popupMenuWidth
        padding: 8

        property var menuItems: []
        property var parentItem: null
        property int currentDepth: 0

        // 高度受可用空间限制，超出时 ScrollView 滚动
        height: Math.min(popupMenuContent.implicitHeight + 18, menuBar.height - y - 12)

        // 定位到菜单栏右侧，y 根据父项位置计算
        x: menuBar.width + 4
        y: {
            if (parentItem) {
                var posY = parentItem.mapToItem(menuBar, 0, 0).y
                return Math.max(8, posY)
            }
            return 8
        }

        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 8
            color: EasyTheme.color.card
            border.width: 0.5
            border.color: EasyTheme.color.divider

            // 阴影效果
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: EasyTheme.isDark ? "#60000000" : "#30000000"
                shadowBlur: 0.5
                shadowVerticalOffset: 2
                shadowHorizontalOffset: 2
            }
        }

        contentItem: ScrollView {
            clip: true
            contentWidth: availableWidth
            ScrollBar.vertical: EasyScrollBar { }

            Column {
                id: popupMenuContent
                spacing: 4
                width: menuBar.popupMenuWidth - 12

                Repeater {
                    model: popupMenu.menuItems

                    delegate: Rectangle {
                        id: popupMenuItem
                        width: popupMenuContent.width
                        height: 36
                        radius: 6
                        color: popupItemArea.containsMouse ? EasyTheme.color.menuHover : "transparent"

                        property var itemData: modelData
                        property bool hasChildren: itemData ? (itemData.children ? itemData.children.length > 0 : false) : false
                        property bool isActive: itemData ? menuBar.activePath === itemData.url : false

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            EasyIconFont {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 18
                                icon: popupMenuItem.itemData && popupMenuItem.itemData.icon ? popupMenuItem.itemData.icon : ""
                                iconSize: 18
                                color: popupMenuItem.isActive ? EasyTheme.color.primary : EasyTheme.color.text
                            }

                            Label {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: popupMenuItem.itemData ? popupMenuItem.itemData.title : ""
                                font.pixelSize: 13
                                color: popupMenuItem.isActive ? EasyTheme.color.primary : EasyTheme.color.text
                                elide: Text.ElideRight
                            }

                            // 子菜单箭头
                            EasyIconFont {
                                Layout.alignment: Qt.AlignVCenter
                                visible: popupMenuItem.hasChildren
                                icon: EasyIcon.material.keyboard_arrow_right
                                iconSize: 18
                                color: EasyTheme.color.secondary
                            }
                        }

                        MouseArea {
                            id: popupItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (popupMenuItem.hasChildren) {
                                    // 有子菜单，显示下一级
                                    subPopupMenu.showMenu(popupMenuItem.itemData.children, popupMenuItem)
                                } else {
                                    // 无子菜单，触发点击并关闭所有弹出菜单
                                    menuBar.itemClicked(popupMenuItem.itemData)
                                    popupMenu.close()
                                }
                            }
                        }
                    }
                }
            }
        }

        function showMenu(items, parent) {
            menuItems = items
            parentItem = parent
            open()
        }

        onClosed: {
            subPopupMenu.close()
        }
    }

    // ========== 子菜单弹出组件（支持多级嵌套） ==========
    Popup {
        id: subPopupMenu
        width: menuBar.popupMenuWidth
        padding: 8

        property var menuItems: []
        property var parentItem: null

        // 高度受可用空间限制，超出时 ScrollView 滚动
        height: Math.min(subPopupMenuContent.implicitHeight + 18, menuBar.height - y - 12)

        // 定位到父菜单项右侧
        x: popupMenu.x + menuBar.popupMenuWidth + 4
        y: Math.max(8, parentItem && popupMenu.visible
                    ? parentItem.mapToItem(menuBar, 0, 0).y
                    : popupMenu.y)

        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            radius: 8
            color: EasyTheme.color.card
            border.width: 0.5
            border.color: EasyTheme.color.divider

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: EasyTheme.isDark ? "#60000000" : "#30000000"
                shadowBlur: 0.5
                shadowVerticalOffset: 2
                shadowHorizontalOffset: 2
            }
        }

        contentItem: ScrollView {
            clip: true
            contentWidth: availableWidth
            ScrollBar.vertical: EasyScrollBar { }

            Column {
                id: subPopupMenuContent
                spacing: 4
                width: menuBar.popupMenuWidth - 12

                Repeater {
                    model: subPopupMenu.menuItems

                    delegate: Rectangle {
                        id: subPopupMenuItem
                        width: subPopupMenuContent.width
                        height: 36
                        radius: 6
                        color: subPopupItemArea.containsMouse ? EasyTheme.color.menuHover : "transparent"

                        property var itemData: modelData
                        property bool isActive: menuBar.activePath === (itemData ? itemData.url : "")

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            EasyIconFont {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 18
                                icon: subPopupMenuItem.itemData && subPopupMenuItem.itemData.icon ? subPopupMenuItem.itemData.icon : ""
                                iconSize: 18
                                color: subPopupMenuItem.isActive ? EasyTheme.color.primary : EasyTheme.color.text
                            }

                            Label {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: subPopupMenuItem.itemData ? subPopupMenuItem.itemData.title : ""
                                font.pixelSize: 13
                                color: subPopupMenuItem.isActive ? EasyTheme.color.primary : EasyTheme.color.text
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: subPopupItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                menuBar.itemClicked(subPopupMenuItem.itemData)
                                popupMenu.close()
                                subPopupMenu.close()
                            }
                        }
                    }
                }
            }
        }

        function showMenu(items, parent) {
            menuItems = items
            parentItem = parent
            open()
        }
    }

    // ========== 递归树形菜单组件 ==========
    Component {
        id: treeItemComponent

        Column {
            id: node
            spacing: 4
            width: parent ? parent.width : menuBar.menuWidth  // 关键：继承父宽度

            // 核心属性
            property int localDepth: 0
            property var nodeData: null
            property bool expanded: menuBar.expandAll || (menuBar.searchText !== "" && menuBar.matchesSearch(nodeData))

            // 当前节点按钮
            EasyMenuButton {
                id: menuBtn
                width: node.width
                height: 36
                icon: node.nodeData && node.nodeData.icon ? node.nodeData.icon : ""
                title: node.nodeData ? node.nodeData.title : ""
                iconTail: (nodeData && nodeData.children && nodeData.children.length
                                           > 0) ? (node.expanded ? EasyIcon.material.keyboard_arrow_up : EasyIcon.material.keyboard_arrow_down) : ""
                active: menuBar.activePath === (node.nodeData ? node.nodeData.url : "")
                extraLeftPadding: node.localDepth * 20

                onClicked: {
                    node.expanded = !node.expanded
                    menuBar.itemClicked(node.nodeData)
                }
            }

            // 子节点容器
            Column {
                id: childrenContainer
                width: node.width           // 关键：继承 node 宽度
                spacing: 4
                clip: true

                // 高度动画：从0到implicitHeight
                height: node.expanded ? implicitHeight : 0
                opacity: node.expanded ? 1 : 0

                // 展开/折叠动画
                Behavior on height {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                Repeater {
                    model: (node.nodeData && node.nodeData.children) ? node.nodeData.children : []

                    delegate: Loader {
                        width: childrenContainer.width
                        active: menuBar.matchesSearch(modelData)
                        visible: active
                        sourceComponent: treeItemComponent

                        onLoaded: {
                            item.localDepth = node.localDepth + 1
                            item.nodeData = modelData
                        }
                    }
                }
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // Search input — only when expanded and searchable
        Rectangle {
            id: searchBox
            visible: !menuBar.collapsed && menuBar.searchable
            width: parent.width
            height: visible ? 52 : 0
            color: "transparent"

            EasyInput {
                anchors {
                    left: parent.left; right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12; rightMargin: 12
                }
                placeholder: "搜索菜单..."
                size: EasyTheme.size.sizeNormal
                clearable: true
                prefixIcon: EasyIcon.material.search
                onTextChanged: menuBar.searchText = text.toLowerCase()
            }

            // Bottom separator
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom
                    leftMargin: 12; rightMargin: 12 }
                height: 1
                color: EasyTheme.color.divider
            }
        }

        ScrollView {
            width: parent.width
            height: parent.height - searchBox.height
            padding: menuBar.collapsed ? 6 : 10
            contentWidth: availableWidth
            ScrollBar.vertical: EasyScrollBar { }
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: colLayout
                spacing: 4
                width: parent.width

                Repeater {
                    model: menuBar.menus

                    delegate: Loader {
                        Layout.fillWidth: true
                        active: menuBar.matchesSearch(modelData)
                        visible: active
                        sourceComponent: menuBar.collapsed ? collapsedItemComponent : treeItemComponent
                        onLoaded: {
                            item.localDepth = 0
                            item.nodeData = modelData
                        }
                    }
                }
            }
        }
    }

    // ========== 折叠状态下的菜单项组件 ==========
    Component {
        id: collapsedItemComponent

        EasyTooltip {
            id: tooltipWrapper
            width: menuBar.collapsedWidth
            height: 36

            property int localDepth: 0
            property var nodeData: null

            text: (menuBar.collapsed && tooltipWrapper.nodeData && tooltipWrapper.nodeData.children && tooltipWrapper.nodeData.children.length === 0) ? tooltipWrapper.nodeData.title : ""
            delay: 500
            placement: "right"

            Rectangle {
                id: collapsedNode
                anchors.fill: parent
                radius: 8
                color: {
                    if (isActive) {
                        return EasyTheme.color.primary
                    } else if (collapsedBtnArea.containsMouse) {
                        return EasyTheme.color.menuHover
                    } else {
                        return "transparent"
                    }
                }

                property bool hasChildren: tooltipWrapper.nodeData ? (tooltipWrapper.nodeData.children ? tooltipWrapper.nodeData.children.length > 0 : false) : false

                // 激活状态高亮
                property bool isActive: menuBar.activePath === (tooltipWrapper.nodeData ? tooltipWrapper.nodeData.url : "")

                Behavior on color { ColorAnimation { duration: 120 } }

                EasyIconFont {
                    anchors.centerIn: parent
                    icon: (tooltipWrapper.nodeData && tooltipWrapper.nodeData.icon) ? tooltipWrapper.nodeData.icon : ""
                    iconSize: 20
                    color: collapsedNode.isActive ? EasyTheme.color.menuActiveText : EasyTheme.color.text
                }

                // 折叠态不显示子菜单箭头

                MouseArea {
                    id: collapsedBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (collapsedNode.hasChildren) {
                            // 有子菜单，显示弹出菜单
                            popupMenu.showMenu(tooltipWrapper.nodeData.children, collapsedNode)
                        } else {
                            // 无子菜单，直接触发点击
                            menuBar.itemClicked(tooltipWrapper.nodeData)
                        }
                    }

                    // 悬停时自动展开
                    onEntered: {
                        if (menuBar.hoverExpand && menuBar.collapsed) {
                            menuBar.collapsed = false
                            menuBar.collapseChanged(false)
                        }
                    }
                }
            }
        }
    }
}
