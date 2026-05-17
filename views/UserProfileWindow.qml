import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI
import Chat 1.0

/**
 * UserProfileWindow —— 用户详情窗口
 *
 * 点击主窗口用户头像时弹出，展示用户详细信息和数据。
 */
EasySimpleWindow {
    id: profileWindow
    title: "用户详情"
    width: 720
    height: 720
    minimumWidth: 560
    minimumHeight: 420

    // 用户数据（可由外部传入）
    property string userName: "张三"
    property string userId: "USR-2024-00128"
    property string userRole: "管理员"
    property string userStatus: "在线"
    property string userEmail: "zhangsan@example.com"
    property string userPhone: "138****8888"
    property string userDept: "技术研发部"
    property string userJoinDate: "2023-06-15"
    property string userLocation: "杭州"

    function showWindow(parentWindow) {
        if (parentWindow) {
            x = parentWindow.x + (parentWindow.width - width) / 2
            y = parentWindow.y + (parentWindow.height - height) / 2
        }
        visible = true
        raise()
        requestActivate()
    }

    function refreshChatMessages() {
        var sessions = ChatManager.sessions;
        var data = [];
        for (var i = 0; i < sessions.length; i++) {
            var session = sessions[i];
            var messages = session.messages;
            var msgCount = messages.length;
            var children = [];

            for (var j = 0; j < msgCount; j++) {
                var msg = messages[j];
                var roleStr = msg.role;
                var roleLabel = roleStr === "user" ? "用户" : (roleStr === "assistant" ? "AI" : "系统");
                var content = msg.content || "";
                var timeStr = msg.timestamp instanceof Date
                    ? Qt.formatDateTime(msg.timestamp, "yyyy-MM-dd hh:mm") : "";

                children.push({
                    "time": timeStr,
                    "role": roleLabel,
                    "preview": content.length > 40 ? content.substring(0, 40) + "..." : content,
                    "length": content.length
                });
            }

            var updateTimeStr = session.updateTime instanceof Date
                ? Qt.formatDateTime(session.updateTime, "yyyy-MM-dd hh:mm") : "";

            data.push({
                "time": updateTimeStr,
                "session": session.title,
                "role": msgCount > 0 ? "对话" : "",
                "preview": msgCount > 0 ? "共 " + msgCount + " 条消息" : "空对话",
                "length": msgCount,
                "children": children
            });
        }
        chatMessageTable.tableData = data;
    }

    onVisibleChanged: {
        if (visible) refreshChatMessages()
    }

    // ===== 窗口内容 =====
    Rectangle {
        anchors.fill: parent
        color: EasyTheme.color.background

        Connections {
            target: ChatManager
            function onSessionsChanged() { refreshChatMessages() }
        }

        ScrollView {
            id: scrollView
            anchors.fill: parent
            clip: true
            ScrollBar.vertical: EasyScrollBar { }
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: scrollView.availableWidth - 40
                x: 20
                spacing: 16

                // ── 顶部：头像 + 基础信息 ──
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    EasyAvatar {
                        id: profileAvatar
                        size: 72
                        text: profileWindow.userName
                        shape: "circle"
                        borderWidth: 2
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            spacing: 10

                            Text {
                                text: profileWindow.userName
                                font.pixelSize: 20
                                font.bold: true
                                color: EasyTheme.color.text
                            }

                            EasyTag {
                                text: profileWindow.userRole
                                type: "primary"
                                size: EasyTheme.size.sizeSmall
                            }

                            EasyTag {
                                text: profileWindow.userStatus
                                type: "success"
                                size: EasyTheme.size.sizeSmall
                            }
                        }

                        Text {
                            text: "ID: " + profileWindow.userId
                            font.pixelSize: 12
                            color: EasyTheme.color.placeholder
                        }

                        Text {
                            text: profileWindow.userDept + " · " + profileWindow.userLocation
                            font.pixelSize: 13
                            color: EasyTheme.color.secondary
                        }
                    }
                }

                EasyDivider { Layout.fillWidth: true }

                // ── 中部：详细信息卡片 ──
                EasyCard {
                    Layout.fillWidth: true
                    cardPadding: 16
                    shadowBlur: 4

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "基本信息"
                            font.pixelSize: 14
                            font.bold: true
                            color: EasyTheme.color.text
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 24
                            rowSpacing: 12

                            // 邮箱
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "邮箱"
                                    font.pixelSize: 11
                                    color: EasyTheme.color.placeholder
                                }
                                Text {
                                    text: profileWindow.userEmail
                                    font.pixelSize: 13
                                    color: EasyTheme.color.text
                                }
                            }

                            // 手机
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "手机"
                                    font.pixelSize: 11
                                    color: EasyTheme.color.placeholder
                                }
                                Text {
                                    text: profileWindow.userPhone
                                    font.pixelSize: 13
                                    color: EasyTheme.color.text
                                }
                            }

                            // 入职日期
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "入职日期"
                                    font.pixelSize: 11
                                    color: EasyTheme.color.placeholder
                                }
                                Text {
                                    text: profileWindow.userJoinDate
                                    font.pixelSize: 13
                                    color: EasyTheme.color.text
                                }
                            }

                            // 部门
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "部门"
                                    font.pixelSize: 11
                                    color: EasyTheme.color.placeholder
                                }
                                Text {
                                    text: profileWindow.userDept
                                    font.pixelSize: 13
                                    color: EasyTheme.color.text
                                }
                            }
                        }
                    }
                }

                // ── 操作记录表格 ──
                EasyCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 280
                    cardPadding: 16
                    shadowBlur: 4

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "近期操作记录"
                            font.pixelSize: 14
                            font.bold: true
                            color: EasyTheme.color.text
                        }

                        EasyTable {
                            id: operationTable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            rowHeight: 34
                            stripe: true
                            hoverHighlight: true
                            rowBorder: true
                            pagination: true
                            pageSize: 5

                            columns: [
                                { title: "时间", key: "time", width: 150 },
                                { title: "操作类型", key: "type", width: 120 },
                                { title: "详情", key: "detail", width: -1 },
                                { title: "状态", key: "status", width: 80, align: Text.AlignHCenter }
                            ]

                            tableData: [
                                { time: "2026-04-26 09:30", type: "登录", detail: "Windows 客户端登录", status: "成功" },
                                { time: "2026-04-25 18:12", type: "修改配置", detail: "更新了模型供应商配置", status: "成功" },
                                { time: "2026-04-25 14:05", type: "导出", detail: "导出了会话记录", status: "成功" },
                                { time: "2026-04-24 11:20", type: "登录", detail: "macOS 客户端登录", status: "成功" },
                                { time: "2026-04-23 16:45", type: "删除", detail: "删除了历史会话 #1284", status: "成功" },
                                { time: "2026-04-22 09:00", type: "登录", detail: "iOS 客户端登录", status: "成功" },
                                { time: "2026-04-21 20:30", type: "修改密码", detail: "更新了账户密码", status: "成功" },
                                { time: "2026-04-20 13:15", type: "导入", detail: "批量导入了 24 条配置", status: "成功" }
                            ]
                        }
                    }
                }

                // ── 聊天消息表格 ──
                EasyCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 560
                    cardPadding: 16
                    shadowBlur: 4

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "全部聊天消息"
                            font.pixelSize: 14
                            font.bold: true
                            color: EasyTheme.color.text
                        }

                        EasyTable {
                            id: chatMessageTable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            rowHeight: 34
                            stripe: true
                            hoverHighlight: true
                            rowBorder: true
                            expandable: true
                            pagination: true
                            pageSize: 10

                            columns: [
                                { title: "时间", key: "time", width: 140 },
                                { title: "会话", key: "session", width: 120 },
                                { title: "角色", key: "role", width: 70, align: Text.AlignHCenter },
                                { title: "内容预览", key: "preview", width: -1 },
                                { title: "字数", key: "length", width: 60, align: Text.AlignHCenter }
                            ]

                            tableData: []
                        }
                    }
                }
            }
        }
    }
}
