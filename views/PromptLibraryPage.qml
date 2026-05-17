import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI
import Utils 1.0
import Chat 1.0

Page {
    id: root
    background: Rectangle {
        color: EasyTheme.color.background
    }

    property var prompts: []
    property var categories: []
    property string filterText: ""
    property string selectedCategory: ""
    property int cardMinWidth: 260
    property int cardMaxWidth: 420

    function refreshPrompts() {
        prompts = PromptManager.listPrompts(selectedCategory, filterText)
        categories = PromptManager.categories()
    }

    Component.onCompleted: refreshPrompts()

    // When signals fire or filter changes, reload
    Connections {
        target: PromptManager
        function onPromptsChanged() { refreshPrompts() }
    }

    onFilterTextChanged: refreshPrompts()
    onSelectedCategoryChanged: refreshPrompts()

    ScrollView {
        id: scrollRoot
        anchors.fill: parent
        padding: 24
        clip: true
        ScrollBar.vertical: EasyScrollBar { }

        ColumnLayout {
            width: scrollRoot.availableWidth
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "提示词库"
                    font.pixelSize: 24
                    font.bold: true
                    color: EasyTheme.color.text
                }
                Item { Layout.fillWidth: true }
                EasyButton {
                    text: "+ 新建"
                    onClicked: editDialog.openForCreate()
                }
                EasyButton {
                    text: "导入"
                    primary: false
                    onClicked: importDialog.open()
                }
                EasyButton {
                    text: "导出"
                    primary: false
                    onClicked: {
                        var json = PromptManager.exportPromptsJson()
                        Clipboard.setText(json)
                        ToastManager.success("JSON 已复制到剪贴板")
                    }
                }
            }

            Text {
                text: "保存和复用常用提示词，支持变量插值"
                font.pixelSize: 13
                color: EasyTheme.color.placeholder
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                EasySearchInput {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 300
                    placeholder: "搜索提示词..."
                    onTextChanged: filterText = text
                }

                Repeater {
                    model: categories
                    delegate: EasyButton {
                        text: modelData
                        primary: selectedCategory === modelData
                        onClicked: selectedCategory = selectedCategory === modelData ? "" : modelData
                    }
                }
            }

            // Prompt cards grid — adaptive columns
            Flow {
                id: cardFlow
                Layout.fillWidth: true
                spacing: 16

                Repeater {
                    model: prompts
                    delegate: EasyCard {
                        width: Math.min(460, Math.max(320, (cardFlow.width - 16 * (Math.max(1, Math.floor((cardFlow.width + 16) / 340)) - 1)) / Math.max(1, Math.floor((cardFlow.width + 16) / 340))))
                        padding: 16

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            RowLayout {
                                spacing: 10
                                ColumnLayout {
                                    spacing: 2
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.title
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: EasyTheme.color.text
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: modelData.category
                                        font.pixelSize: 11
                                        color: EasyTheme.color.placeholder
                                    }
                                }
                            }

                            Text {
                                text: modelData.content.replace(/\n/g, " ").substring(0, 80) + "..."
                                font.pixelSize: 11
                                color: EasyTheme.color.secondary
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            // Tags
                            Flow {
                                Layout.fillWidth: true
                                spacing: 4
                                visible: modelData.tags && modelData.tags.length > 0
                                Repeater {
                                    model: modelData.tags || []
                                    delegate: EasyTag {
                                        text: modelData
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: EasyTheme.color.divider
                            }

                            RowLayout {
                                spacing: 8
                                EasyButton {
                                    text: "复制"
                                    onClicked: {
                                        Clipboard.setText(modelData.content)
                                        ToastManager.success("提示词已复制到剪贴板")
                                        PromptManager.incrementUsage(modelData.id)
                                    }
                                }
                                EasyButton {
                                    text: "使用"
                                    primary: false
                                    onClicked: {
                                        PromptManager.incrementUsage(modelData.id)
                                        if (typeof window !== 'undefined') {
                                            window.activePath = "chat"
                                            window.pendingPromptId = modelData.id
                                        }
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                EasyButton {
                                    text: "编辑"
                                    primary: false
                                    onClicked: editDialog.openForEdit(modelData)
                                }
                                EasyButton {
                                    text: "删除"
                                    primary: false
                                    onClicked: {
                                        deleteConfirm.promptId = modelData.id
                                        deleteConfirm.promptTitle = modelData.title
                                        deleteConfirm.open()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ===== Edit/Create Dialog =====
    EasyDialog {
        id: editDialog
        headerTitle: editId >= 0 ? "编辑提示词" : "新建提示词"
        titleIcon: EasyIcon.material.edit_note
        confirmText: "保存"
        cancelText: "取消"
        dialogWidth: 560

        property int editId: -1

        function openForCreate() {
            editId = -1
            titleField.text = ""
            contentField.text = ""
            categoryField.text = ""
            tagsField.text = ""
            open()
        }

        function openForEdit(promptData) {
            editId = promptData.id
            titleField.text = promptData.title
            contentField.text = promptData.content
            categoryField.text = promptData.category || ""
            tagsField.text = promptData.tags ? promptData.tags.join(", ") : ""
            open()
        }

        function save() {
            if (!titleField.text.trim() || !contentField.text.trim()) {
                ToastManager.warning("标题和内容不能为空")
                return
            }
            var tags = tagsField.text.split(",").map(function(t) { return t.trim() }).filter(function(t) { return t.length > 0 })

            if (editId >= 0) {
                var fields = { title: titleField.text.trim(), content: contentField.text.trim(),
                               category: categoryField.text.trim() || "通用", tags: tags }
                PromptManager.updatePrompt(editId, fields)
            } else {
                PromptManager.addPrompt(titleField.text.trim(), contentField.text.trim(),
                    categoryField.text.trim() || "通用", tags)
            }
            close()
        }

        ColumnLayout {
            spacing: 12
            width: parent.width

            Text { text: "标题"; font.pixelSize: 12; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
            EasyInput {
                id: titleField
                Layout.fillWidth: true
                placeholder: "提示词名称"
            }

            Text { text: "分类"; font.pixelSize: 12; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
            EasyInput {
                id: categoryField
                Layout.fillWidth: true
                placeholder: "例如：开发、写作、通用"
            }

            Text { text: "标签（逗号分隔）"; font.pixelSize: 12; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
            EasyInput {
                id: tagsField
                Layout.fillWidth: true
                placeholder: "code, review, python"
            }

            Text { text: "内容（用 {{变量名}} 作为占位符）"; font.pixelSize: 12; color: EasyTheme.color.text; font.family: EasyTheme.font.family }
            EasyTextArea {
                id: contentField
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                placeholder: "输入提示词内容...\n变量示例：请翻译 {{text}} 为 {{target_lang}}"
            }
        }
    }

    // ===== Delete Confirm =====
    EasyDialog {
        id: deleteConfirm
        headerTitle: "确认删除"
        titleIcon: EasyIcon.material.warning
        confirmText: "删除"
        cancelText: "取消"
        accentStart: "#ef4444"
        accentEnd: "#dc2626"
        dialogWidth: 400

        property int promptId: -1
        property string promptTitle: ""

        Text {
            text: "确定要删除「" + deleteConfirm.promptTitle + "」吗？此操作不可撤销。"
            font.pixelSize: 14
            font.family: EasyTheme.font.family
            color: EasyTheme.color.text
            wrapMode: Text.WordWrap
            width: parent.width
        }
        onAccepted: {
            PromptManager.deletePrompt(deleteConfirm.promptId)
        }
    }

    // ===== Import Dialog =====
    EasyDialog {
        id: importDialog
        headerTitle: "导入提示词"
        titleIcon: EasyIcon.material.upload_file
        confirmText: "导入"
        cancelText: "取消"
        dialogWidth: 500

        ColumnLayout {
            spacing: 12
            width: parent.width

            Text {
                text: "粘贴JSON数据来导入提示词："
                font.pixelSize: 13
                font.family: EasyTheme.font.family
                color: EasyTheme.color.text
            }
            EasyTextArea {
                id: textArea
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                placeholder: "粘贴导出的JSON..."
            }
        }

        onAccepted: {
            if (textArea.text.trim()) {
                PromptManager.importPromptsJson(textArea.text.trim())
            }
        }
    }
}
