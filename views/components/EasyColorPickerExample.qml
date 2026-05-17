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

        Text { text: "颜色选择器 (EasyColorPicker)"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }

        ColumnLayout {
            spacing: 12; width: parent.width

            Text { text: "基础用法"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyColorPicker { currentColor: "#FF4f6ef7" }
                EasyColorPicker { currentColor: "#FF22c55e" }
                EasyColorPicker { currentColor: "#FFef4444" }
            }

            Text { text: "不同尺寸"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyColorPicker { size: EasyTheme.size.sizeMini; currentColor: "#FF4f6ef7" }
                EasyColorPicker { size: EasyTheme.size.sizeSmall; currentColor: "#FF22c55e" }
                EasyColorPicker { currentColor: "#FFf59e0b" }
                EasyColorPicker { size: EasyTheme.size.sizeLarge; currentColor: "#FFef4444" }
            }

            Text { text: "带透明度的颜色"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyColorPicker { currentColor: "#804f6ef7" }
                EasyColorPicker { currentColor: "#40ef4444" }
                EasyColorPicker { currentColor: "#CC22c55e" }
            }

            Text { text: "可清除"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyColorPicker { currentColor: "#FF6366f1"; clearable: true }
                EasyColorPicker { currentColor: "#FF22c55e"; clearable: true }
            }

            Text { text: "禁用状态"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyColorPicker { currentColor: "#FF4f6ef7"; enabled: false }
                EasyColorPicker { currentColor: "#FF22c55e"; enabled: false }
            }
        }

        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

        Text { text: "事件处理"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }

        ColumnLayout {
            spacing: 12; width: parent.width

            Text { text: "选择颜色后触发 colorSelected 信号"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 16
                EasyColorPicker {
                    id: demoPicker
                    currentColor: "#FF6366f1"
                    onColorSelected: function(color) {
                        previewRect.color = color
                    }
                }
                Rectangle {
                    id: previewRect
                    width: 40; height: 40
                    radius: 8
                    color: demoPicker.currentColor
                    border.color: EasyTheme.color.border
                    border.width: 1
                }
            }
        }
    }
}