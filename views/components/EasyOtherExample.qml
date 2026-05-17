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

    // ========== EasyDivider ==========
    Text {
        text: "分隔线 (EasyDivider)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 16
        width: parent.width
        Text { text: "上方内容"; color: EasyTheme.color.text }
        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }
        Text { text: "下方内容"; color: EasyTheme.color.text }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyCard ==========
    Text {
        text: "卡片 (EasyCard)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    EasyCard {
        Layout.fillWidth: true
        ColumnLayout {
            spacing: 8
            width: parent.width
            Text { text: "卡片标题"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }
            Text { text: "这是一个卡片组件的示例内容。"; font.pixelSize: 13; color: EasyTheme.color.text }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyCarousel ==========
    Text {
        text: "轮播 (EasyCarousel)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    EasyCarousel {
        Layout.fillWidth: true
        carouselHeight: 180
        items: [
            { "image": "", "title": "欢迎使用 EasyUI", "description": "一套现代化的 Qt Quick 组件库" },
            { "image": "", "title": "丰富的组件", "description": "包含按钮、输入框、表格等 40+ 组件" },
            { "image": "", "title": "主题切换", "description": "支持亮色/暗色主题，一键切换" }
        ]
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyLyric ==========
    Text {
        text: "歌词 (EasyLyric)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    Rectangle {
        Layout.fillWidth: true
        height: 200
        color: EasyTheme.color.card
        radius: 12
        EasyLyric {
            anchors.fill: parent
            anchors.margins: 20
            lineHeight: 36
            lyricText: "[00:00.00]晴天 - 周杰伦\n[00:05.00]故事的小黄花\n[00:08.00]从出生那年就飘着\n[00:12.00]童年的荡秋千\n[00:15.00]随记忆一直晃到现在"
            currentTime: 8000
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyIconFont ==========
    Text {
        text: "图标字体 (EasyIconFont)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text { text: "常用图标"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 16
            EasyIconFont { icon: "\ue88a"; iconSize: 24 }
            EasyIconFont { icon: "\ue8b8"; iconSize: 24 }
            EasyIconFont { icon: "\ue8b6"; iconSize: 24 }
            EasyIconFont { icon: "\ue158"; iconSize: 24 }
            EasyIconFont { icon: "\ue7f4"; iconSize: 24 }
            EasyIconFont { icon: "\ue7fd"; iconSize: 24 }
            EasyIconFont { icon: "\ue5cd"; iconSize: 24 }
            EasyIconFont { icon: "\ue145"; iconSize: 24 }
            EasyIconFont { icon: "\ue872"; iconSize: 24 }
            EasyIconFont { icon: "\ue87d"; iconSize: 24 }
        }
        Text { text: "自定义颜色"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 16
            EasyIconFont { icon: "\ue87d"; iconSize: 24; color: EasyTheme.color.primary }
            EasyIconFont { icon: "\ue87d"; iconSize: 24; color: EasyTheme.color.success }
            EasyIconFont { icon: "\ue87d"; iconSize: 24; color: EasyTheme.color.warning }
            EasyIconFont { icon: "\ue87d"; iconSize: 24; color: EasyTheme.color.colorError }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyMarkdownView ==========
    Text {
        text: "Markdown视图 (EasyMarkdownView)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    EasyMarkdownView {
        Layout.fillWidth: true
        text: "# EasyUI Markdown 示例\n\n## 功能特性\n\n- **代码高亮** 支持多种编程语言\n- **表格渲染** 自动对齐和样式\n- **文本选择** 支持复制\n\n```cpp\n#include <QObject>\n\nclass Example : public QObject {\n    Q_OBJECT\n};\n```\n\n| 特性 | 支持 |\n|------|------|\n| 代码块 | 是 |\n| 表格 | 是 |\n| 图片 | 是 | \n 我无法直接生成或返回图片链接，但可以通过搜索获取网络上的图片。让我搜索一张图片给你。
![Qt Design Studio 2.0](https://kimi-web-img.moonshot.cn/img/www.qt.io/adfff155ed3039d3760ad41286f705999fa914fc.png )

Qt Design Studio 的界面设计工具截图。\n"
    }
    }
}
