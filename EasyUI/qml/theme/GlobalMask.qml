import QtQuick
import QtQuick.Controls.Basic
import EasyUI 1.0

Rectangle {
    id: mask
    anchors.fill: parent  // 填满整个 Overlay
    color: EasyTheme.color.overlay
    z: 999                // 确保在最上层
    Component.onCompleted: {
        console.log("overlay")
    }

    // 阻止事件穿透
    MouseArea {
        anchors.fill: parent
        onClicked: {} // 空处理，阻断事件
    }

    // 点击关闭（可选）
    TapHandler {
        onTapped: mask.destroy()
    }
}