import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

Popup {
    id: root
    modal: false; dim: false; padding: 0
    closePolicy: Popup.OnEscape
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round(parent.height * 0.15)
    width: 520; height: Math.min(420, listView.contentHeight + searchBar.height + 16)

    property var commands: []
    property string placeholderText: "搜索命令..."
    signal commandSelected(string id, var data)

    onOpened: {
        searchField.text = ""; searchField.forceActiveFocus()
        // 创建手动遮罩（modal 遮罩会拦截 OnPressOutside）
        if (!_dim) {
            _dim = Qt.createQmlObject("import QtQuick; Rectangle { color: \"#80000000\"; anchors.fill: parent; z: -1; MouseArea { anchors.fill: parent; onClicked: root.close() } }", Overlay.overlay)
        }
        _dim.visible = true
    }
    onClosed: { if (_dim) _dim.visible = false }

    property var _dim: null

    // 全局快捷键：Ctrl+K / Ctrl+Shift+P 打开命令面板
    Shortcut { sequence: "Ctrl+K"; onActivated: root.open() }
    Shortcut { sequence: "Ctrl+Shift+P"; onActivated: root.open() }

    background: Rectangle {
        color: EasyTheme.color.card; radius: 14
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true; shadowBlur: 0.8; shadowColor: EasyTheme.color.shadow
            shadowHorizontalOffset: 0; shadowVerticalOffset: 0
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            id: searchBar
            Layout.fillWidth: true; Layout.preferredHeight: 48
            color: "transparent"

            RowLayout {
                anchors { fill: parent; leftMargin: 16; rightMargin: 12 }
                spacing: 8
                Text {
                    text: EasyIcon.material.search || "⌕"; font.family: "Material Symbols Outlined"
                    font.pixelSize: 20; color: EasyTheme.color.placeholder
                }
                TextField {
                    id: searchField; Layout.fillWidth: true
                    font.pixelSize: 14; color: EasyTheme.color.text
                    placeholderText: root.placeholderText
                    placeholderTextColor: EasyTheme.color.placeholder
                    background: Item {}
                    Keys.onDownPressed: { if (listView.count > 0) { listView.currentIndex = 0; listView.itemAtIndex(0).forceActiveFocus() } }
                    Keys.onUpPressed: { if (listView.count > 0) { listView.currentIndex = listView.count - 1; listView.itemAtIndex(listView.currentIndex).forceActiveFocus() } }
                    Keys.onReturnPressed: { if (listView.count > 0) triggerCommand(listView.currentItem ? listView.currentItem._cmdData : null) }
                    onTextChanged: { listView.currentIndex = 0 }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: EasyTheme.color.divider }

        ListView {
            id: listView; Layout.fillWidth: true; Layout.fillHeight: true
            Layout.topMargin: 8; Layout.bottomMargin: 8
            clip: true; spacing: 0; keyNavigationWraps: true
            ScrollBar.vertical: EasyScrollBar {}
            model: filteredCommands
            property var filteredCommands: {
                var c = []; var q = searchField.text.toLowerCase().trim()
                for (var i = 0; i < root.commands.length; i++) {
                    var cmd = root.commands[i]; if (!q) { c.push(cmd); continue }
                    if ((cmd.title || "").toLowerCase().indexOf(q) >= 0 ||
                        (cmd.keywords || "").toLowerCase().indexOf(q) >= 0 ||
                        (cmd.category || "").toLowerCase().indexOf(q) >= 0) c.push(cmd)
                }
                return c
            }
            delegate: Rectangle {
                id: delegateItem
                width: listView.width; height: 48; radius: 0
                color: delegateArea.containsMouse || ListView.isCurrentItem ? EasyTheme.color.buttonHover : "transparent"
                property var _cmdData: modelData

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 12 }
                    spacing: 10
                    Text {
                        text: modelData.icon || ""; font.pixelSize: 18
                        color: EasyTheme.color.text; visible: text.length > 0
                        Layout.preferredWidth: 28
                    }
                    ColumnLayout { spacing: 1; Layout.fillWidth: true
                        Text {
                            text: modelData.title || ""; font.pixelSize: 13; font.bold: true
                            color: EasyTheme.color.text; elide: Text.ElideRight; Layout.fillWidth: true
                        }
                        Text {
                            text: modelData.subtitle || ""; font.pixelSize: 11
                            color: EasyTheme.color.secondary; elide: Text.ElideRight
                            Layout.fillWidth: true; visible: text.length > 0
                        }
                    }
                    Rectangle {
                        visible: modelData.shortcut !== undefined
                        Layout.preferredWidth: shortcutText.implicitWidth + 10; Layout.preferredHeight: 22; radius: 4
                        color: EasyTheme.color.card; border.color: EasyTheme.color.border; border.width: 1
                        Text {
                            id: shortcutText; anchors.centerIn: parent; text: modelData.shortcut || ""
                            font.pixelSize: 11; color: EasyTheme.color.secondary
                        }
                    }
                }

                // 注册命令自带的快捷键
                Shortcut {
                    sequence: modelData.shortcut || ""
                    enabled: modelData.shortcut !== undefined
                    onActivated: triggerCommand(modelData)
                }

                MouseArea {
                    id: delegateArea; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor; onClicked: triggerCommand(modelData)
                }
                Keys.onReturnPressed: triggerCommand(modelData)
                Keys.onUpPressed: {
                    if (index > 0) {
                        listView.currentIndex = index - 1
                        listView.itemAtIndex(listView.currentIndex).forceActiveFocus()
                    } else {
                        searchField.forceActiveFocus()
                    }
                }
                Keys.onDownPressed: {
                    if (index < listView.count - 1) {
                        listView.currentIndex = index + 1
                        listView.itemAtIndex(listView.currentIndex).forceActiveFocus()
                    }
                }

                function triggerCommand(cmd) {
                    if (!cmd) return
                    root.commandSelected(cmd.id, cmd.data || {})
                    root.close()
                }
            }
        }
    }

    function triggerCommand(cmd) {
        if (!cmd) return
        root.commandSelected(cmd.id, cmd.data || {})
        root.close()
    }
}
