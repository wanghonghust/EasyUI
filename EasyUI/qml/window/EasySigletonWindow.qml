pragma Singleton

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtCore
import EasyUI

EasySimpleWindow {
    id: singletonWin

    visible: false
    width: 460
    height: 480
    minimumWidth: width
    minimumHeight: height
    maximumWidth: width
    maximumHeight: height
    title: "OSS 配置"
    onlyCloseButton: true

    // 标志位防止重复关闭/打开动画
    property bool isShowing: false

    // ===== OSS 配置属性（供外部读取）=====
    property bool ossEnabled: false
    property string ossEndpoint: ""
    property string ossBucket: ""
    property string ossAccessKeyId: ""
    property string ossAccessKeySecret: ""
    property string ossRegion: ""

    // Settings 持久化（显式属性绑定，避免进入默认 children）
    property Settings ossSettings: Settings {
        category: "OSS"
        property alias enabled: singletonWin.ossEnabled
        property alias endpoint: singletonWin.ossEndpoint
        property alias bucket: singletonWin.ossBucket
        property alias accessKeyId: singletonWin.ossAccessKeyId
        property alias accessKeySecret: singletonWin.ossAccessKeySecret
        property alias region: singletonWin.ossRegion
    }

    function showWindow(parentWindow) {
        if (visible) {
            raise()
            requestActivate()
            return
        }

        // 居中到父窗口
        if (parentWindow) {
            x = parentWindow.x + (parentWindow.width - width) / 2
            y = parentWindow.y + (parentWindow.height - height) / 2
        }

        visible = true
        isShowing = true
    }

    function hideWindow() {
        visible = false
        isShowing = false
    }

    onWindowStateChanged: {

        // hideWindow()
    }

    // ===== 窗口内容：OSS 配置表单 =====
    Rectangle {
        anchors.fill: parent
        color: EasyTheme.color.background

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 14

            // 可滚动内容区
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: formColumn.implicitHeight
                clip: true
                ScrollBar.vertical: EasyScrollBar { }

                ColumnLayout {
                    id: formColumn
                    width: parent.width
                    spacing: 14

                    // 标题
                    Row {
                        spacing: 8
                        Text {
                            text: "☁️"
                            font.pixelSize: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "OSS 文件上传配置"
                            font.pixelSize: 16
                            font.bold: true
                            color: EasyTheme.color.text
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    EasyDivider {
                        Layout.fillWidth: true
                    }

                    // 启用开关
                    Row {
                        spacing: 10
                        EasySwitch {
                            id: ossEnabledSwitch
                            size: EasyTheme.size.sizeSmall
                            checked: ossEnabled
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "启用 OSS 文件上传"
                            font.pixelSize: 13
                            color: EasyTheme.color.text
                        }
                    }

                    // Endpoint
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Text {
                            text: "Endpoint"
                            font.pixelSize: 12
                            color: EasyTheme.color.placeholder
                        }
                        EasyInput {
                            id: endpointInput
                            Layout.fillWidth: true
                            size: EasyTheme.size.sizeSmall
                            placeholder: "如: oss-cn-hangzhou.aliyuncs.com"
                            text: ossEndpoint
                        }
                    }

                    // Bucket
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Text {
                            text: "Bucket"
                            font.pixelSize: 12
                            color: EasyTheme.color.placeholder
                        }
                        EasyInput {
                            id: bucketInput
                            Layout.fillWidth: true
                            size: EasyTheme.size.sizeSmall
                            placeholder: "存储桶名称"
                            text: ossBucket
                        }
                    }

                    // AccessKey ID
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Text {
                            text: "AccessKey ID"
                            font.pixelSize: 12
                            color: EasyTheme.color.placeholder
                        }
                        EasyInput {
                            id: accessKeyIdInput
                            Layout.fillWidth: true
                            size: EasyTheme.size.sizeSmall
                            placeholder: "LTAI..."
                            text: ossAccessKeyId
                        }
                    }

                    // AccessKey Secret
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Text {
                            text: "AccessKey Secret"
                            font.pixelSize: 12
                            color: EasyTheme.color.placeholder
                        }
                        EasyInput {
                            id: accessKeySecretInput
                            Layout.fillWidth: true
                            size: EasyTheme.size.sizeSmall
                            placeholder: " SecretKey"
                            password: true
                            text: ossAccessKeySecret
                        }
                    }

                    // Region
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Text {
                            text: "Region (可选)"
                            font.pixelSize: 12
                            color: EasyTheme.color.placeholder
                        }
                        EasyInput {
                            id: regionInput
                            Layout.fillWidth: true
                            size: EasyTheme.size.sizeSmall
                            placeholder: "如: cn-hangzhou"
                            text: ossRegion
                        }
                    }
                }
            }

            // 底部按钮（固定在底部）
            Row {
                spacing: 10
                Layout.alignment: Qt.AlignRight

                EasyButton {
                    text: "取消"
                    size: EasyTheme.size.sizeSmall
                    onClicked: {
                        // 恢复设置值
                        ossEnabledSwitch.checked = ossEnabled
                        endpointInput.text = ossEndpoint
                        bucketInput.text = ossBucket
                        accessKeyIdInput.text = ossAccessKeyId
                        accessKeySecretInput.text = ossAccessKeySecret
                        regionInput.text = ossRegion
                        hideWindow()
                    }
                }

                EasyButton {
                    text: "保存"
                    primary: true
                    size: EasyTheme.size.sizeSmall
                    onClicked: {
                        ossEnabled = ossEnabledSwitch.checked
                        ossEndpoint = endpointInput.text
                        ossBucket = bucketInput.text
                        ossAccessKeyId = accessKeyIdInput.text
                        ossAccessKeySecret = accessKeySecretInput.text
                        ossRegion = regionInput.text
                        hideWindow()
                    }
                }
            }
        }
    }
}
