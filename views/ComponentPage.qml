import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI
import "components"

/**
 * ComponentPage —— 组件详情包装页
 *
 * 通过 componentKey 动态加载对应组件的示例和文档。
 */
Page {
    id: root
    background: Rectangle { color: EasyTheme.color.background }

    property string componentKey: ""
    property var navigator: null

    // 组件信息映射表
    readonly property var componentMap: ({
        "button": {
            title: "按钮 — EasyButton / EasyButtonGroup",
            example: "components/EasyButtonExample.qml",
            doc: "components/doc/EasyButton.md"
        },
        "input": {
            title: "输入框 — EasyInput / Number / IP / MAC / TextArea / Search",
            example: "components/EasyInputExample.qml",
            doc: "components/doc/EasyInput.md"
        },
        "select": {
            title: "选择器 — EasySelect / TimePicker / DatePicker",
            example: "components/EasySelectExample.qml",
            doc: "components/doc/EasySelect.md"
        },
        "switch": {
            title: "开关与复选 — EasySwitch / Checkbox / Radio / Toggle",
            example: "components/EasySwitchExample.qml",
            doc: "components/doc/EasySwitch.md"
        },
        "slider": {
            title: "滑块与评分 — EasySlider / Rate / Segmented",
            example: "components/EasySliderExample.qml",
            doc: "components/doc/EasySlider.md"
        },
        "display": {
            title: "数据展示 — EasyBadge / Tag / Avatar / Progress / Loading",
            example: "components/EasyDisplayExample.qml",
            doc: "components/doc/EasyDisplay.md"
        },
        "table": {
            title: "表格与分页 — EasyTable / Pagination / Transfer",
            example: "components/EasyTableExample.qml",
            doc: "components/doc/EasyTable.md"
        },
        "feedback": {
            title: "反馈与弹窗 — EasyAlert / Tooltip / Dialog / Drawer",
            example: "components/EasyFeedbackExample.qml",
            doc: "components/doc/EasyFeedback.md"
        },
        "nav": {
            title: "导航 — EasyBreadcrumb / TabBar / Collapse",
            example: "components/EasyNavExample.qml",
            doc: "components/doc/EasyNav.md"
        },
        "other": {
            title: "其他 — Divider / Card / Carousel / Lyric / IconFont / Markdown",
            example: "components/EasyOtherExample.qml",
            doc: "components/doc/EasyOther.md"
        },
        "menubar": {
            title: "菜单栏 — EasyMenuBar / EasyMenuButton",
            example: "components/EasyMenuBarExample.qml",
            doc: "components/doc/EasyMenuBar.md"
        }
    })

    readonly property var info: componentMap[componentKey] || null

    ComponentDetailPage {
        anchors.fill: parent
        pageTitle: info ? info.title : ""
        exampleSource: info ? Qt.resolvedUrl(info.example) : ""
        docPath: info ? "views/" + info.doc : ""
        backCallback: function() {
            if (root.navigator && root.navigator.goTo) {
                root.navigator.goTo("components")
            }
        }
    }
}
