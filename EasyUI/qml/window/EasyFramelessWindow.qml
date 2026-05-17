import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

import QWindowKit 1.0

ApplicationWindow {
    id: root
    property bool showWhenReady: true
    property alias titleBar: titleBar
    property alias width: root.width
    property alias height: root.height

    minimumHeight: 30 + 2 * root.border

    minimumWidth: 18 * 5 + 140

    // color: "transparent"
    property bool forceClose: false

    property int windowFlags
    property int bw: 0
    property int border: 0
    property alias title: root.title
    default property alias children: contentArea.children
    property alias leftContent: leftSide.sourceComponent
    property alias leftSideExpanded: leftSide.expanded

    // ── Title bar button visibility ──
    property bool showThemeButton: true
    property bool showMinimizeButton: true
    property bool showMaximizeButton: true
    property bool showCloseButton: true

    // ── Custom title bar actions (placed between title and system buttons) ──
    property alias titleBarActions: titleActionsRow.data

    function applyWindowStyle() {
        windowAgent.setWindowAttribute("dark-mode", EasyTheme.isDark)
        root.color = "transparent"
        windowAgent.setWindowAttribute("dwm-blur", false)
        windowAgent.setWindowAttribute("mica-alt", false)
        windowAgent.setWindowAttribute("acrylic-material", false)
        windowAgent.setWindowAttribute("mica", true)
    }

    Component.onCompleted: {
        windowAgent.setup(root);
        if (root.showWhenReady) {
            root.visible = true;
            applyWindowStyle()
        }
    }

    Connections {
        target: ThemeSettings
        function onThemeSettingsChanged() {
            applyWindowStyle()
        }
    }

    onClosing: close => {
        if (forceClose) {
            forceClose = false;
            return;
        }
        close.accepted = false;
        confirmDialog.open();
    }

    WindowAgent {
        id: windowAgent
    }

    // ── 退出确认弹窗（必须挂在真实 Item 上，不能通过 default children 别名进入 contentArea） ──
    Item {
        id: _dialogHost
        parent: root.contentItem  // 挂在 Window.contentItem（真实 Item）上
        anchors.fill: parent

        EasyDialog {
            id: confirmDialog
            headerTitle: "退出确认"
            titleIcon:   EasyIcon.material.warning
            confirmText: "退出"
            cancelText:  "取消"
            dialogWidth: 360
            contentMinH: 80

            accentStart: "#f97316"
            accentEnd:   "#ef4444"

        Text {
                width: parent.width
                text: "确定要退出应用程序吗？"
                font.pixelSize: 14
                color: EasyTheme.color.text
                wrapMode: Text.WordWrap
                bottomPadding: 4
            }

            Text {
                width: parent.width
                text: "当前会话数据已自动保存。"
                font.pixelSize: 12
                color: EasyTheme.color.placeholder
                wrapMode: Text.WordWrap
                bottomPadding: 8
            }

            onAccepted: {
                root.forceClose = true
                Qt.quit()
            }

            onRejected: { }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        clip: true
        // border.width: root.border
        // border.color: EasyTheme.color.windowBorder
        color: EasyTheme.color.background

        SplitView {
            id: split
            anchors.fill: parent
            orientation: Qt.Horizontal

            Behavior on SplitView.preferredWidth {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }

            readonly property bool hasSidebar: leftSide.sourceComponent != null

            handle: Rectangle {
                implicitWidth: split.hasSidebar ? 1 : 0
                implicitHeight: split.height
                color: split.hasSidebar && SplitHandle.hovered ? EasyTheme.color.primary : EasyTheme.color.divider
                visible: split.hasSidebar

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                containmentMask: Item {
                    width: 12
                    height: split.height
                    x: -6
                }
            }
            Loader {
                id: leftSide
                property bool expanded: split.hasSidebar
                property int collapsedWidth: 60
                property int expandedWidth: 200
                property int maximumWidth: 400
                property real collapseThreshold: 100
                SplitView.fillHeight: true
                SplitView.preferredWidth: split.hasSidebar ? (expanded ? expandedWidth : collapsedWidth) : 0
                SplitView.minimumWidth: split.hasSidebar ? collapsedWidth : 0
                SplitView.maximumWidth: split.hasSidebar ? maximumWidth : 0
                visible: split.hasSidebar

                onWidthChanged: {
                    if (width <= collapseThreshold && expanded) {
                        expanded = false
                    } else if (width > collapseThreshold && !expanded) {
                        expanded = true
                    }
                }

                onExpandedChanged: {
                    if (expanded && width <= collapseThreshold) {
                        SplitView.preferredWidth = expandedWidth
                    }
                }
            }

            ColumnLayout {
                SplitView.fillHeight: true
                SplitView.fillWidth: true

                anchors.margins: bw + root.border
                spacing: 0

                Rectangle {
                    id: titleBar
                    Layout.fillWidth: true
                    height: 30
                    clip: true
                    color: "transparent"
                    z: 999
                    Component.onCompleted: windowAgent.setTitleBar(titleBar)

                    Rectangle {
                        anchors.fill: parent
                        radius: 10 - bw
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            // 标题（占据剩余空间）
                            Text {
                                id: titleText
                                text: root.title
                                color: EasyTheme.color.text
                                font.bold: true
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                Layout.leftMargin: 10
                            }

                            // ── Custom actions slot ──
                            RowLayout {
                                id: titleActionsRow
                                spacing: 4
                                Layout.fillHeight: true
                                Component.onCompleted: windowAgent.setHitTestVisible(titleActionsRow, true)
                            }

                            // 主题切换
                            EasyIconButton {
                                id: changeTheme
                                visible: root.showThemeButton
                                radius: 0
                                hoverColor: EasyTheme.color.miniMaxBtnHover
                                icon: EasyTheme.icon.theme
                                onClicked: ThemeSettings.setDarkMode(!EasyTheme.isDark)
                                Component.onCompleted: windowAgent.setHitTestVisible(changeTheme, true)
                            }

                            // 最小化
                            EasyIconButton {
                                id: minButton
                                visible: root.showMinimizeButton
                                radius: 0
                                hoverColor: EasyTheme.color.miniMaxBtnHover
                                icon: EasyTheme.icon.minimize
                                onClicked: root.showMinimized()
                                Component.onCompleted: windowAgent.setSystemButton(WindowAgent.Minimize, minButton)
                            }

                            // 最大化
                            EasyIconButton {
                                id: maxButton
                                visible: root.showMaximizeButton
                                radius: 0
                                hoverColor: EasyTheme.color.miniMaxBtnHover
                                icon: root.visibility === Window.Maximized ? EasyTheme.icon.maximize : EasyTheme.icon.maximizeRestore
                                onClicked: {
                                    if (root.visibility === Window.Maximized) {
                                        root.showNormal();
                                    } else {
                                        root.showMaximized();
                                    }
                                }
                                Component.onCompleted: windowAgent.setSystemButton(WindowAgent.Maximize, maxButton)
                            }

                            // 关闭按钮
                            EasyIconButton {
                                id: closeButton
                                visible: root.showCloseButton
                                radius: 0
                                hoverColor: !closeButton.enabled ? "gray" : EasyTheme.color.closeBtnHover
                                icon: EasyTheme.icon.close
                                onClicked: window.close()
                                Component.onCompleted: windowAgent.setSystemButton(WindowAgent.Close, closeButton)
                            }
                        }
                    }
                }
                Item {
                    id: contentArea
                    clip: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
