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

    // ========== EasyInput ==========
    Text {
        text: "输入框 (EasyInput)"
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
            EasyInput { placeholder: "Mini"; width: 160; size: EasyTheme.size.sizeMini }
            EasyInput { placeholder: "Small"; width: 160; size: EasyTheme.size.sizeSmall }
            EasyInput { placeholder: "Normal"; width: 160 }
            EasyInput { placeholder: "Large"; width: 160; size: EasyTheme.size.sizeLarge }
        }
        Text { text: "类型"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 16
            EasyInput { placeholder: "普通输入"; width: 200 ;clearable: true}
            EasyInput { placeholder: "密码"; password: true; width: 200;clearable: true }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyNumberInput ==========
    Text {
        text: "数字输入框 (EasyNumberInput)"
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
            EasyNumberInput { value: 10; size: EasyTheme.size.sizeMini }
            EasyNumberInput { value: 20; size: EasyTheme.size.sizeSmall }
            EasyNumberInput { value: 30 }
            EasyNumberInput { value: 40; size: EasyTheme.size.sizeLarge }
        }
        Text { text: "整数范围"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        EasyNumberInput { value: 50; min: 0; max: 100; step: 1 }
        Text { text: "小数精度"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        EasyNumberInput { value: 1.5; min: 0.0; max: 10.0; step: 0.1; precision: 2 }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyIPInput ==========
    Text {
        text: "IP地址输入框 (EasyIPInput)"
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
            EasyIPInput { placeholder: "192.168.1.1"; width: 180; size: EasyTheme.size.sizeMini }
            EasyIPInput { placeholder: "192.168.1.1"; width: 180; size: EasyTheme.size.sizeSmall }
            EasyIPInput { placeholder: "192.168.1.1"; width: 180 }
            EasyIPInput { placeholder: "192.168.1.1"; width: 180; size: EasyTheme.size.sizeLarge }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyMACInput ==========
    Text {
        text: "MAC地址输入框 (EasyMACInput)"
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
            EasyMACInput { placeholder: "AA:BB:CC:DD:EE:FF"; width: 220; size: EasyTheme.size.sizeMini }
            EasyMACInput { placeholder: "AA:BB:CC:DD:EE:FF"; width: 220; size: EasyTheme.size.sizeSmall }
            EasyMACInput { placeholder: "AA:BB:CC:DD:EE:FF"; width: 220 }
            EasyMACInput { placeholder: "AA:BB:CC:DD:EE:FF"; width: 220; size: EasyTheme.size.sizeLarge }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyTextArea ==========
    Text {
        text: "多行文本框 (EasyTextArea)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        RowLayout {
            spacing: 16
            EasyTextArea { placeholder: "请输入多行文本..."; width: 280; height: 100 }
            EasyTextArea { placeholder: "只读模式"; text: "这是一段只读的示例文本。"; width: 280; height: 80; readOnly: true }
            EasyTextArea { placeholder: "禁用状态"; width: 280; height: 80; enabled: false }
        }
        EasyTextArea { placeholder: "显示字数统计"; width: 280; height: 80; maxLength: 100; showCount: true }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasySearchInput ==========
    Text {
        text: "搜索框 (EasySearchInput)"
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
            EasySearchInput { placeholder: "Mini"; width: 180; size: EasyTheme.size.sizeMini }
            EasySearchInput { placeholder: "Small"; width: 180; size: EasyTheme.size.sizeSmall }
            EasySearchInput { placeholder: "Normal"; width: 180 }
            EasySearchInput { placeholder: "Large"; width: 180; size: EasyTheme.size.sizeLarge }
        }
    }
    }
}
