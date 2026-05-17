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

    // ========== EasySelect ==========
    Text {
        text: "选择器 (EasySelect)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    Column {
        spacing: 16
        EasySelect {
            size: EasyTheme.size.sizeMini
            options: ["选项1", "选项2", "选项3", "选项4", "选项5"]
            currentIndex: 0
        }
        EasySelect {
            size: EasyTheme.size.sizeSmall
            options: ["选项1", "选项2", "选项3", "选项4", "选项5"]
            currentIndex: 0
        }
        EasySelect {
            size: EasyTheme.size.sizeLarge
            options: ["选项1", "选项2", "选项3", "选项4", "选项5"]
            currentIndex: 0
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== TimePicker ==========
    Text {
        text: "时间选择器 (TimePicker)"
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
            TimePicker { hour: 9; minute: 36; second: 48; showSeconds: true; size: EasyTheme.size.sizeMini }
            TimePicker { hour: 9; minute: 36; second: 48; showSeconds: true; size: EasyTheme.size.sizeSmall }
            TimePicker { hour: 9; minute: 36; second: 48; showSeconds: true }
            TimePicker { hour: 9; minute: 36; second: 48; showSeconds: true; size: EasyTheme.size.sizeLarge }
        }
        Text { text: "显示模式"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        TimePicker { hour: 14; minute: 30; showSeconds: false }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyDatePicker ==========
    Text {
        text: "日期选择器 (EasyDatePicker)"
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
            EasyDatePicker { width: 160; format: "yyyy-MM-dd"; size: EasyTheme.size.sizeMini }
            EasyDatePicker { width: 160; format: "yyyy-MM-dd"; size: EasyTheme.size.sizeSmall }
            EasyDatePicker { width: 160; format: "yyyy-MM-dd" }
            EasyDatePicker { width: 160; format: "yyyy-MM-dd"; size: EasyTheme.size.sizeLarge }
        }
    }
    }
}
