// MarkdownTable.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI 1.0

Rectangle {
    id: root

    property var blockData: null
    property var textFont: null
    property color textColor: EasyTheme.color.text
    property color borderColor: EasyTheme.color.divider
    property color headerBackground: EasyTheme.markdown.table.headerBgColor
    property color rowBackground: EasyTheme.markdown.table.bgColor
    property color rowAltBackground: EasyTheme.markdown.table.stripeColor
    property bool isDark: EasyTheme.isDark

    signal previewRequested(string imageUrl, string displayText)

    property int cellPadding: 10
    property int minRowHeight: 34

    implicitHeight: table.height + 10
    color: borderColor
    radius: 4

    property var _columns: []
    property var _tableData: []
    property var _rowHeights: []

    onBlockDataChanged: updateData()

    Timer {
        id: recalcTimer
        interval: 1
        onTriggered: root.recalculateRowHeights()
    }

    onWidthChanged: recalcTimer.start()

    function inlineToHtml(text) {
        if (!text) return ""
        var codeBg = isDark ? "#2d2d3d" : "#f0f0f0"
        var linkColor = isDark ? "#58a6ff" : "#0969da"
        var html = text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
        html = html.replace(/\*\*(.+?)\*\*/g, "<b>$1</b>")
        html = html.replace(/\*(.+?)\*/g, "<i>$1</i>")
        html = html.replace(/~~(.+?)~~/g, "<s>$1</s>")
        html = html.replace(/`([^`]+)`/g, '<span style="background-color:' + codeBg + ';padding:1px 4px;border-radius:3px;font-family:Consolas,monospace;font-size:0.9em;">$1</span>')
        html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" style="color:' + linkColor + ';">$1</a>')
        return html
    }

    function updateData() {
        var cols = []
        var rows = []

        if (blockData && blockData.spans && blockData.spans.length > 0) {
            var h = (blockData.spans[0].text || "").split("|")
            for (var i = 0; i < h.length; i++) {
                cols.push({
                    title: h[i] || "",
                    key: "col" + i,
                    width: -1,
                    align: Text.AlignLeft
                })
            }
            for (var r = 1; r < blockData.spans.length; r++) {
                var cells = (blockData.spans[r].text || "").split("|")
                var row = {}
                for (var c = 0; c < cols.length; c++) {
                    row["col" + c] = c < cells.length ? (cells[c] || "") : ""
                }
                rows.push(row)
            }
        }

        _columns = cols
        _tableData = rows
        recalcTimer.start()
    }

    function recalculateRowHeights() {
        var numCols = _columns.length
        if (numCols === 0 || root.width <= 0 || !_tableData) {
            _rowHeights = []
            return
        }

        var tableContentWidth = Math.max(100, root.width - 2)
        var cellPadTotal = cellPadding * 2
        var expandableW = 0
        var totalFixedW = 0
        var autoColCount = 0
        for (var i = 0; i < numCols; i++) {
            if (_columns[i].width > 0) totalFixedW += _columns[i].width
            else autoColCount++
        }
        var colWidth = autoColCount > 0 ? Math.max(30, (tableContentWidth - totalFixedW - expandableW) / autoColCount) : 30
        var textWidth = Math.max(20, colWidth - cellPadTotal)

        cellMeasurer.width = textWidth
        cellMeasurer.font.family = root.textFont ? root.textFont.family : "Microsoft YaHei, Segoe UI, sans-serif"
        cellMeasurer.font.pixelSize = root.textFont ? root.textFont.pixelSize : 13

        var heights = []

        cellMeasurer.textFormat = Text.PlainText
        cellMeasurer.font.bold = true
        var headerH = minRowHeight
        for (var c = 0; c < numCols; c++) {
            var title = _columns[c].title || ""
            if (title.length > 0) {
                cellMeasurer.text = title
                var h = cellMeasurer.implicitHeight + cellPadTotal
                if (h > headerH) headerH = h
            }
        }
        cellMeasurer.font.bold = false

        for (var r = 0; r < _tableData.length; r++) {
            var rowH = minRowHeight
            for (var c = 0; c < numCols; c++) {
                var cellValue = String(_tableData[r]["col" + c] !== undefined ? _tableData[r]["col" + c] : "")
                if (/^!\[.*\]\(.+\)$/.test(cellValue.trim())) {
                    var imgH = 180 + cellPadTotal
                    if (imgH > rowH) rowH = imgH
                    continue
                }
                if (cellValue.length === 0) continue
                cellMeasurer.textFormat = Text.RichText
                cellMeasurer.text = inlineToHtml(cellValue)
                var h = cellMeasurer.implicitHeight + cellPadTotal
                if (h > rowH) rowH = h
            }
            heights.push(Math.max(minRowHeight, Math.ceil(rowH)))
        }

        _rowHeights = heights
        _headerHeight = Math.max(minRowHeight, Math.ceil(headerH))
    }

    property real _headerHeight: minRowHeight

    Text {
        id: cellMeasurer
        visible: false
        wrapMode: Text.WordWrap
    }

    EasyTable {
        id: table
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.top: parent.top
        anchors.topMargin: 1
        width: parent.width - 2

        columns: root._columns
        tableData: root._tableData
        stripe: true
        headerColor: root.headerBackground
        rowColor: root.rowBackground
        altRowColor: root.rowAltBackground
        rowHeight: root.minRowHeight
        rowHeights: root._rowHeights
        headerHeight: root._headerHeight
        cellPadding: root.cellPadding
        hoverHighlight: false
        sortable: false

        delegate: Item {
            width: root.cellPadding > 0 ? 100 : 100
            height: rowHeight

            readonly property string cellValue: String(value !== undefined ? value : "")
            readonly property bool isImage: new RegExp("^!\\[.*\\]\\(.+\\)$").test(cellValue.trim())
            readonly property var imgMatch: new RegExp("^!\\[([^\\]]*)\\]\\(([^)]+)\\)$").exec(cellValue.trim())

            Text {
                visible: !parent.isImage
                anchors.fill: parent
                text: root.inlineToHtml(parent.cellValue)
                textFormat: Text.RichText
                color: root.textColor
                font.family: root.textFont ? root.textFont.family : "Microsoft YaHei, Segoe UI, sans-serif"
                font.pixelSize: root.textFont ? root.textFont.pixelSize : 13
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                clip: true
                onLinkActivated: function(link) { Qt.openUrlExternally(link) }
            }

            Image {
                visible: parent.isImage
                source: parent.imgMatch ? parent.imgMatch[2] : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                cache: true
                width: Math.min(implicitWidth, 260)
                height: Math.min(implicitHeight, rowHeight - 10)
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var url = parent.parent.imgMatch ? parent.parent.imgMatch[2] : ""
                        var alt = parent.parent.imgMatch ? parent.parent.imgMatch[1] : ""
                        if (url.length > 0) {
                            root.previewRequested(url, alt || qsTr("图片预览"))
                        }
                    }
                }
            }
        }
    }

}