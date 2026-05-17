import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

/**
 * TransferPanel —— 穿梭框面板
 */
Rectangle {
    id: root

    property string title: ""
    property bool searchable: true
    property alias listView: listView
    property string filterText: ""
    property int panelFontSize: EasyTheme.size.fontSizeNormal
    property int panelSmallFontSize: EasyTheme.size.fontSizeSmall

    signal filterChanged(string text)

    radius: EasyTheme.size.radius
    color: EasyTheme.color.card
    border.color: EasyTheme.color.border
    border.width: EasyTheme.size.borderWidth

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: EasyTheme.size.radius
            color: EasyTheme.color.hover

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.radius
                color: parent.color
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: EasyTheme.size.paddingNormal
                anchors.rightMargin: EasyTheme.size.paddingSmall
                spacing: EasyTheme.size.paddingSmall

                Text {
                    text: root.title
                    font.pixelSize: root.panelFontSize
                    font.bold: true
                    font.family: EasyTheme.font.family
                    color: EasyTheme.color.text
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                TextField {
                    visible: root.searchable
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 26
                    font.pixelSize: root.panelSmallFontSize
                    font.family: EasyTheme.font.family
                    placeholderText: "搜索"
                    placeholderTextColor: EasyTheme.color.placeholder
                    color: EasyTheme.color.text
                    leftPadding: 6
                    rightPadding: 6
                    topPadding: 0
                    bottomPadding: 0
                    background: Rectangle {
                        radius: EasyTheme.size.radiusSmall
                        color: EasyTheme.color.background
                        border.color: parent.activeFocus ? EasyTheme.color.primary : EasyTheme.color.border
                        border.width: parent.activeFocus ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth

                        Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
                        Behavior on border.width { NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
                    }
                    onTextChanged: root.filterChanged(text)
                }
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            leftMargin: EasyTheme.size.paddingSmall
            rightMargin: EasyTheme.size.paddingSmall
            topMargin: EasyTheme.size.paddingSmall
            bottomMargin: EasyTheme.size.paddingSmall
            ScrollBar.vertical: EasyScrollBar { }

            Text {
                anchors.centerIn: parent
                visible: listView.model === 0
                text: "暂无数据"
                font.pixelSize: root.panelSmallFontSize
                font.family: EasyTheme.font.family
                color: EasyTheme.color.placeholder
            }
        }
    }
}