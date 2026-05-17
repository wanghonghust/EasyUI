import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

/**
 * EasyTransfer —— 穿梭框组件
 *
 * 属性：
 *   sourceItems    {list<var>}    左侧源数据列表 [{label, value}]
 *   targetItems    {list<var>}    右侧目标数据列表（选中项）
 *   titleLeft      {string}       左侧标题，默认 "源列表"
 *   titleRight     {string}       右侧标题，默认 "目标列表"
 *   itemHeight     {int}          每项高度，默认 36
 *   searchable     {bool}         是否可搜索，默认 true
 *   size           {int}          控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *
 * 信号：
 *   changed()                     数据变化时触发
 */
Rectangle {
    id: root

    property var sourceItems: []
    property var targetItems: []
    property string titleLeft: "源列表"
    property string titleRight: "目标列表"
    property int itemHeight: 36
    property bool searchable: true
    property int size: EasyTheme.size.sizeNormal

    implicitWidth: 520
    implicitHeight: 320
    radius: EasyTheme.size.radiusLarge
    color: EasyTheme.color.transparent

    signal changed()

    property var leftSelectedIndices: []
    property var rightSelectedIndices: []
    property string leftFilter: ""
    property string rightFilter: ""

    readonly property int computedItemHeight: {
        switch (size) {
        case EasyTheme.size.sizeSmall:  return 28
        case EasyTheme.size.sizeLarge:  return 44
        default:                        return 36
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge
        default:                        return EasyTheme.size.fontSizeNormal
        }
    }
    readonly property int computedSmallFontSize: {
        switch (size) {
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeNormal
        default:                        return EasyTheme.size.fontSizeSmall
        }
    }

    property var filteredSourceItems: {
        var result = []
        for (var i = 0; i < sourceItems.length; i++) {
            var item = sourceItems[i]
            if (!isTransferred(item.value) && matchesFilter(item.label, leftFilter))
                result.push(item)
        }
        return result
    }

    property var filteredTargetItems: {
        var result = []
        for (var i = 0; i < targetItems.length; i++) {
            var item = targetItems[i]
            if (matchesFilter(item.label, rightFilter))
                result.push(item)
        }
        return result
    }

    function matchesFilter(label, filter) {
        return filter === "" || label.toLowerCase().indexOf(filter.toLowerCase()) >= 0
    }

    function isTransferred(value) {
        for (var i = 0; i < targetItems.length; i++)
            if (targetItems[i].value === value) return true
        return false
    }

    RowLayout {
        anchors.fill: parent
        spacing: EasyTheme.size.paddingNormal

        TransferPanel {
            id: leftPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.titleLeft + " (" + filteredSourceItems.length + ")"
            searchable: root.searchable
            filterText: root.leftFilter
            panelFontSize: root.computedFontSize
            panelSmallFontSize: root.computedSmallFontSize
            onFilterChanged: { root.leftFilter = text; root.leftSelectedIndices = [] }
            listView.model: filteredSourceItems.length
            listView.delegate: TransferDelegate {
                selected: root.leftSelectedIndices.indexOf(index) >= 0
                label: filteredSourceItems[index].label
                itemHeight: root.computedItemHeight
                itemFontSize: root.computedSmallFontSize
                onClicked: toggleSelection(root.leftSelectedIndices, index, sel => root.leftSelectedIndices = sel)
            }
        }

        TransferButtons {
            Layout.alignment: Qt.AlignVCenter
            canMoveRight: root.leftSelectedIndices.length > 0
            canMoveLeft: root.rightSelectedIndices.length > 0
            onMoveRight: root.moveToRight()
            onMoveLeft: root.moveToLeft()
        }

        TransferPanel {
            id: rightPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: root.titleRight + " (" + filteredTargetItems.length + ")"
            searchable: root.searchable
            filterText: root.rightFilter
            panelFontSize: root.computedFontSize
            panelSmallFontSize: root.computedSmallFontSize
            onFilterChanged: { root.rightFilter = text; root.rightSelectedIndices = [] }
            listView.model: filteredTargetItems.length
            listView.delegate: TransferDelegate {
                selected: root.rightSelectedIndices.indexOf(index) >= 0
                label: filteredTargetItems[index].label
                itemHeight: root.computedItemHeight
                itemFontSize: root.computedSmallFontSize
                onClicked: toggleSelection(root.rightSelectedIndices, index, sel => root.rightSelectedIndices = sel)
            }
        }
    }

    function toggleSelection(arr, index, setter) {
        var idx = arr.indexOf(index)
        var copy = arr.slice()
        if (idx >= 0) copy.splice(idx, 1)
        else copy.push(index)
        setter(copy)
    }

    function moveToRight() {
        if (leftSelectedIndices.length === 0) return
        var newTarget = targetItems.slice()
        for (var i = 0; i < leftSelectedIndices.length; i++) {
            var item = filteredSourceItems[leftSelectedIndices[i]]
            newTarget.push({ label: item.label, value: item.value })
        }
        targetItems = newTarget
        leftSelectedIndices = []
        changed()
    }

    function moveToLeft() {
        if (rightSelectedIndices.length === 0) return
        var valuesToRemove = []
        for (var i = 0; i < rightSelectedIndices.length; i++)
            valuesToRemove.push(filteredTargetItems[rightSelectedIndices[i]].value)

        var newTarget = []
        for (var j = 0; j < targetItems.length; j++)
            if (valuesToRemove.indexOf(targetItems[j].value) < 0)
                newTarget.push(targetItems[j])

        targetItems = newTarget
        rightSelectedIndices = []
        changed()
    }

    function getTargetValues() {
        return targetItems.map(function(item) { return item.value })
    }

    function getTargetLabels() {
        return targetItems.map(function(item) { return item.label })
    }

    function clearSelection() {
        leftSelectedIndices = []
        rightSelectedIndices = []
    }
}