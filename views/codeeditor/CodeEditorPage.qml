import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQml
import EasyUI 1.0
import Utils 1.0
import CodeHighlighter


/**
 * CodeEditorPage —— 代码编辑器
 *
 * SplitView 左侧 EasyTreeView 浏览文件，右侧 EasyTabBar 多标签 + 代码编辑。
 */
Page {
    id: root
    background: Rectangle {
        color: EasyTheme.color.background
    }

    // ── 当前文件状态 ──
    property string currentFilePath: ""
    property string currentFileName: ""
    property string currentLanguage: ""
    property bool modified: false
    property var _treeModel: []
    property var _openFiles: [] // [{path, name, language, content, modified}]
    property int _currentFileIndex: -1
    property int _fontSize: 13
    property bool _suppressTextChange: false
    property string _folderPath: ""
    property string _folderUrl: ""
    property var _contextMenuNode: null
    property string _pendingAction: "" // "newFile", "newFolder", "rename", "delete"
    property bool _isLargeFile: false

    // ── 语言检测 ──
    function detectLanguage(fileName) {
        if (!fileName)
            return ""
        var parts = fileName.split(".")
        if (parts.length < 2)
            return ""
        var ext = parts[parts.length - 1].toLowerCase()
        var map = {
            "cpp": "cpp",
            "c": "cpp",
            "h": "cpp",
            "hpp": "cpp",
            "cc": "cpp",
            "cxx": "cpp",
            "qml": "qml",
            "py": "python",
            "pyw": "python",
            "js": "javascript",
            "jsx": "javascript",
            "mjs": "javascript",
            "ts": "typescript",
            "json": "json",
            "java": "java",
            "go": "go",
            "rs": "rust",
            "xml": "xml",
            "html": "html",
            "css": "css",
            "md": "markdown",
            "yaml": "yaml",
            "yml": "yaml",
            "sh": "bash",
            "bash": "bash",
            "sql": "sql",
            "kt": "kotlin",
            "kts": "kotlin"
        }
        return map[ext] || ""
    }

    // ── 文件图标 ──
    function fileIcon(name) {
        var ext = name.split(".").pop().toLowerCase()
        var map = {
            "qml": EasyIcon.material.code,
            "cpp": EasyIcon.material.code,
            "c": EasyIcon.material.code,
            "h": EasyIcon.material.code,
            "js": EasyIcon.material.javascript,
            "ts": EasyIcon.material.javascript,
            "py": EasyIcon.material.python,
            "json": EasyIcon.material.data_object,
            "md": EasyIcon.material.description,
            "html": EasyIcon.material.html,
            "css": EasyIcon.material.css,
            "xml": EasyIcon.material.data_object
        }
        return map[ext] || EasyIcon.material.description
    }

    // ── 保存当前标签内容 ──
    function saveCurrentContent() {
        if (_currentFileIndex >= 0 && _currentFileIndex < _openFiles.length) {
            var arr = _openFiles.slice()
            arr[_currentFileIndex] = Object.assign({}, arr[_currentFileIndex])
            arr[_currentFileIndex].content = editorTextArea.text
            arr[_currentFileIndex].modified = modified
            _openFiles = arr
        }
    }

    // ── 切换到标签 ──
    function switchToFile(index) {
        if (index === _currentFileIndex)
            return
        saveCurrentContent()

        _currentFileIndex = index
        var f = _openFiles[index]
        currentFilePath = f.path
        currentFileName = f.name
        currentLanguage = f.language
        modified = f.modified
        _isLargeFile = isLargeContent(f.content)
        _suppressTextChange = true
        editorTextArea.text = f.content
        _suppressTextChange = false
        updateLineNumbers()
    }

    // ── 打开/关闭文件夹 ──
    function openFolder(folderUrl) {
        _folderUrl = folderUrl.toString()
        // 从 file:// URL 中提取本地路径
        var rawPath = _folderUrl
        if (rawPath.startsWith("file:///"))
            _folderPath = decodeURIComponent(rawPath.substring(8))
        else if (rawPath.startsWith("file://"))
            _folderPath = decodeURIComponent(rawPath.substring(7))
        else
            _folderPath = rawPath
        folderLabel.text = _folderPath
        _treeModel = fileTreeModel.buildTree(folderUrl)
    }

    function closeFolder() {
        _folderPath = ""
        _folderUrl = ""
        folderLabel.text = "未打开文件夹"
        _treeModel = []
    }

    function refreshTree() {
        if (_folderUrl === "")
            return
        _treeModel = fileTreeModel.buildTree(_folderUrl)
    }

    function getParentPath(node) {
        var p = node.path
        var lastSlash = Math.max(p.lastIndexOf("/"), p.lastIndexOf("\\"))
        return lastSlash > 0 ? p.substring(0, lastSlash) : _folderPath
    }

    function showContextMenu(node, pos) {
        _contextMenuNode = node
        var globalPos = fileTree.mapToItem(Overlay.overlay, pos.x, pos.y)
        contextMenu.popup(globalPos.x, globalPos.y, buildContextMenuItems())
    }

    function buildContextMenuItems() {
        var items = []
        items.push({
                       "text": "新建文件",
                       "icon": EasyIcon.material.note_add,
                       "enabled": root._folderPath !== "",
                       "action": function () {
                           root._pendingAction = "newFile"
                           nameInput.headerTitle = "新建文件"
                           nameInput.confirmText = "创建"
                           nameInputText.text = ""
                           nameInputText.placeholder = "输入文件名"
                           nameInput.open()
                       }
                   })
        items.push({
                       "text": "新建文件夹",
                       "icon": EasyIcon.material.create_new_folder,
                       "enabled": root._folderPath !== "",
                       "action": function () {
                           root._pendingAction = "newFolder"
                           nameInput.headerTitle = "新建文件夹"
                           nameInput.confirmText = "创建"
                           nameInputText.text = ""
                           nameInputText.placeholder = "输入文件夹名"
                           nameInput.open()
                       }
                   })
        items.push({
                       "separator": true
                   })
        items.push({
                       "text": "重命名",
                       "icon": EasyIcon.material.edit,
                       "enabled": root._contextMenuNode !== null,
                       "action": function () {
                           root._pendingAction = "rename"
                           nameInput.headerTitle = "重命名"
                           nameInput.confirmText = "确定"
                           nameInputText.text = root._contextMenuNode.label
                           nameInputText.placeholder = "输入新名称"
                           nameInput.open()
                       }
                   })
        items.push({
                       "text": "删除",
                       "icon": EasyIcon.material.delete_outline,
                       "enabled": root._contextMenuNode !== null,
                       "action": function () {
                           var node = root._contextMenuNode
                           deleteConfirmText.text = "确定删除 \"" + node.label + "\" 吗？此操作不可撤销。"
                           deleteConfirmDialog.open()
                       }
                   })
        items.push({
                       "separator": true
                   })
        items.push({
                       "text": "复制路径",
                       "icon": EasyIcon.material.content_copy,
                       "enabled": root._contextMenuNode !== null,
                       "action": function () {
                           Clipboard.setText(root._contextMenuNode.path)
                       }
                   })
        return items
    }

    function isLargeContent(content) {
        return content.length > 500000 || content.split("\n").length > 5000
    }

    // ── 打开文件 ──
    function openFile(fileUrl, fileName) {
        // 已在打开列表中
        for (var i = 0; i < _openFiles.length; i++) {
            if (_openFiles[i].path === fileUrl) {
                switchToFile(i)
                tabBar.currentIndex = i
                return
            }
        }

        var content = fileIo.readFile(fileUrl)
        _isLargeFile = isLargeContent(content)
        var lang = detectLanguage(fileName)
        _openFiles = _openFiles.concat([{
                                            "path": fileUrl,
                                            "name": fileName,
                                            "language": lang,
                                            "content": content,
                                            "modified": false
                                        }])
        var idx = _openFiles.length - 1
        saveCurrentContent()
        _currentFileIndex = idx
        currentFilePath = fileUrl
        currentFileName = fileName
        currentLanguage = lang
        modified = false
        _suppressTextChange = true
        editorTextArea.text = content
        _suppressTextChange = false
        updateLineNumbers()
        tabBar.currentIndex = idx
    }

    // ── 保存文件 ──
    function saveFile() {
        if (!currentFilePath) {
            saveAsDialog.open()
            return
        }
        if (fileIo.writeFile(currentFilePath, editorTextArea.text)) {
            modified = false
            if (_currentFileIndex >= 0) {
                var arr = _openFiles.slice()
                arr[_currentFileIndex] = Object.assign({},
                                                       arr[_currentFileIndex])
                arr[_currentFileIndex].modified = false
                _openFiles = arr
            }
        }
    }

    // ── 新建文件 ──
    function newFile() {
        var count = 1
        for (var i = 0; i < _openFiles.length; i++) {
            if (_openFiles[i].name.indexOf("未命名") === 0)
                count++
        }
        var name = "未命名_" + count
        _openFiles = _openFiles.concat([{
                                            "path": "",
                                            "name": name,
                                            "language": "",
                                            "content": "",
                                            "modified": false
                                        }])
        var idx = _openFiles.length - 1
        saveCurrentContent()
        _currentFileIndex = idx
        currentFilePath = ""
        currentFileName = name
        currentLanguage = ""
        modified = false
        _suppressTextChange = true
        editorTextArea.text = ""
        _suppressTextChange = false
        updateLineNumbers()
        tabBar.currentIndex = idx
    }

    // ── 跳转到行 ──
    function goToLine(lineNumber) {
        var lines = editorTextArea.text.split("\n")
        var target = Math.max(1, Math.min(lineNumber, lines.length))
        var pos = 0
        for (var i = 0; i < target - 1; i++)
            pos += lines[i].length + 1
        editorTextArea.cursorPosition = pos
        editorTextArea.forceActiveFocus()
    }

    // ── 关闭标签 ──
    property int _pendingCloseIndex: -1

    function closeFile(index) {
        saveCurrentContent()
        // 检查文件是否已修改
        if (index >= 0 && index < _openFiles.length
                && _openFiles[index].modified) {
            _pendingCloseIndex = index
            closeSaveText.text = "文件 \"" + _openFiles[index].name + "\" 已修改，是否保存更改？"
            closeSaveDialog.open()
        } else {
            doCloseFile(index)
        }
    }

    function doCloseFile(index) {
        var arr = _openFiles.slice()
        arr.splice(index, 1)
        _openFiles = arr

        if (_openFiles.length === 0) {
            _currentFileIndex = -1
            currentFilePath = ""
            currentFileName = ""
            currentLanguage = ""
            modified = false
            _suppressTextChange = true
            editorTextArea.text = ""
            _suppressTextChange = false
        } else {
            var newIdx = Math.min(index, _openFiles.length - 1)
            tabBar.currentIndex = newIdx
            switchToFile(newIdx)
        }
    }

    // ── 行号 ──
    function updateLineNumbers() {
        lineNumFlick.lineCount = editorTextArea.text.split("\n").length
    }

    // ── 标签数据（供 EasyTabBar 使用） ──
    property var _tabItems: {
        var arr = []
        for (var i = 0; i < root._openFiles.length; i++) {
            var f = root._openFiles[i]
            arr.push({
                         "title": f.name + (f.modified ? " ●" : ""),
                         "icon": root.fileIcon(f.name),
                         "closable": true
                     })
        }
        return arr
    }

    // ── C++ 辅助 ──
    FileIO {
        id: fileIo
    }
    FileTreeModel {
        id: fileTreeModel
    }

    // ── 快捷键 ──
    Shortcut {
        sequence: "Ctrl+S"
        onActivated: saveFile()
    }
    Shortcut {
        sequence: "Ctrl+Shift+S"
        onActivated: saveAsDialog.open()
    }
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: newFile()
    }
    Shortcut {
        sequence: "Ctrl+G"
        onActivated: {
            goToLineSpin.from = 1
            goToLineSpin.to = editorTextArea.text.split("\n").length
            goToLineSpin.value = 1
            goToLineDialog.open()
        }
    }
    Shortcut {
        sequence: "Ctrl++"
        onActivated: root._fontSize = Math.min(32, root._fontSize + 1)
    }
    Shortcut {
        sequence: "Ctrl+-"
        onActivated: root._fontSize = Math.max(8, root._fontSize - 1)
    }
    Shortcut {
        sequence: "Ctrl+0"
        onActivated: root._fontSize = 13
    }

    // ======== SplitView 布局 ========
    SplitView {
        id: split
        anchors.fill: parent

        handle: Rectangle {
            implicitWidth: 1
            implicitHeight: split.height
            color: SplitHandle.hovered ? EasyTheme.color.primary : EasyTheme.color.divider
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            containmentMask: Item {
                width: 12
                height: split.height
                x: -6
            }
        }

        // ── 左侧文件树面板 ──
        Rectangle {
            SplitView.minimumWidth: 180
            SplitView.maximumWidth: 500
            implicitWidth: 260
            color: EasyTheme.color.background

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 头部
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 6
                        spacing: 2

                        Text {
                            id: folderLabel
                            text: "未打开文件夹"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: EasyTheme.color.placeholder
                            elide: Text.ElideLeft
                            Layout.fillWidth: true
                        }

                        EasyIconButton {
                            width: 28; height: 28
                            icon: EasyIcon.material.note_add
                            hoverColor: EasyTheme.color.buttonHover
                            onClicked: root.newFile()
                        }

                        // 刷新
                        EasyIconButton {
                            width: 28; height: 28
                            icon: EasyIcon.material.refresh
                            hoverColor: EasyTheme.color.buttonHover
                            visible: root._folderPath !== ""
                            onClicked: root.refreshTree()
                        }

                        // 打开/关闭文件夹
                        EasyIconButton {
                            width: 28; height: 28
                            icon: root._folderPath === "" ? EasyIcon.material.folder_open : EasyIcon.material.folder_off
                            hoverColor: EasyTheme.color.buttonHover
                            onClicked: root._folderPath === "" ? folderDialog.open() : root.closeFolder()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: EasyTheme.color.border
                    opacity: 0.3
                }

                // EasyTreeView
                EasyTreeView {
                    id: fileTree
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root._treeModel
                    indent: 20

                    onNodeClicked: node => {
                                       if (node.children !== undefined)
                                       return
                                       root.openFile(node.path, node.label)
                                   }

                    onNodeRightClicked: (node, pos) => {
                                            root.showContextMenu(node, pos)
                                        }

                    onEmptyAreaRightClicked: pos => {
                                                 root.showContextMenu(null, pos)
                                             }
                }

                // 状态栏 — 显示当前选中文件路径
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    color: "transparent"
                    visible: root.currentFilePath !== ""

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        text: root.currentFilePath
                        font.pixelSize: 10
                        color: EasyTheme.color.placeholder
                        elide: Text.ElideLeft
                        width: parent.width - 16
                    }
                }

                // 名称输入对话框
                EasyDialog {
                    id: nameInput
                    headerTitle: ""
                    confirmText: "确定"
                    cancelText: "取消"

                    ColumnLayout {
                        spacing: 8
                        Layout.fillWidth: true

                        EasyInput {
                            id: nameInputText
                            Layout.fillWidth: true
                            placeholder: ""
                            onAccepted: nameInput.accept()
                        }
                    }

                    onAccepted: {
                        var name = nameInputText.text.trim()
                        if (name === "")
                            return

                        if (root._pendingAction === "newFile") {
                            var parentPath = root._contextMenuNode ? (root._contextMenuNode.children !== undefined ? root._contextMenuNode.path : root.getParentPath(root._contextMenuNode)) : root._folderPath
                            fileIo.createFile(parentPath, name)
                        } else if (root._pendingAction === "newFolder") {
                            var pPath = root._contextMenuNode ? (root._contextMenuNode.children !== undefined ? root._contextMenuNode.path : root.getParentPath(root._contextMenuNode)) : root._folderPath
                            fileIo.createFolder(pPath, name)
                        } else if (root._pendingAction === "rename") {
                            var node = root._contextMenuNode
                            if (node) {
                                var oldPath = node.path
                                fileIo.renamePath(oldPath, name)
                                // 如果文件已打开，更新标签
                                var sep = oldPath.indexOf(
                                            "\\") >= 0 ? "\\" : "/"
                                for (var i = 0; i < root._openFiles.length; i++) {
                                    if (root._openFiles[i].path === oldPath) {
                                        var arr = root._openFiles.slice()
                                        var newPath = root.getParentPath(
                                                    node) + sep + name
                                        arr[i] = Object.assign({}, arr[i])
                                        arr[i].path = newPath
                                        arr[i].name = name
                                        root._openFiles = arr
                                        if (i === root._currentFileIndex) {
                                            root.currentFilePath = newPath
                                            root.currentFileName = name
                                        }
                                        break
                                    }
                                }
                            }
                        }
                        root.refreshTree()
                        root._pendingAction = ""
                    }

                    onRejected: {
                        root._pendingAction = ""
                    }
                }

                // 删除确认对话框
                EasyDialog {
                    id: deleteConfirmDialog
                    headerTitle: "删除确认"
                    confirmText: "删除"
                    cancelText: "取消"

                    ColumnLayout {
                        spacing: 12
                        Layout.fillWidth: true

                        Text {
                            id: deleteConfirmText
                            text: ""
                            font.pixelSize: 14
                            color: EasyTheme.color.text
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                    }

                    onAccepted: {
                        var node = root._contextMenuNode
                        if (node) {
                            var nodePath = node.path
                            // 如果文件已打开，关闭标签
                            for (var i = root._openFiles.length - 1; i >= 0; i--) {
                                if (root._openFiles[i].path === nodePath) {
                                    root.doCloseFile(i)
                                }
                            }
                            fileIo.deletePath(nodePath)
                            root.refreshTree()
                        }
                    }
                }
            }
        }

        // ── 右侧编辑器面板 ──
        Rectangle {
            SplitView.fillWidth: true
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // ── 顶部栏（标签 + 操作按钮） ──
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "transparent"

                    EasyTabBar {
                        id: tabBar
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        tabs: root._tabItems
                        currentIndex: root._currentFileIndex
                        addable: false

                        onTabClicked: index => {
                                          saveCurrentContent()
                                          switchToFile(index)
                                      }

                        onTabClosed: index => {
                                         closeFile(index)
                                     }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: EasyTheme.color.divider
                    opacity: 0.5
                }

                // ── 编辑区域 ──
                Item {
                    id: editorArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // 无文件时的空状态
                    Text {
                        anchors.centerIn: parent
                        text: root._folderPath
                              !== "" ? "从左侧文件树选择文件开始编辑" : "打开文件夹，选择文件开始编辑\nCtrl+N 新建文件"
                        font.pixelSize: 14
                        color: EasyTheme.color.placeholder
                        horizontalAlignment: Text.AlignHCenter
                        visible: root._openFiles.length === 0
                    }

                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: statusBar.top
                        spacing: 0
                        visible: root._openFiles.length > 0

                        // 行号（窗口化渲染：只生成可见行号的字符串）
                        Flickable {
                            id: lineNumFlick
                            width: 48
                            Layout.fillHeight: true
                            interactive: false
                            clip: true

                            property int lineCount: 1
                            property real lineH: Math.max(
                                                     editorTextArea.cursorRectangle.height,
                                                     root._fontSize * 1.5)

                            contentWidth: width
                            contentHeight: editorScrollView.contentItem ? editorScrollView.contentItem.contentHeight : 0

                            Binding {
                                target: lineNumFlick
                                property: "contentY"
                                value: editorScrollView.contentItem.contentY
                            }

                            function updateVisibleLines() {
                                if (lineH <= 0)
                                    return
                                var startLine = Math.floor(contentY / lineH) + 1
                                var endLine = Math.min(startLine + Math.ceil(
                                                           height / lineH),
                                                       lineCount)
                                var lines = []
                                for (var i = startLine; i <= endLine; i++)
                                    lines.push(i.toString())

                                lineNumText.y = (startLine - 1) * lineH + editorTextArea.topPadding
                                lineNumText.text = lines.join("\n")
                            }

                            onContentYChanged: updateVisibleLines()
                            onLineCountChanged: updateVisibleLines()
                            onLineHChanged: updateVisibleLines()
                            onHeightChanged: updateVisibleLines()
                            Component.onCompleted: updateVisibleLines()

                            Text {
                                id: lineNumText
                                width: parent.width - 6
                                font: editorTextArea.font
                                color: EasyTheme.color.placeholder
                                opacity: 0.6
                                horizontalAlignment: Text.AlignRight
                                lineHeight: Math.max(lineNumFlick.lineH,
                                                     1) / Math.max(
                                                editorTextArea.font.pixelSize,
                                                1)
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            color: EasyTheme.color.border
                            opacity: 0.2
                        }
                        // 编辑器
                        ScrollView {
                            id: editorScrollView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            ScrollBar.vertical: EasyScrollBar { }

                            TextArea {
                                id: editorTextArea
                                font.family: "Cascadia Code, 'JetBrains Mono', Consolas, monospace"
                                font.pixelSize: root._fontSize
                                color: EasyTheme.color.text
                                selectByMouse: true
                                selectionColor: EasyTheme.color.primary
                                wrapMode: TextArea.NoWrap
                                background: null
                                padding: 8
                                leftPadding: 12
                                topPadding: 8
                                bottomPadding: 8

                                // 当前行高亮
                                Rectangle {
                                    y: editorTextArea.cursorRectangle.y
                                    x: 0
                                    width: editorTextArea.width
                                    height: editorTextArea.cursorRectangle.height
                                    color: EasyTheme.isDark ? Qt.rgba(
                                                                  1, 1, 1,
                                                                  0.07) : Qt.rgba(
                                                                  0, 0, 0, 0.04)
                                    visible: editorTextArea.activeFocus
                                    z: -1
                                }

                                CodeHighlighter {
                                    textDocument: editorTextArea.textDocument
                                    language: root.currentLanguage
                                    theme: EasyTheme.isDark ? "onedark" : "onelight"
                                    enabled: !root._isLargeFile
                                }

                                onTextChanged: {
                                    updateLineNumbers()
                                    if (_suppressTextChange)
                                        return
                                    if (!modified) {
                                        modified = true
                                        if (_currentFileIndex >= 0) {
                                            var arr = _openFiles.slice()
                                            arr[_currentFileIndex] = Object.assign(
                                                        {},
                                                        arr[_currentFileIndex])
                                            arr[_currentFileIndex].modified = true
                                            _openFiles = arr
                                        }
                                    }
                                }
                            }

                            // 编辑区右键（必须在 TextArea 之后，确保优先接收事件）
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton
                                onClicked: mouse => {
                                               var pos = editorScrollView.mapToItem(
                                                   Overlay.overlay,
                                                   mouse.x, mouse.y)
                                               editorContextMenu.popup(pos.x,
                                                                       pos.y, [{
                                                                                   "text": "撤销",
                                                                                   "icon": EasyIcon.material.undo,
                                                                                   "enabled": root._openFiles.length > 0,
                                                                                   "action": function () {
                                                                                       editorTextArea.undo()
                                                                                   }
                                                                               }, {
                                                                                   "text": "重做",
                                                                                   "icon": EasyIcon.material.redo,
                                                                                   "enabled": root._openFiles.length > 0,
                                                                                   "action": function () {
                                                                                       editorTextArea.redo()
                                                                                   }
                                                                               }, {
                                                                                   "separator": true
                                                                               }, {
                                                                                   "text": "剪切",
                                                                                   "icon": EasyIcon.material.content_cut,
                                                                                   "enabled": editorTextArea.selectedText !== "",
                                                                                   "action": function () {
                                                                                       Clipboard.setText(editorTextArea.selectedText)
                                                                                       editorTextArea.remove(editorTextArea.selectionStart, editorTextArea.selectionEnd)
                                                                                   }
                                                                               }, {
                                                                                   "text": "复制",
                                                                                   "icon": EasyIcon.material.content_copy,
                                                                                   "enabled": editorTextArea.selectedText !== "",
                                                                                   "action": function () {
                                                                                       Clipboard.setText(editorTextArea.selectedText)
                                                                                   }
                                                                               }, {
                                                                                   "text": "粘贴",
                                                                                   "icon": EasyIcon.material.content_paste,
                                                                                   "enabled": Clipboard.text !== "",
                                                                                   "action": function () {
                                                                                       editorTextArea.insert(editorTextArea.cursorPosition, Clipboard.text)
                                                                                   }
                                                                               }, {
                                                                                   "separator": true
                                                                               }, {
                                                                                   "text": "全选",
                                                                                   "icon": EasyIcon.material.select_all,
                                                                                   "enabled": root._openFiles.length > 0,
                                                                                   "action": function () {
                                                                                       editorTextArea.selectAll()
                                                                                   }
                                                                               }, {
                                                                                   "separator": true
                                                                               }, {
                                                                                   "text": "保存",
                                                                                   "icon": EasyIcon.material.save,
                                                                                   "enabled": root.currentFilePath !== "",
                                                                                   "action": function () {
                                                                                       root.saveFile()
                                                                                   }
                                                                               }, {
                                                                                   "text": "另存为",
                                                                                   "icon": EasyIcon.material.save_as,
                                                                                   "enabled": root.currentFilePath !== "",
                                                                                   "action": function () {
                                                                                       saveAsDialog.open()
                                                                                   }
                                                                               }])
                                           }
                            }
                        }
                    }

                    // 底部状态栏
                    Rectangle {
                        id: statusBar
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 26
                        color: EasyTheme.isDark ? Qt.rgba(0, 0, 0,
                                                          0.3) : Qt.rgba(0, 0,
                                                                         0,
                                                                         0.04)
                        visible: root._openFiles.length > 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 16

                            Text {
                                text: editorTextArea.text.length + " 字符"
                                font.pixelSize: 11
                                color: EasyTheme.color.placeholder
                                opacity: 0.7
                            }

                            Text {
                                text: "大文件模式（语法高亮已禁用）"
                                font.pixelSize: 11
                                color: EasyTheme.color.warning || "#e08f00"
                                visible: root._isLargeFile
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                id: cursorPosText
                                text: {
                                    var pos = editorTextArea.cursorPosition
                                    var txt = editorTextArea.text
                                    var before = txt.substring(0, pos)
                                    var line = before.split("\n").length
                                    var lastNl = before.lastIndexOf("\n")
                                    var col = pos - lastNl
                                    return "行 " + line + "，列 " + col
                                }
                                font.pixelSize: 11
                                color: EasyTheme.color.placeholder
                                opacity: 0.7
                            }
                        }
                    }
                }
            }
        }
        // 树右键菜单
        EasyContextMenu {
            id: contextMenu
        }

        // 编辑区右键菜单
        EasyContextMenu {
            id: editorContextMenu
        }

        FolderDialog {
            id: folderDialog
            title: "选择文件夹"
            onAccepted: {
                if (selectedFolder)
                    root.openFolder(selectedFolder)
            }
        }

        EasyDialog {
            id: closeSaveDialog
            headerTitle: "保存文件"
            confirmText: "保存"
            cancelText: "取消"

            ColumnLayout {
                spacing: 14
                Layout.fillWidth: true

                Text {
                    id: closeSaveText
                    text: "文件已修改，是否保存更改？"
                    font.pixelSize: 14
                    color: EasyTheme.color.text
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                // "不保存" 按钮
                EasyButton {
                    Layout.fillWidth: true
                    text: "不保存"
                    primary: false
                    onClicked: {
                        closeSaveDialog.close()
                        root.doCloseFile(root._pendingCloseIndex)
                        root._pendingCloseIndex = -1
                    }
                }
            }

            onAccepted: {
                var idx = root._pendingCloseIndex
                if (idx >= 0 && idx < root._openFiles.length) {
                    saveCurrentContent()
                    fileIo.writeFile(root._openFiles[idx].path,
                                     root._openFiles[idx].content)
                }
                closeSaveDialog.close()
                root.doCloseFile(idx)
                root._pendingCloseIndex = -1
            }

            onRejected: {
                root._pendingCloseIndex = -1
            }
        }

        FileDialog {
            id: saveAsDialog
            title: "另存为"
            fileMode: FileDialog.SaveFile
            onAccepted: {
                if (currentFile) {
                    if (fileIo.writeFile(currentFile, editorTextArea.text)) {
                        currentFilePath = currentFile
                        currentFileName = decodeURIComponent(
                                    currentFile.toString().replace("file:///",
                                                                   "").split(
                                        "/").pop())
                        modified = false
                        if (_currentFileIndex >= 0) {
                            var arr = _openFiles.slice()
                            arr[_currentFileIndex] = Object.assign(
                                        {}, arr[_currentFileIndex])
                            arr[_currentFileIndex].path = currentFile
                            arr[_currentFileIndex].name = currentFileName
                            arr[_currentFileIndex].modified = false
                            _openFiles = arr
                        }
                    }
                }
            }
        }

        EasyDialog {
            id: goToLineDialog
            headerTitle: "跳转到行"
            confirmText: "跳转"
            cancelText: "取消"

            ColumnLayout {
                spacing: 12
                Layout.fillWidth: true

                Text {
                    text: "行号 (1 - " + editorTextArea.text.split(
                              "\n").length + ")"
                    font.pixelSize: 13
                    color: EasyTheme.color.placeholder
                }

                SpinBox {
                    id: goToLineSpin
                    from: 1
                    to: editorTextArea.text.split("\n").length
                    value: 1
                    editable: true
                    Layout.fillWidth: true
                }
            }

            onAccepted: root.goToLine(goToLineSpin.value)
        }
    }
}
