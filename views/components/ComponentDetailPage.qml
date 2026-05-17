import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI
import Handler 1.0

/**
 * ComponentDetailPage —— 组件详情页
 *
 * 参数：
 *   title         {string}  组件标题（如 "EasyButton"）
 *   exampleSource {url}     示例 QML 文件路径（Loader 加载）
 *   docPath       {url}     Markdown 文档路径
 */
Page {
    id: root
    background: Rectangle { color: EasyTheme.color.background }

    property string pageTitle: ""
    property url exampleSource: ""
    property url docPath: ""

    // 加载文档内容
    property string docText: ""

    function loadDocument() {
        if (!docPath.toString()) return
        root.docText = Handler.readFile(docPath.toString())
    }

    Component.onCompleted: loadDocument()
    onDocPathChanged: loadDocument()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========== 顶部工具栏 ==========
        Rectangle {
            Layout.fillWidth: true
            height: 48
            color: EasyTheme.color.background

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: root.pageTitle
                    font.pixelSize: 16
                    font.bold: true
                    color: EasyTheme.color.text
                }

                Item { Layout.fillWidth: true }
            }
        }

        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

        // ========== 内容区 ==========
        SplitView {
            id: splitView
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            // 跟踪左侧面板占比，拖拽或缩放时保持比例
            property real leftRatio: 0.6

            onWidthChanged: {
                if (splitView.width > 0)
                    leftPane.SplitView.preferredWidth = splitView.width * splitView.leftRatio
            }

            handle: Rectangle {
                implicitWidth: 1
                implicitHeight: splitView.height
                color: SplitHandle.hovered ? EasyTheme.color.primary : EasyTheme.color.divider

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                containmentMask: Item {
                    width: 12
                    height: splitView.height
                    x: -6
                }
            }

            // 左侧：示例区域
            Rectangle {
                id: leftPane
                SplitView.minimumWidth: 300
                SplitView.preferredWidth: splitView.width * 0.6
                color: EasyTheme.color.background

                onWidthChanged: {
                    if (splitView.width > 0 && leftPane.width > 0)
                        splitView.leftRatio = leftPane.width / splitView.width
                }

                ScrollView {
                    id: exampleScroll
                    anchors.fill: parent
                    anchors.topMargin: 16
                    anchors.bottomMargin: 16
                    clip: true
                    ScrollBar.vertical: EasyScrollBar { }
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    contentWidth: exampleScroll.width

                    Loader {
                        id: exampleLoader
                        width: parent.width - 2 * 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: root.exampleSource
                    }
                }
            }

            // 右侧：文档区域
            Rectangle {
                SplitView.minimumWidth: 260
                SplitView.preferredWidth: splitView.width * 0.4
                color: EasyTheme.color.background

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    Text {
                        text: "文档说明"
                        padding: 16
                        font.pixelSize: 14
                        font.bold: true
                        color: EasyTheme.color.text
                    }

                    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

                    ScrollView {
                        id: docScroll
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        ScrollBar.vertical: EasyScrollBar { }
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        contentWidth: docScroll.width

                        EasyMarkdownView {
                            anchors.margins: 16
                            width: docScroll.width
                            text: root.docText
                        }
                    }
                }
            }
        }
    }
}
