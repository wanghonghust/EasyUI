import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI


/**
 * EasyPagination —— 分页器
 *
 * 属性：
 *   currentPage    {int}       当前页码，从 1 开始
 *   totalPage      {int}       总页数
 *   pageSize       {int}       每页条数，可选
 *   totalCount     {int}       总条数，可选
 *   visiblePages   {int}       可见页码数量，默认 5
 *   size           {int}       控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *   showFirstLast  {bool}      显示首尾页跳转按钮，默认 true
 *   showJump       {bool}      显示页码跳转输入框，默认 true
 *   showPageSizeSelector {bool} 显示每页条数选择器，默认 false
 *   pageSizeOptions {list}     每页条数可选值，默认 [10, 20, 50, 100]
 *
 * 信号：
 *   pageChanged(int page)          页码变化
 *   pageSizeUpdated(int size)      每页条数变化
 */
Item {
    id: root

    property int currentPage: 1
    property int totalPage: 1
    property int pageSize: 10
    property int totalCount: 0
    property int visiblePages: 5
    property int size: EasyTheme.size.sizeNormal

    // 首尾页 & 跳转 & 每页条数
    property bool showFirstLast: true
    property bool showJump: true
    property bool showPageSizeSelector: false
    property var pageSizeOptions: [10, 20, 50, 100]

    // 根据 size 计算控件尺寸
    readonly property int computedBtnSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:
            return 26
        case EasyTheme.size.sizeSmall:
            return 28
        case EasyTheme.size.sizeLarge:
            return 40
        default:
            return 32
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:
            return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:
            return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:
            return EasyTheme.size.fontSizeLarge
        default:
            return EasyTheme.size.fontSizeNormal
        }
    }
    readonly property int computedArrowSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:
            return 14
        case EasyTheme.size.sizeSmall:
            return 15
        case EasyTheme.size.sizeLarge:
            return 20
        default:
            return 16
        }
    }

    signal pageChanged(int page)
    signal pageSizeUpdated(int size)

    implicitWidth: row.implicitWidth
    implicitHeight: computedBtnSize

    function _setPage(page) {
        if (page >= 1 && page <= totalPage) {
            currentPage = page
            pageChanged(page)
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // ===== 首页 =====
        Rectangle {
            width: root.computedBtnSize
            height: root.computedBtnSize
            radius: 6
            visible: root.showFirstLast && root.totalPage > 0
            color: root.currentPage <= 1 ? "transparent" : EasyTheme.color.card
            border.color: root.currentPage <= 1 ? EasyTheme.color.border : "transparent"
            border.width: 1
            opacity: root.currentPage <= 1 ? 0.5 : 1

            MouseArea {
                anchors.fill: parent
                enabled: root.currentPage > 1
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root._setPage(1)
            }

            EasyIconFont {
                anchors.centerIn: parent
                icon: EasyIcon.material.first_page
                iconSize: root.computedArrowSize
                color: root.currentPage <= 1 ? EasyTheme.color.placeholder : EasyTheme.color.text
            }
        }

        // ===== 上一页 =====
        Rectangle {
            width: root.computedBtnSize
            height: root.computedBtnSize
            radius: 6
            color: root.currentPage <= 1 ? "transparent" : EasyTheme.color.card
            border.color: root.currentPage <= 1 ? EasyTheme.color.border : "transparent"
            border.width: 1
            opacity: root.currentPage <= 1 ? 0.5 : 1

            MouseArea {
                anchors.fill: parent
                enabled: root.currentPage > 1
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    root.currentPage--
                    root.pageChanged(root.currentPage)
                }
            }

            EasyIconFont {
                anchors.centerIn: parent
                icon: EasyIcon.material.chevron_left
                iconSize: root.computedArrowSize * 1.5
                color: root.currentPage <= 1 ? EasyTheme.color.placeholder : EasyTheme.color.text
            }
        }

        // ===== 页码按钮 =====
        Repeater {
            id: pageRepeater
            model: getPageNumbers()

            Rectangle {
                width: root.computedBtnSize
                height: root.computedBtnSize
                radius: 6
                color: modelData
                       == root.currentPage ? EasyTheme.color.primary : EasyTheme.color.card
                border.color: modelData
                              == root.currentPage ? EasyTheme.color.primary : EasyTheme.color.border
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var page = Number(modelData)
                        if (!isNaN(page)) {
                            parent.parent.parent._setPage(page)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: root.computedFontSize
                    font.bold: modelData == root.currentPage
                    color: modelData == root.currentPage ? "white" : (modelData === "..." ? EasyTheme.color.placeholder : EasyTheme.color.text)
                }
            }
        }

        // ===== 下一页 =====
        Rectangle {
            width: root.computedBtnSize
            height: root.computedBtnSize
            radius: 6
            color: root.currentPage >= root.totalPage ? "transparent" : EasyTheme.color.card
            border.color: root.currentPage
                          >= root.totalPage ? EasyTheme.color.border : "transparent"
            border.width: 1
            opacity: root.currentPage >= root.totalPage ? 0.5 : 1

            MouseArea {
                anchors.fill: parent
                enabled: root.currentPage < root.totalPage
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    root.currentPage++
                    root.pageChanged(root.currentPage)
                }
            }
            EasyIconFont {
                anchors.centerIn: parent
                icon: EasyIcon.material.chevron_right
                iconSize: root.computedArrowSize * 1.5
                color: root.currentPage
                       >= root.totalPage ? EasyTheme.color.placeholder : EasyTheme.color.text
            }
        }

        // ===== 末页 =====
        Rectangle {
            width: root.computedBtnSize
            height: root.computedBtnSize
            radius: 6
            visible: root.showFirstLast && root.totalPage > 0
            color: root.currentPage >= root.totalPage ? "transparent" : EasyTheme.color.card
            border.color: root.currentPage
                          >= root.totalPage ? EasyTheme.color.border : "transparent"
            border.width: 1
            opacity: root.currentPage >= root.totalPage ? 0.5 : 1

            MouseArea {
                anchors.fill: parent
                enabled: root.currentPage < root.totalPage
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root._setPage(root.totalPage)
            }

            EasyIconFont {
                anchors.centerIn: parent
                icon: EasyIcon.material.last_page
                iconSize: root.computedArrowSize
                color: root.currentPage
                       >= root.totalPage ? EasyTheme.color.placeholder : EasyTheme.color.text
            }
        }

        // ===== 分割线 =====
        Rectangle {
            width: 1
            height: root.computedBtnSize * 0.5
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showJump || root.showPageSizeSelector
            color: EasyTheme.color.divider
        }

        // ===== 页码跳转 =====
        Row {
            visible: root.showJump && root.totalPage > 0
            spacing: 4

            Text {
                text: "跳转"
                font.pixelSize: root.computedFontSize
                color: EasyTheme.color.text
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: jumpInput
                width: 48
                height: root.computedBtnSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: EasyTheme.color.text
                padding: 0
                background: Rectangle {
                    radius: 6
                    color: EasyTheme.color.card
                    border.color: jumpInput.activeFocus ? EasyTheme.color.primary : EasyTheme.color.border
                    border.width: 1
                }
                validator: IntValidator {
                    bottom: 1
                    top: Math.max(1, root.totalPage)
                }
                onAccepted: {
                    var val = parseInt(text)
                    if (!isNaN(val) && val >= 1 && val <= root.totalPage) {
                        root._setPage(val)
                    }
                    text = ""
                }
            }

            Text {
                text: "页"
                font.pixelSize: root.computedFontSize
                color: EasyTheme.color.placeholder
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ===== 每页条数选择器 =====
        Row {
            visible: root.showPageSizeSelector
            spacing: 4

            Text {
                text: "每页"
                font.pixelSize: root.computedFontSize
                color: EasyTheme.color.text
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                id: pageSizeSelector
                width: 60
                height: root.computedBtnSize
                radius: 6
                color: EasyTheme.color.card
                border.color: pageSizeMenu.visible ? EasyTheme.color.primary : EasyTheme.color.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 4
                    spacing: 2

                    Text {
                        text: root.pageSize
                        font.pixelSize: root.computedFontSize
                        color: EasyTheme.color.text
                        Layout.fillWidth: true
                    }

                    EasyIconFont {
                        icon: EasyIcon.material.arrow_drop_down
                        iconSize: root.computedArrowSize
                        color: EasyTheme.color.placeholder
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pageSizeMenu.open()
                }

                Popup {
                    id: pageSizeMenu
                    y: parent.height + 4
                    padding: 4
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                    contentItem: Column {
                        spacing: 2
                        Repeater {
                            model: root.pageSizeOptions

                            Rectangle {
                                width: 56
                                height: root.computedBtnSize
                                radius: 4
                                color: modelData === root.pageSize
                                    ? EasyTheme.color.primary
                                    : (area.containsMouse ? EasyTheme.color.hover : "transparent")

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: root.computedFontSize
                                    color: modelData === root.pageSize ? "white" : EasyTheme.color.text
                                }

                                MouseArea {
                                    id: area
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData !== root.pageSize) {
                                            root.pageSizeUpdated(modelData)
                                        }
                                        pageSizeMenu.close()
                                    }
                                }
                            }
                        }
                    }

                    background: Rectangle {
                        radius: 8
                        color: EasyTheme.color.card
                        border.color: EasyTheme.color.border
                        border.width: 1
                    }
                }
            }

            Text {
                text: "条"
                font.pixelSize: root.computedFontSize
                color: EasyTheme.color.placeholder
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // 计算显示的页码
    function getPageNumbers() {
        var pages = []
        if (totalPage <= visiblePages) {
            for (var i = 1; i <= totalPage; i++) {
                pages.push(i)
            }
        } else {
            var half = Math.floor(visiblePages / 2)
            var start = currentPage - half
            var end = currentPage + half

            if (start < 1) {
                start = 1
                end = visiblePages
            } else if (end > totalPage) {
                end = totalPage
                start = totalPage - visiblePages + 1
            }

            if (start > 1) {
                pages.push(1)
            }
            if (start > 2) {
                pages.push("...")
            }

            for (var j = start; j <= end; j++) {
                pages.push(j)
            }

            if (end < totalPage - 1) {
                pages.push("...")
            }
            if (end < totalPage) {
                pages.push(totalPage)
            }
        }
        return pages
    }
}
