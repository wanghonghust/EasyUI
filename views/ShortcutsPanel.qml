import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Page {
    id: root
    background: Rectangle { color: EasyTheme.color.background }

    property var shortcutGroups: [
        {
            title: "全局",
            shortcuts: [
                { key: "Ctrl+K", action: "打开命令面板" },
                { key: "Ctrl+Shift+P", action: "打开命令面板" },
                { key: "Ctrl+,", action: "打开设置" },
                { key: "Ctrl+H", action: "回到首页" },
                { key: "Ctrl+1", action: "切换到 AI 助手" },
                { key: "Ctrl+2", action: "切换到代码编辑器" },
                { key: "F11", action: "全屏切换" },
                { key: "Esc", action: "关闭弹窗/对话框" },
            ]
        },
        {
            title: "对话",
            shortcuts: [
                { key: "Enter", action: "发送消息" },
                { key: "Shift+Enter", action: "换行" },
                { key: "Ctrl+N", action: "新建对话" },
                { key: "Ctrl+S", action: "保存当前对话" },
                { key: "Ctrl+E", action: "导出当前对话" },
                { key: "Ctrl+F", action: "搜索历史对话" },
                { key: "Ctrl+Shift+H", action: "打开对话历史" },
                { key: "Ctrl+I", action: "打开提示词库" },
            ]
        },
        {
            title: "代码编辑器",
            shortcuts: [
                { key: "Ctrl+S", action: "保存文件" },
                { key: "Ctrl+Shift+S", action: "另存为" },
                { key: "Ctrl+N", action: "新建文件" },
                { key: "Ctrl+G", action: "跳转到行" },
                { key: "Ctrl+Z", action: "撤销" },
                { key: "Ctrl+Y", action: "重做" },
                { key: "Ctrl+A", action: "全选" },
                { key: "Ctrl++", action: "放大字体" },
                { key: "Ctrl+-", action: "缩小字体" },
                { key: "Ctrl+0", action: "还原字体大小" },
            ]
        },
        {
            title: "主题",
            shortcuts: [
                { key: "Ctrl+Shift+D", action: "切换深色/浅色模式" },
                { key: "Ctrl+Shift+T", action: "打开主题设置" },
            ]
        }
    ]

    ScrollView {
        anchors.fill: parent; padding: 24; clip: true
        ScrollBar.vertical: EasyScrollBar { }

        ColumnLayout {
            width: parent.width - 48; spacing: 24

            Text { text: "⌨️ 快捷键"; font.pixelSize: 24; font.bold: true; color: EasyTheme.color.text }
            Text { text: "按 ? 键可随时打开此面板"; font.pixelSize: 13; color: EasyTheme.color.placeholder }

            Repeater {
                model: root.shortcutGroups
                delegate: ColumnLayout {
                    Layout.fillWidth: true; spacing: 8

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: EasyTheme.color.divider }

                    Text {
                        text: modelData.title; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text
                        Layout.topMargin: 8
                    }

                    Repeater {
                        model: modelData.shortcuts
                        delegate: RowLayout {
                            Layout.fillWidth: true; Layout.preferredHeight: 36
                            spacing: 16

                            Rectangle {
                                Layout.preferredWidth: Math.max(100, keyText.implicitWidth + 20)
                                Layout.preferredHeight: 28; radius: 6
                                color: EasyTheme.color.buttonHover
                                border.color: EasyTheme.color.border; border.width: 1

                                Text {
                                    id: keyText; anchors.centerIn: parent; text: modelData.key
                                    font.pixelSize: 12; font.family: "Consolas, monospace"
                                    color: EasyTheme.color.primary
                                }
                            }

                            Text {
                                Layout.fillWidth: true; text: modelData.action
                                font.pixelSize: 13; color: EasyTheme.color.text
                            }
                        }
                    }
                }
            }

            // Footer
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: EasyTheme.color.divider }
            Text {
                text: "💡 提示：按 Ctrl+K 打开命令面板，可以快速搜索和执行所有命令"
                font.pixelSize: 12; color: EasyTheme.color.secondary; wrapMode: Text.WordWrap; Layout.fillWidth: true
            }
        }
    }
}
