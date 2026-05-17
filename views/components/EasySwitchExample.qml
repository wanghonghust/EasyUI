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

    // ========== EasySwitch ==========
    Text {
        text: "开关 (EasySwitch)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text {
            text: "不同尺寸"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 24
            ColumnLayout {
                spacing: 4
                EasySwitch {
                    checked: true
                    size: EasyTheme.size.sizeMini
                }
                Text {
                    text: "Mini"
                    font.pixelSize: 11
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                spacing: 4
                EasySwitch {
                    checked: true
                    size: EasyTheme.size.sizeSmall
                }
                Text {
                    text: "Small"
                    font.pixelSize: 11
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                spacing: 4
                EasySwitch {
                    checked: true
                }
                Text {
                    text: "Normal"
                    font.pixelSize: 11
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                spacing: 4
                EasySwitch {
                    checked: true
                    size: EasyTheme.size.sizeLarge
                }
                Text {
                    text: "Large"
                    font.pixelSize: 11
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        Text {
            text: "状态"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 24
            ColumnLayout {
                EasySwitch {
                    checked: true
                }
                Text {
                    text: "开启"
                    font.pixelSize: 12
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                EasySwitch {
                    checked: false
                }
                Text {
                    text: "关闭"
                    font.pixelSize: 12
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    EasyDivider {
        Layout.fillWidth: true
        orientation: Qt.Horizontal
    }

    // ========== EasyCheckbox ==========
    Text {
        text: "复选框 (EasyCheckbox)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text {
            text: "不同尺寸"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 24
            EasyCheckbox {
                text: "Mini"
                size: EasyTheme.size.sizeMini
                checked: true
            }
            EasyCheckbox {
                text: "Small"
                size: EasyTheme.size.sizeSmall
                checked: true
            }
            EasyCheckbox {
                text: "Normal"
                checked: true
            }
            EasyCheckbox {
                text: "Large"
                size: EasyTheme.size.sizeLarge
                checked: true
            }
        }
        Text {
            text: "状态"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 24
            EasyCheckbox {
                text: "选中"
                checked: true
            }
            EasyCheckbox {
                text: "未选"
                checked: false
            }
            EasyCheckbox {
                text: "禁用"
                enabled: false
            }
        }
    }

    EasyDivider {
        Layout.fillWidth: true
        orientation: Qt.Horizontal
    }

    // ========== EasyRadio ==========
    Text {
        text: "单选框 (EasyRadio)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text {
            text: "不同尺寸"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 24
            EasyRadio {
                text: "Mini"
                size: EasyTheme.size.sizeMini
                checked: true
            }
            EasyRadio {
                text: "Small"
                size: EasyTheme.size.sizeSmall
            }
            EasyRadio {
                text: "Normal"
                checked: false
            }
            EasyRadio {
                text: "Large"
                size: EasyTheme.size.sizeLarge
            }
        }
        Text {
            text: "状态"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 24
            EasyRadio {
                text: "选中"
                checked: true
            }
            EasyRadio {
                text: "未选"
                checked: false
            }
            EasyRadio {
                text: "禁用"
                enabled: false
            }
        }
    }

    Text {
        text: "单选组 (EasyRadioGroup)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    Text {
        text: "同一组内的单选框互斥，点击自动切换"
        font.pixelSize: 12
        color: EasyTheme.color.placeholder
    }
    ColumnLayout {
        spacing: 8
        width: parent.width

        EasyRadioGroup { id: fruitGroup }

        RowLayout {
            spacing: 24
            EasyRadio { text: "苹果"; group: fruitGroup; value: "apple"; checked: true }
            EasyRadio { text: "香蕉"; group: fruitGroup; value: "banana" }
            EasyRadio { text: "橙子"; group: fruitGroup; value: "orange" }
        }

        Text {
            text: "选择: " + (fruitGroup.radios.find(r => r.checked) ? fruitGroup.radios.find(r => r.checked).value : "无")
            font.pixelSize: 13
            color: EasyTheme.color.primary
        }
    }

    ColumnLayout {
        spacing: 8
        width: parent.width

        EasyRadioGroup { id: sizeGroup }

        Text {
            text: "不同尺寸组的互斥"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 20
            EasyRadio { text: "小号"; group: sizeGroup; value: "s"; size: EasyTheme.size.sizeSmall }
            EasyRadio { text: "中号"; group: sizeGroup; value: "m"; checked: true }
            EasyRadio { text: "大号"; group: sizeGroup; value: "l"; size: EasyTheme.size.sizeLarge }
        }
    }

    EasyDivider {
        Layout.fillWidth: true
        orientation: Qt.Horizontal
    }

    // ========== EasyToggle ==========
    Text {
        text: "切换按钮 (EasyToggle)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text {
            text: "不同尺寸"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 16
            ColumnLayout {
                spacing: 4
                EasyToggle {
                    text: "Mini"
                    size: EasyTheme.size.sizeMini
                    checked: true
                }
                Text {
                    text: "Mini"
                    font.pixelSize: 11
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                spacing: 4
                EasyToggle {
                    text: "Small"
                    size: EasyTheme.size.sizeSmall
                    checked: true
                }
                Text {
                    text: "Small"
                    font.pixelSize: 11
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                spacing: 4
                EasyToggle {
                    text: "Normal"
                    checked: true
                }
                Text {
                    text: "Normal"
                    font.pixelSize: 11
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                spacing: 4
                EasyToggle {
                    text: "Large"
                    size: EasyTheme.size.sizeLarge
                    checked: true
                }
                Text {
                    text: "Large"
                    font.pixelSize: 11
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        Text {
            text: "状态"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            spacing: 16
            ColumnLayout {
                spacing: 8
                EasyToggle {
                    text: "开启"
                    checked: true
                }
                Text {
                    text: "选中"
                    font.pixelSize: 12
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                spacing: 8
                EasyToggle {
                    text: "关闭"
                }
                Text {
                    text: "未选中"
                    font.pixelSize: 12
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            ColumnLayout {
                spacing: 8
                EasyToggle {
                    text: "禁用"
                    enabled: false
                }
                Text {
                    text: "禁用"
                    font.pixelSize: 12
                    color: EasyTheme.color.placeholder
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
    }
}
