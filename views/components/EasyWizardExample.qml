import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: 500

    Component {
        id: step1
        ColumnLayout {
            anchors.fill: parent
            spacing: 12
            Text {
                text: "项目名称"
                font.pixelSize: 12
                color: EasyTheme.color.placeholder
            }
            EasyInput {
                Layout.fillWidth: true
                placeholder: "输入项目名称"
            }
            Text {
                text: "项目描述"
                font.pixelSize: 12
                color: EasyTheme.color.placeholder
            }
            EasyTextArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholder: "简单描述项目目标和范围"
            }
        }
    }

    Component {
        id: step2
        RowLayout {
            anchors.fill: parent
            spacing: 16
            Repeater {
                model: ["空白项目", "Web 应用", "API 服务", "桌面应用"]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: "transparent"
                    border.color: EasyTheme.color.border
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 13
                        color: EasyTheme.color.text
                    }
                }
            }
        }
    }

    Component {
        id: step3
        ColumnLayout {
            anchors.fill: parent
            spacing: 12
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                radius: 10
                color: EasyTheme.color.buttonHover
                Text {
                    anchors.centerIn: parent
                    text: "已配置就绪，点击完成按钮创建项目"
                    font.pixelSize: 13
                    color: EasyTheme.color.text
                }
            }
        }
    }

    EasyWizard {
        id: wizard
        anchors {
            fill: parent
            margins: 24
        }
        steps: [{
                "title": "基础信息",
                "subtitle": "填写项目的基本信息",
                "content": step1
            }, {
                "title": "选择模板",
                "subtitle": "从预设模板中选择或从空白开始",
                "content": step2
            }, {
                "title": "确认创建",
                "subtitle": "检查配置并创建项目",
                "content": step3
            }]
        onFinished: {
            console.log("Wizard finished")
        }
        onCancelled: {
            console.log("Wizard cancelled")
        }
    }
}
