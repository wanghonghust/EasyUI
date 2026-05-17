import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: 400

    EasyCommandPalette {
        id: palette
        commands: [
            { id: "home", title: "首页", subtitle: "返回首页仪表盘", icon: "🏠", shortcut: "Ctrl+H", category: "导航" },
            { id: "chat", title: "AI 助手", subtitle: "打开聊天对话界面", icon: "💬", shortcut: "Ctrl+1", category: "导航" },
            { id: "theme", title: "主题设置", subtitle: "自定义颜色和外观", icon: "🎨", shortcut: "Ctrl+T", category: "设置" },
            { id: "new_chat", title: "新建对话", subtitle: "创建一个新的聊天会话", icon: "✚", shortcut: "Ctrl+N", category: "聊天" },
            { id: "search", title: "搜索对话", subtitle: "在所有历史对话中搜索", icon: "🔍", shortcut: "Ctrl+F", category: "聊天" },
            { id: "export", title: "导出对话", subtitle: "导出当前对话为 Markdown", icon: "📥", shortcut: "Ctrl+E", category: "文件" },
            { id: "code_editor", title: "代码编辑器", subtitle: "打开代码编辑工具", icon: "📝", shortcut: "Ctrl+2", category: "导航" },
            { id: "about", title: "关于", subtitle: "查看版本和技术栈信息", icon: "ℹ", category: "系统" }
        ]
        onCommandSelected: function(id, data) {
            palette.close()
            if (id === "home") window.activePath = "home"
            else if (id === "chat") window.activePath = "chat"
            else if (id === "theme") window.activePath = "theme"
            else if (id === "code_editor") window.activePath = "codeeditor"
            else if (id === "about") contentArea.pushUrlTo("about")
            else {} // other commands handled by app
        }
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 16

        Text { text: "命令面板 (Ctrl+K)"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }
        Text { text: "全局搜索和快捷操作入口，支持模糊搜索。"; font.pixelSize: 13; color: EasyTheme.color.secondary; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        Row { spacing: 12
            EasyButton { text: "打开命令面板"; onClicked: palette.open() }
            EasyButton { text: "Ctrl+K 快捷键"; primary: false }
        }

        Text { text: "\n命令数据格式: {id, title, subtitle, icon?, shortcut?, category?, keywords?, data?}"; font.pixelSize: 11; color: EasyTheme.color.placeholder; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }
}
