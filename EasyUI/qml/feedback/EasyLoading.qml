import QtQuick
import QtQuick.Controls.Basic
import EasyUI

/**
 * EasyLoading —— 加载状态指示器
 *
 * 属性：
 *   spinning    {bool}    是否旋转，默认 true
 *   size        {real}    尺寸，默认 40
 *   indicatorColor {color} 颜色，默认主题色
 *   text        {string}  加载文字，可选
 */
Rectangle {
    id: root

    property bool spinning: true
    property real size: 40
    property color indicatorColor: EasyTheme.color.primary
    property string text: ""
    property bool enabled: true
    opacity: enabled ? 1.0 : 0.45
    Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }

    width: text ? size + textLabel.width + 8 : size
    height: size
    implicitWidth: width
    implicitHeight: height
    radius: size / 2
    color: "transparent"

    // 旋转加载指示器
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        width: root.size
        height: root.size
        visible: root.spinning && root.text === ""
        palette.dark: root.indicatorColor
    }

    // 带文字的旋转加载
    Row {
        id: spinningWithText
        anchors.centerIn: parent
        spacing: 6
        visible: root.spinning && root.text !== ""

        BusyIndicator {
            width: root.size
            height: root.size
            palette.dark: root.indicatorColor
        }

        Text {
            text: root.text
            font.pixelSize: 12
            color: root.indicatorColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // 加载文字（静态时显示在中心）
    Text {
        id: textLabel
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: 12
        color: root.indicatorColor
        visible: !root.spinning && root.text !== ""
    }

    // 静态加载（点动画）
    Row {
        id: dotLoader
        anchors.centerIn: parent
        spacing: 4
        visible: !root.spinning && root.text === ""

        Repeater {
            model: 3
            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: root.indicatorColor

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: dotLoader.visible
                    PauseAnimation { duration: 200 * index }
                    NumberAnimation { from: 0.3; to: 1; duration: 200 }
                    NumberAnimation { from: 1; to: 0.3; duration: 200 }
                }
            }
        }
    }
}
