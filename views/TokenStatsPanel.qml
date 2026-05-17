import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI
import Chat 1.0

Rectangle {
    id: root
    color: EasyTheme.color.background
    property var chatManager: ChatManager

    property var stats: chatManager ? chatManager.getTokenStats() : ({})

    function refresh() {
        stats = chatManager ? chatManager.getTokenStats() : ({})
    }

    ScrollView {
        id: scrollRoot
        anchors.fill: parent; padding: 24; clip: true
        ScrollBar.vertical: EasyScrollBar { }

        ColumnLayout {
            width: scrollRoot.availableWidth; spacing: 20

            RowLayout {
                Text { text: "📊 Token 统计"; font.pixelSize: 24; font.bold: true; color: EasyTheme.color.text; Layout.fillWidth: true }
                EasyButton { text: "🔄 刷新"; primary: false; onClicked: refresh() }
            }

            Text { text: "估算值，基于 1 token ≈ 4 字符计算"; font.pixelSize: 12; color: EasyTheme.color.placeholder }

            // Summary cards — adaptive columns
            Flow {
                id: statFlow
                Layout.fillWidth: true; spacing: 16

                EasyCard {
                    width: Math.min(280, Math.max(160, (statFlow.width - 16 * (Math.max(1, Math.floor((statFlow.width + 16) / 176)) - 1)) / Math.max(1, Math.floor((statFlow.width + 16) / 176)))); height: 100; padding: 16
                    ColumnLayout { anchors.centerIn: parent; spacing: 4
                        Text { text: String(stats.totalMessages || 0); font.pixelSize: 28; font.bold: true
                            color: EasyTheme.color.primary; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "总消息数"; font.pixelSize: 12; color: EasyTheme.color.secondary; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                EasyCard {
                    width: Math.min(280, Math.max(160, (statFlow.width - 16 * (Math.max(1, Math.floor((statFlow.width + 16) / 176)) - 1)) / Math.max(1, Math.floor((statFlow.width + 16) / 176)))); height: 100; padding: 16
                    ColumnLayout { anchors.centerIn: parent; spacing: 4
                        Text { text: String(stats.estimatedTokens || 0); font.pixelSize: 28; font.bold: true
                            color: EasyTheme.color.success; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "预估 Tokens"; font.pixelSize: 12; color: EasyTheme.color.secondary; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                EasyCard {
                    width: Math.min(280, Math.max(160, (statFlow.width - 16 * (Math.max(1, Math.floor((statFlow.width + 16) / 176)) - 1)) / Math.max(1, Math.floor((statFlow.width + 16) / 176)))); height: 100; padding: 16
                    ColumnLayout { anchors.centerIn: parent; spacing: 4
                        Text { text: "$" + String(stats.estimatedCost || "0"); font.pixelSize: 28; font.bold: true
                            color: EasyTheme.color.warning; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "预估费用 (USD)"; font.pixelSize: 12; color: EasyTheme.color.secondary; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                EasyCard {
                    width: Math.min(280, Math.max(160, (statFlow.width - 16 * (Math.max(1, Math.floor((statFlow.width + 16) / 176)) - 1)) / Math.max(1, Math.floor((statFlow.width + 16) / 176)))); height: 100; padding: 16
                    ColumnLayout { anchors.centerIn: parent; spacing: 4
                        Text { text: String(stats.sessionCount || 0); font.pixelSize: 28; font.bold: true
                            color: EasyTheme.color.primary; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "会话总数"; font.pixelSize: 12; color: EasyTheme.color.secondary; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                EasyCard {
                    width: Math.min(280, Math.max(160, (statFlow.width - 16 * (Math.max(1, Math.floor((statFlow.width + 16) / 176)) - 1)) / Math.max(1, Math.floor((statFlow.width + 16) / 176)))); height: 100; padding: 16
                    ColumnLayout { anchors.centerIn: parent; spacing: 4
                        Text { text: String(stats.userMessages || 0); font.pixelSize: 28; font.bold: true
                            color: EasyTheme.color.primary; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "用户消息"; font.pixelSize: 12; color: EasyTheme.color.secondary; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                EasyCard {
                    width: Math.min(280, Math.max(160, (statFlow.width - 16 * (Math.max(1, Math.floor((statFlow.width + 16) / 176)) - 1)) / Math.max(1, Math.floor((statFlow.width + 16) / 176)))); height: 100; padding: 16
                    ColumnLayout { anchors.centerIn: parent; spacing: 4
                        Text { text: String(stats.assistantMessages || 0); font.pixelSize: 28; font.bold: true
                            color: EasyTheme.color.success; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "AI 回复"; font.pixelSize: 12; color: EasyTheme.color.secondary; Layout.alignment: Qt.AlignHCenter }
                    }
                }
            }

            // Total chars
            EasyCard {
                Layout.fillWidth: true; padding: 16
                RowLayout { anchors.fill: parent; spacing: 16
                    Text { text: "📝"; font.pixelSize: 24 }
                    ColumnLayout { spacing: 2; Layout.fillWidth: true
                        Text { text: "总字符数: " + (stats.totalChars || 0).toLocaleString(); font.pixelSize: 14; font.bold: true; color: EasyTheme.color.text }
                        Text { text: "平均每消息: " + ((stats.totalMessages > 0) ? Math.round((stats.totalChars || 0) / stats.totalMessages) : 0).toLocaleString() + " 字符"; font.pixelSize: 12; color: EasyTheme.color.secondary }
                    }
                }
            }
        }
    }

    Component.onCompleted: refresh()
}
