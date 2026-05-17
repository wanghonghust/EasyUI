import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI
import Handler

EasySimpleWindow {
    id: aboutWindow
    title: "关于 EasyChat"
    width: 860
    height: 840
    minimumWidth: 860
    minimumHeight: 840
    maximumWidth: 860
    maximumHeight: 840
    onlyCloseButton: true

    property string readmeContent: ""
    property bool readmeLoaded: false

    function showWindow(parentWindow) {
        if (parentWindow) {
            x = parentWindow.x + (parentWindow.width - width) / 2
            y = parentWindow.y + (parentWindow.height - height) / 2
        }
        visible = true
        raise()
        requestActivate()

        if (!readmeLoaded) {
            readmeContent = Handler.readFile("qrc:/README.md")
            if (!readmeContent) {
                readmeContent = "# 加载失败\n\n无法读取 README.md，请检查资源文件。"
            }
            readmeLoaded = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: EasyTheme.color.background

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // 顶部图标 + 标题
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Rectangle {
                    width: 48
                    height: 48
                    radius: 12
                    color: EasyTheme.color.primary

                    Text {
                        anchors.centerIn: parent
                        text: "E"
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "EasyChat"
                        font.pixelSize: 18
                        font.bold: true
                        color: EasyTheme.color.text
                    }

                    Text {
                        text: "v0.1.0  ·  Built with Qt 6 / QML"
                        font.pixelSize: 12
                        color: EasyTheme.color.placeholder
                    }
                }
            }

            EasyDivider { Layout.fillWidth: true }

            // README 内容区
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rightMargin: -16
                clip: true
                leftPadding: 8; rightPadding: 0; topPadding: 8; bottomPadding: 8
                ScrollBar.vertical: EasyScrollBar { }
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                EasyMarkdownView {
                    width: parent.width - 8
                    text: readmeContent || (readmeLoaded ? "" : "加载中...")
                }
            }
        }
    }
}
