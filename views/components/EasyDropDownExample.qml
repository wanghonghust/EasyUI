import QtQuick
import QtQuick.Layouts
import EasyUI

Item {
    implicitHeight: contentLayout.implicitHeight + 48

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 24

    // ========== 基础用法 ==========
    Text {
        text: "基础用法"
        font.pixelSize: 16; font.bold: true
        color: EasyTheme.color.text
    }
    Text {
        text: "点击按钮展开下拉菜单。控件宽度 = 按钮宽度 + 箭头，下拉宽度独立"
        font.pixelSize: 12; color: EasyTheme.color.placeholder
        Layout.fillWidth: true
    }
    RowLayout {
        spacing: 16

        EasyDropDown {
            id: basicDrop
            model: [
                { text: "操作一", onClick: () => console.log("操作一") },
                { text: "操作二", onClick: () => console.log("操作二") },
                { text: "操作三", onClick: () => console.log("操作三") }
            ]
            popupWidth: 160

            EasyButton {
                id: basicBtn
                height: basicDrop.computedHeight
                text: "下拉菜单"
                primary: true
                size: basicDrop.size
            }
            EasyIconFont {
                anchors.left: basicBtn.right
                anchors.leftMargin: 8
                anchors.verticalCenter: basicBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 20
                color: "white"
            }
        }

        EasyDropDown {
            id:asd
            model: [{
                    "text": "编辑",
                    "icon": EasyIcon.material.edit,
                    "onClick": () => console.log("edit")
                }, {
                    "text": "复制",
                    "icon": EasyIcon.material.content_copy,
                    "onClick": () => console.log("copy")
                }, {
                    "text": "粘贴",
                    "icon": EasyIcon.material.content_paste,
                    "onClick": () => console.log("paste")
                }]
            width: 120

            EasyIconButton {
                icon: EasyIcon.material.more
                hoverColor: EasyTheme.color.miniMaxBtnHover
            }
        }

        EasyDropDown {
            id: asas
            model: [{
                    "text": "编辑",
                    "icon": EasyIcon.material.edit,
                    "onClick": () => console.log("edit")
                }, {
                    "text": "复制",
                    "icon": EasyIcon.material.content_copy,
                    "onClick": () => console.log("copy")
                }, {
                    "text": "粘贴",
                    "icon": EasyIcon.material.content_paste,
                    "onClick": () => console.log("paste")
                }]
            width: 120

            EasyIconButton {
                icon: EasyIcon.material.more
                hoverColor: EasyTheme.color.miniMaxBtnHover
            }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== 带图标 + 分割线 ==========
    Text {
        text: "带图标与分割线"
        font.pixelSize: 16; font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 16
        EasyDropDown {
            id: iconDrop
            size: EasyTheme.size.sizeSmall
            popupWidth: 180
            model: [
                { text: "编辑", icon: EasyIcon.material.edit, onClick: () => console.log("edit") },
                { text: "复制", icon: EasyIcon.material.content_copy, onClick: () => console.log("copy") },
                { text: "粘贴", icon: EasyIcon.material.content_paste, onClick: () => console.log("paste") },
                { text: "", divider: true },
                { text: "删除", icon: EasyIcon.material.delete, onClick: () => console.log("delete") }
            ]

            EasyButton {
                id: iconBtn
                height: iconDrop.computedHeight
                text: "编辑"
                size: iconDrop.size
                primary: false
            }
            EasyIconFont {
                anchors.left: iconBtn.right
                anchors.leftMargin: 6
                anchors.verticalCenter: iconBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 18
                color: EasyTheme.color.placeholder
            }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== 禁用项 ==========
    Text {
        text: "禁用项"
        font.pixelSize: 16; font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 16
        EasyDropDown {
            id: disabledDrop
            size: EasyTheme.size.sizeSmall
            popupWidth: 160
            model: [
                { text: "正常项", onClick: () => {} },
                { text: "禁用项", disabled: true },
                { text: "正常项二", onClick: () => {} }
            ]

            EasyButton {
                id: disBtn
                height: disabledDrop.computedHeight
                text: "含禁用项"
                size: disabledDrop.size
                primary: false
            }
            EasyIconFont {
                anchors.left: disBtn.right
                anchors.leftMargin: 6
                anchors.verticalCenter: disBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 18
                color: EasyTheme.color.placeholder
            }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== 尺寸 ==========
    Text {
        text: "不同尺寸"
        font.pixelSize: 16; font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 16

        EasyDropDown {
            id: sizeMini
            size: EasyTheme.size.sizeMini
            model: [{ text: "小号选项" }, { text: "小号选项二" }]

            EasyButton {
                id: miniBtn
                height: sizeMini.computedHeight
                text: "Mini"
                size: sizeMini.size
            }
            EasyIconFont {
                anchors.left: miniBtn.right; anchors.leftMargin: 6
                anchors.verticalCenter: miniBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 16; color: "white"
            }
        }

        EasyDropDown {
            id: sizeNormal
            model: [{ text: "默认选项" }, { text: "默认选项二" }]

            EasyButton {
                id: normBtn
                height: sizeNormal.computedHeight
                text: "Normal"
                size: sizeNormal.size
            }
            EasyIconFont {
                anchors.left: normBtn.right; anchors.leftMargin: 8
                anchors.verticalCenter: normBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 20; color: "white"
            }
        }

        EasyDropDown {
            id: sizeLarge
            size: EasyTheme.size.sizeLarge
            model: [{ text: "大号选项" }, { text: "大号选项二" }]

            EasyButton {
                id: largeBtn
                height: sizeLarge.computedHeight
                text: "Large"
                size: sizeLarge.size
            }
            EasyIconFont {
                anchors.left: largeBtn.right; anchors.leftMargin: 10
                anchors.verticalCenter: largeBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 24; color: "white"
            }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== Hover 触发 ==========
    Text {
        text: "悬浮触发"
        font.pixelSize: 16; font.bold: true
        color: EasyTheme.color.text
    }
    Text {
        text: "鼠标悬浮即展开，移出后自动收起"
        font.pixelSize: 12; color: EasyTheme.color.placeholder
        Layout.fillWidth: true
    }
    RowLayout {
        spacing: 16
        EasyDropDown {
            id: hoverDrop
            trigger: "hover"
            size: EasyTheme.size.sizeSmall
            popupWidth: 160
            model: [
                { text: "菜单项 A", onClick: () => {} },
                { text: "菜单项 B", onClick: () => {} },
                { text: "菜单项 C", onClick: () => {} }
            ]

            EasyButton {
                id: hoverBtn
                height: hoverDrop.computedHeight
                text: "悬浮展开"
                size: hoverDrop.size
                primary: false
            }
            EasyIconFont {
                anchors.left: hoverBtn.right; anchors.leftMargin: 6
                anchors.verticalCenter: hoverBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 18
                color: EasyTheme.color.placeholder
            }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== 不同对齐方向 ==========
    Text {
        text: "不同对齐方向"
        font.pixelSize: 16; font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 16
        EasyDropDown {
            id: alignStart
            placement: "bottom-start"
            popupWidth: 180
            model: [
                { text: "左对齐菜单长文本项" },
                { text: "项二" }
            ]

            EasyButton {
                id: alignStartBtn
                height: alignStart.computedHeight
                text: "bottom-start"
                size: EasyTheme.size.sizeSmall
                primary: false
            }
            EasyIconFont {
                anchors.left: alignStartBtn.right; anchors.leftMargin: 6
                anchors.verticalCenter: alignStartBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 18
                color: EasyTheme.color.placeholder
            }
        }
        EasyDropDown {
            id: alignEnd
            placement: "bottom-end"
            popupWidth: 200
            model: [
                { text: "右对齐菜单长文本项" },
                { text: "项二" }
            ]

            EasyButton {
                id: alignEndBtn
                height: alignEnd.computedHeight
                text: "bottom-end"
                size: EasyTheme.size.sizeSmall
                primary: false
            }
            EasyIconFont {
                anchors.left: alignEndBtn.right; anchors.leftMargin: 6
                anchors.verticalCenter: alignEndBtn.verticalCenter
                icon: EasyIcon.material.arrow_drop_down
                iconSize: 18
                color: EasyTheme.color.placeholder
            }
        }
    }
    }
}
