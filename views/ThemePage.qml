import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI


/**
 * ThemePage —— 主题设置页面
 */
ScrollView {
    id: root
    clip: true
    ScrollBar.vertical: EasyScrollBar { }
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    contentWidth: availableWidth

    background: Rectangle {
        color: EasyTheme.color.background
    }

    ColumnLayout {
        width: root.width - 40
        x: 20
        spacing: 12

        // ═══ 外观设置 ═══
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 16
            radius: EasyTheme.size.radiusLarge
            color: EasyTheme.color.card
            border.color: EasyTheme.color.border
            height: appearanceContent.implicitHeight + 24

            ColumnLayout {
                id: appearanceContent
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                spacing: 10

                Row {
                    spacing: 6
                    EasyIconFont { icon: EasyIcon.material.palette; iconSize: 16; color: EasyTheme.color.primary }
                    Text { text: "外观"; font.pixelSize: 13; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                }

                // 深色模式
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        Text { text: "深色模式"; font.pixelSize: 12; color: EasyTheme.color.text }
                        Text { text: "切换深色/浅色主题"; font.pixelSize: 11; color: EasyTheme.color.placeholder }
                    }
                    EasySwitch {
                        id: darkModeSwitch
                        checked: EasyTheme.isDark
                        onCheckedChanged: ThemeSettings.setDarkMode(checked)
                    }
                }

                EasyDivider {}

                // 主题色
                Text { text: "主题色"; font.pixelSize: 12; color: EasyTheme.color.text }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8

                    ColorButton { active: ThemeSettings.primaryColor === "#528bff"; btnColor: "#528bff"; onBtnClicked: ThemeSettings.setPrimaryColor("#528bff") }
                    ColorButton { active: ThemeSettings.primaryColor === "#9c27b0"; btnColor: "#9c27b0"; onBtnClicked: ThemeSettings.setPrimaryColor("#9c27b0") }
                    ColorButton { active: ThemeSettings.primaryColor === "#4caf50"; btnColor: "#4caf50"; onBtnClicked: ThemeSettings.setPrimaryColor("#4caf50") }
                    ColorButton { active: ThemeSettings.primaryColor === "#ff9800"; btnColor: "#ff9800"; onBtnClicked: ThemeSettings.setPrimaryColor("#ff9800") }
                    ColorButton { active: ThemeSettings.primaryColor === "#f44336"; btnColor: "#f44336"; onBtnClicked: ThemeSettings.setPrimaryColor("#f44336") }
                    ColorButton { active: ThemeSettings.primaryColor === "#00bcd4"; btnColor: "#00bcd4"; onBtnClicked: ThemeSettings.setPrimaryColor("#00bcd4") }
                    ColorButton { active: ThemeSettings.primaryColor === "#e91e63"; btnColor: "#e91e63"; onBtnClicked: ThemeSettings.setPrimaryColor("#e91e63") }
                    ColorButton { active: ThemeSettings.primaryColor === "#3f51b5"; btnColor: "#3f51b5"; onBtnClicked: ThemeSettings.setPrimaryColor("#3f51b5") }
                }

                RowLayout {
                    spacing: 8
                    Text { text: "自定义"; font.pixelSize: 11; color: EasyTheme.color.placeholder }
                    EasyColorPicker {
                        id: colorPicker
                        currentColor: ThemeSettings.primaryColor
                        Layout.preferredWidth: 120
                        onColorSelected: c => ThemeSettings.setPrimaryColor(c)
                    }
                }
            }
        }

        // ═══ 界面设置 ═══
        Rectangle {
            Layout.fillWidth: true
            radius: EasyTheme.size.radiusLarge
            color: EasyTheme.color.card
            border.color: EasyTheme.color.border
            height: interfaceContent.implicitHeight + 24

            ColumnLayout {
                id: interfaceContent
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                spacing: 10

                Row {
                    spacing: 6
                    EasyIconFont { icon: EasyIcon.material.space_dashboard; iconSize: 16; color: EasyTheme.color.primary }
                    Text { text: "界面"; font.pixelSize: 13; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                }

                // 圆角大小
                Text { text: "圆角大小"; font.pixelSize: 12; color: EasyTheme.color.text }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    EasySlider {
                        id: radiusSlider
                        from: 0; to: 20
                        value: ThemeSettings.cornerRadius
                        Layout.fillWidth: true
                        onValueEdited: value => ThemeSettings.setCornerRadius(value)
                    }
                    Text {
                        text: Math.round(radiusSlider.value) + "px"
                        font.pixelSize: 12; color: EasyTheme.color.placeholder
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        width: 48; height: 28
                        radius: radiusSlider.value
                        color: EasyTheme.color.primary
                        Behavior on radius { NumberAnimation { duration: 150 } }
                    }
                    Rectangle {
                        width: 48; height: 28
                        radius: radiusSlider.value
                        color: "transparent"
                        border.color: EasyTheme.color.border
                        border.width: 1
                        Behavior on radius { NumberAnimation { duration: 150 } }
                    }
                }

                EasyDivider {}

                // 字体大小
                Text { text: "字体大小"; font.pixelSize: 12; color: EasyTheme.color.text }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    EasySlider {
                        id: fontSlider
                        from: 10; to: 20
                        value: ThemeSettings.fontSize
                        Layout.fillWidth: true
                        onValueEdited: value => ThemeSettings.setFontSize(value)
                    }
                    Text {
                        text: Math.round(fontSlider.value) + "px"
                        font.pixelSize: 12; color: EasyTheme.color.placeholder
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Text {
                    text: "Aa 这是一段预览文字"
                    font.pixelSize: ThemeSettings.fontSize
                    color: EasyTheme.color.secondary
                }
            }
        }

        // ═══ 组件预览 ═══
        Rectangle {
            Layout.fillWidth: true
            radius: EasyTheme.size.radiusLarge
            color: EasyTheme.color.card
            border.color: EasyTheme.color.border
            height: previewContent.implicitHeight + 24

            ColumnLayout {
                id: previewContent
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                spacing: 8

                Row {
                    spacing: 6
                    EasyIconFont { icon: EasyIcon.material.grid_view; iconSize: 16; color: EasyTheme.color.primary }
                    Text { text: "组件预览"; font.pixelSize: 13; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { text: "按钮"; font.pixelSize: 11; color: EasyTheme.color.placeholder; Layout.preferredWidth: 48 }
                    EasyButton { text: "主要"; primary: true; size: EasyTheme.size.sizeSmall }
                    EasyButton { text: "次要"; primary: false; size: EasyTheme.size.sizeSmall }
                    EasyButton { text: "禁用"; enabled: false; size: EasyTheme.size.sizeSmall }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { text: "输入框"; font.pixelSize: 11; color: EasyTheme.color.placeholder; Layout.preferredWidth: 48 }
                    EasyInput { placeholder: "请输入..."; Layout.fillWidth: true }
                    EasySelect { placeholder: "选择"; options: ["选项一", "选项二", "选项三"] }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { text: "标签"; font.pixelSize: 11; color: EasyTheme.color.placeholder; Layout.preferredWidth: 48 }
                    EasyTag { text: "默认" }
                    EasyTag { text: "成功"; type: "success" }
                    EasyTag { text: "警告"; type: "warning" }
                    EasyTag { text: "错误"; type: "error" }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    Row { spacing: 6
                        Text { text: "开关"; font.pixelSize: 11; color: EasyTheme.color.placeholder; anchors.verticalCenter: parent.verticalCenter }
                        EasySwitch { checked: true; anchors.verticalCenter: parent.verticalCenter }
                        EasySwitch { checked: false; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Row { spacing: 6
                        Text { text: "复选框"; font.pixelSize: 11; color: EasyTheme.color.placeholder; anchors.verticalCenter: parent.verticalCenter }
                        EasyCheckbox { text: "选项"; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Row { spacing: 6
                        Text { text: "切换"; font.pixelSize: 11; color: EasyTheme.color.placeholder; anchors.verticalCenter: parent.verticalCenter }
                        EasyToggle { text: "开启"; checked: true; size: EasyTheme.size.sizeSmall; anchors.verticalCenter: parent.verticalCenter }
                        EasyToggle { text: "关闭"; size: EasyTheme.size.sizeSmall; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }

        // ═══ 恢复默认 ═══
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            Item { Layout.fillWidth: true }
            EasyButton {
                text: "恢复默认"
                icon: EasyIcon.material.settings_backup_restore
                primary: false
                onClicked: {
                    ThemeSettings.resetToDefaults()
                    darkModeSwitch.checked = false
                    radiusSlider.value = 8
                    fontSlider.value = 14
                    colorPicker.currentColor = "#528bff"
                }
            }
        }

        // 底部留白
        Item { Layout.fillHeight: true; Layout.minimumHeight: 20 }
    }

    // 颜色选择按钮组件
    component ColorButton: Rectangle {
        property bool active: false
        property color btnColor: "#528bff"
        signal btnClicked

        width: 32; height: 32; radius: 16
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            width: active ? 28 : 22; height: active ? 28 : 22; radius: active ? 14 : 11
            color: btnColor
            Behavior on width { NumberAnimation { duration: 120 } }
            Behavior on height { NumberAnimation { duration: 120 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: btnClicked()
        }
    }
}
