// MarkdownTable.qml
import QtQuick
import QtQuick.Controls
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

    property int cellPadding: 10
    property int minRowHeight: 34

    implicitHeight: table.height + 10
    color: borderColor
    radius: 4

    // Convert blockData to EasyTable format
    property var _columns: []
    property var _tableData: []

    onBlockDataChanged: updateData()

    function updateData() {
        var cols = []
        var rows = []

        if (blockData && blockData.spans && blockData.spans.length > 0) {
            // Parse headers
            var h = (blockData.spans[0].text || "").split("|")
            for (var i = 0; i < h.length; i++) {
                cols.push({
                    title: h[i] || "",
                    key: "col" + i,
                    width: -1,
                    align: Text.AlignLeft
                })
            }
            // Parse data rows
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
        rowHeight: Math.max(root.minRowHeight, root.textFont ? root.textFont.pixelSize + 20 : 34)
        cellPadding: root.cellPadding
        hoverHighlight: false
        sortable: false

        delegate: Text {
            text: value !== undefined ? String(value) : ""
            color: root.textColor
            font.family: root.textFont ? root.textFont.family : "Microsoft YaHei, Segoe UI, sans-serif"
            font.pixelSize: root.textFont ? root.textFont.pixelSize : 13
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            clip: true
        }
    }
}
