import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

Item {
    width: parent ? parent.width : 600
    height: Math.max(contentLayout.implicitHeight + 48, 300)

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 24

        Text { text: "滚动条 (EasyScrollBar)"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }

        ColumnLayout {
            spacing: 16; width: parent.width

            Text { text: "VS Code 风格滚动条"; font.pixelSize: 12; color: EasyTheme.color.placeholder }

            RowLayout {
                spacing: 20

                // Vertical
                ColumnLayout {
                    spacing: 8
                    Text { text: "垂直滚动"; font.pixelSize: 12; color: EasyTheme.color.secondary }
                    Rectangle {
                        Layout.preferredWidth: 220; Layout.preferredHeight: 200
                        radius: EasyTheme.size.radius; color: EasyTheme.color.card
                        border.color: EasyTheme.color.border; border.width: 1
                        ScrollView {
                            anchors.fill: parent; anchors.margins: 12; clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            ScrollBar.vertical: EasyScrollBar { }
                            Text {
                                width: parent.width
                                text: Array(30).fill("").map((_,i) => "行 " + (i+1)).join("\n")
                                font.pixelSize: 13; color: EasyTheme.color.text; lineHeight: 1.6
                            }
                        }
                    }
                }

                // Horizontal
                ColumnLayout {
                    spacing: 8
                    Text { text: "水平滚动"; font.pixelSize: 12; color: EasyTheme.color.secondary }
                    Rectangle {
                        Layout.preferredWidth: 300; Layout.preferredHeight: 60
                        radius: EasyTheme.size.radius; color: EasyTheme.color.card
                        border.color: EasyTheme.color.border; border.width: 1
                        ScrollView {
                            anchors.fill: parent; anchors.margins: 12; clip: true
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                            ScrollBar.horizontal: EasyScrollBar { }
                            Row {
                                spacing: 8; height: 30
                                Repeater {
                                    model: 30
                                    delegate: Rectangle {
                                        width: 40; height: 30; radius: 6; color: EasyTheme.color.primary
                                        Text { anchors.centerIn: parent; text: index + 1; font.pixelSize: 11; color: "white" }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Both
            Text { text: "双向滚动"; font.pixelSize: 12; color: EasyTheme.color.secondary }
            Rectangle {
                Layout.preferredWidth: 400; Layout.preferredHeight: 200
                radius: EasyTheme.size.radius; color: EasyTheme.color.card
                border.color: EasyTheme.color.border; border.width: 1
                ScrollView {
                    anchors.fill: parent; anchors.margins: 12; clip: true
                    ScrollBar.vertical: EasyScrollBar { }
                    ScrollBar.horizontal: EasyScrollBar { }
                    Grid {
                        columns: 12; spacing: 4; width: 600; height: 400
                        Repeater {
                            model: 120
                            delegate: Rectangle {
                                width: 40; height: 40; radius: 6
                                color: index % 3 === 0 ? EasyTheme.color.primary : index % 3 === 1 ? EasyTheme.color.success : EasyTheme.color.warning
                            }
                        }
                    }
                }
            }
        }

        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

        Text { text: "用法"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }

        ColumnLayout {
            spacing: 8; width: parent.width
            Text {
                font.pixelSize: 12; font.family: "Consolas, Monaco, monospace"; color: EasyTheme.color.secondary; lineHeight: 1.5
                text: "```qml\nScrollView {\n    ScrollBar.vertical: EasyScrollBar { }\n    ScrollBar.horizontal: EasyScrollBar { }\n    // content...\n}\n```"
            }
            Text {
                font.pixelSize: 12; color: EasyTheme.color.placeholder; lineHeight: 1.6
                text: "• 6px 默认 / 10px hover 展开\n• 圆角矩形 thumb 半透明灰\n• expandOnHover: false 可禁用展开\n• 自动锚定到 ScrollView 边缘"
            }
        }
    }
}
