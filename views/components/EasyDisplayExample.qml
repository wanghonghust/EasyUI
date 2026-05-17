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

    // ========== EasyBadge ==========
    Text {
        text: "徽标 (EasyBadge)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text { text: "不同尺寸"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 16
            EasyBadge { text: "9"; size: EasyTheme.size.sizeMini }
            EasyBadge { text: "9"; size: EasyTheme.size.sizeSmall }
            EasyBadge { text: "9" }
            EasyBadge { text: "9"; size: EasyTheme.size.sizeLarge }
        }
        Text { text: "类型"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 16
            EasyBadge { text: "99+" }
            EasyBadge { dot: true }
            EasyBadge { text: "New"; type: "success" }
            EasyBadge { text: "Hot"; type: "warning" }
            EasyBadge { text: "Error"; type: "error" }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyTag ==========
    Text {
        text: "标签 (EasyTag)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text { text: "不同尺寸"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 12
            EasyTag { text: "Mini"; size: EasyTheme.size.sizeMini }
            EasyTag { text: "Small"; size: EasyTheme.size.sizeSmall }
            EasyTag { text: "Normal" }
            EasyTag { text: "Large"; size: EasyTheme.size.sizeLarge }
        }
        Text { text: "类型与状态"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 12
            EasyTag { text: "标签一" }
            EasyTag { text: "可关闭"; closable: true }
            EasyTag { text: "成功"; type: "success" }
            EasyTag { text: "警告"; type: "warning"; closable: true }
            EasyTag { text: "错误"; type: "error" }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyAvatar ==========
    Text {
        text: "头像 (EasyAvatar)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 20
        EasyAvatar { text: "张"; size: 48 }
        EasyAvatar { text: "李明"; size: 48 }
        EasyAvatar { text: "Wang"; size: 48; shape: "square" }
        EasyAvatar { text: "图"; size: 48 }
        EasyAvatar { text: "陈"; size: 48; borderWidth: 2 }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyProgress ==========
    Text {
        text: "进度条 (EasyProgress)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 16
        width: parent.width
        EasyProgress { value: 35; width: 300 }
        EasyProgress { value: 68; width: 300; showText: true }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyLoading ==========
    Text {
        text: "加载状态 (EasyLoading)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 32
        Column {
            spacing: 8
            EasyLoading { spinning: true; size: 36 }
            Text { text: "旋转加载"; font.pixelSize: 12; color: EasyTheme.color.placeholder; anchors.horizontalCenter: parent.horizontalCenter }
        }
        Column {
            spacing: 8
            EasyLoading { spinning: false; size: 36 }
            Text { text: "静态加载"; font.pixelSize: 12; color: EasyTheme.color.placeholder; anchors.horizontalCenter: parent.horizontalCenter }
        }
        Column {
            spacing: 8
            EasyLoading { spinning: true; size: 36; text: "加载中..." }
            Text { text: "带文字"; font.pixelSize: 12; color: EasyTheme.color.placeholder; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasySkeleton ==========
    Text {
        text: "骨架屏 (EasySkeleton)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    Text {
        text: "内容加载占位，带 shimmer 动画"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
    }
    EasySkeleton { rows: 4; rowHeight: 14; spacing: 10 }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyEmpty ==========
    Text {
        text: "空状态 (EasyEmpty)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 24
        Layout.fillWidth: true

        Rectangle {
            Layout.preferredWidth: 200
            height: 140
            color: EasyTheme.isDark ? Qt.rgba(1,1,1,0.03) : Qt.rgba(0,0,0,0.02)
            radius: 8

            EasyEmpty {
                anchors.centerIn: parent
                title: "暂无数据"
                description: "请稍后再试"
            }
        }

        Rectangle {
            Layout.preferredWidth: 200
            height: 140
            color: EasyTheme.isDark ? Qt.rgba(1,1,1,0.03) : Qt.rgba(0,0,0,0.02)
            radius: 8

            EasyEmpty {
                anchors.centerIn: parent
                icon: EasyIcon.material.search_off
                title: "未找到结果"
                description: "请修改搜索条件"
            }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyTimeline ==========
    Text {
        text: "时间线 (EasyTimeline)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    EasyTimeline {
        Layout.fillWidth: true
        items: [
            { "title": "项目立项", "time": "2024-01-15", "description": "确定项目方向和技术方案", "color": "#409eff" },
            { "title": "UI 设计", "time": "2024-02-01", "description": "完成界面设计和原型制作", "color": "#67c23a" },
            { "title": "核心开发", "time": "2024-03-10", "description": "完成主要功能模块开发", "color": "#e6a23c" },
            { "title": "测试上线", "time": "2024-04-20", "description": "系统测试并正式上线", "color": "#f56c6c" }
        ]
    }
    }
}
