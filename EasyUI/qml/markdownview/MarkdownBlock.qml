// MarkdownBlock.qml
import QtQuick
import QtQuick.Controls
import EasyUI 1.0

Item {
    id: root

    property var blockData: null
    property int blockIndex: 0
    property var style: null
    property var selectionHandler: null

    property bool hovered: false
    property bool selected: false
    property bool copyEnabled: true
    property bool autoWidth: false

    signal clicked(var block)
    signal copyRequested

    onBlockDataChanged: {
        hovered = false
        selected = false
        applyStoredSelection()
    }

    height: loader.height
    implicitWidth: blockData && blockData.estimatedWidth
        ? blockData.estimatedWidth : (autoWidth ? 60 : width)
    width: autoWidth ? implicitWidth : parent.width

    // ── Selection helpers ──

    function textAreaItem() {
        var item = loader.item
        if (!item) return null
        if (item.textArea !== undefined) return item.textArea
        return null
    }

    function applySelection(selStart, selEnd) {
        var ta = textAreaItem()
        if (!ta) return
        if (selStart >= 0 && selEnd > selStart) {
            ta.select(selStart, selEnd)
        } else {
            ta.deselect()
        }
    }

    function applyStoredSelection() {
        if (!selectionHandler) return
        if (!selectionHandler.hasSelection) {
            applySelection(-1, -1)
            root.selected = false
            return
        }
        var sel = selectionHandler.selectionForBlock(root.blockIndex)
        if (sel && Object.keys(sel).length > 0) {
            root.selected = true
            var start = sel.start
            var end = sel.end
            var ta = textAreaItem()
            if (ta && end === -1) end = ta.length
            if (ta) applySelection(start, end)
        } else {
            root.selected = false
            applySelection(-1, -1)
        }
    }

    Connections {
        target: selectionHandler
        enabled: false  // driven by MarkdownView, not per-block broadcast
        function onSelectionChanged() { applyStoredSelection() }
    }

    Component.onCompleted: applyStoredSelection()

    // ── Background highlights ──

    Rectangle {
        anchors.fill: parent
        color: EasyTheme.color.text
        opacity: selected ? 0.1 : 0
        visible: selected
    }

    Rectangle {
        anchors.fill: parent
        color: EasyTheme.color.primary
        opacity: hovered ? 0.05 : 0
        visible: copyEnabled
    }

    Loader {
        id: loader
        width: root.autoWidth ? root.implicitWidth : root.width

        onLoaded: applyStoredSelection()

        sourceComponent: {
            if (!blockData)
                return emptyComponent
            var t = blockData.type
            if (t >= 2 && t <= 7)
                return headingComponent
            if (t === 8)
                return codeBlockComponent
            if (t === 9)
                return blockQuoteComponent
            if (t >= 10 && t <= 12)
                return listItemComponent
            if (t === 13)
                return horizontalRuleComponent
            if (t === 14)
                return tableComponent
            if (t === 15) {
                return imageComponent
            }
            if (t === 17) {
                return htmlBlockComponent
            }
            return paragraphComponent
        }

        property int headingLevel: blockData ? blockData.type - 1 : 1
    }

    Component {
        id: emptyComponent
        Item { height: 0 }
    }

    // 复制按钮
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 4
        width: 28
        height: 28
        radius: 6
        visible: hovered && copyEnabled
        color: copyBtnArea.containsMouse ? EasyTheme.color.buttonHover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }

        EasyIconFont {
            anchors.centerIn: parent
            icon: copyBtnArea.containsMouse ? EasyIcon.material.content_copy : EasyIcon.material.content_paste
            iconSize: 14
            color: EasyTheme.color.placeholder
        }

        MouseArea {
            id: copyBtnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                copyRequested()
                ToastManager.success(qsTr("Copied!"))
            }
        }
    }

    // ===== Component definitions =====

    Component {
        id: paragraphComponent
        TextArea {
            id: paragraphText
            readonly property alias textArea: paragraphText
            width: root.autoWidth ? implicitWidth : root.width
            wrapMode: root.autoWidth ? TextArea.NoWrap : TextArea.WrapAtWordBoundaryOrAnywhere
            textFormat: TextEdit.RichText
            readOnly: true
            selectByMouse: false
            background: Rectangle { color: "transparent" }
            padding: 0
            leftPadding: 0
            topPadding: 0
            bottomPadding: 0

            text: root.blockData && root.blockData.html ? root.blockData.html : buildHtmlFallback()

            function buildHtmlFallback() {
                if (!root.blockData || !root.blockData.spans) return ""
                var html = ""
                var spans = root.blockData.spans
                for (var i = 0; i < spans.length; i++) {
                    var span = spans[i]
                    var content = (span.text || "").replace(/&/g, "&amp;")
                                                    .replace(/</g, "&lt;")
                                                    .replace(/>/g, "&gt;")
                    if (span.code) {
                        html += '<span style="background-color:' + (root.style?.codeBackground || "#f0f0f0") +
                               ';padding:2px 6px;border-radius:4px;font-family:Consolas,monospace;font-size:0.9em;color:' +
                               (root.style?.codeTextColor || "#e6554f") + '">' + content + '</span>'
                    } else if (span.linkUrl) {
                        html += '<a href="' + span.linkUrl + '" style="color:' +
                               (root.style?.linkColor || "#0969da") + ';text-decoration:underline;text-underline-offset:2px">' + content + '</a>'
                    } else {
                        var s = span.bold ? "font-weight:bold;" : ""
                        s += span.italic ? "font-style:italic;" : ""
                        s += span.strikethrough ? "text-decoration:line-through;" : ""
                        html += s ? '<span style="' + s + '">' + content + '</span>' : content
                    }
                }
                return html
            }

            font.family: root.style?.baseFont?.family || "Microsoft YaHei, Segoe UI, sans-serif"
            font.pixelSize: root.style?.baseFont?.pixelSize || EasyTheme.font.sizeNormal
            color: root.style?.textColor || EasyTheme.color.text

            onLinkActivated: (link) => Qt.openUrlExternally(link)
        }
    }

    Component {
        id: headingComponent
        MarkdownHeading {
            width: root.autoWidth ? implicitWidth : root.width
            level: loader.headingLevel
            blockData: root.blockData
            textFont: root.style ? root.style.baseFont : null
            textColor: root.style ? root.style.textColor : "#24292e"
            headingScale: root.style ? root.style.headingScale : 1.0
            borderColor: root.style ? root.style.borderColor : "#e1e4e8"
            autoWidth: root.autoWidth
            selectByMouse: false
        }
    }

    Component {
        id: codeBlockComponent
        MarkdownCodeBlock {
            width: root.autoWidth ? Math.min(implicitWidth, root.width) : root.width
            blockData: root.blockData
            codeFont: root.style ? root.style.codeFont : null
            codeBackground: root.style ? root.style.codeBackground : "#f6f8fa"
            codeTextColor: root.style ? root.style.codeTextColor : "#24292e"
            borderColor: root.style ? root.style.borderColor : "#e1e4e8"
            linkColor: root.style ? root.style.linkColor : "#0366d6"
            headerBorderColor: root.style ? root.style.borderColor : "#e1e4e8"
            isDark: root.style ? root.style.isDark : false
            onCopyRequested: root.copyRequested()
        }
    }

    Component {
        id: blockQuoteComponent
        Rectangle {
            readonly property alias textArea: quoteText
            width: root.autoWidth ? Math.min(quoteText.implicitWidth + 40, root.width) : root.width
            height: quoteText.height + 24
            color: root.style ? Qt.alpha(root.style.blockQuoteColor, 0.06) : Qt.rgba(0,0,0,0.03)
            radius: 0

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                width: 4
                radius: 2
                color: root.style?.blockQuoteColor || EasyTheme.color.placeholder
            }

            TextArea {
                id: quoteText
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: root.autoWidth ? undefined : parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                textFormat: TextEdit.RichText
                wrapMode: root.autoWidth ? TextArea.NoWrap : TextArea.WrapAtWordBoundaryOrAnywhere
                text: root.blockData?.html ? root.blockData.html : buildHtmlFallback()
                font.family: root.style?.baseFont?.family || "Microsoft YaHei, Segoe UI, sans-serif"
                font.pixelSize: root.style?.baseFont?.pixelSize || EasyTheme.font.sizeNormal
                color: root.style?.blockQuoteColor || EasyTheme.color.secondary
                readOnly: true
                selectByMouse: false
                background: Rectangle { color: "transparent" }

                function buildHtmlFallback() {
                    if (!root.blockData || !root.blockData.spans) return ""
                    var html = ""
                    var spans = root.blockData.spans
                    for (var i = 0; i < spans.length; i++) {
                        var span = spans[i]
                        var content = (span.text || "").replace(/&/g, "&amp;")
                                                        .replace(/</g, "&lt;")
                                                        .replace(/>/g, "&gt;")
                        if (span.code) {
                            html += '<span style="background-color:' + (root.style?.codeBackground || "#f0f0f0") +
                                   ';padding:2px 6px;border-radius:4px;font-family:Consolas,monospace;font-size:0.9em;color:' +
                                   (root.style?.codeTextColor || "#e6554f") + '">' + content + '</span>'
                        } else if (span.linkUrl) {
                            html += '<a href="' + span.linkUrl + '" style="color:' +
                                   (root.style?.linkColor || "#0969da") + ';text-decoration:underline;text-underline-offset:2px">' + content + '</a>'
                        } else {
                            var s = span.bold ? "font-weight:bold;" : ""
                            s += span.italic ? "font-style:italic;" : ""
                            s += span.strikethrough ? "text-decoration:line-through;" : ""
                            html += s ? '<span style="' + s + '">' + content + '</span>' : content
                        }
                    }
                    return html
                }

                onLinkActivated: (link) => Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: listItemComponent
        MarkdownListItem {
            width: root.autoWidth ? Math.min(implicitWidth, root.width) : root.width
            itemData: root.blockData
            textFont: root.style ? root.style.baseFont : null
            textColor: root.style ? root.style.textColor : "#24292e"
            linkColor: root.style ? root.style.linkColor : "#0366d6"
            codeBackground: root.style ? root.style.codeBackground : "#f6f8fa"
            codeTextColor: root.style ? root.style.codeTextColor : "#24292e"
            isDark: root.style ? root.style.isDark : false
            listIndent: root.style ? root.style.listIndent : 24
            autoWidth: root.autoWidth
        }
    }

    Component {
        id: tableComponent
        MarkdownTable {
            readonly property var textArea: null  // tables: block-level only
            width: root.autoWidth ? Math.min(implicitWidth, root.width) : root.width
            blockData: root.blockData
            textFont: root.style ? root.style.baseFont : null
            textColor: root.style ? root.style.textColor : "#24292e"
            borderColor: root.style ? root.style.borderColor : "#e1e4e8"
            headerBackground: root.style ? root.style.tableHeaderBackground : "#f6f8fa"
            rowBackground: root.style ? root.style.tableRowBackground : "#ffffff"
            rowAltBackground: root.style ? root.style.tableAltRowBackground : "#f6f8fa"
            isDark: root.style ? root.style.isDark : false
        }
    }

    Component {
        id: horizontalRuleComponent
        Item {
            width: root.autoWidth ? 60 : root.width
            height: 24
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: root.autoWidth ? 40 : root.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                height: 1
                color: root.style ? root.style.borderColor : "#e1e4e8"
            }
        }
    }

    Component {
        id: imageComponent
        MarkdownImage {
            width: root.autoWidth ? Math.min(implicitWidth, root.width) : root.width
            blockData: root.blockData
            style: root.style
            autoWidth: root.autoWidth
        }
    }

    Component {
        id: htmlBlockComponent
        MarkdownHtmlBlock {
            width: root.autoWidth ? implicitWidth : root.width
            blockData: root.blockData
            style: root.style
            autoWidth: root.autoWidth
        }
    }
}
