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
        text: "Edge 浏览器风格，选中标签阴影 + 图标使用 EasyIcon.material"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        height: 48
        color: EasyTheme.isDark ? "#1a1a24" : "#f0f1f4"
        radius: 8
        clip: true

        EasyTabBar {
            id: tabBar1
            anchors.fill: parent
            tabs: [
                { "title": "首页", "icon": EasyIcon.material.home, "closable": false },
                { "title": "文档", "icon": EasyIcon.material.description, "closable": true },
                { "title": "设置", "icon": EasyIcon.material.settings, "closable": true },
                { "title": "扩展", "icon": EasyIcon.material.extension, "closable": true }
            ]
            currentIndex: 0
            onTabClicked: (index) => console.log("切换到标签:", index)
            onTabClosed: (index) => {
                var newTabs = tabBar1.tabs.slice()
                newTabs.splice(index, 1)
                tabBar1.tabs = newTabs
                if (tabBar1.currentIndex >= newTabs.length)
                    tabBar1.currentIndex = Math.max(0, newTabs.length - 1)
            }
            onAddClicked: {
                var n = tabBar1.tabs.length + 1
                tabBar1.tabs = tabBar1.tabs.concat({ "title": "新标签 " + n, "icon": EasyIcon.material.web, "closable": true })
                tabBar1.currentIndex = tabBar1.tabs.length - 1
            }
        }
    }

    Text {
        text: "不同尺寸"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
    }

    Rectangle {
        Layout.fillWidth: true
        height: 38
        color: EasyTheme.isDark ? "#1a1a24" : "#f0f1f4"
        radius: 6

        EasyTabBar {
            anchors.fill: parent
            size: EasyTheme.size.sizeMini
            tabs: [
                { "title": "迷你", "icon": EasyIcon.material.tab, "closable": true },
                { "title": "标签", "icon": EasyIcon.material.star, "closable": true }
            ]
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 42
        color: EasyTheme.isDark ? "#1a1a24" : "#f0f1f4"
        radius: 6

        EasyTabBar {
            anchors.fill: parent
            size: EasyTheme.size.sizeSmall
            tabs: [
                { "title": "小号", "icon": EasyIcon.material.tab, "closable": true },
                { "title": "标签", "icon": EasyIcon.material.favorite, "closable": true }
            ]
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 52
        color: EasyTheme.isDark ? "#1a1a24" : "#f0f1f4"
        radius: 6

        EasyTabBar {
            anchors.fill: parent
            size: EasyTheme.size.sizeLarge
            tabs: [
                { "title": "大号", "icon": EasyIcon.material.tab, "closable": true },
                { "title": "标签", "icon": EasyIcon.material.explore, "closable": true }
            ]
        }
    }

    Text {
        text: "不可添加 / 不可关闭"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
    }

    Rectangle {
        Layout.fillWidth: true
        height: 48
        color: EasyTheme.isDark ? "#1a1a24" : "#f0f1f4"
        radius: 6

        EasyTabBar {
            anchors.fill: parent
            addable: false
            tabs: [
                { "title": "固定标签1", "icon": EasyIcon.material.push_pin, "closable": false },
                { "title": "固定标签2", "closable": false },
                { "title": "固定标签3", "closable": false }
            ]
        }
    }
    }
}
