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
}
