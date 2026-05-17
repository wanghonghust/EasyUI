import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import EasyUI
import Chat 1.0
import Utils 1.0

EasySimpleWindow {
    id: root
    title: "对话历史"
    width: 520
    height: 560
    property var chatManager: ChatManager
    property color accentStart: "#6366f1"
    property color accentEnd: "#818cf8"

    property string currentFilter: "all"
    property string searchQuery: ""
    property var searchResults: []
    property var fromDate: null
    property var toDate: null
    property var selectedIds: []

    function refreshSearch() {
        if (searchQuery.trim().length > 0 || fromDate || toDate) {
            searchResults = chatManager ? chatManager.searchSessionsFulltext(
                searchQuery.trim(), fromDate || new Date(2000, 0, 1), toDate || new Date(2099, 0, 1),
                [], "") : []
        } else {
            searchResults = []
        }
    }

    // ── Active model ──
    property var displaySessions: {
        if (searchQuery.trim().length > 0)
            return searchResults
        if (currentFilter === "all")
            return chatManager ? chatManager.sessions : []
        if (currentFilter === "pinned")
            return chatManager ? chatManager.pinnedSessions() : []
        if (currentFilter.startsWith("group:")) {
            var g = currentFilter.substring(6)
            return chatManager ? chatManager.sessionsByGroup(g) : []
        }
        return chatManager ? chatManager.sessions : []
    }

    ColumnLayout {
        spacing: 8

        // ── Search bar with date filters ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            EasySearchInput {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                onTextChanged: { searchQuery = text; root.refreshSearch() }
            }
            EasyButton {
                text: fromDate ? fromDate.toLocaleDateString(Qt.locale(), "MM/dd") : "开始日"
                primary: fromDate !== null
                Layout.preferredHeight: 36
                onClicked: fromPicker.open()
            }
            EasyButton {
                text: toDate ? toDate.toLocaleDateString(Qt.locale(), "MM/dd") : "结束日"
                primary: toDate !== null
                Layout.preferredHeight: 36
                onClicked: toPicker.open()
            }
            EasyButton {
                text: ""
                icon: EasyIcon.material.close
                primary: false
                visible: fromDate !== null || toDate !== null
                Layout.preferredHeight: 36
                onClicked: { fromDate = null; toDate = null; root.refreshSearch() }
            }
        }

        // ── Filter tabs ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            EasyButton {
                text: "全部"
                primary: currentFilter === "all"
                onClicked: {
                    currentFilter = "all"
                    searchQuery = ""
                }
            }
            EasyButton {
                text: "置顶"
                icon: EasyIcon.material.push_pin
                primary: currentFilter === "pinned"
                onClicked: {
                    currentFilter = "pinned"
                    searchQuery = ""
                }
            }
            Repeater {
                model: chatManager ? chatManager.sessionGroups() : []
                delegate: EasyButton {
                    text: modelData
                    icon: EasyIcon.material.folder
                    primary: currentFilter === "group:" + modelData
                    onClicked: {
                        currentFilter = "group:" + modelData
                        searchQuery = ""
                    }
                }
            }
        }

        // ── Session count ──
        Label {
            text: (searchQuery.length > 0 ? "搜索结果: " : "共 ") + displaySessions.length + " 个对话"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }

        // ── Session list ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(listView.contentHeight + 8, 440)
            color: "transparent"

            ListView {
                id: listView
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                spacing: 4
                model: displaySessions

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 56
                    radius: 8
                    color: {
                        if (isCurrent)
                            return Qt.lighter(root.accentStart, 1.35)
                        if (itemArea.containsMouse)
                            return EasyTheme.color.menuHover
                        return "transparent"
                    }
                    border.color: isCurrent ? Qt.lighter(root.accentStart,
                                                         1.1) : "transparent"
                    border.width: 1

                    property var sessionData: modelData
                    readonly property bool isCurrent: modelData === chatManager.currentSession
                    readonly property string sessionId: modelData
                                                        && modelData.sessionId ? modelData.sessionId : ""

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!isCurrent && modelData && chatManager) {
                                chatManager.switchToSession(modelData)
                            }
                        }
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 8
                        }
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 8
                            color: isCurrent ? root.accentStart : EasyTheme.color.card
                            border.color: isCurrent ? "transparent" : EasyTheme.color.border
                            border.width: 1
                            EasyIconFont {
                                anchors.centerIn: parent
                                icon: modelData && modelData.pinned ? EasyIcon.material.push_pin : EasyIcon.material.chat
                                iconSize: 16
                                color: isCurrent ? "white" : EasyTheme.color.placeholder
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Label {
                                    Layout.fillWidth: true
                                    text: (modelData && modelData.title)
                                          || "未命名对话"
                                    font.pixelSize: 13
                                    font.bold: isCurrent
                                    color: EasyTheme.color.text
                                    elide: Text.ElideRight
                                }
                                Rectangle {
                                    visible: modelData && modelData.group
                                             && modelData.group.length > 0
                                    Layout.preferredWidth: groupTag.implicitWidth + 12
                                    Layout.preferredHeight: 18
                                    radius: 9
                                    color: EasyTheme.color.buttonHover
                                    Text {
                                        id: groupTag
                                        anchors.centerIn: parent
                                        text: modelData ? modelData.group : ""
                                        font.pixelSize: 10
                                        color: EasyTheme.color.secondary
                                    }
                                }
                                Rectangle {
                                    visible: isCurrent
                                    Layout.preferredWidth: 6
                                    Layout.preferredHeight: 6
                                    radius: 3
                                    color: root.accentStart
                                }
                            }

                            RowLayout {
                                spacing: 4
                                Label {
                                    text: modelData
                                          && modelData.messageCount ? modelData.messageCount
                                                                      + " 条消息" : "暂无消息"
                                    font.pixelSize: 11
                                    color: EasyTheme.color.placeholder
                                }
                                Label {
                                    visible: searchQuery.length > 0 && modelData
                                             && modelData.matchPreview
                                    text: " — " + (modelData ? String(
                                                                   modelData.matchPreview
                                                                   || "") : "")
                                    font.pixelSize: 11
                                    color: root.accentStart
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Row {
                            spacing: 2
                            opacity: itemArea.containsMouse || isCurrent ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            // Pin
                            EasyIconButton {
                                width: 24; height: 24; radius: 4
                                icon: modelData && modelData.pinned ? EasyIcon.material.push_pin : EasyIcon.material.push_pin
                                hoverColor: EasyTheme.color.buttonHover
                                onClicked: {
                                    if (modelData) {
                                        modelData.pinned = !modelData.pinned
                                        chatManager.saveToFile()
                                    }
                                }
                            }

                            // Group
                            EasyIconButton {
                                width: 24; height: 24; radius: 4
                                icon: EasyIcon.material.folder
                                hoverColor: EasyTheme.color.buttonHover
                                onClicked: {
                                    groupDialog.session = modelData
                                    groupDialog.open()
                                }
                            }

                            // Export
                            EasyIconButton {
                                width: 24; height: 24; radius: 4
                                icon: EasyIcon.material.download
                                hoverColor: EasyTheme.color.buttonHover
                                onClicked: {
                                    if (!modelData || !modelData.sessionId)
                                        return
                                    saveDialog.sessionId = modelData.sessionId
                                    saveDialog.open()
                                }
                            }

                            // Rename
                            EasyIconButton {
                                width: 24; height: 24; radius: 4
                                icon: EasyIcon.material.edit
                                hoverColor: EasyTheme.color.buttonHover
                                onClicked: {
                                    renameDialog.session = modelData
                                    renameDialog.open()
                                }
                            }

                            // Delete
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 4
                                color: deleteArea.containsMouse ? "#fee2e2" : "transparent"
                                visible: chatManager && chatManager.sessionCount > 1

                                EasyIconFont {
                                    anchors.centerIn: parent
                                    icon: EasyIcon.material.delete
                                    iconSize: 14
                                    color: deleteArea.containsMouse ? "#dc2626" : EasyTheme.color.placeholder
                                }

                                MouseArea {
                                    id: deleteArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        deleteConfirmDialog.session = modelData
                                        deleteConfirmDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }

                ScrollBar.vertical: EasyScrollBar { }
            }
        }

        // ── Bottom actions ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            EasyButton {
                text: "导出全部 JSON"
                icon: EasyIcon.material.download
                primary: false
                onClicked: {
                    var json = chatManager.exportAllSessionsToJson()
                    Clipboard.setText(json)
                    ToastManager.success("已复制所有对话 JSON 到剪贴板")
                }
            }
            EasyButton {
                text: "批量导出"
                icon: EasyIcon.material.inventory_2
                primary: false
                visible: selectedIds.length > 0
                onClicked: batchExportDialog.open()
            }
            Item {
                Layout.fillWidth: true
            }
            EasyButton {
                text: "新建对话"
                icon: EasyIcon.material.add
                onClicked: {
                    chatManager.createSession("新对话")
                    root.visible = false
                }
            }
        }
    }

    // ── Group assignment dialog ──
    EasyDialog {
        id: groupDialog
        property var session: null
        headerTitle: "分组设置"
        titleIcon: EasyIcon.material.folder
        confirmText: "保存"
        cancelText: "取消"
        accentStart: root.accentStart
        accentEnd: root.accentEnd
        dialogWidth: 360

        onOpened: {
            if (session)
                groupField.text = session.group || ""
        }
        onAccepted: {
            if (session) {
                session.group = groupField.text.trim()
                chatManager.saveToFile()
            }
            session = null
        }
        onRejected: {
            session = null
        }

        Label {
            text: "分组名称"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        Rectangle {
            width: parent.width
            height: 42
            radius: 10
            color: EasyTheme.color.card
            border.color: groupField.activeFocus ? root.accentStart : EasyTheme.color.border
            border.width: groupField.activeFocus ? 1.5 : 1
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }
            TextField {
                id: groupField
                anchors.fill: parent
                anchors.margins: 1
                leftPadding: 12
                background: Item {}
                font.pixelSize: 14
                color: EasyTheme.color.text
                placeholderText: "如: 工作、学习、项目A"
                placeholderTextColor: EasyTheme.color.placeholder
                Keys.onReturnPressed: groupDialog.accept()
            }
        }
    }

    // ── Save dialog ──
    FileDialog {
        id: saveDialog
        property string sessionId: ""
        title: "导出对话"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Markdown 文件 (*.md)", "JSON 文件 (*.json)"]
        defaultSuffix: "md"
        onAccepted: {
            if (!selectedFile || !sessionId)
                return
            var path = String(selectedFile)
            var content = nameFilters[currentIndex].indexOf(
                        ".json") >= 0 ? chatManager.exportSessionToJson(
                                            sessionId) : chatManager.exportSessionToMarkdown(
                                            sessionId)
            if (content)
                chatManager.saveToFile(
                            path.replace(
                                /\.\w+$/,
                                "") + (nameFilters[currentIndex].indexOf(
                                           ".json") >= 0 ? ".json" : ".md"))
            sessionId = ""
        }
    }

    // ── Delete confirmation ──
    EasyDialog {
        id: deleteConfirmDialog
        property var session: null
        headerTitle: "删除对话"
        titleIcon: EasyIcon.material.warning
        confirmText: "删除"
        cancelText: "取消"
        accentStart: "#ef4444"
        accentEnd: "#dc2626"
        dialogWidth: 360

        Label {
            text: "确定要删除对话 \"" + (deleteConfirmDialog.session ? deleteConfirmDialog.session.title : "") + "\" 吗？\n此操作不可撤销。"
            font.pixelSize: 14
            color: EasyTheme.color.text
            wrapMode: Text.Wrap
            width: parent.width
        }
        onAccepted: {
            if (session)
                chatManager.deleteSession(session)
            session = null
        }
        onRejected: {
            session = null
        }
    }

    // ── Rename dialog ──
    EasyDialog {
        id: renameDialog
        property var session: null
        headerTitle: "重命名对话"
        titleIcon: EasyIcon.material.edit
        confirmText: "保存"
        cancelText: "取消"
        accentStart: root.accentStart
        accentEnd: root.accentEnd
        dialogWidth: 360

        onOpened: {
            if (session) {
                renameField.text = session.title
                renameField.forceActiveFocus()
                renameField.selectAll()
            }
        }
        onAccepted: {
            if (session && renameField.text.trim().length > 0) {
                session.title = renameField.text.trim()
                chatManager.saveToFile()
            }
            session = null
        }
        onRejected: {
            session = null
        }

        Label {
            text: "对话名称"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        Rectangle {
            width: parent.width
            height: 42
            radius: 10
            color: EasyTheme.color.card
            border.color: renameField.activeFocus ? root.accentStart : EasyTheme.color.border
            border.width: renameField.activeFocus ? 1.5 : 1
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }
            TextField {
                id: renameField
                anchors.fill: parent
                anchors.margins: 1
                leftPadding: 12
                background: Item {}
                font.pixelSize: 14
                color: EasyTheme.color.text
                placeholderText: "输入对话名称"
                placeholderTextColor: EasyTheme.color.placeholder
                Keys.onReturnPressed: renameDialog.accept()
            }
        }
    }

    // ── Date pickers ──
    EasyDatePicker {
        id: fromPicker
        onDateSelected: function(d) { root.fromDate = d; root.refreshSearch() }
    }
    EasyDatePicker {
        id: toPicker
        onDateSelected: function(d) { root.toDate = d; root.refreshSearch() }
    }

    // ── Batch export dialog ──
    EasyDialog {
        id: batchExportDialog
        headerTitle: "批量导出"
        titleIcon: EasyIcon.material.inventory_2
        confirmText: "导出"
        cancelText: "取消"
        accentStart: root.accentStart
        accentEnd: root.accentEnd
        dialogWidth: 400
        property string exportFormat: "json"
        onAccepted: {
            var dirPath = Qt.applicationDirPath + "/chat_export_" + new Date().toISOString().slice(0, 10)
            chatManager.exportSessionsBatch(selectedIds, dirPath, exportFormat)
            selectedIds = []
            ToastManager.success("导出完成: " + dirPath)
        }
        ColumnLayout {
            spacing: 12
            Label { text: "导出 " + selectedIds.length + " 个对话"; font.pixelSize: 14; color: EasyTheme.color.text }
            Label { text: "格式:"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout {
                spacing: 8
                EasyButton { text: "JSON"; primary: batchExportDialog.exportFormat === "json"; onClicked: batchExportDialog.exportFormat = "json" }
                EasyButton { text: "Markdown"; primary: batchExportDialog.exportFormat === "md"; onClicked: batchExportDialog.exportFormat = "md" }
                EasyButton { text: "HTML"; primary: batchExportDialog.exportFormat === "html"; onClicked: batchExportDialog.exportFormat = "html" }
            }
            Label {
                text: "导出到: " + Qt.applicationDirPath + "/chat_export_YYYY-MM-DD/"
                font.pixelSize: 11; color: EasyTheme.color.secondary
                wrapMode: Text.WordWrap; Layout.fillWidth: true
            }
        }
    }
}
