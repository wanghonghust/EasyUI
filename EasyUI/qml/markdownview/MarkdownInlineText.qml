// MarkdownInlineText.qml
import QtQuick
import EasyUI 1.0

Text {
    id: root

    property var spanData: null
    property var textFont: null
    property color textColor: EasyTheme.color.text
    property color linkColor: EasyTheme.color.primary
    property color codeBackground: EasyTheme.markdown.code.bgColor
    property color codeTextColor: EasyTheme.markdown.code.textColor
    property bool isDark: EasyTheme.isDark
    property bool autoWidth: false

    text: spanData ? spanData.text || "" : ""
    font.family: spanData && spanData.code ? "Consolas" : (textFont ? textFont.family : "Microsoft YaHei, Segoe UI, sans-serif")
    font.pixelSize: spanData && spanData.code ?
                     (textFont ? textFont.pixelSize - 1 : 10) :
                     (textFont ? textFont.pixelSize : 11)
    font.bold: spanData ? spanData.bold || false : false
    font.italic: spanData ? spanData.italic || false : false
    font.strikeout: spanData ? spanData.strikethrough || false : false
    color: spanData && spanData.code ? codeTextColor :
           (spanData && spanData.linkUrl ? linkColor : textColor)

    // Text 会自动根据 Flow 的布局换行
    wrapMode: autoWidth ? Text.NoWrap : Text.Wrap

    // 行内代码背景
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        anchors.leftMargin: -2
        anchors.rightMargin: -2
        color: codeBackground
        radius: 4
        visible: spanData && spanData.code
        z: -1
    }

    // 链接下划线
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1
        width: parent.width
        height: 1
        color: linkColor
        visible: spanData && spanData.linkUrl
        opacity: 0.6
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        enabled: spanData && spanData.linkUrl
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            if (spanData && spanData.linkUrl) {
                Qt.openUrlExternally(spanData.linkUrl)
            }
        }
    }
}
