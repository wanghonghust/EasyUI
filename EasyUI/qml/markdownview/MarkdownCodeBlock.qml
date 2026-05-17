// MarkdownCodeBlock.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import CodeHighlighter
import EasyUI 1.0
import Utils 1.0

Rectangle {
    id: root

    readonly property alias textArea: codeText
    property var blockData: null
    property var codeFont: null
    property color codeBackground: EasyTheme.markdown.code.bgColor
    property color codeTextColor: EasyTheme.markdown.code.textColor
    property color borderColor: EasyTheme.color.border
    property color linkColor: EasyTheme.color.primary
    property color headerBorderColor: EasyTheme.color.divider
    property bool isDark: EasyTheme.isDark

    signal copyRequested

    height: headerBar.height + codeArea.height + 20
    color: codeBackground
    radius: 6
    border.color: borderColor
    border.width: EasyTheme.size.borderWidth

    property color headerBg: isDark ? Qt.lighter(codeBackground, 1.2) : Qt.darker(codeBackground, 1.05)

    // 头部
    Rectangle {
        id: headerBar
        width: parent.width
        height: 34
        color: root.headerBg
        radius: 6

        // 底部分隔线
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: root.headerBorderColor
            visible: false
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8

            // 语言标签
            Label {
                text: blockData && blockData.language ? blockData.language : ""
                font.family: codeFont ? codeFont.family : "Consolas"
                font.pixelSize: 11
                color: EasyTheme.color.placeholder
                visible: blockData && blockData.language
                opacity: 0.7
            }

            Item {
                Layout.fillWidth: true
            }

            // 复制按钮
            Rectangle {
                visible: codeText.text.length > 0
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 5
                color: copyBtnArea.containsMouse ? Qt.rgba(EasyTheme.color.primary.r, EasyTheme.color.primary.g, EasyTheme.color.primary.b, 0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                EasyIconFont {
                    anchors.centerIn: parent
                    icon: EasyIcon.material.content_copy
                    iconSize: 13
                    color: copyBtnArea.containsMouse ? EasyTheme.color.text : EasyTheme.color.placeholder
                }

                MouseArea {
                    id: copyBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.copyRequested()
                        Clipboard.setText(codeText.text)
                        ToastManager.success(qsTr("Copied!"))
                    }
                }
            }
        }
    }

    // 代码区域
    ScrollView {
        id: codeArea
        ScrollBar.vertical: EasyScrollBar { }
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        height: codeText.implicitHeight + 4

        TextArea {
            id: codeText
            text: blockData && blockData.spans && blockData.spans.length > 0
                  ? (blockData.spans[0].text || "") : ""
            font.family: codeFont ? codeFont.family : "Consolas, monospace"
            font.pixelSize: codeFont ? codeFont.pixelSize : EasyTheme.font.sizeSmall
            color: codeTextColor
            readOnly: true
            selectByMouse: false
            wrapMode: TextEdit.NoWrap
            background: null
            padding: 0
            leftPadding: 4
            topPadding: 2
            bottomPadding: 2
            selectionColor: linkColor
            selectedTextColor: isDark ? "#ffffff" : codeBackground

            CodeHighlighter {
                textDocument: codeText.textDocument
                language: blockData.language || ""
                theme: EasyTheme.isDark ? "onedark" : "onelight"
            }
        }
    }
}
