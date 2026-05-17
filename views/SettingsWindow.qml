import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import EasyUI
import Chat 1.0
import Utils 1.0
import ModelConfig 1.0

Item {
    id: wrapper

    property var chatManager: ChatManager
    property alias currentSession: root.currentSession
    property color accentStart: "#6366f1"
    property color accentEnd: "#818cf8"
    property int activeTab: 0

    function show(tab, parentWindow) {
        activeTab = Math.max(0, Math.min(3, tab || 0))
        syncConfigFields()
        if (parentWindow) root.transientParent = parentWindow
        root.visible = true
        root.show()
    }

    function syncConfigFields() {
        var cs = root.currentSession
        if (!cs)
            return
        titleField.text = cs.title
        apiKeyField.text = cs.config.apiKey
        baseUrlField.text = cs.config.baseUrl
        modelField.text = cs.config.model
        systemMsgField.text = cs.config.systemMessage
        historyRoundsField.value = cs.config.maxHistoryRounds
        maxTokensField.value = cs.config.maxTokens
        contextWindowField.value = cs.config.contextWindowSize || 128000
        reasoningEnabledSwitch.checked = cs.config.reasoningEnabled
        searchEnabledSwitch.checked = cs.config.searchEnabled
    }

    function saveSessionConfig() {
        var cs = root.currentSession
        if (!cs)
            return
        cs.title = titleField.text
        cs.config.apiKey = apiKeyField.text
        cs.config.baseUrl = baseUrlField.text
        cs.config.model = modelField.text
        cs.config.systemMessage = systemMsgField.text
        cs.config.maxHistoryRounds = historyRoundsField.value
        cs.config.maxTokens = maxTokensField.value
        cs.config.contextWindowSize = contextWindowField.value
        cs.config.reasoningEnabled = reasoningEnabledSwitch.checked
        cs.config.searchEnabled = searchEnabledSwitch.checked
        chatManager.saveToFile()
        ToastManager.success("配置已保存")
    }

    EasySimpleWindow {
        id: root
        title: activeTab === 0 ? "会话记录" : (activeTab === 1 ? "会话配置" : (activeTab === 2 ? "模型配置" : "OSS 配置"))
        width: 700
        height: 560
        minimumWidth: 560
        minimumHeight: 400
        visible: false
        showWhenReady: false
        modality: Qt.WindowModal

        property var chatManager: wrapper.chatManager
        property var currentSession: wrapper.chatManager.currentSession
        property color accentStart: wrapper.accentStart
        property color accentEnd: wrapper.accentEnd

        // ═══ Sidebar + Content layout ═══
        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Sidebar ──
            EasyMenuBar {
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                collapsed: false
                menus: [
                    { title: "会话记录", icon: EasyIcon.material.chat, url: "history" },
                    { title: "会话配置", icon: EasyIcon.material.settings, url: "config" },
                    { title: "模型配置", icon: EasyIcon.material.lock, url: "models" },
                    { title: "OSS 配置", icon: EasyIcon.material.cloud, url: "oss" }
                ]
                activePath: activeTab === 0 ? "history" : (activeTab === 1 ? "config" : (activeTab === 2 ? "models" : "oss"))
                onItemClicked: item => {
                    if (item.url === "history") activeTab = 0
                    else if (item.url === "config") { activeTab = 1; syncConfigFields() }
                    else if (item.url === "models") activeTab = 2
                    else if (item.url === "oss") activeTab = 3
                }
            }

            // ── Content area ──
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: EasyTheme.color.background

                // Tab 0: Chat History
                Item {
                    anchors.fill: parent
                    visible: activeTab === 0

                    ColumnLayout {
                        id: historyTab
                        anchors { fill: parent; margins: 16 }
                        spacing: 6

                        property string currentFilter: "all"
                        property string searchQuery: ""
                        property var searchResults: []
                        property var fromDate: null
                        property var toDate: null
                        property string deleteTargetId: ""
                        property string deleteTargetTitle: ""

                        property var displaySessions: {
                            if (historyTab.searchQuery.trim().length > 0)
                                return historyTab.searchResults
                            if (historyTab.currentFilter === "all")
                                return chatManager ? chatManager.sessions : []
                            if (historyTab.currentFilter === "pinned")
                                return chatManager ? chatManager.pinnedSessions(
                                                         ) : []
                            if (historyTab.currentFilter.startsWith("group:")) {
                                return chatManager ? chatManager.sessionsByGroup(
                                                         historyTab.currentFilter.substring(
                                                             6)) : []
                            }
                            return chatManager ? chatManager.sessions : []
                        }

                        function refreshSearch() {
                            if (historyTab.searchQuery.trim().length > 0 || historyTab.fromDate
                                    || historyTab.toDate) {
                                historyTab.searchResults = chatManager ? chatManager.searchSessionsFulltext(historyTab.searchQuery.trim(), historyTab.fromDate || new Date(2000, 0, 1), historyTab.toDate || new Date(2099, 0, 1), [], "") : []
                            } else {
                                historyTab.searchResults = []
                            }
                        }
                        // Search bar
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            EasySearchInput {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                onTextChanged: {
                                    historyTab.searchQuery = text
                                    historyTab.refreshSearch()
                                }
                            }
                            EasyButton {
                                text: historyTab.fromDate ? historyTab.fromDate.toLocaleDateString(
                                                     Qt.locale(),
                                                     "MM/dd") : "开始日"
                                primary: historyTab.fromDate !== null
                                Layout.preferredHeight: 32
                                onClicked: fromPicker.open()
                            }
                            EasyButton {
                                text: historyTab.toDate ? historyTab.toDate.toLocaleDateString(
                                                   Qt.locale(), "MM/dd") : "结束日"
                                primary: historyTab.toDate !== null
                                Layout.preferredHeight: 32
                                onClicked: toPicker.open()
                            }
                            EasyButton {
                                text: "清除"
                                icon: EasyIcon.material.close
                                Layout.preferredHeight: 32
                                visible: historyTab.fromDate !== null || historyTab.toDate !== null
                                onClicked: {
                                    historyTab.fromDate = null
                                    historyTab.toDate = null
                                    historyTab.refreshSearch()
                                }
                            }
                        }

                        EasyDatePicker {
                            id: fromPicker
                        }
                        EasyDatePicker {
                            id: toPicker
                        }

                        // Filter tabs
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            EasyButton {
                                text: "全部"
                                primary: historyTab.currentFilter === "all"
                                onClicked: {
                                    historyTab.currentFilter = "all"
                                    historyTab.searchQuery = ""
                                }
                            }
                            EasyButton {
                                text: "置顶"
                                icon: EasyIcon.material.push_pin
                                primary: historyTab.currentFilter === "pinned"
                                onClicked: {
                                    historyTab.currentFilter = "pinned"
                                    historyTab.searchQuery = ""
                                }
                            }
                            Repeater {
                                model: chatManager ? chatManager.sessionGroups() : []
                                delegate: EasyButton {
                                    text: modelData
                                    icon: EasyIcon.material.folder
                                    primary: historyTab.currentFilter === "group:" + modelData
                                    onClicked: {
                                        historyTab.currentFilter = "group:" + modelData
                                        historyTab.searchQuery = ""
                                    }
                                }
                            }
                        }

                        Label {
                            text: (historyTab.searchQuery.length > 0 ? "搜索结果: " : "共 ")
                                  + historyTab.displaySessions.length + " 个对话"
                            font.pixelSize: 11
                            color: EasyTheme.color.placeholder
                        }

// Delete confirmation inline banner
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 6
                            color: "#fee2e2"
                            visible: historyTab.deleteTargetId.length > 0
                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: 8
                                }
                                spacing: 6
                                EasyIconFont {
                                    icon: EasyIcon.material.warning
                                    iconSize: 16
                                    color: "#dc2626"
                                }
                                Text {
                                    text: "删除 \"" + historyTab.deleteTargetTitle + "\"？"
                                    font.pixelSize: 12
                                    color: "#dc2626"
                                    Layout.fillWidth: true
                                }
                                EasyButton {
                                    text: "确认"
                                    type: "danger"
                                    onClicked: {
                                        var s = chatManager.getSession(
                                                    historyTab.deleteTargetId)
                                        if (s)
                                            chatManager.deleteSession(s)
                                        historyTab.deleteTargetId = ""
                                        historyTab.deleteTargetTitle = ""
                                    }
                                }
                                EasyButton {
                                    text: "取消"
                                    primary: false
                                    onClicked: {
                                        historyTab.deleteTargetId = ""
                                        historyTab.deleteTargetTitle = ""
                                    }
                                }
                            }
                        }

                        // Session list
                        ListView {
                            id: historyListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: historyTab.displaySessions

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 48
                                radius: 6
                                color: {
                                    if (isCurrent)
                                        return Qt.lighter(wrapper.accentStart,
                                                          1.35)
                                    if (itemArea.containsMouse)
                                        return EasyTheme.color.menuHover
                                    return "transparent"
                                }
                                property var sessionData: modelData
                                readonly property bool isCurrent: modelData !== null
                                                                  && chatManager.currentSession !== null && modelData.sessionId === chatManager.currentSession.sessionId

                                MouseArea {
                                    id: itemArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!isCurrent && modelData)
                                            chatManager.switchToSession(
                                                        modelData)
                                    }
                                }
                                RowLayout {
                                    anchors {
                                        fill: parent
                                        leftMargin: 10
                                        rightMargin: 2
                                    }
                                    spacing: 6
                                    Rectangle {
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        radius: 6
                                        color: isCurrent ? wrapper.accentStart : EasyTheme.color.card
                                        EasyIconFont {
                                            anchors.centerIn: parent
                                            icon: modelData && modelData.pinned ? EasyIcon.material.push_pin : EasyIcon.material.chat
                                            iconSize: 14
                                            color: isCurrent ? "#ffffff" : EasyTheme.color.secondary
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        Text {
                                            text: (modelData
                                                   && modelData.title) || "未命名"
                                            font.pixelSize: 12
                                            font.bold: isCurrent
                                            color: EasyTheme.color.text
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: modelData
                                                  && modelData.messageCount ? modelData.messageCount + " 条消息" : "暂无消息"
                                            font.pixelSize: 10
                                            color: EasyTheme.color.placeholder
                                        }
                                    }
                                    Row {
                                        spacing: 2
                                        opacity: itemArea.containsMouse ? 1 : 0
                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 120
                                            }
                                        }
                                        EasyIconButton {
                                            width: 22; height: 22; radius: 4
                                            icon: EasyIcon.material.push_pin
                                            hoverColor: EasyTheme.color.buttonHover
                                            onClicked: {
                                                if (modelData) {
                                                    modelData.pinned = !modelData.pinned
                                                    chatManager.saveToFile()
                                                }
                                            }
                                        }
                                        EasyIconButton {
                                            width: 22; height: 22; radius: 4
                                            icon: EasyIcon.material.mdelete
                                            hoverColor: "#fee2e2"
                                            visible: chatManager && chatManager.sessionCount > 1
                                            onClicked: {
                                                if (modelData && modelData.sessionId) {
                                                    historyTab.deleteTargetId = modelData.sessionId
                                                    historyTab.deleteTargetTitle = modelData.title || ""
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Bottom actions
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            EasyButton {
                                text: "导出 JSON"
                                icon: EasyIcon.material.download
                                primary: false
                                onClicked: {
                                    Clipboard.setText(
                                                chatManager.exportAllSessionsToJson(
                                                    ))
                                    ToastManager.success("已复制到剪贴板")
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            EasyButton {
                                text: "新建"
                                icon: EasyIcon.material.add
                                onClicked: {
                                    chatManager.createSession("新对话")
                                }
                            }
                        }
                    }
                }

                // Tab 1: Session Config
                Item {
                    anchors.fill: parent
                    visible: activeTab === 1

                    Flickable {
                        anchors {
                            left: parent.left; right: parent.right
                            top: parent.top; bottom: parent.bottom
                            leftMargin: 16; topMargin: 16; bottomMargin: 16; rightMargin: 2
                        }
                        clip: true
                        contentHeight: configCol.implicitHeight
                        ScrollBar.vertical: EasyScrollBar { }

                        ColumnLayout {
                            id: configCol
                            width: parent.width - 16
                            spacing: 12

                            // ── Basic info section ──
                            Rectangle {
                                Layout.fillWidth: true
                                radius: EasyTheme.size.radiusLarge
                                color: EasyTheme.color.card
                                border.color: EasyTheme.color.border
                                height: basicInfoContent.implicitHeight + 24
                                ColumnLayout {
                                    id: basicInfoContent
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 8
                                    Row {
                                        spacing: 6
                                        EasyIconFont { icon: EasyIcon.material.edit_note; iconSize: 16; color: EasyTheme.color.primary }
                                        Text { text: "基本信息"; font.pixelSize: 13; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                                    }
                                    Label {
                                        text: "对话标题"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: titleField
                                        Layout.fillWidth: true
                                        placeholder: "对话标题"
                                    }
                                }
                            }

                            // ── API configuration section ──
                            Rectangle {
                                Layout.fillWidth: true
                                radius: EasyTheme.size.radiusLarge
                                color: EasyTheme.color.card
                                border.color: EasyTheme.color.border
                                height: apiConfigContent.implicitHeight + 24
                                ColumnLayout {
                                    id: apiConfigContent
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 8
                                    Row {
                                        spacing: 6
                                        EasyIconFont { icon: EasyIcon.material.cloud; iconSize: 16; color: EasyTheme.color.primary }
                                        Text { text: "API 配置"; font.pixelSize: 13; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                                    }
                                    Label {
                                        text: "API Key"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: apiKeyField
                                        Layout.fillWidth: true
                                        placeholder: "sk-..."
                                        password: true
                                    }
                                    Label {
                                        text: "Base URL"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: baseUrlField
                                        Layout.fillWidth: true
                                        placeholder: "https://api.openai.com/v1/chat/completions"
                                    }
                                    Label {
                                        text: "模型"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: modelField
                                        Layout.fillWidth: true
                                        placeholder: "gpt-4o-mini"
                                    }
                                }
                            }

                            // ── System prompt section ──
                            Rectangle {
                                Layout.fillWidth: true
                                radius: EasyTheme.size.radiusLarge
                                color: EasyTheme.color.card
                                border.color: EasyTheme.color.border
                                height: sysPromptContent.implicitHeight + 24
                                ColumnLayout {
                                    id: sysPromptContent
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 8
                                    Row {
                                        spacing: 6
                                        EasyIconFont { icon: EasyIcon.material.smart_toy; iconSize: 16; color: EasyTheme.color.primary }
                                        Text { text: "系统提示与角色预设"; font.pixelSize: 13; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 72
                                        radius: 8
                                        color: EasyTheme.color.background
                                        border.color: EasyTheme.color.border
                                        TextArea {
                                            id: systemMsgField
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            font.pixelSize: 12
                                            font.family: EasyTheme.font.family
                                            color: EasyTheme.color.text
                                            wrapMode: TextArea.Wrap
                                            placeholderText: "系统提示词..."
                                            background: Item {}
                                        }
                                    }
                                    Label {
                                        text: "角色预设"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    RowLayout {
                                        id: presetRow
                                        spacing: 6
                                        property var presets: [{
                                                "name": "通用",
                                                "icon": EasyIcon.material.chat,
                                                "content": "You are a helpful AI assistant."
                                            }, {
                                                "name": "代码",
                                                "icon": EasyIcon.material.code,
                                                "content": "You are an expert software engineer."
                                            }, {
                                                "name": "翻译",
                                                "icon": EasyIcon.material.translate,
                                                "content": "You are a professional translator."
                                            }, {
                                                "name": "写作",
                                                "icon": EasyIcon.material.edit_note,
                                                "content": "You are a professional writer and editor."
                                            }, {
                                                "name": "数据",
                                                "icon": EasyIcon.material.analytics,
                                                "content": "You are a data analysis expert."
                                            }]
                                        Repeater {
                                            model: presetRow.presets
                                            EasyButton {
                                                text: modelData.name
                                                icon: modelData.icon
                                                primary: systemMsgField.text === modelData.content
                                                size: EasyTheme.size.sizeSmall
                                                onClicked: systemMsgField.text = modelData.content
                                            }
                                        }
                                    }
                                }
                            }

                            // ── Parameters section ──
                            Rectangle {
                                Layout.fillWidth: true
                                radius: EasyTheme.size.radiusLarge
                                color: EasyTheme.color.card
                                border.color: EasyTheme.color.border
                                height: paramsContent.implicitHeight + 48
                                ColumnLayout {
                                    id: paramsContent
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 8
                                    Row {
                                        spacing: 6
                                        EasyIconFont { icon: EasyIcon.material.tune; iconSize: 16; color: EasyTheme.color.primary }
                                        Text { text: "参数设置"; font.pixelSize: 13; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                                    }
                                    RowLayout {
                                        spacing: 16
                                        ColumnLayout {
                                            spacing: 2
                                            Label {
                                                text: "历史轮数"
                                                font.pixelSize: 11
                                                color: EasyTheme.color.placeholder
                                            }
                                            EasyNumberInput {
                                                id: historyRoundsField
                                                value: 10
                                                min: 1
                                                max: 100
                                                step: 1
                                                precision: 0
                                            }
                                        }
                                        ColumnLayout {
                                            spacing: 2
                                            Label {
                                                text: "最大 Token"
                                                font.pixelSize: 11
                                                color: EasyTheme.color.placeholder
                                            }
                                            EasyNumberInput {
                                                id: maxTokensField
                                                value: 8192
                                                min: 256
                                                max: 128000
                                                step: 1024
                                                precision: 0
                                            }
                                        }
                                        ColumnLayout {
                                            spacing: 2
                                            Label {
                                                text: "上下文窗口"
                                                font.pixelSize: 11
                                                color: EasyTheme.color.placeholder
                                            }
                                            EasyNumberInput {
                                                id: contextWindowField
                                                value: 128000
                                                min: 4096
                                                max: 1048576
                                                step: 8192
                                                precision: 0
                                            }
                                        }
                                    }
                                    RowLayout {
                                        spacing: 16
                                        EasyToggle {
                                            id: reasoningEnabledSwitch
                                            size: EasyTheme.size.sizeSmall
                                            text: "思考模式"
                                        }
                                        EasyToggle {
                                            id: searchEnabledSwitch
                                            size: EasyTheme.size.sizeSmall
                                            text: "联网搜索"
                                        }
                                    }
                                }
                            }

                            EasyButton {
                                text: "保存配置"
                                icon: EasyIcon.material.save
                                Layout.fillWidth: true
                                onClicked: saveSessionConfig()
                            }
                        }
                    }
                }

                // Tab 2: Model Config
                Item {
                    anchors.fill: parent
                    visible: activeTab === 2

                    Flickable {
                        anchors {
                            left: parent.left; right: parent.right
                            top: parent.top; bottom: parent.bottom
                            leftMargin: 16; topMargin: 16; bottomMargin: 16; rightMargin: 2
                        }
                        clip: true
                        contentHeight: modelCol.implicitHeight
                        ScrollBar.vertical: EasyScrollBar { }

                        ColumnLayout {
                            id: modelCol
                            width: parent.width - 16
                            spacing: 8

Rectangle {
                                Layout.fillWidth: true
                                radius: EasyTheme.size.radiusLarge
                                color: EasyTheme.color.card
                                border.color: EasyTheme.color.border
                                height: vendorContent.implicitHeight + 24
                                ColumnLayout {
                                    id: vendorContent
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 8
                                    Row {
                                        spacing: 6
                                        EasyIconFont { icon: EasyIcon.material.vpn_key; iconSize: 16; color: EasyTheme.color.primary }
                                        Text { text: "厂商与 API Key 管理"; font.pixelSize: 14; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                                    }

                                    Repeater {
                                        model: ConfigManager.listVendorsQml ? ConfigManager.listVendorsQml(
                                                                                  ) : []
                                        delegate: Rectangle {
                                            Layout.fillWidth: true
                                            height: 52
                                            radius: 8
                                            color: EasyTheme.color.background
                                            border.color: EasyTheme.color.border
                                            RowLayout {
                                                anchors {
                                                    fill: parent
                                                    margins: 10
                                                }
                                                spacing: 8
                                                EasyIconFont {
                                                    icon: EasyIcon.material.dns
                                                    iconSize: 16
                                                    color: EasyTheme.color.secondary
                                                }
                                                Text {
                                                    text: modelData.name
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    color: EasyTheme.color.text
                                                    font.family: EasyTheme.font.family
                                                    Layout.fillWidth: true
                                                }
                                                Text {
                                                    text: modelData.defaultBaseUrl
                                                    font.pixelSize: 10
                                                    color: EasyTheme.color.placeholder
                                                    elide: Text.ElideMiddle
                                                    Layout.fillWidth: true
                                                }
                                                EasyInput {
                                                    id: vendorKeyInput
                                                    Layout.preferredWidth: 200
                                                    placeholder: "API Key..."
                                                    password: true
                                                }
                                                EasyButton {
                                                    text: "保存"
                                                    icon: EasyIcon.material.check
                                                    size: EasyTheme.size.sizeSmall
                                                    onClicked: {
                                                        if (vendorKeyInput.text.trim(
                                                                    ).length > 0) {
                                                            ConfigManager.addApiKeyQml(
                                                                        modelData.id,
                                                                        "默认",
                                                                        vendorKeyInput.text.trim(
                                                                            ))
                                                            vendorKeyInput.text = ""
                                                            ToastManager.success(
                                                                        "API Key 已添加")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                radius: EasyTheme.size.radiusLarge
                                color: EasyTheme.color.card
                                border.color: EasyTheme.color.border
                                height: webSearchContent.implicitHeight + 24
                                ColumnLayout {
                                    id: webSearchContent
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 8
                                    Row {
                                        spacing: 6
                                        EasyIconFont { icon: EasyIcon.material.travel_explore; iconSize: 16; color: EasyTheme.color.primary }
                                        Text { text: "Web 搜索配置"; font.pixelSize: 14; font.bold: true; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
                                    }
                                    Label {
                                        text: "提供商:"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: searchProviderField
                                        Layout.fillWidth: true
                                        placeholder: "tavily"
                                        text: WebSearchManager.provider
                                        onTextChanged: WebSearchManager.provider = text
                                    }
                                    Label {
                                        text: "Tavily API Key:"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: searchApiKeyField
                                        Layout.fillWidth: true
                                        placeholder: "tvly-..."
                                        password: true
                                        text: WebSearchManager.apiKey
                                        onTextChanged: WebSearchManager.apiKey = text
                                    }
                                    Text {
                                        text: "免费注册: https://tavily.com"
                                        font.pixelSize: 10
                                        color: EasyTheme.color.secondary
                                        font.family: EasyTheme.font.family
                                    }
                                }
                            }
                        }
                    }
                }

                // Tab 3: OSS 配置
                Item {
                    anchors.fill: parent
                    visible: activeTab === 3

                    Flickable {
                        anchors {
                            left: parent.left; right: parent.right
                            top: parent.top; bottom: parent.bottom
                            leftMargin: 16; topMargin: 16; bottomMargin: 16; rightMargin: 2
                        }
                        clip: true
                        contentHeight: ossCol.implicitHeight
                        ScrollBar.vertical: EasyScrollBar { }

                        ColumnLayout {
                            id: ossCol
                            width: parent.width - 16
                            spacing: 10

                            property Settings ossSettings: Settings {
                                category: "OSS"
                                property alias enabled: ossEnabledSwitch.checked
                                property alias endpoint: endpointField.text
                                property alias bucket: bucketField.text
                                property alias accessKeyId: accessKeyIdField.text
                                property alias accessKeySecret: accessKeySecretField.text
                                property alias region: regionField.text
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                radius: EasyTheme.size.radiusLarge
                                color: EasyTheme.color.card
                                border.color: EasyTheme.color.border
                                height: ossHeaderContent.implicitHeight + 24
                                ColumnLayout {
                                    id: ossHeaderContent
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 8
                                    Row {
                                        spacing: 6
                                        EasyIconFont {
                                            icon: EasyIcon.material.cloud_upload
                                            iconSize: 16
                                            color: EasyTheme.color.primary
                                        }
                                        Text {
                                            text: "OSS 对象存储配置"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: EasyTheme.color.text
                                            font.family: EasyTheme.font.family
                                        }
                                    }
                                    EasyToggle {
                                        id: ossEnabledSwitch
                                        size: EasyTheme.size.sizeSmall
                                        text: "启用 OSS"
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                radius: EasyTheme.size.radiusLarge
                                color: EasyTheme.color.card
                                border.color: EasyTheme.color.border
                                height: ossConnContent.implicitHeight + 24
                                ColumnLayout {
                                    id: ossConnContent
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 8
                                    Row {
                                        spacing: 6
                                        EasyIconFont {
                                            icon: EasyIcon.material.storage
                                            iconSize: 16
                                            color: EasyTheme.color.secondary
                                        }
                                        Text {
                                            text: "连接配置"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: EasyTheme.color.text
                                            font.family: EasyTheme.font.family
                                        }
                                    }
                                    Label {
                                        text: "Endpoint"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: endpointField
                                        Layout.fillWidth: true
                                        placeholder: "https://oss-cn-hangzhou.aliyuncs.com"
                                    }
                                    Label {
                                        text: "Bucket"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: bucketField
                                        Layout.fillWidth: true
                                        placeholder: "my-bucket"
                                    }
                                    Label {
                                        text: "AccessKey ID"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: accessKeyIdField
                                        Layout.fillWidth: true
                                        placeholder: "LTAI..."
                                    }
                                    Label {
                                        text: "AccessKey Secret"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: accessKeySecretField
                                        Layout.fillWidth: true
                                        placeholder: "****"
                                        password: true
                                    }
                                    Label {
                                        text: "Region"
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                    EasyInput {
                                        id: regionField
                                        Layout.fillWidth: true
                                        placeholder: "oss-cn-hangzhou"
                                    }
                                }
                            }

                            Text {
                                text: "配置自动保存到本地"
                                font.pixelSize: 10
                                color: EasyTheme.color.secondary
                                font.family: EasyTheme.font.family
                            }
                        }
                    }
                }
            }
        }
    }
}
