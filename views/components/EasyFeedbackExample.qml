import QtQuick
import QtQuick.Layouts
import EasyUI

Item {
    id: rootItem
    implicitHeight: contentLayout.implicitHeight + 48

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 24

    // ========== EasyAlert ==========
    Text {
        text: "提示框 (EasyAlert)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        EasyAlert { text: "这是一条普通提示信息" }
        EasyAlert { type: "success"; title: "操作成功"; text: "您的数据已成功保存" }
        EasyAlert { type: "warning"; text: "请注意，此操作不可撤销" }
        EasyAlert { type: "error"; title: "发生错误"; text: "网络连接失败，请检查网络设置"; closable: false }
    }
    Text {
        text: "带类型色边框 (showBorder: true)"
        font.pixelSize: 14
        font.bold: true
        color: EasyTheme.color.secondary
        Layout.topMargin: 4
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        EasyAlert { type: "info"; text: "这是一条信息提示"; showBorder: true }
        EasyAlert { type: "success"; title: "操作成功"; text: "数据已成功保存到服务器"; showBorder: true }
        EasyAlert { type: "warning"; title: "请确认"; text: "此操作不可撤销，请谨慎执行"; showBorder: true }
        EasyAlert { type: "error"; title: "系统错误"; text: "网络连接超时，请稍后重试"; showBorder: true; closable: false }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyTooltip ==========
    Text {
        text: "工具提示 (EasyTooltip)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 32
        EasyTooltip { text: "上方提示"; placement: "top"; EasyButton { text: "悬停查看提示" } }
        EasyTooltip { text: "下方提示"; placement: "bottom"; EasyButton { text: "悬停查看提示"; primary: false } }
        EasyTooltip { text: "左侧提示"; placement: "left"; EasyButton { text: "悬停" } }
        EasyTooltip { text: "右侧提示"; placement: "right"; EasyButton { text: "悬停"; primary: false } }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyDialog ==========
    Text {
        text: "对话框 (EasyDialog)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 12
        EasyButton {
            text: "默认图标"
            primary: true
            onClicked: sampleDialog.open()
        }
        EasyButton {
            text: "警告图标"
            primary: false
            onClicked: warnDialog.open()
        }
        EasyButton {
            text: "无取消按钮"
            primary: false
            onClicked: noCancelDialog.open()
        }
    }

    EasyDialog {
        id: sampleDialog
        headerTitle: "示例对话框"
        confirmText: "确认"
        cancelText: "取消"
        dialogWidth: 400
        ColumnLayout {
            spacing: 16
            width: parent.width
            Text { text: "这是一个示例对话框"; font.pixelSize: 14; color: EasyTheme.color.text }
            EasyInput { placeholder: "输入一些内容"; width: parent.width }
            EasyCheckbox { text: "记住选择" }
        }
    }
    EasyDialog {
        id: warnDialog
        headerTitle: "删除确认"
        titleIcon: EasyIcon.material.warning
        confirmText: "删除"
        cancelText: "取消"
        dialogWidth: 400
        ColumnLayout {
            spacing: 16
            width: parent.width
            Text { text: "确定要删除此项吗？此操作不可撤销。"; font.pixelSize: 14; color: EasyTheme.color.text }
        }
    }
    EasyDialog {
        id: noCancelDialog
        headerTitle: "消息通知"
        titleIcon: EasyIcon.material.info
        confirmText: "知道了"
        cancelText: ""
        dialogWidth: 380
        ColumnLayout {
            spacing: 16
            width: parent.width
            Text { text: "操作已成功完成。"; font.pixelSize: 14; color: EasyTheme.color.text }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyDrawer ==========
    Text {
        text: "抽屉 (EasyDrawer)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    RowLayout {
        spacing: 12
        EasyButton { text: "左侧抽屉"; onClicked: leftDrawer.open() }
        EasyButton { text: "右侧抽屉"; onClicked: rightDrawer.open() }
        EasyButton { text: "顶部抽屉"; onClicked: topDrawer.open() }
        EasyButton { text: "底部抽屉"; onClicked: bottomDrawer.open() }
    }

    EasyDrawer {
        id: leftDrawer
        edge: Qt.LeftEdge
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            Text { text: "左侧抽屉内容"; font.pixelSize: 14; font.bold: true; color: EasyTheme.color.text }
            EasyButton { text: "关闭"; onClicked: leftDrawer.close() }
        }
    }
    EasyDrawer {
        id: rightDrawer
        edge: Qt.RightEdge
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            Text { text: "右侧抽屉内容"; font.pixelSize: 14; font.bold: true; color: EasyTheme.color.text }
            EasyButton { text: "关闭"; primary: true; onClicked: rightDrawer.close() }
        }
    }
    EasyDrawer {
        id: topDrawer
        edge: Qt.TopEdge
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            Text { text: "顶部抽屉内容"; font.pixelSize: 14; font.bold: true; color: EasyTheme.color.text }
            EasyButton { text: "关闭"; onClicked: topDrawer.close() }
        }
    }
    EasyDrawer {
        id: bottomDrawer
        edge: Qt.BottomEdge
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            Text { text: "底部抽屉内容"; font.pixelSize: 14; font.bold: true; color: EasyTheme.color.text }
            EasyButton { text: "关闭"; onClicked: bottomDrawer.close() }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyToast ==========
    Text {
        text: "通知提示 (EasyToast)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    Flow {
        spacing: 12
        width: parent.width
        EasyButton { text: "信息"; onClicked: ToastManager.info("这是一条普通提示") }
        EasyButton { text: "成功"; primary: true; onClicked: ToastManager.success("操作成功完成！") }
        EasyButton { text: "警告"; onClicked: ToastManager.warning("请注意，此操作不可撤销") }
        EasyButton { text: "错误"; onClicked: ToastManager.error("网络连接失败，请检查设置", 5000) }
        EasyButton { text: "自定义时长 8s"; onClicked: ToastManager.show("自定义显示时长为 8 秒", "info", 8000) }
        EasyButton { text: "靠右弹出"; onClicked: { ToastManager.position = "top-right"; ToastManager.success("这是右侧弹出的提示"); ToastManager.position = "top-center" } }
        EasyButton { text: "靠左弹出"; onClicked: { ToastManager.position = "top-left"; ToastManager.success("这是左侧弹出的提示"); ToastManager.position = "top-center" } }
        EasyButton { text: "底部弹出"; onClicked: { ToastManager.position = "bottom-center"; ToastManager.info("这是底部弹出的提示"); ToastManager.position = "top-center" } }
        EasyButton { text: "关闭所有"; onClicked: ToastManager.closeAll() }
    }

    RowLayout {
        spacing: 12
        Layout.topMargin: 8
        EasyButton { text: "无关闭按钮"; onClicked: { ToastManager.showCloseButton = false; ToastManager.info("这个 toast 没有关闭按钮"); ToastManager.showCloseButton = true } }
        EasyButton { text: "窄宽度"; onClicked: ToastManager.show("窄宽度 toast，maxWidth=260", "info") }
        EasyButton { text: "超长文本"; onClicked: ToastManager.error("这是一条非常长的错误提示信息，用于测试文本换行效果，确保在窄宽度下也能完整显示所有内容", 6000) }
    }
}
}
