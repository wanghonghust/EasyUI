// MarkdownHtmlBlock.qml - HTML 内容渲染组件
import QtQuick
import QtQuick.Controls
import EasyUI 1.0

Item {
    id: root

    readonly property alias textArea: htmlText

    // 必需属性
    required property var blockData
    property var style: null
    property bool autoWidth: false

    // 可配置的边距（替代硬编码的 8）
    property real padding: 8
    property real topPadding: padding
    property real bottomPadding: padding
    property real leftPadding: padding
    property real rightPadding: padding

    readonly property real textAvailableWidth: Math.max(0, width - leftPadding - rightPadding)

    readonly property string rawHtmlContent: {
        if (!blockData) {
            return "";
        }
        if (blockData.rawText && blockData.rawText.length > 0) {
            return blockData.rawText;
        }
        if (blockData.spans && blockData.spans.length > 0) {
            return blockData.spans[0].text || "";
        }
        return "";
    }

    readonly property string normalizedHtmlContent: normalizeHtmlContent(rawHtmlContent)
    readonly property var imageEntries: parseImageEntries(normalizedHtmlContent)
    readonly property bool imageOnlyBlock: isImageOnlyHtml(normalizedHtmlContent, imageEntries.length)
    readonly property bool mixedWithImages: !imageOnlyBlock && imageEntries.length > 0
    readonly property var mixedSegments: mixedWithImages ? parseMixedSegments(normalizedHtmlContent, imageEntries) : []
    readonly property real contentImplicitWidth: {
        if (imageOnlyBlock) return imageColumn.width
        if (mixedWithImages) return mixedColumn.width
        return htmlText.implicitWidth
    }
    readonly property real contentImplicitHeight: {
        if (imageOnlyBlock) return imageColumn.height
        if (mixedWithImages) return mixedColumn.height
        return htmlText.implicitHeight
    }

    function extractAttribute(attributes, name) {
        var quotedRegex = new RegExp(name + "\\s*=\\s*(['\"])" + "(.*?)" + "\\1", "i");
        var quotedMatch = quotedRegex.exec(attributes);
        if (quotedMatch && quotedMatch.length > 2) {
            return quotedMatch[2];
        }

        var bareRegex = new RegExp(name + "\\s*=\\s*([^\\s>]+)", "i");
        var bareMatch = bareRegex.exec(attributes);
        return bareMatch && bareMatch.length > 1 ? bareMatch[1] : "";
    }

    function isUnsupportedImageSource(url) {
        if (!url || typeof url !== "string") {
            return false;
        }
        return /^data:image\/(webp|avif)/i.test(url)
            || /\.(webp|avif)(\?|#|$)/i.test(url);
    }

    function formatDisplayName(url) {
        if (!url || typeof url !== "string") {
            return "image";
        }
        if (/^data:image\/webp/i.test(url) || /\.webp(\?|#|$)/i.test(url)) {
            return "webp";
        }
        if (/^data:image\/avif/i.test(url) || /\.avif(\?|#|$)/i.test(url)) {
            return "avif";
        }
        return "image";
    }

    function escapeHtml(text) {
        return (text || "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");
    }

    function buildUnsupportedImagePlaceholder(url, alt) {
        return '<span data-unsupported-image="true" style="font-style:italic;opacity:0.75;">['
               + formatDisplayName(url).toUpperCase()
               + ' image: '
               + escapeHtml(alt || "Image")
               + ']</span>';
    }

    function normalizeHtmlContent(html) {
        if (!html) {
            return "";
        }

        var normalized = html;
        normalized = normalized.replace(/\[!\[([^\]]*)\]\(([^\)\"\s]+)(?:\s*\"[^\"]*\")?\)\]\(([^\)]+)\)/g,
                                        '<a href="$3"><img alt="$1" src="$2" /></a>');
        normalized = normalized.replace(/!\[([^\]]*)\]\(([^\)\"\s]+)(?:\s*\"[^\"]*\")?\)/g,
                                        '<img alt="$1" src="$2" />');
        normalized = normalized.replace(/<img\b([^>]*)>/gi, function(_, attributes) {
            var attrs = attributes || "";
            var url = extractAttribute(attrs, "src");
            if (!isUnsupportedImageSource(url)) {
                return "<img" + attrs + ">";
            }
            return buildUnsupportedImagePlaceholder(url, extractAttribute(attrs, "alt"));
        });
        return normalized;
    }

    function parseImageEntries(html) {
        if (!html) {
            return [];
        }

        var entries = [];
        var imageRegex = /<img\b([^>]*)>/gi;
        var match = null;

        while ((match = imageRegex.exec(html)) !== null) {
            var attributes = match[1] || "";
            var url = extractAttribute(attributes, "src");
            if (!url) {
                continue;
            }

            var href = "";
            var prefix = html.slice(0, match.index);
            var anchorMatch = /<a\b([^>]*)>[^<]*$/i.exec(prefix);
            if (anchorMatch) {
                href = extractAttribute(anchorMatch[1] || "", "href");
            }

            entries.push({
                url: url,
                href: href,
                alt: extractAttribute(attributes, "alt") || "Image"
            });
        }

        return entries;
    }

    function isImageOnlyHtml(html, imageCount) {
        if (!html || imageCount === 0) {
            return false;
        }

        var stripped = html
            .replace(/<img\b[^>]*>/gi, "")
            .replace(/<\/??(div|p|span|figure|figcaption|picture|a)\b[^>]*>/gi, "")
            .replace(/<br\s*\/?>/gi, "")
            .replace(/&nbsp;/gi, " ")
            .replace(/\s+/g, " ")
            .trim();

        return stripped.length === 0;
    }

    function parseMixedSegments(html, entries) {
        if (!html || !entries || entries.length === 0) return []

        var segments = []
        var imgRegex = /<img\b[^>]*>/gi
        var lastIndex = 0
        var match

        while ((match = imgRegex.exec(html)) !== null) {
            var textBefore = html.slice(lastIndex, match.index)
            if (textBefore.length > 0) {
                var cleaned = textBefore.replace(/<br\s*\/?>/gi, "").replace(/&nbsp;/gi, " ").trim()
                if (cleaned.length > 0) {
                    segments.push({ type: "text", html: cleaned })
                }
            }

            var attrs = match[1] || ""
            var url = extractAttribute(attrs, "src")
            var alt = extractAttribute(attrs, "alt") || "Image"
            var href = ""
            var prefix = html.slice(0, match.index)
            var anchorMatch = /<a\b([^>]*)>[^<]*$/i.exec(prefix)
            if (anchorMatch) {
                href = extractAttribute(anchorMatch[1] || "", "href")
            }
            segments.push({
                type: "image",
                url: url,
                href: href,
                alt: alt
            })

            lastIndex = match.index + match[0].length
        }

        var tail = html.slice(lastIndex)
        if (tail.length > 0) {
            var cleanedTail = tail.replace(/<br\s*\/?>/gi, "").replace(/&nbsp;/gi, " ").trim()
            if (cleanedTail.length > 0) {
                segments.push({ type: "text", html: cleanedTail })
            }
        }

        return segments
    }

    // 显式暴露实际尺寸，避免在 Loader / Layout 中只拿到高度而宽度仍保持为 0
    width: autoWidth
        ? implicitWidth
        : (parent ? parent.width : implicitWidth)
    implicitWidth: autoWidth
        ? contentImplicitWidth + leftPadding + rightPadding
        : (parent ? parent.width : contentImplicitWidth + leftPadding + rightPadding)
    implicitHeight: contentImplicitHeight + topPadding + bottomPadding
    height: implicitHeight

    Flow {
        id: imageColumn
        visible: root.imageOnlyBlock
        x: root.leftPadding
        y: root.topPadding
        width: root.autoWidth ? implicitWidth : root.textAvailableWidth
        height: childrenRect.height
        spacing: root.padding

        Repeater {
            model: root.imageEntries

            delegate: MarkdownImage {
                blockData: ({
                    spans: [{
                        imageUrl: modelData.url,
                        linkUrl: modelData.href || "",
                        text: modelData.alt
                    }]
                })
                style: root.style
                autoWidth: root.autoWidth
                showCaption: false
            }
        }
    }

    Column {
        id: mixedColumn
        visible: root.mixedWithImages
        x: root.leftPadding
        y: root.topPadding
        width: root.autoWidth ? implicitWidth : root.textAvailableWidth
        height: childrenRect.height
        spacing: root.padding

        Repeater {
            model: root.mixedSegments

            delegate: Item {
                width: mixedColumn.width
                height: childrenRect.height

                Loader {
                    anchors.horizontalCenter: parent.horizontalCenter
                    sourceComponent: modelData.type === "image" ? mixedImageDelegate : mixedTextDelegate
                }

                Component {
                    id: mixedTextDelegate

                    TextArea {
                        width: root.autoWidth ? implicitWidth : mixedColumn.width
                        textFormat: TextEdit.RichText
                        wrapMode: root.autoWidth ? TextArea.NoWrap : TextArea.WrapAtWordBoundaryOrAnywhere
                        text: modelData.html
                        color: root.style?.textColor || EasyTheme.color.text
                        font.pixelSize: root.style?.baseFont?.pixelSize || EasyTheme.font.sizeNormal
                        readOnly: true
                        selectByMouse: false
                        background: Rectangle { color: "transparent" }
                        padding: 0
                        leftPadding: 0
                        topPadding: 0
                        bottomPadding: 0
                    }
                }

                Component {
                    id: mixedImageDelegate

                    MarkdownImage {
                        blockData: ({
                            spans: [{
                                imageUrl: modelData.url,
                                linkUrl: modelData.href || "",
                                text: modelData.alt
                            }]
                        })
                        style: root.style
                        autoWidth: root.autoWidth
                        showCaption: false
                    }
                }
            }
        }
    }

    TextArea {
        id: htmlText
        visible: !root.imageOnlyBlock && !root.mixedWithImages

        x: root.leftPadding
        y: root.topPadding
        width: root.autoWidth ? implicitWidth : root.textAvailableWidth

        textFormat: TextEdit.RichText
        wrapMode: root.autoWidth ? TextArea.NoWrap : TextArea.WrapAtWordBoundaryOrAnywhere
        text: root.imageOnlyBlock ? "" : root.normalizedHtmlContent

        // 应用传入的 style (假设 style 包含颜色、字号等，可根据实际结构修改)
        color: root.style?.textColor || EasyTheme.color.text
        font.pixelSize: root.style?.baseFont?.pixelSize || EasyTheme.font.sizeNormal

        readOnly: true
        selectByMouse: false
        background: Rectangle { color: "transparent" }
        padding: 0
        leftPadding: 0
        topPadding: 0
        bottomPadding: 0

        onLinkActivated: function(link) {
            Qt.openUrlExternally(link);
        }
    }

    // 修复交互：仅用于改变鼠标样式，不拦截事件（允许文本被选中）
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // 关键优化：不拦截任何按钮点击
        cursorShape: root.imageOnlyBlock ? Qt.ArrowCursor
            : (htmlText.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor)
    }
}
