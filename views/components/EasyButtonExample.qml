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

        // ========== EasyButton ==========
        Text { text: "按钮 (EasyButton)"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }

        ColumnLayout {
            spacing: 12; width: parent.width

            // ── 尺寸 ──
            Text { text: "不同尺寸"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyButton { text: "Mini"; size: EasyTheme.size.sizeMini }
                EasyButton { text: "Small"; size: EasyTheme.size.sizeSmall }
                EasyButton { text: "Normal" }
                EasyButton { text: "Large"; size: EasyTheme.size.sizeLarge }
            }

            // ── 类型变体 ──
            Text { text: "类型变体"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyButton { text: "Primary" }
                EasyButton { text: "Success"; type: "success" }
                EasyButton { text: "Warning"; type: "warning" }
                EasyButton { text: "Danger"; type: "danger" }
            }

            // ── 次要按钮(带边框) ──
            Text { text: "次要按钮"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyButton { text: "默认"; primary: false }
                EasyButton { text: "Success"; primary: false; type: "success" }
                EasyButton { text: "Warning"; primary: false; type: "warning" }
                EasyButton { text: "Danger"; primary: false; type: "danger" }
            }

            // ── Plain / 文字按钮 ──
            Text { text: "Plain 文字按钮"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyButton { text: "编辑"; type: "plain" }
                EasyButton { text: "取消"; type: "plain"; primary: false }
                EasyButton { text: "返回"; type: "plain"; primary: false }
            }

            // ── 图标按钮 ──
            Text { text: "图标按钮"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyButton { text: "设置"; icon: EasyIcon.material.settings }
                EasyButton { text: "添加"; icon: EasyIcon.material.add }
                EasyButton { text: "删除"; icon: EasyIcon.material.close; type: "danger" }
            }

            // ── 圆形图标按钮 ──
            Text { text: "圆形图标按钮"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyButton { icon: EasyIcon.material.add; round: true }
                EasyButton { icon: EasyIcon.material.close; round: true; type: "danger" }
                EasyButton { icon: EasyIcon.material.settings; round: true; primary: false }
            }

            // ── 加载态 ──
            Text { text: "加载中"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyButton { text: "保存中..."; loading: true }
                EasyButton { text: "删除中..."; loading: true; type: "danger" }
                EasyButton { text: "加载中..."; loading: true; primary: false }
            }

            // ── 禁用态 ──
            Text { text: "禁用状态"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyButton { text: "禁用"; enabled: false }
                EasyButton { text: "禁用"; enabled: false; primary: false }
                EasyButton { text: "禁用"; enabled: false; type: "danger" }
            }
        }

        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

        // ========== EasyButtonGroup ==========
        Text { text: "按钮组 (EasyButtonGroup)"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }

        ColumnLayout {
            spacing: 12; width: parent.width

            Text { text: "单选模式"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyButtonGroup { buttons: ["日", "周", "月", "年"]; currentIndex: 0 }

            Text { text: "多选模式"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyButtonGroup { buttons: ["加粗", "斜体", "下划线", "删除线"]; exclusive: false; currentIndices: [0, 2] }
        }
    }
}
