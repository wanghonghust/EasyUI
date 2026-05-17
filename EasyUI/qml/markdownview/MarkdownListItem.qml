// MarkdownListItem.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import EasyUI 1.0

Item {
    id: root

    readonly property alias textArea: contentText
    property var itemData: null
    property var textFont: null
    property color textColor: EasyTheme.color.text
    property color linkColor: EasyTheme.color.primary
    property color codeBackground: EasyTheme.markdown.code.bgColor
    property color codeTextColor: EasyTheme.markdown.code.textColor
    property bool isDark: EasyTheme.isDark
    property real listIndent: 24
    property bool autoWidth: false

    height: itemColumn.height
    implicitWidth: itemColumn.implicitWidth
    width: autoWidth ? implicitWidth : (parent ? parent.width : 0)

    // 构建 spans 的 HTML 富文本
    function buildSpansHtml(spans) {
        if (!spans) return ""
        var html = ""
        for (var i = 0; i < spans.length; i++) {
            var span = spans[i]
            var content = span.text || ""
            content = content.replace(/&/g, "&amp;")
                             .replace(/</g, "&lt;")
                             .replace(/>/g, "&gt;")

            if (span.code) {
                html += '<span style="background-color: ' + codeBackground + ';'
                      + 'padding: 2px 4px; border-radius: 3px;'
                      + 'font-family: Consolas, monospace;'
                      + 'color: ' + codeTextColor + ';">' + content + '</span>'
            } else if (span.linkUrl) {
                html += '<a href="' + span.linkUrl + '" style="color: ' + linkColor + ';">' + content + '</a>'
            } else {
                var style = ""
                if (span.bold) style += "font-weight: bold; "
                if (span.italic) style += "font-style: italic; "
                if (span.strikethrough) style += "text-decoration: line-through; "
                if (style) {
                    html += '<span style="' + style + '">' + content + '</span>'
                } else {
                    html += content
                }
            }
        }
        return html
    }

    Column {
        id: itemColumn
        width: root.autoWidth ? implicitWidth : root.width
        spacing: 4

        // 主行
        Row {
            spacing: 8
            width: parent.width

            Text {
                id: marker
                width: listIndent - 8
                text: {
                    if (!itemData) return ""
                    if (itemData.type === 10 || itemData.type === 12) return "•"
                    if (itemData.type === 11) return (itemData.level || 1) + "."
                    if (itemData.isTask === true) return itemData.taskChecked === true ? "☑" : "☐"
                    return "•"
                }
                font.family: textFont ? textFont.family : "Microsoft YaHei, Segoe UI, sans-serif"
                font.pixelSize: textFont ? textFont.pixelSize : 14
                color: textColor
                horizontalAlignment: Text.AlignRight
            }

            TextArea {
                id: contentText
                width: root.autoWidth ? implicitWidth : parent.width - marker.width - 8
                textFormat: TextEdit.RichText
                wrapMode: root.autoWidth ? TextArea.NoWrap : TextArea.WrapAtWordBoundaryOrAnywhere
                text: buildSpansHtml(itemData && itemData.spans ? itemData.spans : [])
                font.family: textFont ? textFont.family : "Microsoft YaHei, Segoe UI, sans-serif"
                font.pixelSize: textFont ? textFont.pixelSize : 14
                color: textColor
                readOnly: true
                selectByMouse: false
                background: Rectangle { color: "transparent" }
                padding: 0
                leftPadding: 0
                topPadding: 0
                bottomPadding: 0

                onLinkActivated: (link) => Qt.openUrlExternally(link)
            }
        }

        // 子项
        Loader {
            id: childLoader
            width: parent.width
            active: itemData !== null && itemData.children !== undefined && itemData.children.length > 0
            visible: active

            sourceComponent: Component {
                Column {
                    width: parent.width
                    spacing: 4
                    leftPadding: listIndent

                    Repeater {
                        model: root.itemData.children || []
                        delegate: childDelegate
                    }
                }
            }
        }
    }

    Component {
        id: childDelegate
        Item {
            required property var modelData

            height: childCol.height
            width: parent ? parent.width : 0

            Column {
                id: childCol
                width: parent.width
                spacing: 4

                Row {
                    spacing: 8
                    width: parent.width

                    Text {
                        id: childMarker
                        width: listIndent - 8
                        text: {
                            if (!modelData) return ""
                            if (modelData.type === 10 || modelData.type === 12) return "•"
                            if (modelData.type === 11) return (modelData.level || 1) + "."
                            if (modelData.isTask === true) return modelData.taskChecked === true ? "☑" : "☐"
                            return "•"
                        }
                        font.family: root.textFont ? root.textFont.family : root.textFont ? root.textFont.family : "Microsoft YaHei, Segoe UI, sans-serif"
                        font.pixelSize: root.textFont ? root.textFont.pixelSize : 14
                        color: root.textColor
                        horizontalAlignment: Text.AlignRight
                    }

                    TextArea {
                        width: root.autoWidth ? implicitWidth : parent.width - childMarker.width - 8
                        textFormat: TextEdit.RichText
                        wrapMode: root.autoWidth ? TextArea.NoWrap : TextArea.WrapAtWordBoundaryOrAnywhere
                        text: root.buildSpansHtml(modelData.spans || [])
                        font.family: root.textFont ? root.textFont.family : root.textFont ? root.textFont.family : "Microsoft YaHei, Segoe UI, sans-serif"
                        font.pixelSize: root.textFont ? root.textFont.pixelSize : 14
                        color: root.textColor
                        readOnly: true
                        selectByMouse: false
                        background: Rectangle { color: "transparent" }
                        padding: 0
                        leftPadding: 0
                        topPadding: 0
                        bottomPadding: 0

                        onLinkActivated: (link) => Qt.openUrlExternally(link)
                    }
                }

                Loader {
                    width: parent.width
                    active: modelData.children !== undefined && modelData.children !== null && modelData.children.length > 0
                    visible: active

                    sourceComponent: Component {
                        Column {
                            width: parent.width
                            spacing: 4
                            leftPadding: listIndent

                            Repeater {
                                model: modelData.children || []
                                delegate: childDelegate
                            }
                        }
                    }
                }
            }
        }
    }
}