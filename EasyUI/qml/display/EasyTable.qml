import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

/**
 * EasyTable —— 纯 QML 表格组件
 *
 * 属性：
 *   columns        {list}    列定义数组，每个元素包含 title, key, width, align
 *   tableData      {list}    表格数据数组（对象数组）
 *   delegate       {Component} 自定义单元格渲染组件，不设置时默认 Text。
 *                             delegate 可用属性：columnData(列定义), rowData(整行数据), value(当前单元格值)
 *   selectable     {bool}    是否支持行选择（单击高亮），默认 false
 *   sortable       {bool}    是否支持列排序，默认 false
 *   stripe         {bool}    是否显示斑马纹，默认 true
 *   hoverHighlight {bool}    是否高亮hover行，默认 true
 *   rowBorder      {bool}    是否显示行分隔线，默认 false
 *   headerColor    {color}   表头背景色，默认 primary
 *   maxHeight      {real}    最大高度，默认 -1（不限制）
 *   rowHeight      {real}    行高，默认 36
 *   expandable     {bool}    是否支持子项展开，默认 false
 *   childrenProperty {string} 子项属性名，默认 "children"
 *
 * 信号：
 *   rowClicked(int index, var rowData)      行点击
 *   rowDoubleClicked(int index, var rowData) 行双击
 *   selectionChanged(var selectedIndices)   选择变化
 *   sortChanged(string key, bool ascending) 排序变化
 *
 * 内部属性：
 *   selectedRows    选中的行索引数组（只读）
 *   sortKey         当前排序列 key
 *   sortAscending   是否升序
 */
Rectangle {
    id: root
    width: parent ? parent.width : 400

    property var columns: []
    property var tableData: []
    property Component delegate: null
    property bool selectable: false
    property bool sortable: false
    property bool stripe: true
    property bool hoverHighlight: true
    property bool rowBorder: false
    property color headerColor: EasyTheme.color.background
    property color rowColor: EasyTheme.color.card
    property color altRowColor: EasyTheme.color.tableStrip
    property real maxHeight: -1
    property real rowHeight: 36

    // 分页
    property bool pagination: false
    property int pageSize: 10
    property int currentPage: 1

    // 子项展开
    property bool expandable: false
    property string childrenProperty: "children"

    implicitHeight: height

    readonly property var selectedRows: _selectedSet
    property string sortKey: ""
    property bool sortAscending: true

    signal rowClicked(int index, var rowData)
    signal rowDoubleClicked(int index, var rowData)
    signal selectionChanged(var selectedIndices)
    signal sortChanged(string key, bool ascending)
    signal pageChanged(int page)

    // 列内左右边距
    property real cellPadding: 12

    // 内部状态
    property var _selectedSet: ({})
    property var _expandedSet: ({})
    property var _refreshToken: 0
    property var _sortedData: {
        var token = _refreshToken; // 依赖刷新令牌
        if (!sortKey || !sortable) return tableData;
        var data = tableData.slice();
        data.sort(function(a, b) {
            var va = a[sortKey], vb = b[sortKey];
            if (va === vb) return 0;
            if (va === undefined || va === null) return 1;
            if (vb === undefined || vb === null) return -1;
            // 数字比较
            if (typeof va === 'number' && typeof vb === 'number') {
                return sortAscending ? va - vb : vb - va;
            }
            // 字符串比较
            var sa = String(va), sb = String(vb);
            var cmp = sa.localeCompare(sb);
            return sortAscending ? cmp : -cmp;
        });
        return data;
    }

    // 分页后的数据
    readonly property var _pagedData: {
        if (!pagination) return _sortedData;
        var start = (currentPage - 1) * pageSize;
        var end = start + pageSize;
        return _sortedData.slice(start, end);
    }

    // 总页数
    readonly property int totalPage: {
        if (!pagination || !tableData || tableData.length === 0) return 1;
        return Math.ceil(tableData.length / pageSize);
    }

    // 展开后的扁平化数据（将展开的子行插入到父行后面）
    readonly property var _displayData: {
        var token = _refreshToken;
        var source = _pagedData;
        if (!root.expandable) return source;

        var es = root._expandedSet;
        var result = [];
        var cp = root.childrenProperty;

        function flatten(nodes, depth, keyPrefix) {
            for (var i = 0; i < nodes.length; i++) {
                var key = keyPrefix + i;
                var node = nodes[i];
                var children = node[cp];
                var hasChildren = children instanceof Array && children.length > 0;

                result.push({
                    _rowData: node,
                    _depth: depth,
                    _hasChildren: hasChildren,
                    _isExpanded: es[key] === true,
                    _key: key
                });

                if (hasChildren && es[key] === true) {
                    flatten(children, depth + 1, key + "_");
                }
            }
        }

        flatten(source, 0, "");
        return result;
    }

    height: {
        var bodyH;
        if (pagination && !expandable) {
            bodyH = pageSize * root.rowHeight;
        } else {
            bodyH = rowRepeater.count * root.rowHeight;
        }
        var contentH = bodyH + headerRect.height + (paginationBar.visible ? 44 : 0);
        return maxHeight > 0 ? Math.min(maxHeight, contentH) : contentH;
    }
    Behavior on height { NumberAnimation { duration: 150 } }
    color: EasyTheme.color.card
    clip: true

    // ===== 表头与内容之间的分隔线 =====
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerRect.bottom
        height: 1
        color: EasyTheme.color.border
    }
    // ===== 表头 =====
    Rectangle {
        id: headerRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.rowHeight
        color: root.headerColor

        Row {
            id: headerRow
            anchors.fill: parent
            anchors.leftMargin: 1
            anchors.rightMargin: 1

            // 展开图标占位(与数据行对齐)
            Item {
                width: root.expandable ? 24 : 0
                height: headerRect.height
            }

            Repeater {
                model: root.columns

                Rectangle {
                    width: modelData.width > 0 ? modelData.width : (headerRow.width - _totalFixedWidth - (root.expandable ? 24 : 0)) / Math.max(1, _autoColCount)
                    height: headerRect.height
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: root.cellPadding
                        anchors.rightMargin: root.cellPadding
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: modelData.title || ""
                            color: EasyTheme.color.text
                            font.bold: true
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        // 排序指示器
                        Text {
                            visible: root.sortable
                            text: root.sortKey === modelData.key
                                  ? (root.sortAscending ? " ▲" : " ▼")
                                  : ""
                            color: EasyTheme.color.text
                            font.pixelSize: 10
                            opacity: root.sortKey === modelData.key ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }

                    // 排序点击区域
                    MouseArea {
                        anchors.fill: parent
                        visible: root.sortable
                        cursorShape: root.sortable ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (root.sortKey === modelData.key) {
                                root.sortAscending = !root.sortAscending;
                            } else {
                                root.sortKey = modelData.key;
                                root.sortAscending = true;
                            }
                            root.sortChanged(root.sortKey, root.sortAscending);
                        }
                    }
                }
            }
        }
    }

    // ===== 表头与内容之间的分隔线 =====
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerRect.bottom
        height: 1
        color: EasyTheme.color.border
    }

    // ===== 表体 =====
    ScrollView {
        id: scrollView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerRect.bottom
        anchors.bottom: paginationBar.visible ? paginationBar.top : parent.bottom
        clip: true
        contentWidth: availableWidth
        contentHeight: rowRepeater.count * root.rowHeight

        ScrollBar.vertical: EasyScrollBar { }


        // 内容区域
        Item {
            id: contentArea
            width: scrollView.contentWidth
            height: scrollView.contentHeight

            Repeater {
                id: rowRepeater
                model: root._displayData

                Rectangle {
                    id: rowRect
                    width: contentArea.width
                    height: root.rowHeight
                    y: index * root.rowHeight
                    color: rowMouse.containsMouse && root.hoverHighlight
                           ? EasyTheme.color.hover
                           : (root._selectedSet[index] === true
                              ? (EasyTheme.isDark ? Qt.rgba(0.32, 0.51, 1.0, 0.15) : Qt.rgba(0.32, 0.51, 1.0, 0.08))
                              : (!root.stripe
                                 ? root.rowColor
                                 : (index % 2 === 0 ? root.rowColor : root.altRowColor)))

                    // 行数据
                    property var rowData: root.expandable ? (modelData._rowData || modelData) : modelData
                    property var _depth: root.expandable ? (modelData._depth !== undefined ? modelData._depth : 0) : 0
                    property var _hasChildren: root.expandable ? (modelData._hasChildren || false) : false
                    property var _isExpanded: root.expandable ? (modelData._isExpanded || false) : false
                    property var _expandKey: root.expandable ? (modelData._key || "") : ""

                    // 行点击高亮
                    property bool _isSelected: root.selectable && root._selectedSet[index] === true

                    // 提前捕获 root 引用，供 JS 信号处理器使用
                    property var tableRoot: root

                    // 左侧选中指示条
                    Rectangle {
                        width: 3
                        height: parent.height
                        color: EasyTheme.color.primary
                        visible: rowRect._isSelected
                    }

                    // 行分隔线
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: EasyTheme.color.border
                        visible: root.rowBorder
                    }

                    // 点击与 hover（置于底层，不拦截 delegate 事件）
                    MouseArea {
                        id: rowMouse
                        z: 0
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var tr = rowRect.tableRoot
                            if (tr.selectable) {
                                var set = tr._selectedSet;
                                if (set[index]) {
                                    delete set[index];
                                } else {
                                    set[index] = true;
                                }
                                tr._selectedSet = set;
                                tr.selectionChanged(Object.keys(set).map(Number));
                            }
                            tr.rowClicked(index, rowRect.rowData);
                        }
                        onDoubleClicked: rowRect.tableRoot.rowDoubleClicked(index, rowRect.rowData)
                    }

                    // 各列（含展开图标）
                    Row {
                        id: dataRow
                        anchors.fill: parent
                        anchors.leftMargin: 1
                        z: 1

                        // 缩进间距（子行缩进）
                        Item {
                            width: root.expandable ? rowRect._depth * 24 : 0
                            height: root.rowHeight
                        }

                        // 展开/折叠图标（始终占位 24px 以保持对齐）
                        Item {
                            width: root.expandable ? 24 : 0
                            height: root.rowHeight

                            EasyIconFont {
                                anchors.centerIn: parent
                                visible: rowRect._hasChildren
                                icon: rowRect._isExpanded ? EasyIcon.material.keyboard_arrow_down : EasyIcon.material.keyboard_arrow_right
                                iconSize: 18
                                color: EasyTheme.color.text
                            }

                            MouseArea {
                                anchors.fill: parent
                                visible: rowRect._hasChildren
                                cursorShape: rowRect._hasChildren ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    var key = rowRect._expandKey;
                                    var set = root._expandedSet;
                                    if (set[key]) {
                                        delete set[key];
                                    } else {
                                        set[key] = true;
                                    }
                                    root._expandedSet = set;
                                    root._refreshToken++;
                                }
                            }
                        }

                        Repeater {
                            model: root.columns

                            Item {
                                clip: true
                                x: modelData.width > 0 ? 0 : 0
                                width: modelData.width > 0 ? modelData.width : ((dataRow.width - root._totalFixedWidth - (root.expandable ? (rowRect._depth * 24 + 24) : 0)) / Math.max(1, root._autoColCount))
                                height: root.rowHeight

                                // 自定义 delegate
                                Loader {
                                    x: root.cellPadding
                                    width: parent.width - root.cellPadding * 2
                                    height: root.rowHeight
                                    visible: root.delegate !== null
                                    sourceComponent: root.delegate
                                    property var columnData: modelData
                                    property var rowData: rowRect.rowData
                                    property var value: {
                                        var val = modelData.key !== undefined ? rowRect.rowData[modelData.key] : "";
                                        return val !== undefined && val !== null ? val : "";
                                    }
                                }

                                // 默认 Text
                                Text {
                                    x: root.cellPadding
                                    width: parent.width - root.cellPadding * 2
                                    height: root.rowHeight
                                    visible: root.delegate === null
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: modelData.align || Text.AlignLeft
                                    text: {
                                        var val = modelData.key !== undefined ? rowRect.rowData[modelData.key] : "";
                                        return val !== undefined && val !== null ? String(val) : "";
                                    }
                                    color: EasyTheme.color.text
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }

        // 空数据提示
        Text {
            visible: root.tableData && root.tableData.length === 0
            anchors.centerIn: parent
            text: "暂无数据"
            font.pixelSize: 13
            color: EasyTheme.color.placeholder
            z: 1
        }
    }

    RowLayout {
        id: paginationBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        visible: root.pagination && root.tableData && root.tableData.length > 0
        height: visible ? 32 : 0

        // 统计信息
        Text {
            text: {
                var total = root.tableData ? root.tableData.length : 0;
                var start = total === 0 ? 0 : (root.currentPage - 1) * root.pageSize + 1;
                var end = Math.min(root.currentPage * root.pageSize, total);
                return "共 " + total + " 条 | 第 " + start + " - " + end + " 条";
            }
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        EasyPagination {
            currentPage: root.currentPage
            totalPage: root.totalPage
            pageSize: root.pageSize
            totalCount: root.tableData ? root.tableData.length : 0
            size: EasyTheme.size.sizeSmall
            onPageChanged: function(page) {
                root.currentPage = page
                root.pageChanged(page)
            }
        }
    }

    // ===== 工具函数 =====

    // 计算固定宽度列的总宽度
    readonly property real _totalFixedWidth: {
        var total = 0;
        for (var i = 0; i < columns.length; i++) {
            if (columns[i].width > 0) total += columns[i].width;
        }
        return total;
    }

    // 未设置宽度的列数量
    readonly property int _autoColCount: {
        var count = 0;
        for (var i = 0; i < columns.length; i++) {
            if (!columns[i].width || columns[i].width <= 0) count++;
        }
        return count;
    }

    // 供 delegate 内部修改行数据后调用，强制刷新表格
    function refresh() {
        _refreshToken++
    }
}
