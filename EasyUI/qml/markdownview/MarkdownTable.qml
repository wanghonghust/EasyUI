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

    property int cellPadding: 10
    property int minRowHeight: 34

    implicitHeight: table.height + 10
    color: borderColor
    radius: 4

    property var _columns: []
    property var _tableData: []

    onBlockDataChanged: updateData()

    function inlineToHtml(text) {
        if (!text) return ""
        var html = text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
        html = html.replace(/\*\*(.+?)\*\*/g, "<b>$1</b>")
        html = html.replace(/\*(.+?)\*/g, "<i>$1</i>")
        html = html.replace(/~~(.+?)~~/g, "<s>$1</s>")
        var codeBg = isDark ? "#2d2d3d" : "#f0f0f0"
        html = html.replace(/`([^`]+)`/g, '<span style="background-color:' + codeBg + ';padding:1px 4px;border-radius:3px;font-family:Consolas,monospace;font-size:0.9em;">$1</span>')
        var linkColor = root.isDark ? "#58a6ff" : "#0969da"
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

        delegate: Item {
            width: root.cellPadding > 0 ? 100 : 100
            height: root.rowHeight

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
                height: Math.min(implicitHeight, 180)
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var url = parent.parent.imgMatch ? parent.parent.imgMatch[2] : ""
                        var alt = parent.parent.imgMatch ? parent.parent.imgMatch[1] : ""
                        if (url.length > 0) {
                            pvImage.source = url
                            pvDialogTitle.text = alt || qsTr("图片预览")
                            pvDialogSizeLabel.text = ""
                            pvFlick.scale = 1.0
                            pvDialog.open()
                        }
                    }
                }
            }
        }
    }

    // ===== Image Preview Dialog =====
    Dialog {
        id: pvDialog
        modal: true
        padding: 0
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: parent ? Math.min(parent.width - 48, 1280) : 1100
        height: parent ? Math.min(parent.height - 48, 920) : 760
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Overlay.modal: Rectangle { color: EasyTheme.color.overlay }

        background: Rectangle {
            radius: EasyTheme.size.radius
            color: EasyTheme.color.card
            border.width: EasyTheme.size.borderWidth
            border.color: EasyTheme.color.border
        }

        contentItem: Item {
            anchors.fill: parent

            // ── Header ──
            Item {
                id: pvHeader
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
                            id: pvDialogTitle
                            text: qsTr("图片预览")
                            color: EasyTheme.color.text
                            font.pixelSize: 15
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            id: pvDialogSizeLabel
                            text: ""
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
                    color: pvCloseBtn.containsMouse ? EasyTheme.color.hover : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: EasyIcon.material.close
                        iconSize: 18
                        color: EasyTheme.color.secondary
                    }

                    MouseArea {
                        id: pvCloseBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pvDialog.close()
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
                id: pvStage
                anchors.top: pvHeader.bottom
                anchors.bottom: pvToolbar.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                radius: EasyTheme.size.radius
                color: EasyTheme.isDark ? "#0d0d12" : "#f9fafb"
                border.width: EasyTheme.size.borderWidth
                border.color: EasyTheme.color.divider
                clip: true

                Flickable {
                    id: pvFlick
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentWidth > width || contentHeight > height
                    contentWidth: Math.max(width, pvImage.width + 40)
                    contentHeight: Math.max(height, pvImage.height + 40)

                    property real scale: 1.0
                    property real minScale: 0.15
                    property real maxScale: 8.0

                    function centerContent() {
                        contentX = Math.max(0, (contentWidth - width) / 2)
                        contentY = Math.max(0, (contentHeight - height) / 2)
                    }

                    Item {
                        width: pvFlick.contentWidth
                        height: pvFlick.contentHeight

                        Image {
                            id: pvImage
                            anchors.centerIn: parent
                            width: status === Image.Ready ? sourceSize.width * pvFlick.scale : 0
                            height: status === Image.Ready ? sourceSize.height * pvFlick.scale : 0
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            cache: true

                            onStatusChanged: {
                                if (status === Image.Ready) {
                                    var sw = sourceSize.width
                                    var sh = sourceSize.height
                                    if (sw > 0 && sh > 0) {
                                        pvDialogSizeLabel.text = sw + " × " + sh + " px"
                                        var s = Math.min((pvStage.width - 24) / sw, (pvStage.height - 24) / sh, 2.4)
                                        pvFlick.scale = Math.max(pvFlick.minScale, Math.min(s, pvFlick.maxScale))
                                    }
                                    Qt.callLater(pvFlick.centerContent)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            cursorShape: pvFlick.interactive ? Qt.OpenHandCursor : Qt.ArrowCursor
                            onWheel: function(wheel) {
                                pvFlick.scale = Math.max(pvFlick.minScale, Math.min(pvFlick.maxScale, pvFlick.scale + (wheel.angleDelta.y > 0 ? 0.12 : -0.12)))
                                wheel.accepted = true
                            }
                        }
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: pvImage.status === Image.Loading
                        visible: running
                        width: 40
                        height: 40
                    }
                }
            }

            // ── Toolbar ──
            Item {
                id: pvToolbar
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 12
                width: pvRow.width + 20
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
                    id: pvRow
                    anchors.centerIn: parent
                    spacing: 4
                    height: parent.height

                    // Zoom out
                    Rectangle {
                        width: 36; height: 36; radius: EasyTheme.size.radius
                        color: pvZoomOutArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: pvImage.status === Image.Ready ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 100 } }
                        EasyIconFont { anchors.centerIn: parent; icon: EasyIcon.material.remove; iconSize: 18; color: EasyTheme.color.text }
                        MouseArea { id: pvZoomOutArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: pvImage.status === Image.Ready; onClicked: pvFlick.scale = Math.max(pvFlick.minScale, Math.min(pvFlick.maxScale, pvFlick.scale - 0.15)) }
                    }

                    // Scale badge
                    Rectangle {
                        width: 56; height: 32; radius: EasyTheme.size.radius
                        color: EasyTheme.isDark ? "#14141a" : "#f0f1f3"
                        anchors.verticalCenter: parent.verticalCenter
                        Label { anchors.centerIn: parent; text: Math.round(pvFlick.scale * 100) + "%"; color: EasyTheme.color.secondary; font.pixelSize: 12; font.bold: true }
                    }

                    // Zoom in
                    Rectangle {
                        width: 36; height: 36; radius: EasyTheme.size.radius
                        color: pvZoomInArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: pvImage.status === Image.Ready ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 100 } }
                        EasyIconFont { anchors.centerIn: parent; icon: EasyIcon.material.add; iconSize: 18; color: EasyTheme.color.text }
                        MouseArea { id: pvZoomInArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: pvImage.status === Image.Ready; onClicked: pvFlick.scale = Math.max(pvFlick.minScale, Math.min(pvFlick.maxScale, pvFlick.scale + 0.15)) }
                    }

                    // Separator
                    Rectangle { width: 1; height: 22; color: EasyTheme.color.divider; anchors.verticalCenter: parent.verticalCenter }

                    // Fit
                    Rectangle {
                        width: 52; height: 36; radius: EasyTheme.size.radius
                        color: pvFitArea.containsMouse ? EasyTheme.color.primaryBg : EasyTheme.color.primary
                        opacity: pvImage.status === Image.Ready ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth; border.color: pvFitArea.containsMouse ? EasyTheme.color.primaryBorder : EasyTheme.color.primary
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Label { anchors.centerIn: parent; text: qsTr("适应"); color: pvFitArea.containsMouse ? EasyTheme.color.primary : "#ffffff"; font.pixelSize: 12; font.bold: true }
                        MouseArea { id: pvFitArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: pvImage.status === Image.Ready; onClicked: { var sw = pvImage.sourceSize.width; var sh = pvImage.sourceSize.height; if (sw > 0 && sh > 0) { pvFlick.scale = Math.max(pvFlick.minScale, Math.min((pvStage.width - 24) / sw, (pvStage.height - 24) / sh, pvFlick.maxScale)); Qt.callLater(pvFlick.centerContent) } } }
                    }

                    // 1:1
                    Rectangle {
                        width: 44; height: 36; radius: EasyTheme.size.radius
                        color: pvOriginalArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: pvImage.status === Image.Ready ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth; border.color: EasyTheme.color.border
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Label { anchors.centerIn: parent; text: "1:1"; color: EasyTheme.color.text; font.pixelSize: 12; font.bold: true }
                        MouseArea { id: pvOriginalArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: pvImage.status === Image.Ready; onClicked: { pvFlick.scale = 1.0; Qt.callLater(pvFlick.centerContent) } }
                    }

                    // Separator
                    Rectangle { width: 1; height: 22; color: EasyTheme.color.divider; anchors.verticalCenter: parent.verticalCenter }

                    // Open external
                    Rectangle {
                        width: 64; height: 36; radius: EasyTheme.size.radius
                        color: pvOpenArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: pvImage.source.toString().length > 0 ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth; border.color: EasyTheme.color.border
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Row {
                            anchors.centerIn: parent
                            spacing: 4
                            EasyIconFont { icon: EasyIcon.material.open_in_new; iconSize: 14; color: EasyTheme.color.text; anchors.verticalCenter: parent.verticalCenter }
                            Label { text: qsTr("原图"); color: EasyTheme.color.text; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { id: pvOpenArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally(pvImage.source.toString()) }
                    }
                }
            }
        }
    }
}