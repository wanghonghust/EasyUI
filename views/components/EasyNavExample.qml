import QtQuick
import QtQuick.Layouts
import EasyUI

Item {
    implicitHeight: contentLayout.implicitHeight + 48

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 24

    // ========== EasyTabBar ==========
    Text {
        text: "标签页 (EasyTabBar)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }

    Text {
        text: "基础用法"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
    }

    EasyTabBar {
        id: tabBar1
        Layout.fillWidth: true
        tabs: [
            { "title": "首页", "icon": "\ue88a", "closable": false },
            { "title": "文档", "icon": "\ue873", "closable": true },
            { "title": "设置", "icon": "\ue8b8", "closable": true },
            { "title": "关于", "closable": true }
        ]
        currentIndex: 0
        onTabClicked: (index) => console.log("切换到标签:", index)
        onTabClosed: (index) => {
            var newTabs = tabBar1.tabs.slice()
            newTabs.splice(index, 1)
            tabBar1.tabs = newTabs
            if (tabBar1.currentIndex >= newTabs.length) {
                tabBar1.currentIndex = Math.max(0, newTabs.length - 1)
            }
        }
        onAddClicked: {
            var newTabs = tabBar1.tabs.slice()
            newTabs.push({ "title": "新标签 " + (newTabs.length + 1), "closable": true })
            tabBar1.tabs = newTabs
            tabBar1.currentIndex = newTabs.length - 1
        }
    }

    Text {
        text: "不同尺寸"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
    }

    EasyTabBar {
        Layout.fillWidth: true
        size: EasyTheme.size.sizeMini
        tabs: [
            { "title": "迷你", "closable": true },
            { "title": "标签", "closable": true }
        ]
    }

    EasyTabBar {
        Layout.fillWidth: true
        size: EasyTheme.size.sizeSmall
        tabs: [
            { "title": "小号", "closable": true },
            { "title": "标签", "closable": true }
        ]
    }

    EasyTabBar {
        Layout.fillWidth: true
        size: EasyTheme.size.sizeLarge
        tabs: [
            { "title": "大号", "closable": true },
            { "title": "标签", "closable": true }
        ]
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyBreadcrumb ==========
    Text {
        text: "面包屑 (EasyBreadcrumb)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }

    ColumnLayout {
        spacing: 12
        Layout.fillWidth: true

        EasyBreadcrumb {
            items: ["首页", "产品", "详情"]
        }

        EasyBreadcrumb {
            items: ["首页", "产品", "分类", "列表", "详情"]
            separator: ">"
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyCollapse ==========
    Text {
        text: "折叠面板 (EasyCollapse)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }

    Text {
        text: "基础用法 — 点击标题栏展开/折叠内容"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    EasyCollapse {
        Layout.fillWidth: true
        title: "个人信息"
        isExpanded: true

        ColumnLayout {
            spacing: 6
            RowLayout { spacing: 8
                Text { text: "姓名:"; font.pixelSize: 12; color: EasyTheme.color.placeholder; Layout.preferredWidth: 60 }
                Text { text: "张三"; font.pixelSize: 12; color: EasyTheme.color.text }
            }
            RowLayout { spacing: 8
                Text { text: "邮箱:"; font.pixelSize: 12; color: EasyTheme.color.placeholder; Layout.preferredWidth: 60 }
                Text { text: "zhangsan@example.com"; font.pixelSize: 12; color: EasyTheme.color.text }
            }
            RowLayout { spacing: 8
                Text { text: "角色:"; font.pixelSize: 12; color: EasyTheme.color.placeholder; Layout.preferredWidth: 60 }
                Text { text: "开发者"; font.pixelSize: 12; color: EasyTheme.color.text }
            }
        }
    }

    EasyCollapse {
        Layout.fillWidth: true
        title: "系统设置"

        ColumnLayout {
            spacing: 8
            EasyToggle {
                size: EasyTheme.size.sizeSmall
                text: "启用通知"
            }
            EasyToggle {
                size: EasyTheme.size.sizeSmall
                text: "深色模式"
            }
        }
    }

    EasyCollapse {
        Layout.fillWidth: true
        title: "禁用状态"
        enabled: false
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyTreeView ==========
    Text {
        text: "树形视图 (EasyTreeView)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    Text {
        text: "支持多级展开/折叠，图标使用 EasyIcon.material"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }
    Rectangle {
        Layout.fillWidth: true
        height: 200
        color: EasyTheme.isDark ? Qt.rgba(1,1,1,0.03) : Qt.rgba(0,0,0,0.02)
        radius: 8
        clip: true

        EasyTreeView {
            anchors.fill: parent
            anchors.margins: 8
            model: [
                {
                    "label": "项目源码",
                    "icon": EasyIcon.material.folder,
                    "children": [
                        { "label": "src", "icon": EasyIcon.material.folder, "children": [
                            { "label": "main.cpp", "icon": EasyIcon.material.code },
                            { "label": "utils.cpp", "icon": EasyIcon.material.code }
                        ]},
                        { "label": "README.md", "icon": EasyIcon.material.description },
                        { "label": "CMakeLists.txt", "icon": EasyIcon.material.settings }
                    ]
                },
                {
                    "label": "文档",
                    "icon": EasyIcon.material.folder,
                    "children": [
                        { "label": "API 文档", "icon": EasyIcon.material.menu_book },
                        { "label": "开发指南", "icon": EasyIcon.material.auto_stories }
                    ]
                },
                { "label": "配置文件", "icon": EasyIcon.material.tune }
            ]
            onNodeClicked: (node) => console.log("点击节点:", node.label)
        }
    }
    }
}
