import QtQuick
import QtQuick.Controls.Basic
import EasyUI

Rectangle {
    id: root

    property var chips: []
    property alias text: inputField.text
    property string placeholder: "输入后按 Enter 添加"
    property int size: EasyTheme.size.sizeNormal
    property int maxChips: 20
    property bool allowDuplicates: false
    property bool readOnly: false

    signal chipAdded(string text)
    signal chipRemoved(int index, string text)
    signal chipAccepted(string text)

    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 28
        case EasyTheme.size.sizeSmall:  return 32
        case EasyTheme.size.sizeLarge:  return 44
        default:                        return 36
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge
        default:                        return EasyTheme.size.fontSizeNormal
        }
    }
    readonly property int computedChipHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 22
        case EasyTheme.size.sizeSmall:  return 26
        case EasyTheme.size.sizeLarge:  return 34
        default:                        return 28
        }
    }
    readonly property int computedChipFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 11
        case EasyTheme.size.sizeSmall:  return 12
        case EasyTheme.size.sizeLarge:  return 14
        default:                        return 13
        }
    }

    readonly property real _contentHeight: chipFlow.implicitHeight + (inputRow.visible ? inputRow.height + 8 : 0) + 16
    height: Math.max(computedHeight, _contentHeight)
    implicitHeight: Math.max(computedHeight, _contentHeight)
    implicitWidth: 300
    radius: EasyTheme.size.radius
    color: EasyTheme.color.card
    border.color: inputField.activeFocus ? EasyTheme.color.primary : EasyTheme.color.border
    border.width: inputField.activeFocus ? 1.5 : 1
    clip: true

    Behavior on border.color { ColorAnimation { duration: 150 } }
    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    function _addChip(txt) {
        if (!txt || root.chips.length >= root.maxChips) return
        if (!root.allowDuplicates && _hasChip(txt)) return
        var arr = root.chips.slice()
        arr.push({ text: txt })
        root.chips = arr
        root.chipAdded(txt)
        root.chipAccepted(txt)
    }

    function _removeChip(idx) {
        if (idx < 0 || idx >= root.chips.length) return
        var arr = root.chips.slice()
        var removed = arr.splice(idx, 1)
        root.chips = arr
        root.chipRemoved(idx, removed[0].text)
    }

    function _hasChip(txt) {
        for (var i = 0; i < root.chips.length; i++)
            if (root.chips[i].text === txt) return true
        return false
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 8
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        ScrollBar.vertical: EasyScrollBar { }

        Column {
            id: contentColumn
            width: flickable.width
            spacing: 6

            Flow {
                id: chipFlow
                width: parent.width
                spacing: 5

                Repeater {
                    model: root.chips
                    delegate: Rectangle {
                        height: root.computedChipHeight
                        radius: height / 2
                        color: EasyTheme.isDark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.04)
                        border.color: EasyTheme.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)
                        border.width: 1

                        width: {
                            var w = chipLabel.implicitWidth + chipDot.width + chipLeftPad + chipRightPad
                            if (removeBtn.visible) w += removeBtn.width + removeBtnSpacing
                            return w
                        }

                        readonly property int chipLeftPad: 11
                        readonly property int chipRightPad: removeBtn.visible ? 8 : 12
                        readonly property int removeBtnSpacing: 2

                        Rectangle {
                            id: chipDot
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: parent.chipLeftPad
                            width: 6; height: 6; radius: 3
                            color: modelData.color !== undefined ? modelData.color : EasyTheme.color.primary
                        }

                        Text {
                            id: chipLabel
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: chipDot.right
                            anchors.leftMargin: 5
                            text: modelData.text
                            font.pixelSize: root.computedChipFontSize
                            color: EasyTheme.color.text
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Rectangle {
                            id: removeBtn
                            visible: !root.readOnly
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: chipLabel.right
                            anchors.leftMargin: removeBtnSpacing
                            width: removeBtn.visible ? (root.computedChipHeight - 8) : 0
                            height: width
                            radius: width / 2
                            color: removeMouse.containsMouse ? Qt.rgba(EasyTheme.color.colorError.r, EasyTheme.color.colorError.g, EasyTheme.color.colorError.b, 0.15) : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } }

                            EasyIconFont {
                                anchors.centerIn: parent
                                icon: EasyIcon.material.close
                                iconSize: root.computedChipHeight - 14
                                color: removeMouse.containsMouse ? EasyTheme.color.colorError : EasyTheme.color.placeholder
                            }

                            MouseArea {
                                id: removeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._removeChip(index)
                            }
                        }
                    }
                }
            }

            Row {
                id: inputRow
                visible: !root.readOnly && root.chips.length < root.maxChips
                width: parent.width
                height: root.computedHeight

                TextInput {
                    id: inputField
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    font.pixelSize: root.computedFontSize
                    color: EasyTheme.color.text
                    enabled: !root.readOnly && root.chips.length < root.maxChips
                    selectByMouse: true

                    Text {
                        anchors.fill: parent
                        text: root.placeholder
                        font.pixelSize: root.computedFontSize
                        color: EasyTheme.color.placeholder
                        visible: inputField.text === "" && !inputField.activeFocus
                    }

                    Keys.onReturnPressed: function(event) {
                        event.accepted = true
                        root._addChip(text.trim())
                        text = ""
                    }
                }
            }
        }
    }
}