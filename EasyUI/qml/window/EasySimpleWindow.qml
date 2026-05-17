import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

import QWindowKit 1.0

/**
 * EasySimpleWindow —— 简洁无边框窗口
 *
 * 特性：
 *   - 无边框、圆角窗口
 *   - 只有标题栏和窗口控制按钮（最小化、最大化、关闭）
 *   - 支持拖拽移动、调整大小
 *   - 支持深色/浅色主题
 *
 * 属性：
 *   title          {string}  窗口标题
 *   showWhenReady  {bool}    准备完成后是否自动显示，默认 true
 *   content        {Item}    窗口内容（通过子元素设置）
 *   onlyCloseButton {bool}   是否只显示关闭按钮，默认 false
 */
Window {
    id: singleRoot

    property bool showWhenReady: true
    property bool onlyCloseButton: false
    property alias titleBar: titleBar
    property alias contentArea: contentArea

    default property alias children: contentArea.children

    Component.onCompleted: {
        console.log("singleRoot onCompleted");
        windowAgent.setup(singleRoot);
        windowAgent.setWindowAttribute("dark-mode", EasyTheme.isDark);
        if (singleRoot.showWhenReady) {
            singleRoot.visible = true;
            singleRoot.color = EasyTheme.color.background;
            windowAgent.setWindowAttribute("dwm-blur", false);
            windowAgent.setWindowAttribute("mica-alt", false);
            windowAgent.setWindowAttribute("acrylic-material", false);
            windowAgent.setWindowAttribute("mica", true);
        }
    }
    onVisibleChanged: vis => {
        if (!vis)
            return;
        windowAgent.setup(singleRoot);
        windowAgent.setWindowAttribute("dark-mode", EasyTheme.isDark);

        singleRoot.visible = true;
        singleRoot.color = EasyTheme.color.background;
        windowAgent.setWindowAttribute("dwm-blur", false);
        windowAgent.setWindowAttribute("mica-alt", false);
        windowAgent.setWindowAttribute("acrylic-material", false);
        windowAgent.setWindowAttribute("mica", true);

    }

    // 监听主题变化，同步更新窗口属性
    Connections {
        target: EasyTheme
        function onIsDarkChanged() {
            console.log("onIsDarkChanged")
            windowAgent.setWindowAttribute("dark-mode", EasyTheme.isDark);
            singleRoot.color = EasyTheme.color.background;
            windowAgent.setWindowAttribute("dwm-blur", false);
            windowAgent.setWindowAttribute("mica-alt", false);
            windowAgent.setWindowAttribute("acrylic-material", false);
            windowAgent.setWindowAttribute("mica", true);
        }
    }

    WindowAgent {
        id: windowAgent
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        clip: true
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            z: 9999
            propagateComposedEvents: true
            onPressed: function(mouse) {
                contentArea.forceActiveFocus()
                mouse.accepted = false
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── 标题栏 ────────────────────────────────────────────
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 30
                color: "transparent"

                Component.onCompleted: windowAgent.setTitleBar(titleBar)

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 窗口图标（可选）
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 30
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "◆"
                            font.pixelSize: 14
                            color: EasyTheme.color.primary
                        }
                    }

                    // 标题
                    Text {
                        text: singleRoot.title
                        color: EasyTheme.color.text
                        font.bold: true
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }

                    // 最小化按钮
                    EasyIconButton {
                        id: minButton
                        radius: 0
                        visible: !singleRoot.onlyCloseButton
                        hoverColor: EasyTheme.color.miniMaxBtnHover
                        icon: EasyTheme.icon.minimize
                        onClicked: singleRoot.showMinimized()
                        Component.onCompleted: windowAgent.setSystemButton(WindowAgent.Minimize, minButton)
                    }

                    // 最大化/还原按钮
                    EasyIconButton {
                        id: maxButton
                        radius: 0
                        visible: !singleRoot.onlyCloseButton
                        hoverColor: EasyTheme.color.miniMaxBtnHover
                        icon: singleRoot.visibility === Window.Maximized ? EasyTheme.icon.maximize : EasyTheme.icon.maximizeRestore
                        onClicked: {
                            if (singleRoot.visibility === Window.Maximized) {
                                singleRoot.showNormal();
                            } else {
                                singleRoot.showMaximized();
                            }
                        }
                        Component.onCompleted: windowAgent.setSystemButton(WindowAgent.Maximize, maxButton)
                    }

                    // 关闭按钮
                    EasyIconButton {
                        id: closeButton
                        radius: 0
                        hoverColor: EasyTheme.color.closeBtnHover
                        icon: EasyTheme.icon.close
                        onClicked: singleRoot.close()
                        Component.onCompleted: windowAgent.setSystemButton(WindowAgent.Close, closeButton)
                    }
                }
            }

            // ── 内容区域 ───────────────────────────────────────────
            Rectangle {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: EasyTheme.color.background
            }
        }
    }
}
