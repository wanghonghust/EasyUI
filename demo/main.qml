import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

EasyFramelessWindow {
    id: window
    title: "EasyUI Demo"
    width: 640
    height: 480
    minimumWidth: 400
    minimumHeight: 300

    showThemeButton: true
    showMinimizeButton: true
    showMaximizeButton: true
    showCloseButton: true

    Component.onCompleted: {
        window.visible = true
    }

    Rectangle {
        anchors.fill: parent
        color: EasyTheme.color.background

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24

            Text {
                text: "EasyUI Demo"
                font.pixelSize: 28
                font.bold: true
                color: EasyTheme.color.text
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Qt 6 / QML Component Library"
                font.pixelSize: 14
                color: EasyTheme.color.secondary
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignHCenter

                EasyButton {
                    text: "主按钮"
                    primary: true
                    onClicked: console.log("primary clicked")
                }
                EasyButton {
                    text: "次要按钮"
                    primary: false
                    onClicked: console.log("secondary clicked")
                }
                EasyButton {
                    text: "禁用"
                    enabled: false
                }
            }

            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignHCenter

                EasyInput {
                    Layout.preferredWidth: 200
                    placeholder: "输入文字..."
                }
                EasySelect {
                    width: 160
                    options: ["选项一", "选项二", "选项三"]
                    currentIndex: 0
                }
            }

            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignHCenter

                EasySwitch {
                    id: darkSwitch
                    checked: EasyTheme.isDark
                    onCheckedChanged: ThemeSettings.setDarkMode(checked)
                }
                Text {
                    text: "深色模式"
                    font.pixelSize: 13
                    color: EasyTheme.color.text
                }
            }

            EasyDivider {
                Layout.fillWidth: true
                Layout.preferredWidth: 300
            }

            Text {
                text: "EasyUI v1.0 — 50+ components ready"
                font.pixelSize: 11
                color: EasyTheme.color.placeholder
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
