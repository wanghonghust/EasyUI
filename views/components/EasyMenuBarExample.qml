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

    // ========== EasyMenuBar ==========
    Text {
        text: "菜单栏 (EasyMenuBar)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }

    Text {
        text: "展开状态"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
    }

    Rectangle {
        Layout.fillWidth: true
        height: 260
        color: EasyTheme.color.card
        radius: 8

        EasyMenuBar {
            anchors.fill: parent
            anchors.margins: 8
            menus: [
                { "title": "首页", "icon": "\ue88a", "url": "home", "children": [] },
                { "title": "设置", "icon": "\ue8b8", "url": "theme", "children": [
                    { "title": "主题", "icon": "", "url": "theme", "children": [] },
                    { "title": "字体", "icon": "", "url": "font", "children": [] }
                ]},
                { "title": "帮助", "icon": "\ue88e", "url": "about", "children": [] }
            ]
            activePath: "home"
        }
    }

    Text {
        text: "折叠状态"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
    }

    Rectangle {
        width: 60
        height: 260
        color: EasyTheme.color.card
        radius: 8

        EasyMenuBar {
            anchors.fill: parent
            anchors.margins: 8
            collapsed: true
            menus: [
                { "title": "首页", "icon": "\ue88a", "url": "home", "children": [] },
                { "title": "设置", "icon": "\ue8b8", "url": "theme", "children": [] },
                { "title": "帮助", "icon": "\ue88e", "url": "about", "children": [] }
            ]
            activePath: "home"
        }
    }
    }
}
