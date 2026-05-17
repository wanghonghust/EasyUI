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

        // ========== 基础用法 ==========
        Text {
            text: "基础用法"
            font.pixelSize: 16; font.bold: true
            color: EasyTheme.color.text
        }
        Text {
            text: "输入后按 Enter 添加标签，点击标签 × 删除"
            font.pixelSize: 12; color: EasyTheme.color.placeholder
            Layout.fillWidth: true
        }

        EasyChipInput {
            Layout.fillWidth: true
            placeholder: "输入标签后按 Enter"
        }

        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

        // ========== 预置 + 不同尺寸 ==========
        Text {
            text: "预置标签 · 不同尺寸"
            font.pixelSize: 16; font.bold: true
            color: EasyTheme.color.text
        }

        EasyChipInput {
            size: EasyTheme.size.sizeSmall
            Layout.fillWidth: true
            placeholder: "继续添加..."
            chips: [
                { text: "Qt Quick", color: "#6366f1" },
                { text: "C++", color: "#f59e0b" },
                { text: "QML", color: "#10b981" }
            ]
        }

        EasyChipInput {
            Layout.fillWidth: true
            placeholder: "继续添加..."
            chips: [
                { text: "TypeScript", color: "#3178c6" },
                { text: "Python", color: "#3776ab" },
                { text: "Rust", color: "#dea584" },
                { text: "Go", color: "#00add8" }
            ]
        }

        EasyChipInput {
            size: EasyTheme.size.sizeLarge
            Layout.fillWidth: true
            placeholder: "继续添加..."
            chips: [
                { text: "Vue", color: "#42b883" },
                { text: "React", color: "#61dafb" }
            ]
        }

        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

        // ========== 只读 / 限制数量 ==========
        Text {
            text: "只读 & 数量限制"
            font.pixelSize: 16; font.bold: true
            color: EasyTheme.color.text
        }
        Text {
            text: "只读模式不可删除/添加。maxChips=5 达到上限后隐藏输入框"
            font.pixelSize: 12; color: EasyTheme.color.placeholder
            Layout.fillWidth: true
        }

        EasyChipInput {
            readOnly: true
            Layout.fillWidth: true
            chips: [
                { text: "HTTP", color: "#6366f1" },
                { text: "WebSocket", color: "#f59e0b" },
                { text: "gRPC", color: "#10b981" }
            ]
        }

        EasyChipInput {
            maxChips: 5
            Layout.fillWidth: true
            placeholder: "最多 5 个标签..."
            chips: [
                { text: "Tag1" }, { text: "Tag2" }, { text: "Tag3" }, { text: "Tag4" }
            ]
        }
    }
}
