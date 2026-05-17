import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI
import "components"

/**
 * ComponentsPage —— 组件库入口页
 *
 * 展示所有 EasyUI 组件的列表，点击后进入详情页查看示例和文档。
 */
Page {
    id: root
    background: Rectangle {
        color: EasyTheme.color.background
    }

    property var selectedItem: null

    // 组件列表数据
    property var componentList: [
        {
            "title": "按钮",
            "subtitle": "EasyButton / EasyButtonGroup",
            "icon": "\ue9e0",
            "example": "views/components/EasyButtonExample.qml",
            "doc": "views/components/doc/EasyButton.md"
        },
        {
            "title": "输入框",
            "subtitle": "EasyInput / Number / IP / MAC / TextArea / Search",
            "icon": "\ue8b6",
            "example": "views/components/EasyInputExample.qml",
            "doc": "views/components/doc/EasyInput.md"
        },
        {
            "title": "选择器",
            "subtitle": "EasySelect / TimePicker / DatePicker",
            "icon": "\ueb7c",
            "example": "views/components/EasySelectExample.qml",
            "doc": "views/components/doc/EasySelect.md"
        },
        {
            "title": "开关与复选",
            "subtitle": "EasySwitch / Checkbox / Radio / RadioGroup / Toggle",
            "icon": "\ue8a1",
            "example": "views/components/EasySwitchExample.qml",
            "doc": "views/components/doc/EasySwitch.md"
        },
        {
            "title": "滑块与评分",
            "subtitle": "EasySlider / Rate / Segmented",
            "icon": "\ue9e4",
            "example": "views/components/EasySliderExample.qml",
            "doc": "views/components/doc/EasySlider.md"
        },
        {
            "title": "数据展示",
            "subtitle": "EasyBadge / Tag / Avatar / Progress / Loading / Skeleton / Empty / Timeline",
            "icon": "\ue80c",
            "example": "views/components/EasyDisplayExample.qml",
            "doc": "views/components/doc/EasyDisplay.md"
        },
        {
            "title": "表格与分页",
            "subtitle": "EasyTable / Pagination / Transfer",
            "icon": "\ue9ef",
            "example": "views/components/EasyTableExample.qml",
            "doc": "views/components/doc/EasyTable.md"
        },
        {
            "title": "反馈与弹窗",
            "subtitle": "EasyAlert / Tooltip / Dialog / Drawer",
            "icon": "\ue88e",
            "example": "views/components/EasyFeedbackExample.qml",
            "doc": "views/components/doc/EasyFeedback.md"
        },
        {
            "title": "导航",
            "subtitle": "EasyBreadcrumb / TabBar / TreeView / Collapse",
            "icon": "\ue8a0",
            "example": "views/components/EasyNavExample.qml",
            "doc": "views/components/doc/EasyNav.md"
        },
        {
            "title": "其他",
            "subtitle": "Divider / Card / Carousel / Lyric / IconFont / Markdown",
            "icon": "\ue5d3",
            "example": "views/components/EasyOtherExample.qml",
            "doc": "views/components/doc/EasyOther.md"
        },
        {
            "title": "菜单栏",
            "subtitle": "EasyMenuBar / EasyMenuButton",
            "icon": "\ue8b8",
            "example": "views/components/EasyMenuBarExample.qml",
            "doc": "views/components/doc/EasyMenuBar.md"
        },
        {
            "title": "级联选择",
            "subtitle": "EasyCascader — 多级联动选择",
            "icon": "",
            "example": "views/components/EasyCascaderExample.qml",
            "doc": "views/components/doc/EasyCascader.md"
        },
        {
            "title": "图表",
            "subtitle": "EasyChart — 折线/柱状/饼图/环形图",
            "icon": "",
            "example": "views/components/EasyChartExample.qml",
            "doc": "views/components/doc/EasyChart.md"
        },

        {
            "title": "图片查看器",
            "subtitle": "EasyImageViewer — 缩放/拖拽/旋转",
            "icon": "",
            "example": "views/components/EasyImageViewerExample.qml",
            "doc": "views/components/doc/EasyImageViewer.md"
        },
        {
            "title": "命令面板",
            "subtitle": "EasyCommandPalette — Ctrl+K 搜索命令",
            "icon": "",
            "example": "views/components/EasyCommandPaletteExample.qml",
            "doc": "views/components/doc/EasyCommandPalette.md"
        },
        {
            "title": "向导",
            "subtitle": "EasyWizard — 分步向导流程",
            "icon": "",
            "example": "views/components/EasyWizardExample.qml",
            "doc": "views/components/doc/EasyWizard.md"
        },
        {
            "title": "标签输入",
            "subtitle": "EasyChipInput — 标签/芯片输入",
            "icon": "",
            "example": "views/components/EasyChipInputExample.qml",
            "doc": "views/components/doc/EasyChipInput.md"
        },
        {
            "title": "文件拖放",
            "subtitle": "EasyFileDropZone — 拖拽上传区域",
            "icon": "",
            "example": "views/components/EasyFileDropZoneExample.qml",
            "doc": "views/components/doc/EasyFileDropZone.md"
        },

        {
            "title": "悬浮按钮",
            "subtitle": "EasyFloatingActionButton — FAB 浮动按钮",
            "icon": "",
            "example": "views/components/EasyFloatingActionButtonExample.qml",
            "doc": "views/components/doc/EasyFloatingActionButton.md"
        },
        {
            "title": "二维码",
            "subtitle": "EasyQRCode — 二维码生成",
            "icon": "",
            "example": "views/components/EasyQRCodeExample.qml",
            "doc": "views/components/doc/EasyQRCode.md"
        },
        {
            "title": "水印",
            "subtitle": "EasyWatermark — 水印叠加层",
            "icon": "",
            "example": "views/components/EasyWatermarkExample.qml",
            "doc": "views/components/doc/EasyWatermark.md"
        },
        {
            "title": "下拉菜单",
            "subtitle": "EasyDropDown — 点击/悬浮下拉菜单",
            "icon": "",
            "example": "views/components/EasyDropDownExample.qml",
            "doc": "views/components/doc/EasyDropDown.md"
        },
{
            "title": "滚动条",
            "subtitle": "EasyScrollBar — VS Code 极简风格",
            "icon": "\ue9f9",
            "example": "views/components/EasyScrollBarExample.qml",
            "doc": "views/components/doc/EasyScrollBar.md"
        },
        {
            "title": "颜色选择器",
            "subtitle": "EasyColorPicker — 颜色选择/透明度",
            "icon": "\ue40a",
            "example": "views/components/EasyColorPickerExample.qml",
            "doc": "views/components/doc/EasyColorPicker.md"
        }
    ]

    Loader {
        anchors.fill: parent
        sourceComponent: root.selectedItem ? detailComponent : listComponent
    }

    // ========== 列表页 ==========
    Component {
        id: listComponent

        ScrollView {
            anchors.fill: parent
            clip: true
            ScrollBar.vertical: EasyScrollBar { }
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            padding: 24

            ColumnLayout {
                width: parent.width - 48
                spacing: 20

                // 页面标题
                Text {
                    text: "🎨 组件库"
                    font.pixelSize: 24
                    font.bold: true
                    color: EasyTheme.color.text
                }

                Text {
                    text: "共 " + root.componentList.length + " 个组件分类"
                    font.pixelSize: 13
                    color: EasyTheme.color.placeholder
                }

                // 组件卡片网格
                GridLayout {
                    Layout.fillWidth: true
                    columns: Math.max(1, Math.floor((parent.width + 16) / 240))
                    columnSpacing: 16
                    rowSpacing: 16

                    Repeater {
                        model: root.componentList

                        EasyCard {
                            Layout.fillWidth: true
                            height: 100
                            padding: 16

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedItem = modelData
                            }

                            RowLayout {
                                anchors.fill: parent
                                spacing: 16

                                Rectangle {
                                    width: 48
                                    height: 48
                                    radius: 10
                                    color: EasyTheme.color.primary
                                    opacity: 0.12

                                    EasyIconFont {
                                        anchors.centerIn: parent
                                        icon: modelData.icon
                                        iconSize: 24
                                        color: EasyTheme.color.primary
                                    }
                                }

                                ColumnLayout {
                                    spacing: 4
                                    Layout.fillWidth: true

                                    Text {
                                        text: modelData.title
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: EasyTheme.color.text
                                    }

                                    Text {
                                        text: modelData.subtitle
                                        font.pixelSize: 12
                                        color: EasyTheme.color.placeholder
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                EasyIconFont {
                                    icon: "\ue409"
                                    iconSize: 16
                                    color: EasyTheme.color.placeholder
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ========== 详情页 ==========
    Component {
        id: detailComponent

        ComponentDetailPage {
            pageTitle: root.selectedItem.title + " — " + root.selectedItem.subtitle
            exampleSource: root.selectedItem.example
            docPath: root.selectedItem.doc
            backCallback: function() { root.selectedItem = null }
        }
    }
}
