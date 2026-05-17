import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

Rectangle {
    id: root

    property var model: []
    property var selectedPath: []
    property string placeholder: "请选择"
    property bool enabled: true
    property int size: EasyTheme.size.sizeNormal
    property bool dropUpWhenNearBottom: true
    property string displayField: "label"
    property string valueField: "value"
    property string childrenField: "children"
    property int popupWidth: 180
    property int popupHeight: 240
    property bool changeOnSelect: false  // true = select on any click; false = only leaf

    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.heightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.heightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.heightLarge
        default:                        return EasyTheme.size.heightNormal
        }
    }
    readonly property int computedPadding: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 8
        case EasyTheme.size.sizeSmall:  return 10
        case EasyTheme.size.sizeLarge:  return 14
        default:                        return 12
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

    readonly property string _displayText: {
        if (selectedPath.length === 0) return ""
        var parts = []
        for (var i = 0; i < selectedPath.length; i++)
            parts.push(selectedPath[i][displayField] || "")
        return parts.join(" / ")
    }

    property var _columns: []
    property bool _popupOpen: false

    function openPopup() {
        rebuildColumns()
        _popupOpen = true
    }

    function closePopup() {
        _popupOpen = false
        _columns = []
    }

    function rebuildColumns() {
        var cols = [model]
        for (var i = 0; i < selectedPath.length; i++) {
            var parentCol = cols[i]
            var found = null
            for (var j = 0; j < parentCol.length; j++) {
                if (parentCol[j][valueField] === selectedPath[i][valueField]) {
                    found = parentCol[j]
                    break
                }
            }
            if (found && found[childrenField] && found[childrenField].length > 0)
                cols.push(found[childrenField])
            else
                break
        }
        _columns = cols
    }

    implicitWidth: 220
    height: computedHeight
    radius: EasyTheme.size.radius
    color: EasyTheme.color.card
    border.color: root._popupOpen ? EasyTheme.color.primary : (_hover.hovered ? Qt.darker(EasyTheme.color.border, 1.12) : EasyTheme.color.border)
    border.width: root._popupOpen ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth

    HoverHandler { id: _hover; enabled: root.enabled }

    Behavior on border.color {
        ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease }
    }
    Behavior on border.width {
        NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease }
    }

    Text {
        anchors.left: parent.left;  anchors.leftMargin: computedPadding
        anchors.right: arrow.left;  anchors.rightMargin: computedPadding
        anchors.verticalCenter: parent.verticalCenter
        text: _displayText || root.placeholder
        font.pixelSize: computedFontSize
        color: _displayText ? EasyTheme.color.text : EasyTheme.color.placeholder
        elide: Text.ElideRight
    }

    EasyIconFont {
        id: arrow
        anchors.right: parent.right; anchors.rightMargin: computedPadding
        anchors.verticalCenter: parent.verticalCenter
        icon: EasyIcon.material.arrow_drop_down
        iconSize: computedFontSize + 4
        color: EasyTheme.color.placeholder
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            if (root._popupOpen) { root.closePopup(); return }
            root.openPopup()
        }
    }

    Popup {
        id: cascaderPopup
        visible: root._popupOpen
        y: {
            var globalPos = root.mapToItem(Overlay.overlay, 0, 0)
            var globalBottomY = globalPos.y + root.height
            var overlayHeight = Overlay.overlay ? Overlay.overlay.height : 600
            var totalHeight = popupHeight + 12
            if (dropUpWhenNearBottom && (globalBottomY + totalHeight) > overlayHeight)
                return -(totalHeight)
            return root.height + 4
        }
        width: popupWidth * Math.max(1, root._columns.length)
        height: popupHeight
        padding: 8
        modal: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        onVisibleChanged: { if (!visible) root._popupOpen = false }

        background: Rectangle {
            radius: EasyTheme.size.radius
            color: EasyTheme.color.card
            border.width: 0.5
            border.color: EasyTheme.color.divider

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: EasyTheme.isDark ? "#60000000" : "#30000000"
                shadowBlur: 0.5
                shadowVerticalOffset: 2
                shadowHorizontalOffset: 2
            }
        }

        contentItem: RowLayout {
            spacing: 0

            Repeater {
                model: root._columns.length

                delegate: Rectangle {
                    readonly property int colIdx: index

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    clip: true

                    Rectangle {
                        visible: colIdx > 0
                        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                        width: 1
                        color: EasyTheme.color.divider
                    }

                    ScrollView {
                        anchors.fill: parent
                        ScrollBar.vertical: EasyScrollBar { }
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        Column {
                            id: col
                            width: parent.width
                            spacing: 4

                            property var _root: root
                            property int _colIdx: colIdx
                            property var columnData: _root._columns[_colIdx]

                            function selectItem(itemData, hasChildren) {
                                var newPath = _root.selectedPath.slice(0, _colIdx)
                                var entry = {}
                                entry[_root.displayField] = itemData[_root.displayField]
                                entry[_root.valueField] = itemData[_root.valueField]
                                newPath.push(entry)
                                _root.selectedPath = newPath
                                if (hasChildren && !_root.changeOnSelect) {
                                    _root.rebuildColumns()
                                } else {
                                    _root.closePopup()
                                    _root.pathSelected(newPath)
                                }
                            }

                            Repeater {
                                model: parent.columnData || []

                                delegate: Rectangle {
                                    width: popupWidth - 14
                                    height: 36
                                    radius: 6
                                    color: {
                                        if (isActive) return EasyTheme.color.primary
                                        if (itemHover.containsMouse) return EasyTheme.color.menuHover
                                        return "transparent"
                                    }
                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    property var itemData: modelData
                                    property var colRef: parent
                                    property bool hasChildren: {
                                        if (!itemData) return false
                                        var c = itemData[colRef._root.childrenField]
                                        return !!(c && c.length)
                                    }
                                    property bool isActive: {
                                        if (!itemData) return false
                                        var cIdx = colRef._colIdx
                                        var sel = colRef._root.selectedPath.length > cIdx ? colRef._root.selectedPath[cIdx] : null
                                        return sel ? sel[colRef._root.valueField] === itemData[colRef._root.valueField] : false
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Label {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            text: itemData ? (itemData[colRef._root.displayField] || "") : ""
                                            font.pixelSize: 13
                                            color: isActive ? "white" : EasyTheme.color.text
                                            elide: Text.ElideRight
                                        }

                                        EasyIconFont {
                                            visible: hasChildren
                                            Layout.alignment: Qt.AlignVCenter
                                            icon: EasyIcon.material.keyboard_arrow_right
                                            iconSize: 18
                                            color: EasyTheme.color.secondary
                                        }
                                    }

                                    MouseArea {
                                        id: itemHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: parent.parent.selectItem(itemData, hasChildren)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    signal pathSelected(var path)
}
