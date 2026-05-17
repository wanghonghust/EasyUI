import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI 1.0

Page {
    id: root

    property string searchText: ""

    function iconNamesOf() {
        var obj = EasyIcon.material
        var keys = Object.keys(obj)
        var names = []
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i]
            if (typeof obj[key] === "string" && key !== "objectName") {
                names.push(key)
            }
        }
        return names
    }

    property var iconNames: iconNamesOf()

    // 过滤后的图标列表
    property var filteredNames: {
        var result = []
        for (var i = 0; i < iconNames.length; i++) {
            var name = iconNames[i]
            if (searchText.length === 0 || name.toLowerCase().indexOf(searchText.toLowerCase()) >= 0) {
                result.push(name)
            }
        }
        return result
    }

    background: Rectangle {
        color: EasyTheme.color.background
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========== 顶部工具栏 ==========
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: EasyTheme.color.card
            radius: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 16

                Label {
                    text: "图标库"
                    font.pixelSize: 20
                    font.bold: true
                    color: EasyTheme.color.text
                }

                // 搜索框
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: 36
                    radius: 8
                    color: EasyTheme.color.menuHover
                    border.width: 1
                    border.color: searchInput.activeFocus
                                  ? EasyTheme.color.primary : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 6

                        EasyIconFont {
                            icon: EasyIcon.material.search
                            iconSize: 18
                            color: EasyTheme.color.placeholder
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: 13
                            color: EasyTheme.color.text

                            onTextChanged: root.searchText = text
                        }

                        // 清除按钮
                        EasyIconFont {
                            visible: searchInput.text.length > 0
                            icon: EasyIcon.material.close
                            iconSize: 16
                            color: EasyTheme.color.placeholder

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    searchInput.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }

        // ========== 统计信息 ==========
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "transparent"

            Label {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: "Material Symbols — 共 " + root.iconNames.length + " 个图标"
                       + (root.searchText.length > 0 ? "（筛选后 " + root.filteredNames.length + " 个）" : "")
                font.pixelSize: 12
                color: EasyTheme.color.secondary
            }
        }

        // ========== 图标网格（GridView 虚拟化，支持大量图标） ==========
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridView {
                id: gridView
                anchors.centerIn: parent
                width: {
                    var cols = Math.max(1, Math.floor(parent.width / cellWidth))
                    return cols * cellWidth
                }
                height: parent.height
                clip: true

                cellWidth: 116
                cellHeight: 106

                model: root.filteredNames.length

                delegate: Rectangle {
                    id: iconCard
                    width: 104
                    height: 94
                    radius: 10
                    color: cardArea.containsMouse ? EasyTheme.color.menuHover : EasyTheme.color.card
                    border.width: 0.5
                    border.color: EasyTheme.color.divider

                    Behavior on color { ColorAnimation { duration: 100 } }

                    property string iconName: root.filteredNames[index]
                    property string iconCode: EasyIcon.material[root.filteredNames[index]]

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        EasyIconFont {
                            Layout.alignment: Qt.AlignHCenter
                            icon: iconCard.iconCode || ""
                            iconSize: 26
                            color: EasyTheme.color.text
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 96
                            text: iconCard.iconName
                            font.pixelSize: 10
                            color: EasyTheme.color.secondary
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: cardArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            console.log("EasyIcon.material." + iconCard.iconName)
                            copyFeedback.start()
                        }
                    }

                    PropertyAnimation {
                        id: copyFeedback
                        target: iconCard
                        property: "scale"
                        to: 0.95
                        duration: 80
                        onFinished: scaleBack.start()
                    }
                    PropertyAnimation {
                        id: scaleBack
                        target: iconCard
                        property: "scale"
                        to: 1.0
                        duration: 80
                    }
                }
            }

            // 滚动条贴在窗口右边缘
            ScrollBar {
                id: vScrollBar
                anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
                policy: ScrollBar.AsNeeded
                Binding { target: vScrollBar; property: "size"; value: gridView.visibleArea.heightRatio }
                Binding {
                    target: vScrollBar; property: "position"
                    value: gridView.visibleArea.yPosition
                    when: !vScrollBar.pressed
                }
                onPositionChanged: {
                    if (pressed) {
                        gridView.contentY = position * (gridView.contentHeight - gridView.height)
                    }
                }
            }
        }
    }
}
