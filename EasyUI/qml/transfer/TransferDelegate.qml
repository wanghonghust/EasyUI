import QtQuick
import QtQuick.Layouts
import EasyUI

/**
 * TransferDelegate —— 穿梭框列表项委托
 */
Rectangle {
    id: root

    property bool selected: false
    property string label: ""
    property int itemHeight: 36
    property int itemFontSize: EasyTheme.size.fontSizeSmall

    signal clicked()

    width: ListView.view ? ListView.view.width : 0
    height: itemHeight
    radius: EasyTheme.size.radiusSmall
    color: selected ? EasyTheme.color.selection
                    : (hoverArea.containsMouse ? EasyTheme.color.menuHover : EasyTheme.color.transparent)

    Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: EasyTheme.size.paddingSmall
        anchors.rightMargin: EasyTheme.size.paddingSmall
        spacing: EasyTheme.size.paddingSmall

        Rectangle {
            width: 16
            height: 16
            radius: 3
            color: root.selected ? EasyTheme.color.primary : EasyTheme.color.transparent
            border.color: root.selected ? EasyTheme.color.primary : (hoverArea.containsMouse ? EasyTheme.color.primary : EasyTheme.color.border)
            border.width: root.selected ? 0 : EasyTheme.size.borderWidth

            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
            Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.fast } }

            Text {
                anchors.centerIn: parent
                text: "✓"
                font.pixelSize: 10
                font.bold: true
                color: EasyTheme.color.white
                visible: root.selected
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            font.pixelSize: root.itemFontSize
            font.family: EasyTheme.font.family
            color: root.selected ? EasyTheme.color.primary : EasyTheme.color.text
            elide: Text.ElideRight

            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}