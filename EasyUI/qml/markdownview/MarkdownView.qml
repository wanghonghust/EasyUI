// MarkdownView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: root

    signal blockClicked(int index, var block)
    property alias text: documentObj.source

    property bool autoWidth: false

    property var imageList: []
    property int currentImageIndex: -1
    property string previewRawUrl: ""
    property string previewDisplayText: ""
    property string previewResolvedSource: ""
    property bool previewLoading: false
    property bool previewError: false
    property string previewErrorText: ""
    property int previewRequestToken: 0

    implicitHeight: Math.max(markdownColumn.implicitHeight + 2 * EasyTheme.size.padding, 20)
    implicitWidth: root.autoWidth ? calculateImplicitWidth() : (parent ? parent.width : implicitWidth)
    height: implicitHeight
    width: autoWidth ? implicitWidth : (parent ? parent.width : implicitWidth)

    function calculateImplicitWidth() {
        var maxWidth = 60
        var blocks = documentObj.blocks
        for (var i = 0; i < blocks.length; i++) {
            var block = blocks[i]
            if (block.estimatedWidth && block.estimatedWidth > maxWidth)
                maxWidth = block.estimatedWidth
        }
        return maxWidth + 2 * EasyTheme.size.padding
    }

    // Auto-scroll timer for selection drag near edges
    Timer {
        id: autoScrollTimer
        interval: 30
        repeat: true
        property real scrollDelta: 0
        property real lastMouseX: 0
        property real lastMouseY: 0
        onTriggered: {
            if (scrollDelta !== 0 && selectionOverlay._selecting) {
                flickable.contentY = Math.max(0,
                    Math.min(flickable.contentHeight - flickable.height,
                             flickable.contentY + scrollDelta))
                // Update selection based on current mouse position after scroll
                var info = selectionOverlay.blockAtPoint(lastMouseX, lastMouseY, false)
                if (info) {
                    if (info.blockIndex !== selectionOverlay._lastDelegateIdx)
                        selectionOverlay._lastDelegateIdx = info.blockIndex
                    selectionHandlerObj.updateSelection(info.blockIndex, info.offset)
                }
            }
        }
    }

    function updateFlickableInteractive() {
        flickable.interactive = !root.autoWidth && flickable.contentHeight > flickable.height && !selectionOverlay._selecting
    }
    Component.onCompleted: updateFlickableInteractive()
    onAutoWidthChanged: updateFlickableInteractive()

    MarkdownStyle { id: styleObj; Component.onCompleted: syncWithTheme() }

    MarkdownDocument {
        id: documentObj
        onBlocksChanged: {
            selectionHandlerObj.setDocument(documentObj)
            _delegateMap = {}
            root.collectAllImages()
        }
    }

    MarkdownSelectionHandler { id: selectionHandlerObj }

    property var style: styleObj
    property var document: documentObj
    property bool selectable: true
    property bool copyEnabled: true

    property var _delegateMap: ({})
    property int _prevSelStart: -1
    property int _prevSelEnd: -1

    // Targeted selection updates — only blocks whose state changed get updated
    Connections {
        target: selectionHandlerObj
        function onSelectionChanged() {
            if (!selectionHandlerObj.hasSelection) {
                // Deselect entire previous range
                var ps = root._prevSelStart
                var pe = root._prevSelEnd
                if (ps >= 0 && pe >= ps) {
                    for (var i = ps; i <= pe; i++) {
                        var d = root._delegateMap[i]
                        if (d) d.applyStoredSelection()
                    }
                }
                // Also deselect any remaining blocks (selectAll then clear case)
                var allKeys = Object.keys(root._delegateMap)
                for (var k = 0; k < allKeys.length; k++) {
                    var idx = parseInt(allKeys[k])
                    if (idx < ps || idx > pe) {
                        var dd = root._delegateMap[idx]
                        if (dd) dd.applyStoredSelection()
                    }
                }
                root._prevSelStart = -1
                root._prevSelEnd = -1
                return
            }
            var newStart = selectionHandlerObj.selStartBlock
            var newEnd = selectionHandlerObj.selEndBlock
            if (newStart < 0 || newEnd < 0) return
            // Union of old and new ranges
            var minB = Math.min(root._prevSelStart >= 0 ? root._prevSelStart : newStart, newStart)
            var maxB = Math.max(root._prevSelEnd >= 0 ? root._prevSelEnd : newEnd, newEnd)
            for (var i = minB; i <= maxB; i++) {
                var d = root._delegateMap[i]
                if (d) d.applyStoredSelection()
            }
            root._prevSelStart = newStart
            root._prevSelEnd = newEnd
        }
    }

    Connections {
        target: EasyTheme
        function onIsDarkChanged() { syncWithTheme() }
        function onColorChanged() { syncWithTheme() }
        function onFontChanged() { syncWithTheme() }
    }

    function syncWithTheme() {
        styleObj.backgroundColor = EasyTheme.color.background
        styleObj.textColor = EasyTheme.markdown.paragraph.color
        styleObj.codeBackground = EasyTheme.markdown.code.bgColor
        styleObj.codeTextColor = EasyTheme.markdown.code.textColor
        styleObj.linkColor = EasyTheme.markdown.link.color
        styleObj.blockQuoteColor = EasyTheme.markdown.quote.textColor
        styleObj.borderColor = EasyTheme.color.border
        styleObj.tableHeaderBackground = EasyTheme.markdown.table.headerBgColor
        styleObj.tableRowBackground = EasyTheme.markdown.table.bgColor
        styleObj.tableAltRowBackground = EasyTheme.markdown.table.stripeColor
        styleObj.isDark = EasyTheme.isDark
        var baseFont = Qt.font({
            family: "Microsoft YaHei, Segoe UI, sans-serif",
            pixelSize: EasyTheme.font.sizeNormal
        })
        styleObj.baseFont = baseFont
        var codeFont = Qt.font({
            family: EasyTheme.markdown.code.fontFamily,
            pixelSize: EasyTheme.markdown.code.fontSize
        })
        styleObj.codeFont = codeFont
        styleObj.blockSpacing = 16
        styleObj.paragraphSpacing = EasyTheme.size.paddingSmall
        styleObj.listIndent = EasyTheme.size.paddingLarge
    }

    function isSvgSource(url) {
        if (!url || typeof url !== "string") return false
        return /^data:image\/svg\+xml/i.test(url)
            || /\.svg(\?|#|$)/i.test(url)
            || /\/svg(\?|#|$)/i.test(url)
    }

    function isUnsupportedRasterSource(url) {
        if (!url || typeof url !== "string") return false
        return /^data:image\/(webp|avif)/i.test(url)
            || /\.(webp|avif)(\?|#|$)/i.test(url)
    }

    function formatDisplayName(url) {
        if (!url || typeof url !== "string") return "image"
        if (/^data:image\/webp/i.test(url) || /\.webp(\?|#|$)/i.test(url)) return "webp"
        if (/^data:image\/avif/i.test(url) || /\.avif(\?|#|$)/i.test(url)) return "avif"
        return "image"
    }

    function extractAttribute(tag, name) {
        var match = new RegExp(name + "\\s*=\\s*(['\"])(.*?)\\1", "i").exec(tag)
        return match && match.length > 2 ? match[2] : ""
    }

    function removeAttribute(tag, name) {
        return tag.replace(new RegExp("\\s+" + name + "\\s*=\\s*(['\"]).*?\\1", "gi"), "")
    }

    function convertNestedSvgTag(tag) {
        var attrsMatch = /^<svg\b([^>]*)\/?>(\s*)$/i.exec(tag)
        var attrs = attrsMatch && attrsMatch.length > 1 ? attrsMatch[1] : ""
        var x = extractAttribute(tag, "x")
        var y = extractAttribute(tag, "y")
        var transform = extractAttribute(tag, "transform")
        var transforms = []
        if (x || y) transforms.push("translate(" + (x || 0) + " " + (y || 0) + ")")
        if (transform) transforms.push(transform)
        attrs = removeAttribute(attrs, "xmlns")
        attrs = removeAttribute(attrs, "version")
        attrs = removeAttribute(attrs, "x")
        attrs = removeAttribute(attrs, "y")
        attrs = removeAttribute(attrs, "width")
        attrs = removeAttribute(attrs, "height")
        attrs = removeAttribute(attrs, "viewBox")
        attrs = removeAttribute(attrs, "transform")
        if (transforms.length > 0) attrs += ' transform="' + transforms.join(" ") + '"'
        if (/\/\s*>$/.test(tag)) return "<g" + attrs + "></g>"
        return "<g" + attrs + ">"
    }

    function sanitizeSvgMarkup(svgText) {
        if (!svgText || svgText.indexOf("<svg") < 0) return svgText
        var depth = 0
        return svgText.replace(/<\/?svg\b[^>]*>/gi, function(tag) {
            var isClosing = /^<\//.test(tag)
            if (!isClosing) {
                if (depth === 0) {
                    depth += /\/\s*>$/.test(tag) ? 0 : 1
                    return tag
                }
                depth += /\/\s*>$/.test(tag) ? 0 : 1
                return convertNestedSvgTag(tag)
            }
            depth = Math.max(0, depth - 1)
            return depth === 0 ? tag : "</g>"
        })
    }

    function loadPreviewImageSource() {
        root.previewRequestToken += 1
        var token = root.previewRequestToken
        root.previewLoading = false
        root.previewError = false
        root.previewErrorText = ""

        if (root.previewRawUrl.length === 0) {
            root.previewResolvedSource = ""
            return
        }

        if (isUnsupportedRasterSource(root.previewRawUrl)) {
            root.previewResolvedSource = ""
            root.previewError = true
            root.previewErrorText = qsTr("Current Qt runtime does not support ")
                                   + formatDisplayName(root.previewRawUrl).toUpperCase()
                                   + qsTr(" images")
            return
        }

        if (isSvgSource(root.previewRawUrl)) {
            root.previewResolvedSource = ""
            root.previewLoading = true

            var xhr = new XMLHttpRequest()
            xhr.onreadystatechange = function() {
                if (xhr.readyState !== XMLHttpRequest.DONE || token !== root.previewRequestToken) return
                root.previewLoading = false
                if (xhr.status >= 200 && xhr.status < 300 && xhr.responseText) {
                    var sanitized = sanitizeSvgMarkup(xhr.responseText)
                    root.previewResolvedSource = "data:image/svg+xml;utf8," + encodeURIComponent(sanitized)
                } else {
                    root.previewError = true
                    root.previewErrorText = qsTr("Failed to load image")
                    root.previewResolvedSource = root.previewRawUrl
                }
            }
            xhr.open("GET", root.previewRawUrl)
            xhr.send()
            return
        }

        root.previewResolvedSource = root.previewRawUrl
    }

    function collectAllImages() {
        var images = []
        var blocks = documentObj.blocks
        for (var i = 0; i < blocks.length; i++) {
            collectImagesFromBlock(blocks[i], images)
        }
        root.imageList = images
    }

    function collectImagesFromBlock(block, images) {
        if (!block) return

        if (block.spans && block.spans.length > 0) {
            for (var j = 0; j < block.spans.length; j++) {
                var span = block.spans[j]
                if (span.imageUrl && span.imageUrl.length > 0) {
                    images.push({ url: span.imageUrl, displayText: span.text || "" })
                }
            }
        }

        if (block.type === 17 && block.rawText) {
            var imgRe = /<img\b[^>]*>/gi
            var imgMatch
            while ((imgMatch = imgRe.exec(block.rawText)) !== null) {
                var srcMatch = /src\s*=\s*["']([^"']*)["']/i.exec(imgMatch[0])
                if (srcMatch && srcMatch.length > 1 && srcMatch[1].length > 0) {
                    var altMatch = /alt\s*=\s*["']([^"']*)["']/i.exec(imgMatch[0])
                    var url = srcMatch[1]
                    var found = false
                    for (var k = 0; k < images.length; k++) {
                        if (images[k].url === url) { found = true; break }
                    }
                    if (!found) {
                        images.push({ url: url, displayText: altMatch && altMatch.length > 1 ? altMatch[1] : "" })
                    }
                }
            }
        }

        if (block.type === 14 && block.spans && block.spans.length > 1) {
            for (var j = 1; j < block.spans.length; j++) {
                var cells = (block.spans[j].text || "").split("|")
                for (var k = 0; k < cells.length; k++) {
                    var cellText = cells[k].trim()
                    var imgMatchRE = /^!\[([^\]]*)\]\(([^)]+)\)$/.exec(cellText)
                    if (imgMatchRE && imgMatchRE.length > 2) {
                        var url = imgMatchRE[2]
                        var found = false
                        for (var m = 0; m < images.length; m++) {
                            if (images[m].url === url) { found = true; break }
                        }
                        if (!found) {
                            images.push({ url: url, displayText: imgMatchRE[1] || "" })
                        }
                    }
                }
            }
        }

        if (block.children && block.children.length > 0) {
            for (var c = 0; c < block.children.length; c++) {
                collectImagesFromBlock(block.children[c], images)
            }
        }
    }

    function openImagePreview(url, displayText) {
        var idx = -1
        for (var i = 0; i < root.imageList.length; i++) {
            if (root.imageList[i].url === url) {
                idx = i
                break
            }
        }
        if (idx < 0 && root.imageList.length > 0) {
            idx = 0
        }
        root.currentImageIndex = idx
        root.previewRawUrl = url
        root.previewDisplayText = displayText || qsTr("图片预览")
        loadPreviewImageSource()
        sharedImagePreview.open()
    }

    function navigateImagePrev() {
        if (root.imageList.length <= 1) return
        var newIdx = root.currentImageIndex - 1
        if (newIdx < 0) newIdx = root.imageList.length - 1
        root.currentImageIndex = newIdx
        root.previewRawUrl = root.imageList[newIdx].url
        root.previewDisplayText = root.imageList[newIdx].displayText || qsTr("图片预览")
        root.previewFlickScale = 1.0
        loadPreviewImageSource()
        Qt.callLater(function() { sharedImagePreview.fitToWindow() })
    }

    function navigateImageNext() {
        if (root.imageList.length <= 1) return
        var newIdx = root.currentImageIndex + 1
        if (newIdx >= root.imageList.length) newIdx = 0
        root.currentImageIndex = newIdx
        root.previewRawUrl = root.imageList[newIdx].url
        root.previewDisplayText = root.imageList[newIdx].displayText || qsTr("图片预览")
        root.previewFlickScale = 1.0
        loadPreviewImageSource()
        Qt.callLater(function() { sharedImagePreview.fitToWindow() })
    }

    Rectangle {
        anchors.fill: parent
        color: styleObj.backgroundColor
    }

    // ── Flickable + Column + Repeater (all delegates always instantiated) ──

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: markdownColumn.implicitHeight + 2 * EasyTheme.size.padding
        interactive: false  // set dynamically by updateFlickableInteractive()
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        onContentHeightChanged: {
            if (!selectionOverlay._selecting) updateFlickableInteractive()
        }

        Column {
            id: markdownColumn
            x: EasyTheme.size.padding
            y: EasyTheme.size.padding
            width: flickable.width - 2 * EasyTheme.size.padding
            spacing: styleObj.blockSpacing

            Repeater {
                model: documentObj.blocks
                delegate: MarkdownBlock {
                    required property var modelData
                    required property int index

                    autoWidth: root.autoWidth
                    width: root.autoWidth ? implicitWidth : markdownColumn.width
                    blockData: modelData
                    blockIndex: index
                    style: styleObj
                    selectionHandler: selectionHandlerObj

                    onClicked: (block) => root.blockClicked(index, block)
                    onCopyRequested: documentObj.copyBlock(index)
                    onImagePreviewRequested: (url, text) => root.openImagePreview(url, text)

                    Component.onCompleted: {
                        root._delegateMap[index] = this
                    }
                    Component.onDestruction: {
                        delete root._delegateMap[index]
                    }
                }
            }
        }

        ScrollBar.vertical: EasyScrollBar {  }
    }

    // ── Selection overlay ──
    MouseArea {
        id: selectionOverlay
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        enabled: root.selectable
        preventStealing: true

        property bool _selecting: false
        property int _lastDelegateIdx: -1

        onPressed: mouse => {
            var info = blockAtPoint(mouse.x, mouse.y, true)
            if (!info) {
                mouse.accepted = false
                return
            }
            _selecting = true
            _lastDelegateIdx = info.blockIndex
            updateFlickableInteractive()
            selectionHandlerObj.beginSelection(info.blockIndex, info.offset)
            mouse.accepted = true
        }

        onPositionChanged: mouse => {
            if (!_selecting) return
            autoScrollTimer.lastMouseX = mouse.x
            autoScrollTimer.lastMouseY = mouse.y
            var info = blockAtPoint(mouse.x, mouse.y, false)
            if (info) {
                if (info.blockIndex !== _lastDelegateIdx)
                    _lastDelegateIdx = info.blockIndex
                selectionHandlerObj.updateSelection(info.blockIndex, info.offset)
            }
            // Auto-scroll at edges
            if (mouse.y < 25) {
                autoScrollTimer.scrollDelta = -8
                if (!autoScrollTimer.running) autoScrollTimer.start()
            } else if (mouse.y > flickable.height - 25) {
                autoScrollTimer.scrollDelta = 8
                if (!autoScrollTimer.running) autoScrollTimer.start()
            } else {
                autoScrollTimer.scrollDelta = 0
                autoScrollTimer.stop()
            }
        }

        onReleased: {
            autoScrollTimer.stop()
            if (_selecting) {
                _selecting = false
                selectionHandlerObj.endSelection()
                updateFlickableInteractive()
            }
        }

        onCanceled: {
            autoScrollTimer.stop()
            if (_selecting) {
                _selecting = false
                updateFlickableInteractive()
            }
        }

        // Find the block and character offset at a viewport point.
        // If strict is true, returns null for points outside TextArea bounds.
        // If strict is false, always finds the nearest block and clamps offset.
        function blockAtPoint(vx, vy, strict) {
            var contentXY = vy + flickable.contentY
            var keys = Object.keys(root._delegateMap)
            var bestDelegate = null
            var bestBlockIdx = -1
            var bestDist = Infinity

            // Find which block the point falls in (or nearest to)
            for (var k = 0; k < keys.length; k++) {
                var idx = parseInt(keys[k])
                var d = root._delegateMap[keys[k]]
                if (!d) continue
                var dTop = EasyTheme.size.padding + d.y
                var dBottom = dTop + d.height
                if (contentXY >= dTop && contentXY < dBottom) {
                    bestDelegate = d
                    bestBlockIdx = idx
                    break
                }
                var dist = contentXY < dTop ? (dTop - contentXY) : (contentXY - dBottom)
                if (dist < bestDist) {
                    bestDist = dist
                    bestDelegate = d
                    bestBlockIdx = idx
                }
            }
            if (!bestDelegate) return null

            var ta = bestDelegate.textAreaItem()
            if (!ta) {
                // Block without TextArea (table, image, etc.): select from start or end
                if (strict) return null
                return { blockIndex: bestBlockIdx, offset: 0 }
            }

            // Map viewport point to TextArea local coordinates
            var posInTa = selectionOverlay.mapToItem(ta, vx, vy)

            if (strict) {
                // Reject if clearly outside the TextArea
                if (posInTa.y < -6 || posInTa.y > ta.height + 6 ||
                    posInTa.x < -6 || posInTa.x > ta.width + 6)
                    return null
                var strictOffset = ta.positionAt(posInTa.x, posInTa.y)
                return (strictOffset >= 0) ? { blockIndex: bestBlockIdx, offset: strictOffset } : null
            }

            // Permissive: clamp to beginning or end of text
            var offset
            if (posInTa.y < 0) {
                offset = 0
            } else if (posInTa.y > ta.height) {
                offset = ta.length
            } else {
                offset = ta.positionAt(Math.max(0, posInTa.x), posInTa.y)
                if (offset < 0) offset = 0
            }
            return { blockIndex: bestBlockIdx, offset: offset }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: documentObj.loading
        visible: running
        width: 32; height: 32
    }

    Text {
        anchors.centerIn: parent
        text: documentObj.loading ? "" : "暂无内容"
        font.pixelSize: 13
        color: EasyTheme.color.placeholder
        visible: !documentObj.loading && documentObj.blocks.length === 0
    }

    property int _contextBlockIndex: -1

    function blockIndexAt(my) {
        var contentY = my + flickable.contentY
        var keys = Object.keys(root._delegateMap)
        for (var k = 0; k < keys.length; k++) {
            var delegate = root._delegateMap[keys[k]]
            if (!delegate) continue
            var dTop = EasyTheme.size.padding + delegate.y
            var dBottom = dTop + delegate.height
            if (contentY >= dTop && contentY < dBottom) {
                return parseInt(keys[k])
            }
        }
        return -1
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: (mouse) => {
            root._contextBlockIndex = blockIndexAt(mouse.y)
            var globalPos = mapToItem(Overlay.overlay, mouse.x, mouse.y)
            contextMenu.popup(globalPos.x, globalPos.y, [
                {
                    text: qsTr("复制"), icon: EasyIcon.material.content_copy,
                    enabled: selectionHandlerObj.hasSelection,
                    action: function() { selectionHandlerObj.copySelection(); ToastManager.success(qsTr("Copied!")) }
                },
                {
                    text: qsTr("复制块"), icon: EasyIcon.material.copy_all,
                    enabled: root._contextBlockIndex >= 0,
                    action: function() { documentObj.copyBlock(root._contextBlockIndex); ToastManager.success(qsTr("Copied!")) }
                },
                {
                    text: qsTr("复制原文"), icon: EasyIcon.material.code,
                    enabled: documentObj.source.length > 0,
                    action: function() { documentObj.copyToClipboard(documentObj.source); ToastManager.success(qsTr("Copied!")) }
                },
                { separator: true },
                {
                    text: qsTr("全选"), icon: EasyIcon.material.select_all,
                    enabled: documentObj.blocks.length > 0,
                    action: function() { selectionHandlerObj.selectAll() }
                }
            ])
        }
    }

    EasyContextMenu { id: contextMenu }

    Shortcut {
        sequences: [StandardKey.Copy]
        onActivated: {
            selectionHandlerObj.copySelection()
            if (selectionHandlerObj.hasSelection)
                ToastManager.success(qsTr("Copied!"))
        }
    }
    Shortcut {
        sequences: [StandardKey.SelectAll]
        onActivated: selectionHandlerObj.selectAll()
    }

    function scrollToBlock(index) {}
    function copyAll() { documentObj.copyToClipboard(documentObj.source) }
    function setSource(text) { documentObj.source = text }

    property real previewFlickScale: 1.0

    Dialog {
        id: sharedImagePreview
        modal: true
        padding: 0
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: parent ? Math.min(parent.width - 48, 1280) : 1100
        height: parent ? Math.min(parent.height - 48, 920) : 760
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        function naturalImageWidth() {
            return previewImg.sourceSize.width > 0
                   ? previewImg.sourceSize.width
                   : previewImg.implicitWidth
        }

        function naturalImageHeight() {
            return previewImg.sourceSize.height > 0
                   ? previewImg.sourceSize.height
                   : previewImg.implicitHeight
        }

        function clampScale(value) {
            return Math.max(previewFlick.minScale, Math.min(previewFlick.maxScale, value))
        }

        function centerPreview() {
            previewFlick.contentX = Math.max(0, (previewFlick.contentWidth - previewFlick.width) / 2)
            previewFlick.contentY = Math.max(0, (previewFlick.contentHeight - previewFlick.height) / 2)
        }

        function fitToWindow() {
            var sw = naturalImageWidth()
            var sh = naturalImageHeight()
            if (sw <= 0 || sh <= 0 || previewViewport.width <= 0 || previewViewport.height <= 0) return
            var scale = Math.min(previewViewport.width / sw, previewViewport.height / sh)
            previewFlickScale = clampScale(Math.min(scale, 2.4))
            Qt.callLater(centerPreview)
        }

        function resetToOriginal() {
            previewFlickScale = 1.0
            Qt.callLater(centerPreview)
        }

        function zoomBy(delta) {
            previewFlickScale = clampScale(previewFlickScale + delta)
            Qt.callLater(centerPreview)
        }

        onOpened: {
            Qt.callLater(fitToWindow)
            contentItem.forceActiveFocus()
        }

        Overlay.modal: Rectangle {
            color: EasyTheme.color.overlay
        }

        background: Rectangle {
            radius: EasyTheme.size.radius
            color: EasyTheme.color.card
            border.width: EasyTheme.size.borderWidth
            border.color: EasyTheme.color.border
        }

        contentItem: Item {
            anchors.fill: parent
            focus: true
            Keys.onLeftPressed: (event) => {
                if (root.imageList.length > 1 && root.currentImageIndex > 0) {
                    root.navigateImagePrev()
                    event.accepted = true
                }
            }
            Keys.onRightPressed: (event) => {
                if (root.imageList.length > 1 && root.currentImageIndex < root.imageList.length - 1) {
                    root.navigateImageNext()
                    event.accepted = true
                }
            }

            // ── Header ──
            Item {
                id: headerBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 52

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 56
                    spacing: 10

                    EasyIconFont {
                        icon: EasyIcon.material.image
                        iconSize: 20
                        color: EasyTheme.color.secondary
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true

                        Label {
                            text: root.previewDisplayText || qsTr("图片预览")
                            color: EasyTheme.color.text
                            font.pixelSize: 15
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: previewImg.status === Image.Ready
                                  ? sharedImagePreview.naturalImageWidth() + " × " + sharedImagePreview.naturalImageHeight() + " px"
                                  : (root.previewRawUrl || "")
                            color: EasyTheme.color.placeholder
                            font.pixelSize: 11
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    width: 36
                    height: 36
                    radius: EasyTheme.size.radius
                    color: closeBtnMA.containsMouse ? EasyTheme.color.hover : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: EasyIcon.material.close
                        iconSize: 18
                        color: EasyTheme.color.secondary
                    }

                    MouseArea {
                        id: closeBtnMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sharedImagePreview.close()
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: EasyTheme.size.borderWidth
                    color: EasyTheme.color.divider
                }
            }

            // ── Stage ──
            Rectangle {
                id: previewStage
                anchors.top: headerBar.bottom
                anchors.bottom: toolbarBar.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                radius: EasyTheme.size.radius
                color: EasyTheme.isDark ? "#0d0d12" : "#f9fafb"
                border.width: EasyTheme.size.borderWidth
                border.color: EasyTheme.color.divider
                clip: true

                Item {
                    id: previewViewport
                    anchors.fill: parent
                    anchors.margins: 12

                    Flickable {
                        id: previewFlick
                        anchors.fill: parent
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        interactive: contentWidth > width || contentHeight > height
                        contentWidth: Math.max(width, previewImg.width + 40)
                        contentHeight: Math.max(height, previewImg.height + 40)

                        property real scale: root.previewFlickScale
                        property real minScale: 0.15
                        property real maxScale: 8.0

                        onScaleChanged: root.previewFlickScale = scale

                        Item {
                            width: previewFlick.contentWidth
                            height: previewFlick.contentHeight

                            Rectangle {
                                visible: previewImg.status === Image.Ready && !root.previewError
                                width: previewImg.width + 16
                                height: previewImg.height + 16
                                anchors.centerIn: parent
                                radius: 8
                                color: EasyTheme.color.card
                                border.width: EasyTheme.size.borderWidth
                                border.color: EasyTheme.color.border

                                layer.enabled: true
                                layer.effect: EasyShadow { }
                            }

                            Image {
                                id: previewImg
                                anchors.centerIn: parent
                                width: sharedImagePreview.naturalImageWidth() > 0 ? sharedImagePreview.naturalImageWidth() * root.previewFlickScale : 0
                                height: sharedImagePreview.naturalImageHeight() > 0 ? sharedImagePreview.naturalImageHeight() * root.previewFlickScale : 0
                                source: root.previewResolvedSource
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                cache: true

                                onStatusChanged: {
                                    if (status === Image.Ready)
                                        Qt.callLater(function() { sharedImagePreview.fitToWindow() })
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            cursorShape: previewFlick.interactive ? Qt.OpenHandCursor : Qt.ArrowCursor
                            onWheel: (wheel) => {
                                sharedImagePreview.zoomBy(wheel.angleDelta.y > 0 ? 0.12 : -0.12)
                                wheel.accepted = true
                            }
                        }
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: root.previewLoading || previewImg.status === Image.Loading
                        visible: running
                        width: 40
                        height: 40
                    }

                    Label {
                        anchors.centerIn: parent
                        width: Math.max(80, parent.width - 24)
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        text: root.previewError
                              ? (root.previewErrorText.length > 0 ? root.previewErrorText : qsTr("Failed to load image"))
                              : ""
                        visible: root.previewError
                        color: EasyTheme.color.text
                    }
                }

                // ── Navigation Arrows ──
                Rectangle {
                    visible: root.imageList.length > 1 && root.currentImageIndex > 0
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 36
                    radius: width / 2
                    color: prevArrowMA.containsMouse ? EasyTheme.color.hover : EasyTheme.color.card
                    border.width: EasyTheme.size.borderWidth
                    border.color: EasyTheme.color.divider
                    opacity: 0.85
                    Behavior on color { ColorAnimation { duration: 100 } }

                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: EasyIcon.material.chevron_left
                        iconSize: 22
                        color: EasyTheme.color.text
                    }

                    MouseArea {
                        id: prevArrowMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.navigateImagePrev()
                    }
                }

                Rectangle {
                    visible: root.imageList.length > 1 && root.currentImageIndex < root.imageList.length - 1
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 36
                    radius: width / 2
                    color: nextArrowMA.containsMouse ? EasyTheme.color.hover : EasyTheme.color.card
                    border.width: EasyTheme.size.borderWidth
                    border.color: EasyTheme.color.divider
                    opacity: 0.85
                    Behavior on color { ColorAnimation { duration: 100 } }

                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: EasyIcon.material.chevron_right
                        iconSize: 22
                        color: EasyTheme.color.text
                    }

                    MouseArea {
                        id: nextArrowMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.navigateImageNext()
                    }
                }
            }

            // ── Toolbar ──
            Item {
                id: toolbarBar
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 12
                width: toolbarRow.width + 20
                height: 40

                Rectangle {
                    anchors.fill: parent
                    radius: EasyTheme.size.radius
                    color: EasyTheme.isDark ? "#1e1e28" : "#ffffff"
                    border.width: EasyTheme.size.borderWidth
                    border.color: EasyTheme.color.border

                    layer.enabled: true
                    layer.effect: EasyShadow { }
                }

                Row {
                    id: toolbarRow
                    anchors.centerIn: parent
                    spacing: 4
                    height: parent.height

                    Rectangle {
                        width: 36
                        height: 36
                        radius: EasyTheme.size.radius
                        color: zoomOutArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: previewImg.status === Image.Ready && !root.previewError ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 100 } }

                        EasyIconFont {
                            anchors.centerIn: parent
                            icon: EasyIcon.material.remove
                            iconSize: 18
                            color: EasyTheme.color.text
                        }

                        MouseArea {
                            id: zoomOutArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: previewImg.status === Image.Ready && !root.previewError
                            onClicked: sharedImagePreview.zoomBy(-0.15)
                        }
                    }

                    Rectangle {
                        width: 56
                        height: 32
                        radius: EasyTheme.size.radius
                        color: EasyTheme.isDark ? "#14141a" : "#f0f1f3"
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            anchors.centerIn: parent
                            text: Math.round(root.previewFlickScale * 100) + "%"
                            color: EasyTheme.color.secondary
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }

                    Rectangle {
                        width: 36
                        height: 36
                        radius: EasyTheme.size.radius
                        color: zoomInArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: previewImg.status === Image.Ready && !root.previewError ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 100 } }

                        EasyIconFont {
                            anchors.centerIn: parent
                            icon: EasyIcon.material.add
                            iconSize: 18
                            color: EasyTheme.color.text
                        }

                        MouseArea {
                            id: zoomInArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: previewImg.status === Image.Ready && !root.previewError
                            onClicked: sharedImagePreview.zoomBy(0.15)
                        }
                    }

                    Rectangle {
                        width: 1
                        height: 22
                        color: EasyTheme.color.divider
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 52
                        height: 36
                        radius: EasyTheme.size.radius
                        color: fitArea.containsMouse ? EasyTheme.color.primaryBg : EasyTheme.color.primary
                        opacity: previewImg.status === Image.Ready && !root.previewError ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth
                        border.color: fitArea.containsMouse ? EasyTheme.color.primaryBorder : EasyTheme.color.primary
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Label {
                            anchors.centerIn: parent
                            text: qsTr("适应")
                            color: fitArea.containsMouse ? EasyTheme.color.primary : "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: fitArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: previewImg.status === Image.Ready && !root.previewError
                            onClicked: sharedImagePreview.fitToWindow()
                        }
                    }

                    Rectangle {
                        width: 44
                        height: 36
                        radius: EasyTheme.size.radius
                        color: originalArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: previewImg.status === Image.Ready && !root.previewError ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth
                        border.color: EasyTheme.color.border
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Label {
                            anchors.centerIn: parent
                            text: "1:1"
                            color: EasyTheme.color.text
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: originalArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: previewImg.status === Image.Ready && !root.previewError
                            onClicked: sharedImagePreview.resetToOriginal()
                        }
                    }

                    Rectangle {
                        visible: root.imageList.length > 1
                        width: 1
                        height: 22
                        color: EasyTheme.color.divider
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        visible: root.imageList.length > 1
                        width: 36
                        height: 36
                        radius: EasyTheme.size.radius
                        color: prevBtnMA.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: root.currentImageIndex > 0 ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 100 } }

                        EasyIconFont {
                            anchors.centerIn: parent
                            icon: EasyIcon.material.chevron_left
                            iconSize: 18
                            color: EasyTheme.color.text
                        }

                        MouseArea {
                            id: prevBtnMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.currentImageIndex > 0
                            onClicked: root.navigateImagePrev()
                        }
                    }

                    Rectangle {
                        visible: root.imageList.length > 1
                        width: 48
                        height: 32
                        radius: EasyTheme.size.radius
                        color: EasyTheme.isDark ? "#14141a" : "#f0f1f3"
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            anchors.centerIn: parent
                            text: (root.currentImageIndex + 1) + " / " + root.imageList.length
                            color: EasyTheme.color.secondary
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Rectangle {
                        visible: root.imageList.length > 1
                        width: 36
                        height: 36
                        radius: EasyTheme.size.radius
                        color: nextBtnMA.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: root.currentImageIndex < root.imageList.length - 1 ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 100 } }

                        EasyIconFont {
                            anchors.centerIn: parent
                            icon: EasyIcon.material.chevron_right
                            iconSize: 18
                            color: EasyTheme.color.text
                        }

                        MouseArea {
                            id: nextBtnMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.currentImageIndex < root.imageList.length - 1
                            onClicked: root.navigateImageNext()
                        }
                    }

                    Rectangle {
                        width: 1
                        height: 22
                        color: EasyTheme.color.divider
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 64
                        height: 36
                        radius: EasyTheme.size.radius
                        color: openArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: root.previewRawUrl.length > 0 ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth
                        border.color: EasyTheme.color.border
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            EasyIconFont {
                                icon: EasyIcon.material.open_in_new
                                iconSize: 14
                                color: EasyTheme.color.text
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: qsTr("原图")
                                color: EasyTheme.color.text
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: openArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.previewRawUrl.length > 0
                            onClicked: Qt.openUrlExternally(root.previewRawUrl)
                        }
                    }
                }
            }
        }
    }

    }
