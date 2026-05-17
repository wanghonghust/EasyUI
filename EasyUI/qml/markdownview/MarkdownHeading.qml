// MarkdownHeading.qml
import QtQuick
import QtQuick.Controls
import EasyUI 1.0

TextArea {
    id: root

    readonly property alias textArea: root
    property int level: 1
    property var blockData: null
    property var textFont: null
    property color textColor: EasyTheme.color.text
    property real headingScale: 1.0
    property color borderColor: EasyTheme.color.divider
    property bool autoWidth: false

    text: {
        var result = ""
        if (blockData && blockData.spans) {
            for (var i = 0; i < blockData.spans.length; i++)
                result += blockData.spans[i].text || ""
        }
        return result
    }

    font.family: textFont ? textFont.family : "Microsoft YaHei, Segoe UI, sans-serif"
    font.pixelSize: getHeadingSize()
    font.bold: true
    color: textColor
    wrapMode: autoWidth ? Text.NoWrap : Text.WordWrap

    readOnly: true
    selectByMouse: false
    background: Rectangle { color: "transparent" }
    padding: 0
    leftPadding: 0
    topPadding: 0
    bottomPadding: 0

    // 使用 EasyTheme 预设的标题大小
    property var _sizes: [
        EasyTheme.markdown.heading.h1Size,
        EasyTheme.markdown.heading.h2Size,
        EasyTheme.markdown.heading.h3Size,
        EasyTheme.markdown.heading.h4Size,
        EasyTheme.markdown.heading.h5Size,
        EasyTheme.markdown.heading.h6Size
    ]

    function getHeadingSize() {
        var idx = Math.max(0, Math.min(level - 1, 5))
        return _sizes[idx] * headingScale
    }

    // h1/h2 底部分隔线
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: level <= 2 ? EasyTheme.size.borderWidthActive : 0
        color: borderColor
        visible: level <= 2
    }
}
