import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: wrapper

    function show(parentWindow) {
        if (parentWindow)
            root.transientParent = parentWindow
        syncControls()
        root.visible = true
        root.show()
    }

    function syncControls() {
        darkModeSwitch.checked = EasyTheme.isDark
        radiusSlider.value = ThemeSettings.cornerRadius
        fontSlider.value = ThemeSettings.fontSize
        colorPicker.currentColor = ThemeSettings.primaryColor
    }

    Connections {
        target: ThemeSettings
        function onThemeSettingsChanged() {
            syncControls()
        }
    }

    EasySimpleWindow {
        id: root
        title: "主题设置"
        width: 520
        height: 600
        minimumWidth: 400
        minimumHeight: 420
        visible: false
        showWhenReady: false
        modality: Qt.WindowModal

        Flickable {
            anchors {
                left: parent.left; right: parent.right
                top: parent.top; bottom: parent.bottom
                leftMargin: 16; topMargin: 16; bottomMargin: 16; rightMargin: 2
            }
            clip: true
            contentHeight: themeCol.implicitHeight
            ScrollBar.vertical: EasyScrollBar { }

            ColumnLayout {
                id: themeCol
                width: parent.width - 16
                spacing: 12

                // ═══ 外观设置 ═══
                Rectangle {
                    Layout.fillWidth: true
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

                            Repeater {
                                model: ["#528bff", "#9c27b0", "#4caf50", "#ff9800", "#f44336", "#00bcd4", "#e91e63", "#3f51b5"]

                                delegate: Rectangle {
                                    width: 32; height: 32; radius: 16
                                    color: "transparent"
                                    property bool active: ThemeSettings.primaryColor === modelData

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: active ? 28 : 22; height: active ? 28 : 22; radius: active ? 14 : 11
                                        color: modelData
                                        Behavior on width { NumberAnimation { duration: 120 } }
                                        Behavior on height { NumberAnimation { duration: 120 } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: ThemeSettings.setPrimaryColor(modelData)
                                    }
                                }
                            }
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
                        onClicked: ThemeSettings.resetToDefaults()
                    }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: 16 }
            }
        }
    }
}
