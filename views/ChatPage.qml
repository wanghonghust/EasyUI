import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Dialogs
import EasyUI
import Utils
import Chat 1.0

// 使用新的 Chat 模块
Page {
    id: root

    background: Rectangle {
        color: "transparent"
    }

    // ========== 核心改动：使用 ChatManager ==========

    // 单例管理器
    property var chatManager: ChatManager

    // 当前会话（从管理器获取）
    property var currentSession: chatManager.currentSession

    // UI 状态
    property color surfaceGlass: "#d9ffffff"
    property color surfaceLight: "#f0f2ff"
    property color borderColor: "#e4e7f0"
    property color textPrimary: "#1e2435"
    property color textSecondary: "#7c84a0"
    property color accentStart: "#6366f1"
    property color accentEnd: "#818cf8"
    property color accentSolid: "#6366f1"
    property bool awaitingReply: false
    property bool initializing: true
    property bool pageActive: true

    // 已选文件列表
    property var selectedFiles: []

    // ========== 初始化 ==========
    Component.onCompleted: {
        chatManager.currentSessionChanged.connect(onSessionChanged)

        // 延迟初始化，让页面先渲染出来，避免阻塞页面切换
        Qt.callLater(() => {
                         if (!root)
                         return
                         if (currentSession) {
                             initSession(currentSession)
                         } else {
                             chatManager.createSession("新对话")
                         }
                     })
    }

    Component.onDestruction: {
        disconnectOldSignals()
        chatManager.saveToFile()
    }

    // 存储旧的 config 和 session，避免重复连接
    property var oldConfig: null
    property var oldSession: null

    // ========== 会话管理 ==========
    function onSessionChanged() {
        // 先断开旧的连接
        if (root.oldSession || root.oldConfig) {
            disconnectOldSignals()
        }

        currentSession = chatManager.currentSession
        console.log("onSessionChanged")
        initSession(currentSession)
    }

    function disconnectOldSignals() {
        // 断开旧的 Session 信号
        if (root.oldSession) {
            try {
                root.oldSession.generationFinished.disconnect(
                            onGenerationFinished)
            } catch (e) {

            }
            root.oldSession = null
        }

        // 断开旧的 config 信号
        if (root.oldConfig) {
            try {
                root.oldConfig.apiKeyChanged.disconnect()
                root.oldConfig.baseUrlChanged.disconnect()
                root.oldConfig.modelChanged.disconnect()
                root.oldConfig.streamModeChanged.disconnect()
                root.oldConfig.maxHistoryRoundsChanged.disconnect()
                root.oldConfig.maxTokensChanged.disconnect()
                root.oldConfig.reasoningEnabledChanged.disconnect()
                root.oldConfig.searchEnabledChanged.disconnect()
            } catch (e) {

            }
            root.oldConfig = null
        }
    }

    function initSession(session) {
        root.initializing = false
        if (!session || !session.aiManager || !session.config)
            return

        syncConfigToAI(session.config)

        console.log("connect session signals")

        // 连接 ChatSession 的信号（而不是直接连接 aiManager）
        try {
            session.generationFinished.connect(onGenerationFinished)
        } catch (e) {
            console.log("session signal connect error:", e)
        }

        // 连接 config 信号
        try {
            session.config.apiKeyChanged.connect(() => {
                                                     if (session.aiManager)
                                                     session.aiManager.apiKey
                                                     = session.config.apiKey
                                                 })
            session.config.baseUrlChanged.connect(() => {
                                                      if (session.aiManager)
                                                      session.aiManager.baseUrl
                                                      = session.config.baseUrl
                                                  })
            session.config.modelChanged.connect(() => {
                                                    if (session.aiManager)
                                                    session.aiManager.model = session.config.model
                                                })
            session.config.streamModeChanged.connect(() => {
                                                         if (session.aiManager)
                                                         session.aiManager.isStreamMode
                                                         = session.config.streamMode
                                                     })
            session.config.maxHistoryRoundsChanged.connect(() => {
                                                               if (session.aiManager)
                                                               session.aiManager.maxHistoryRounds
                                                               = session.config.maxHistoryRounds
                                                           })
            session.config.maxTokensChanged.connect(() => {
                                                        if (session.aiManager)
                                                        session.aiManager.maxTokens
                                                        = session.config.maxTokens
                                                    })
            session.config.reasoningEnabledChanged.connect(() => {
                                                               if (session.aiManager)
                                                               session.aiManager.reasoningEnabled
                                                               = session.config.reasoningEnabled
                                                           })
            session.config.searchEnabledChanged.connect(() => {
                                                            if (session.aiManager)
                                                            session.aiManager.searchEnabled
                                                            = session.config.searchEnabled
                                                        })
        } catch (e) {
            console.log("config signal connect error:", e)
        }

        // 保存当前引用用于下次断开
        root.oldSession = session
        root.oldConfig = session.config
    }

    function syncConfigToAI(config) {
        if (!currentSession || !currentSession.aiManager)
            return
        try {
            currentSession.aiManager.apiKey = config.apiKey
            currentSession.aiManager.baseUrl = config.baseUrl
            currentSession.aiManager.model = config.model
            currentSession.aiManager.isStreamMode = config.streamMode
            currentSession.aiManager.maxHistoryRounds = config.maxHistoryRounds
            currentSession.aiManager.maxTokens = config.maxTokens
            currentSession.aiManager.reasoningEnabled = config.reasoningEnabled
            currentSession.aiManager.searchEnabled = config.searchEnabled
        } catch (e) {
            console.log("syncConfigToAI error:", e)
        }
    }

    // ========== ChatSession 回调 ==========
    function onGenerationFinished(success, error) {
        if (!root)
            return
        root.awaitingReply = false

        if (!success && error && !cancelledByUser) {
            ToastManager.error(error)
        }
        cancelledByUser = false

        chatListView.scrollToBottom()

        if (chatManager) {
            try {
                chatManager.saveToFile()
            } catch (e) {
                console.log("saveToFile error:", e)
            }
        }
    }

    // ========== 消息操作 ==========
    property var pendingSearchQuery: ""
    property bool cancelledByUser: false

    function sendMessage() {
        const trimmed = inputArea.text.trim()
        if ((trimmed.length === 0 && selectedFiles.length === 0) || awaitingReply || !currentSession)
            return

        cancelledByUser = false

        var doSearch = currentSession.config.searchEnabled && trimmed.length > 0 && WebSearchManager.apiKey.length > 0
        if (doSearch) {
            awaitingReply = true
            pendingSearchQuery = trimmed
            WebSearchManager.search(trimmed)
        } else {
            awaitingReply = true
            doSendMessage(trimmed)
        }
    }

    Connections {
        target: WebSearchManager
        function onSearchCompleted(results) {
            if (pendingSearchQuery.length === 0) return
            if (!currentSession) return
            var ctx = ""
            for (var i = 0; i < results.length; i++) {
                var r = results[i]
                ctx += (i+1) + ". " + (r.title || "") + "\n"
                ctx += "   URL: " + (r.url || "") + "\n"
                ctx += "   " + (r.content || "").substring(0, 300) + "\n\n"
            }
            currentSession.setWebSearchContext(ctx)
            doSendMessage(pendingSearchQuery)
            pendingSearchQuery = ""
        }
        function onSearchError(error) {
            // Search failed, send without context if possible
            if (!currentSession) return
            if (pendingSearchQuery.length > 0) {
                doSendMessage(pendingSearchQuery)
                pendingSearchQuery = ""
            }
        }
    }

    function doSendMessage(trimmed) {
        var attachments = []
        for (var i = 0; i < selectedFiles.length; i++) {
            var f = selectedFiles[i]
            if (f.type === "image" && f.data) {
                attachments.push({
                    type: "image",
                    mimeType: f.mimeType || "image/png",
                    name: f.name || "image.png",
                    width: f.width || 0,
                    height: f.height || 0,
                    data: f.data
                })
            }
        }

        if (attachments.length > 0) {
            currentSession.sendMessageWithAttachments(trimmed.length > 0 ? trimmed : "请看这张图片", attachments)
        } else {
            currentSession.sendMessage(trimmed)
        }

        inputArea.text = ""
        selectedFiles = []
        chatListView.scrollToBottom()
    }

    function cancelRequest() {
        cancelledByUser = true
        if (currentSession) {
            currentSession.cancelGeneration()
        }
        awaitingReply = false
        pendingSearchQuery = ""
    }

    // ========== UI ==========
    Item {
        anchors.fill: parent

        // 初始化加载占位
        EasyLoading {
            anchors.centerIn: parent
            z: 100
            visible: root.initializing
            text: "正在加载..."
        }

        // 暂无内容占位
        Item {
            anchors {
                top: toolbarArea.bottom
                left: parent.left
                right: parent.right
                bottom: fileListContainer.top
            }
            z: 50
            visible: !root.initializing && chatListView.count === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8
                EasyIconFont {
                    Layout.alignment: Qt.AlignHCenter
                    icon: EasyIcon.material.chat_bubble_outline
                    iconSize: 48
                    color: EasyTheme.color.placeholder
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "暂无内容，发送一条消息开始对话"
                    font.pixelSize: 13
                    color: EasyTheme.color.placeholder
                }
            }
        }

        // ========== 聊天区域（从工具栏下方开始） ==========
        ListView {
            id: chatListView
            width: parent.width
            anchors.top: toolbarArea.bottom
            anchors.bottom: fileListContainer.top
            displayMarginBeginning: 68
            displayMarginEnd: 120
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            clip: true
            spacing: 16
            boundsBehavior: Flickable.StopAtBounds

            // 模型
            model: currentSession ? currentSession.messageCount : 0

            // 自动滚动到底部
            property bool autoScrollEnabled: true

            // 监听模型变化，自动滚动
            onCountChanged: {
                if (root.pageActive && autoScrollEnabled && count > 0) {
                    Qt.callLater(scrollToBottom)
                }
            }

            function scrollToBottom() {
                if (count > 0) {
                    positionViewAtEnd()
                }
            }

            // 内置滚动条
            ScrollBar.vertical: EasyScrollBar { }

            // 消息数量变化时滚动
            onModelChanged: {
                if (root.pageActive && autoScrollEnabled && model > 0) {
                    Qt.callLater(scrollToBottom)
                }
            }

            // ========== 消息委托 ==========
            delegate: Item {
                id: messageItem
                required property int index
                // Read messageCount to force re-eval on add/remove/branch switch
                property var msgData: {
                    var _ = currentSession ? currentSession.messageCount : 0
                    return currentSession ? currentSession.messageAt(index) : null
                }

                width: chatListView.width
                height: visible ? bubbleRect.height + 8 : 0
                visible: msgData !== null

                // 监听高度变化触发滚动（流式输出时）
                onHeightChanged: {
                    if (root.pageActive && chatListView.autoScrollEnabled && isStreaming) {
                        Qt.callLater(chatListView.scrollToBottom)
                    }
                }

                opacity: visible ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                readonly property bool isUser: msgData ? (msgData.role === "user") : false
                readonly property bool isStreaming: msgData ? msgData.isStreaming : false
                readonly property real maxBubbleWidth: root.width - 128
                readonly property real minBubbleWidth: isStreaming
                                                       && !isUser ? 120 : 60

                readonly property var modelData: msgData
                readonly property string rawContent: modelData ? String(
                                                                     isStreaming ? (modelData.streamingContent || "") : (modelData.content || "")) : ""

                // 防抖后的内容（用于 MarkdownView，减少渲染频率）
                property string debouncedContent: ""
                property string debouncedReasoning: ""

                // 防抖定时器
                Timer {
                    id: contentDebounceTimer
                    interval: 120
                    repeat: false
                    onTriggered: {
                        if (!messageItem || !messageItem.msgData)
                            return
                        if (!root.pageActive)
                            return
                        var newContent = messageItem.finalContent
                        var newReasoning = messageItem.reasoningContent
                        if (messageItem.debouncedContent !== newContent)
                            messageItem.debouncedContent = newContent
                        if (messageItem.debouncedReasoning !== newReasoning)
                            messageItem.debouncedReasoning = newReasoning
                    }
                }

                // 当 rawContent 变化时，触发防抖更新
                onRawContentChanged: {
                    if (!msgData || !root.pageActive)
                        return
                    if (isStreaming) {
                        contentDebounceTimer.restart()
                    } else {
                        var newContent = finalContent
                        var newReasoning = reasoningContent
                        if (debouncedContent !== newContent)
                            debouncedContent = newContent
                        if (debouncedReasoning !== newReasoning)
                            debouncedReasoning = newReasoning
                    }
                }

                Component.onCompleted: {
                    if (!msgData)
                        return
                    debouncedContent = finalContent
                    debouncedReasoning = reasoningContent
                }

                readonly property string reasoningContent: {
                    if (rawContent.includes("</think>")) {
                        var match = rawContent.match(
                                    /<think>([\s\S]*?)<\/think>/i)
                        return match ? match[1].trim() : ""
                    } else if (rawContent.includes("<think>")) {
                        var match2 = rawContent.match(/<think>([\s\S]*)/i)
                        return match2 ? match2[1].trim() : ""
                    }
                    return ""
                }
                readonly property string finalContent: {
                    var text = rawContent
                    if (text.includes("</think>")) {
                        text = text.replace(/<think>[\s\S]*?<\/think>/gi, "")
                    } else if (text.includes("<think>")) {
                        text = text.replace(/<think>[\s\S]*/gi, "")
                    }
                    return text.trim()
                }
                readonly property bool hasReasoning: reasoningContent.length > 0
                readonly property bool showReasoning: currentSession
                                                      && currentSession.config
                                                      && currentSession.config.reasoningEnabled
                readonly property string renderedContent: finalContent
                readonly property bool useAutoBubbleWidth: isUser

                // 头像
                Rectangle {
                    id: avatarRect
                    width: 36
                    height: 36
                    radius: 18
                    color: EasyTheme.color.card
                    border.color: isUser ? "transparent" : EasyTheme.color.cardBorder
                    border.width: isUser ? 0 : 1

                    anchors.top: parent.top
                    anchors.topMargin: 4
                    anchors.left: isUser ? undefined : parent.left
                    anchors.leftMargin: 8
                    anchors.right: isUser ? parent.right : undefined
                    anchors.rightMargin: 8

                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: isUser ? EasyIcon.material.person : EasyIcon.material.smart_toy
                        iconSize: 20
                    }
                }

                // 气泡
                Rectangle {
                    id: bubbleRect
                    radius: 16
                    border.color: isUser ? "transparent" : EasyTheme.color.cardBorder
                    border.width: isUser ? 0 : 1

                    // AI消息靠左，用户消息靠右
                    anchors.left: isUser ? undefined : avatarRect.right
                    anchors.leftMargin: 12
                    anchors.right: isUser ? avatarRect.left : undefined
                    anchors.rightMargin: 12
                    anchors.top: parent.top

                    readonly property real bubbleHorizontalPadding: 32
                    readonly property real bubbleVerticalPadding: 24
                    readonly property real contentImplicitWidth: contentLoader.item ? contentLoader.item.implicitWidth : minBubbleWidth

                    // 用户消息按文本内容自适应，AI 消息保持固定宽度
                    width: useAutoBubbleWidth ? Math.min(
                                                    maxBubbleWidth, Math.max(
                                                        minBubbleWidth,
                                                        contentImplicitWidth
                                                        + bubbleHorizontalPadding)) : maxBubbleWidth
                    height: Math.max(
                                contentColumn.implicitHeight + bubbleVerticalPadding,
                                60)

                    color: EasyTheme.color.card

                    SequentialAnimation on border.color {
                        running: !isUser && isStreaming && root.pageActive
                        loops: Animation.Infinite
                        ColorAnimation {
                            to: accentStart
                            duration: 800
                        }
                        ColorAnimation {
                            to: EasyTheme.color.cardBorder
                            duration: 800
                        }
                    }

                    Gradient {
                        id: userGradient
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: accentStart
                        }
                        GradientStop {
                            position: 1.0
                            color: accentEnd
                        }
                    }

                    Column {
                        id: contentColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        anchors.topMargin: 12
                        spacing: 4

                        Text {
                            id: timeText
                            width: parent.width
                            text: (modelData
                                   && modelData.timestamp ? Qt.formatDateTime(
                                                                modelData.timestamp,
                                                                "hh:mm") : "--:--")
                                  + (isStreaming ? " ●" : "")
                            color: isStreaming ? accentSolid : EasyTheme.color.secondary
                            font.pixelSize: 11
                            horizontalAlignment: isUser ? Text.AlignRight : Text.AlignLeft

                            SequentialAnimation on opacity {
                                running: isStreaming && root.pageActive
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: 0.5
                                    duration: 600
                                }
                                NumberAnimation {
                                    to: 1.0
                                    duration: 600
                                }
                            }
                        }

                        Loader {
                            id: contentLoader
                            width: parent.width
                            height: item ? item.implicitHeight : 0
                            sourceComponent: isUser ? textComponent : aiContentComponent
                        }

                        Rectangle {
                            id: streamingCursor
                            visible: !isUser && isStreaming
                            width: 2
                            height: 16
                            color: accentSolid

                            SequentialAnimation on opacity {
                                running: visible && root.pageActive
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: 0
                                    duration: 500
                                }
                                NumberAnimation {
                                    to: 1
                                    duration: 500
                                }
                            }
                        }
                    }

                    Component {
                        id: textComponent
                        Item {
                            id: userTextRoot
                            implicitWidth: Math.min(
                                               textMeasure.implicitWidth,
                                               maxBubbleWidth - bubbleRect.bubbleHorizontalPadding)
                            implicitHeight: userText.implicitHeight
                            width: implicitWidth
                            height: implicitHeight

                            Text {
                                id: textMeasure
                                visible: false
                                text: renderedContent
                                font.pixelSize: 12
                                wrapMode: Text.NoWrap
                            }

                            Text {
                                id: userText
                                width: contentLoader.width
                                text: renderedContent
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                color: EasyTheme.color.text
                                font.pixelSize: 12
                                lineHeight: 1.4
                                lineHeightMode: Text.ProportionalHeight
                            }
                        }
                    }

                    Component {
                        id: aiContentComponent
                        Column {
                            id: aiContentRoot
                            spacing: 8
                            width: contentLoader.width - bubbleRect.bubbleHorizontalPadding

                            property bool reasoningExpanded: isStreaming

                            // 思考过程面板（仅当有思考内容且开启思考模式时显示）
                            Rectangle {
                                id: reasoningPanel
                                width: parent.width
                                height: visible ? columnContent.implicitHeight + 12 : 0
                                visible: hasReasoning
                                color: EasyTheme.isDark ? "#2a2a35" : "#f5f5f7"
                                radius: 8
                                clip: true

                                Behavior on height {
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Column {
                                    id: columnContent
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    anchors.topMargin: 6
                                    spacing: 6

                                    // 标题栏
                                    Item {
                                        width: parent.width
                                        height: 24

                                        Row {
                                            id: reasoningHeader
                                            height: 24
                                            spacing: 4

                                            EasyIconFont {
                                                anchors.verticalCenter: parent.verticalCenter
                                                icon: EasyIcon.material.lightbulb
                                                iconSize: 14
                                                color: EasyTheme.color.secondary
                                            }

                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "思考过程"
                                                font.pixelSize: 12
                                                color: EasyTheme.color.secondary
                                            }

                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: aiContentRoot.reasoningExpanded ? "▼" : "▶"
                                                font.pixelSize: 10
                                                color: EasyTheme.color.placeholder
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: aiContentRoot.reasoningExpanded
                                                       = !aiContentRoot.reasoningExpanded
                                        }
                                    }

                                    // 思考内容
                                    EasyMarkdownView {
                                        id: reasoningBody
                                        width: parent.width
                                        text: messageItem.debouncedReasoning
                                        visible: aiContentRoot.reasoningExpanded
                                    }
                                }
                            }

                            // 分隔线（仅当同时显示思考面板和最终答案时）
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: EasyTheme.color.divider
                                visible: hasReasoning && finalContent.length > 0
                            }

                            // 最终答案
                            EasyMarkdownView {
                                width: parent.width
                                text: messageItem.debouncedContent
                            }
                        }
                    }
                }
            }

            // ========== Footer: Loading 指示器 ==========
            footer: Item {
                width: chatListView.width
                height: awaitingReply ? 40 : 0
                visible: height > 0
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 44
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Label {
                        text: "正在生成"
                        color: accentSolid
                        font.pixelSize: 12
                    }

                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: accentSolid
                            opacity: 0.3

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: awaitingReply && root.pageActive
                                PauseAnimation {
                                    duration: index * 200
                                }
                                NumberAnimation {
                                    to: 1.0
                                    duration: 200
                                }
                                NumberAnimation {
                                    to: 0.3
                                    duration: 200
                                }
                                PauseAnimation {
                                    duration: (2 - index) * 200
                                }
                            }
                        }
                    }
                }
            }
        }

        // ========== 已选文件列表（输入框上方） ==========
        Rectangle {
            id: fileListContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: inputAreaRect.top
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            anchors.bottomMargin: 6
            height: Math.min(fileListFlow.implicitHeight + 12, 80)
            color: EasyTheme.color.card
            radius: 12
            border.color: EasyTheme.color.cardBorder
            border.width: 1
            visible: root.selectedFiles.length > 0
            clip: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: 6
                clip: true
                ScrollBar.vertical: EasyScrollBar { }

                Flow {
                    id: fileListFlow
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: root.selectedFiles
                        delegate: Rectangle {
                            required property var modelData
                            required property int index

                            width: fileRow.implicitWidth + 20
                            height: 24
                            radius: 12
                            color: EasyTheme.color.buttonHover
                            border.color: EasyTheme.color.cardBorder
                            border.width: 1

                            Row {
                                id: fileRow
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                spacing: 4

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    font.pixelSize: 11
                                    color: EasyTheme.color.text
                                    elide: Text.ElideMiddle
                                    maximumLineCount: 1
                                }

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: removeArea.containsMouse ? "#ef4444" : "transparent"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 100
                                        }
                                    }

                                    EasyIconFont {
                                        anchors.centerIn: parent
                                        icon: EasyIcon.material.close
                                        iconSize: 14
                                        color: removeArea.containsMouse ? "white" : EasyTheme.color.placeholder
                                    }

                                    MouseArea {
                                        id: removeArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var arr = root.selectedFiles.slice()
                                            arr.splice(index, 1)
                                            root.selectedFiles = arr
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ========== 输入区域 ==========
        Rectangle {
            id: inputAreaRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.bottomMargin: 16
            // 动态高度：最小120，最大250，根据输入内容自适应
            readonly property real contentBasedHeight: {
                var textAreaHeight = inputArea.contentHeight
                        + inputArea.topPadding + inputArea.bottomPadding
                return 20 + switchesRow.height + 5 + textAreaHeight
            }
            height: Math.min(250, Math.max(120, contentBasedHeight))
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            color: EasyTheme.color.card
            radius: 22
            border.color: inputArea.activeFocus ? accentSolid : EasyTheme.color.cardBorder
            border.width: inputArea.activeFocus ? 1.5 : 1

            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                // ========== 文件上传按钮 ==========
                EasyIconButton {
                    id: uploadBtn
                    width: 36
                    height: 36
                    radius: 8
                    icon: EasyIcon.material.attach_file
                    hoverColor: EasyTheme.color.buttonHover
                    enabled: !awaitingReply && currentSession !== null

                    onClicked: {
                        fileDialog.open()
                    }
                }

                ToolTip {
                    text: "上传文件"
                    delay: 500
                    visible: uploadBtnHovered && uploadBtn.enabled
                    parent: uploadBtn
                    property bool uploadBtnHovered: false
                    Connections {
                        target: uploadBtn
                        function onHoverChanged(isHover) {
                            uploadBtnHovered = isHover
                        }
                    }
                }

                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true

                    // ========== 输入框 ==========
                    ScrollView {
                        id: inputScrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ScrollBar.vertical: EasyScrollBar { }

                        TextArea {
                            id: inputArea
                            width: inputScrollView.availableWidth
                            placeholderText: awaitingReply ? "AI正在思考中..." : "输入消息，Enter发送，Shift+Enter换行，Ctrl+V粘贴图片"
                            placeholderTextColor: EasyTheme.color.placeholder
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 14
                            color: EasyTheme.color.text
                            enabled: !awaitingReply && currentSession !== null
                            background: Item {}

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_V && (event.modifiers & Qt.ControlModifier)) {
                                    if (Clipboard.hasImage()) {
                                        event.accepted = true
                                        var info = Clipboard.imageInfo()
                                        if (info && info.data) {
                                            root.selectedFiles = root.selectedFiles.concat([info])
                                        }
                                    }
                                }
                            }

                            Keys.onReturnPressed: event => {
                                                      if (!(event.modifiers & Qt.ShiftModifier)) {
                                                          event.accepted = true
                                                          sendMessage()
                                                      }
                                                  }
                        }
                    }

                    // ========== 功能开关行 ==========
                    Row {
                        id: switchesRow
                        spacing: 10
                        height: 28

                        // 思考模式开关
                        EasyToggle {
                            id: reasoningSwitch
                            size: EasyTheme.size.sizeSmall
                            text: "思考"
                            checked: currentSession
                                     && currentSession.config ? currentSession.config.reasoningEnabled : false
                            enabled: currentSession !== null
                            onToggled: checked => {
                                           if (currentSession
                                               && currentSession.config) {
                                               currentSession.config.reasoningEnabled = checked
                                           }
                                       }
                        }

                        // 联网搜索开关
                        EasyToggle {
                            id: searchSwitch
                            size: EasyTheme.size.sizeSmall
                            text: "搜索"
                            checked: currentSession
                                     && currentSession.config ? currentSession.config.searchEnabled : false
                            enabled: currentSession !== null
                            onToggled: checked => {
                                           if (currentSession
                                               && currentSession.config) {
                                               currentSession.config.searchEnabled = checked
                                           }
                                       }
                        }

                        // 搜索设置按钮
                        EasyButton {
                            icon: EasyIcon.material.settings
                            text: ""
                            primary: false
                            height: 24; width: 28
                            anchors.verticalCenter: parent.verticalCenter
                            visible: currentSession && currentSession.config && currentSession.config.searchEnabled
                            onClicked: settingsWindow.show(2, root.Window.window)
                        }

                        // ── 上下文用量环形指示器 ──
                        EasyProgress {
                            id: contextGauge
                            circular: true
                            circleSize: 22
                            strokeWidth: 3
                            anchors.verticalCenter: parent.verticalCenter
                            visible: currentSession !== null
                            property var usage: currentSession ? currentSession.getContextUsage() : ({"percentage":"0","isWarning":false,"isCritical":false,"estimatedTokens":0,"maxTokens":0})
                            value: parseFloat(usage.percentage || "0")
                            EasyTooltip {
                                visible: parent.visible
                                text: "上下文: " + (contextGauge.usage.estimatedTokens || 0) + "/" + (contextGauge.usage.maxTokens || 0)
                                      + " tokens (" + (contextGauge.usage.percentage || "0") + "%)"
                            }
                        }
                    }
                }

                // ========== 发送按钮 ==========
                Rectangle {
                    id: sendBtn
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    enabled: (inputArea.text.trim().length > 0 || awaitingReply)
                             && currentSession !== null

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: awaitingReply ? "#ef4444" : (sendBtn.enabled ? accentStart : "#b0b3c8")
                        }
                        GradientStop {
                            position: 1.0
                            color: awaitingReply ? "#dc2626" : (sendBtn.enabled ? accentEnd : "#c8cad8")
                        }
                    }

                    scale: sendBtnArea.containsPress ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        source: awaitingReply ? "qrc:/icons/stop_dark.png" : "qrc:/icons/send_dark.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        id: sendBtnArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (awaitingReply) {
                                cancelRequest()
                            } else {
                                sendMessage()
                            }
                        }
                    }
                }
            }
        }

        // ========== 顶部悬浮工具栏 ==========
        Item {
            id: toolbarArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 68
            z: 10

            // 工具栏内容
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 10

                // 模型选择器
                EasySelect {
                    id: modelSelector
                    Layout.preferredWidth: 160
                    size: EasyTheme.size.sizeSmall
                    placeholder: "选择模型"
                    enabled: !root.awaitingReply && currentSession !== null

                    // 当 currentSession 变化时，同步模型列表
                    Connections {
                        target: root
                        function onCurrentSessionChanged() {
                            modelSelector.syncModelFromConfig()
                        }
                    }

                    function syncModelFromConfig() {
                        if (currentSession && currentSession.config) {
                            // 从配置中获取模型列表（使用默认列表）
                            var modelList = ["qwen3.5-plus", "qwen3-max-2026-01-23", "qwen3-coder-next", "qwen3-coder-plus", "glm-5", "glm-4.7", "kimi-k2.5", "MiniMax-M2.5"]
                            options = modelList

                            // 同步当前选中项
                            var currentModel = currentSession.config.model
                            var idx = modelList.indexOf(currentModel)
                            if (idx >= 0) {
                                currentIndex = idx
                            } else {
                                currentIndex = modelList.indexOf("qwen3.5-plus")
                            }
                        }
                    }

                    Component.onCompleted: syncModelFromConfig()
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentSession) {
                            currentSession.config.model = options[currentIndex]
                            syncConfigToAI(currentSession.config)
                        }
                    }
                }

                // ── 分支切换器 ──
                EasyButton {
                    text: "⑂ 分支"
                    primary: false
                    Layout.preferredHeight: 32
                    visible: currentSession && currentSession.branchCount > 1
                    onClicked: branchPopup.open()
                }

                // 分叉按钮
                EasyButton {
                    text: "⑂ +"
                    primary: false
                    Layout.preferredHeight: 32
                    visible: currentSession !== null
                    onClicked: {
                        if (currentSession && currentSession.messageCount > 0) {
                            currentSession.forkAtMessage(currentSession.messageCount - 1)
                        }
                    }
                }

                // ── 分支弹出选择 ──
                Popup {
                    id: branchPopup
                    y: parent.height + 4
                    width: 200
                    height: Math.min(240, branchList.contentHeight + 16)
                    padding: 8
                    modal: true
                    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

                    background: Rectangle {
                        radius: 8
                        color: EasyTheme.color.card
                        border.color: EasyTheme.color.border
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 4

                        Text {
                            text: "选择分支"
                            font.pixelSize: 12; font.bold: true
                            color: EasyTheme.color.text
                        }

                        ListView {
                            id: branchList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: currentSession ? currentSession.branchCount : 0

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 32; radius: 6
                                color: idx === currentSession.activeBranchIndex ? accentStart : (hoverArea.containsMouse ? EasyTheme.color.buttonHover : "transparent")
                                property int idx: index

                                Text {
                                    anchors.centerIn: parent
                                    text: "分支 " + (idx + 1) + (idx === 0 ? " (主)" : "")
                                    font.pixelSize: 12
                                    color: idx === currentSession.activeBranchIndex ? "#fff" : EasyTheme.color.text
                                }
                                MouseArea {
                                    id: hoverArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        currentSession.switchBranch(idx)
                                        branchPopup.close()
                                    }
                                }
                            }
                        }
                    }
                }

                EasyIconButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 8
                    icon: EasyIcon.material.history
                    hoverColor: EasyTheme.color.menuHover
                    border.color: EasyTheme.color.cardBorder
                    border.width: 1
                    onClicked: settingsWindow.show(0, root.Window.window)
                }

                EasyIconButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 8
                    icon: EasyIcon.material.add
                    hoverColor: EasyTheme.color.menuHover
                    border.color: EasyTheme.color.cardBorder
                    border.width: 1
                    onClicked: {
                        if (currentSession && currentSession.messages
                                && currentSession.messages.length === 0) {
                            return
                        }
                        let newSession = chatManager.createSession("新对话")
                        if (newSession) {
                            chatManager.switchToSession(newSession)
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                EasyIconButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 8
                    icon: EasyIcon.material.cloud
                    hoverColor: EasyTheme.color.menuHover
                    border.color: EasyTheme.color.cardBorder
                    border.width: 1
                    onClicked: settingsWindow.show(3, root.Window.window)
                }

                EasyIconButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 8
                    icon: EasyIcon.material.settings
                    hoverColor: EasyTheme.color.menuHover
                    border.color: EasyTheme.color.cardBorder
                    border.width: 1
                    onClicked: settingsWindow.show(1, root.Window.window)
                }

                Rectangle {
                    radius: 12
                    height: 28
                    color: awaitingReply ? "#25fff4e5" : "#25eef7ee"
                    border.color: awaitingReply ? "#25f2c089" : "#25b7dfc0"
                    Layout.preferredWidth: statusRow.implicitWidth + 22

                    Row {
                        id: statusRow
                        anchors.centerIn: parent
                        spacing: 5

                        Rectangle {
                            width: 7
                            height: 7
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: awaitingReply ? "#e0922a" : "#3ea85c"

                            SequentialAnimation on opacity {
                                running: awaitingReply && root.pageActive
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: 0.3
                                    duration: 500
                                }
                                NumberAnimation {
                                    to: 1.0
                                    duration: 500
                                }
                            }
                        }

                        Label {
                            id: statusLabel
                            text: awaitingReply ? "生成中…" : "在线"
                            font.pixelSize: 12
                            font.bold: true
                            color: awaitingReply ? "#c47a1c" : EasyTheme.color.placeholder
                        }
                    }
                }
            }
        }
    }

    // ========== 统一设置窗口 ==========
    SettingsWindow {
        id: settingsWindow
        chatManager: root.chatManager
        accentStart: root.accentStart
        accentEnd: root.accentEnd
    }

    // ========== 文件选择对话框 ==========
    FileDialog {
        id: fileDialog
        title: "选择文件"
        fileMode: FileDialog.OpenFiles
        nameFilters: ["所有文件 (*.*)", "图片 (*.png *.jpg *.jpeg *.gif *.bmp *.webp)", "文档 (*.txt *.md *.pdf *.doc *.docx)", "代码文件 (*.cpp *.c *.h *.hpp *.py *.js *.ts *.java *.go *.rs *.qml)"]
        onAccepted: {
            if (selectedFiles && selectedFiles.length > 0) {
                var newFiles = []
                for (var i = 0; i < selectedFiles.length; i++) {
                    var filePath = String(selectedFiles[i])
                    // 去重
                    var exists = false
                    for (var j = 0; j < root.selectedFiles.length; j++) {
                        if (root.selectedFiles[j].path === filePath) {
                            exists = true
                            break
                        }
                    }
                    if (!exists) {
                        newFiles.push({
                                          "path": filePath,
                                          "name": filePath.substring(
                                                      filePath.lastIndexOf(
                                                          '/') + 1)
                                      })
                    }
                }
                if (newFiles.length > 0) {
                    root.selectedFiles = root.selectedFiles.concat(newFiles)
                }
            }
        }
    }

    // ========== 配置对话框 ==========
    EasyDialog {
        id: configDialog
        headerTitle: "会话配置"
        titleIcon: EasyIcon.material.settings
        confirmText: "保存"
        cancelText: "取消"
        accentStart: root.accentStart
        accentEnd: root.accentEnd

        property var rolePresetModel: [
            { name: "通用助手", content: "You are a helpful AI assistant." },
            { name: "代码专家", content: "You are an expert software engineer. Provide clean, well-documented code with best practices." },
            { name: "翻译官", content: "You are a professional translator. Translate accurately while preserving tone and nuance." },
            { name: "写作助手", content: "You are a professional writer and editor. Help improve clarity, grammar, and style." },
            { name: "数据分析师", content: "You are a data analysis expert. Provide insights and statistical reasoning." }
        ]

        onOpened: {
            if (currentSession) {
                titleField.text = currentSession.title
                apiKeyField.text = currentSession.config.apiKey
                baseUrlField.text = currentSession.config.baseUrl
                modelField.text = currentSession.config.model
                systemMsgField.text = currentSession.config.systemMessage
                historyRoundsField.value = currentSession.config.maxHistoryRounds
                maxTokensField.value = currentSession.config.maxTokens
                contextWindowField.value = currentSession.config.contextWindowSize
                reasoningEnabledSwitch.checked = currentSession.config.reasoningEnabled
                searchEnabledSwitch.checked = currentSession.config.searchEnabled
            }
        }

        onAccepted: {
            if (currentSession) {
                currentSession.title = titleField.text
                currentSession.config.apiKey = apiKeyField.text
                currentSession.config.baseUrl = baseUrlField.text
                currentSession.config.model = modelField.text
                currentSession.config.systemMessage = systemMsgField.text
                currentSession.config.maxHistoryRounds = historyRoundsField.value
                currentSession.config.maxTokens = maxTokensField.value
                currentSession.config.contextWindowSize = contextWindowField.value
                currentSession.config.reasoningEnabled = reasoningEnabledSwitch.checked
                currentSession.config.searchEnabled = searchEnabledSwitch.checked
                syncConfigToAI(currentSession.config)
                chatManager.saveToFile()
                chatManager.switchToSession(currentSession)
            }
        }

        onRejected: {

        }

        Label {
            text: "对话标题"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        Rectangle {
            x: parent.leftPadding
            width: parent.width - parent.leftPadding - parent.rightPadding
            height: 38
            radius: 8
            color: EasyTheme.color.card
            border.color: titleField.activeFocus ? accentSolid : EasyTheme.color.border
            border.width: titleField.activeFocus ? 1.5 : 1
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }
            TextField {
                id: titleField
                anchors.fill: parent
                anchors.margins: 1
                leftPadding: 10
                background: Item {}
                font.pixelSize: 13
                color: EasyTheme.color.text
                placeholderText: "输入对话标题"
                placeholderTextColor: EasyTheme.color.placeholder
            }
        }
        Item {
            height: 4
        }

        Label {
            text: "API Key"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        Rectangle {
            x: parent.leftPadding
            width: parent.width - parent.leftPadding - parent.rightPadding
            height: 38
            radius: 8
            color: EasyTheme.color.card
            border.color: apiKeyField.activeFocus ? accentSolid : EasyTheme.color.border
            border.width: apiKeyField.activeFocus ? 1.5 : 1
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }
            RowLayout {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 0
                TextField {
                    id: apiKeyField
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    leftPadding: 10
                    background: Item {}
                    font.pixelSize: 13
                    color: EasyTheme.color.text
                    echoMode: _showKeyRect.checked ? TextInput.Normal : TextInput.Password
                    placeholderText: "sk-..."
                    placeholderTextColor: EasyTheme.color.placeholder
                }
                Rectangle {
                    id: _showKeyRect
                    width: 36
                    height: 36
                    radius: 7
                    property bool checked: false
                    color: _eyeArea.containsMouse ? EasyTheme.color.buttonHover : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: _showKeyRect.checked ? EasyIcon.material.visibility_off : EasyIcon.material.visibility
                        iconSize: 16
                    }
                    MouseArea {
                        id: _eyeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: _showKeyRect.checked = !_showKeyRect.checked
                    }
                }
            }
        }
        Item {
            height: 4
        }

        Label {
            text: "Base URL"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        Rectangle {
            x: parent.leftPadding
            width: parent.width - parent.leftPadding - parent.rightPadding
            height: 38
            radius: 8
            color: EasyTheme.color.card
            border.color: baseUrlField.activeFocus ? accentSolid : EasyTheme.color.border
            border.width: baseUrlField.activeFocus ? 1.5 : 1
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }
            TextField {
                id: baseUrlField
                anchors.fill: parent
                anchors.margins: 1
                leftPadding: 10
                background: Item {}
                font.pixelSize: 13
                color: EasyTheme.color.text
                placeholderText: "https://api.openai.com/v1/chat/completions"
                placeholderTextColor: EasyTheme.color.placeholder
            }
        }
        Item {
            height: 4
        }

        Label {
            text: "模型"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        Rectangle {
            x: parent.leftPadding
            width: parent.width - parent.leftPadding - parent.rightPadding
            height: 38
            radius: 8
            color: EasyTheme.color.card
            border.color: modelField.activeFocus ? accentSolid : EasyTheme.color.border
            border.width: modelField.activeFocus ? 1.5 : 1
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }
            TextField {
                id: modelField
                anchors.fill: parent
                anchors.margins: 1
                leftPadding: 10
                background: Item {}
                font.pixelSize: 13
                color: EasyTheme.color.text
                placeholderText: "gpt-4o-mini"
                placeholderTextColor: EasyTheme.color.placeholder
            }
        }
        Item {
            height: 4
        }

        Label {
            text: "上下文轮次"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            x: parent.leftPadding
            width: parent.width - parent.leftPadding - parent.rightPadding
            spacing: 8
            EasyNumberInput {
                id: historyRoundsField
                Layout.fillWidth: true
                value: 30
                min: 1
                max: 100
                step: 1
                precision: 0
                showButtons: true
            }
            Text {
                text: "轮"
                font.pixelSize: 12
                color: EasyTheme.color.placeholder
            }
        }
        Item {
            height: 4
        }

        Label {
            text: "最大 Token"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            x: parent.leftPadding
            width: parent.width - parent.leftPadding - parent.rightPadding
            spacing: 8
            EasyNumberInput {
                id: maxTokensField
                Layout.fillWidth: true
                value: 8192
                min: 256
                max: 128000
                step: 1024
                precision: 0
                showButtons: true
            }
            Text {
                text: "tokens"
                font.pixelSize: 12
                color: EasyTheme.color.placeholder
            }
        }
        Item { height: 4 }

        Label {
            text: "上下文窗口大小"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        RowLayout {
            x: parent.leftPadding
            width: parent.width - parent.leftPadding - parent.rightPadding
            spacing: 8
            EasyNumberInput {
                id: contextWindowField
                Layout.fillWidth: true
                value: 128000
                min: 4096
                max: 1048576
                step: 8192
                precision: 0
                showButtons: true
            }
            Text {
                text: "tokens"
                font.pixelSize: 12
                color: EasyTheme.color.placeholder
            }
        }
        Item { height: 4 }

        Label {
            text: "思考模式"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        Row {
            spacing: 8
            height: 28

            EasyToggle {
                id: reasoningEnabledSwitch
                size: EasyTheme.size.sizeSmall
                text: "思考模式"
            }
        }
        Item {
            height: 4
        }

        Row {
            spacing: 8
            height: 28

            EasyToggle {
                id: searchEnabledSwitch
                size: EasyTheme.size.sizeSmall
                text: "联网搜索"
            }
        }
        Item {
            height: 4
        }

        Label {
            text: "系统提示"
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
        }
        Rectangle {
            x: parent.leftPadding
            width: parent.width - parent.leftPadding - parent.rightPadding
            height: 90
            radius: 8
            color: EasyTheme.color.card
            border.color: systemMsgField.activeFocus ? accentSolid : EasyTheme.color.border
            border.width: systemMsgField.activeFocus ? 1.5 : 1
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }
            TextArea {
                id: systemMsgField
                anchors.fill: parent
                anchors.margins: 1
                leftPadding: 10
                topPadding: 8
                background: Item {}
                font.pixelSize: 13
                color: EasyTheme.color.text
                wrapMode: TextArea.Wrap
                placeholderText: "你是一个有用的 AI 助手..."
                placeholderTextColor: EasyTheme.color.placeholder
            }
        }
        Item {
            height: 8
        }
    }

    // ═══ WebSearch 配置对话框 ═══
    EasyDialog {
        id: searchConfigDialog
        headerTitle: "搜索设置"
        titleIcon: EasyIcon.material.travel_explore
        confirmText: "保存"
        cancelText: "取消"
        accentStart: root.accentStart
        accentEnd: root.accentEnd
        dialogWidth: 400

        onOpened: {
            providerField.text = WebSearchManager.provider || "tavily"
            apiKeySearchField.text = WebSearchManager.apiKey || ""
        }
        onAccepted: {
            WebSearchManager.provider = providerField.text.trim()
            WebSearchManager.apiKey = apiKeySearchField.text.trim()
        }

        ColumnLayout {
            spacing: 12
            Label { text: "搜索提供商"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyInput {
                id: providerField
                Layout.fillWidth: true
                placeholder: "tavily"
            }
            Label { text: "Tavily API Key"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyInput {
                id: apiKeySearchField
                Layout.fillWidth: true
                placeholder: "tvly-..."
                password: true
            }
            Text {
                text: "免费注册: https://tavily.com"
                font.pixelSize: 11
                color: EasyTheme.color.secondary
            }
        }
    }
}
