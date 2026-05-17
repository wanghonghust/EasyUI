import QtQuick
import EasyUI

/**
 * StarItem —— 单个评分星星
 */
Item {
    id: root

    property int size: 24
    property int index: 0
    property real value: 0
    property bool allowHalf: false
    property color activeColor: EasyTheme.color.accent
    property color inactiveColor: EasyTheme.color.placeholder
    property bool readonly: false

    signal starClicked(real val)
    signal starHovered(real val)
    signal starExited()

    width: root.size
    height: root.size

    property bool isFull: root.value > root.index
    property bool isHalf: root.allowHalf && (root.value - root.index) >= 0.4 && (root.value - root.index) <= 0.6
    property bool isActive: isFull || isHalf

    // 空心背景星
    Text {
        id: bgStar
        anchors.centerIn: parent
        text: "☆"
        font.pixelSize: root.size
        color: root.inactiveColor
    }

    // 激活星（全星或左半星）
    Item {
        anchors.verticalCenter: parent.verticalCenter
        x: bgStar.x
        width: root.isHalf ? bgStar.implicitWidth / 2 : bgStar.implicitWidth
        height: bgStar.implicitHeight
        clip: true
        visible: root.isActive

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            text: "★"
            font.pixelSize: root.size
            color: root.activeColor
        }
    }

    // 交互区域
    MouseArea {
        anchors.fill: parent
        hoverEnabled: !root.readonly
        enabled: !root.readonly
        cursorShape: root.readonly ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: function(mouse) {
            var val = root.index + (root.allowHalf && mouse.x < width / 2 ? 0.5 : 1)
            starClicked(val)
        }

        onEntered: {
            if (root.allowHalf && mouseX < width / 2)
                starHovered(root.index + 0.5)
            else
                starHovered(root.index + 1)
        }

        onPositionChanged: {
            var val = root.index + 1
            if (root.allowHalf && mouseX < width / 2)
                val = root.index + 0.5
            starHovered(val)
        }

        onExited: starExited()
    }
}
