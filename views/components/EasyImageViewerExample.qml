import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: 300

    EasyImageViewer {
        id: viewer
        source: "F:/QP/EasyChat/res/EasyChat.png"
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 24
        }
        spacing: 16

        Text {
            text: "图片查看器"
            font.pixelSize: 16
            font.bold: true
            color: EasyTheme.color.text
        }
        Text {
            text: "支持缩放（滚轮）、拖拽平移、旋转、重置。点击下方按钮打开。"
            font.pixelSize: 13
            color: EasyTheme.color.secondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        EasyButton {
            text: "打开图片查看器"
            onClicked: viewer.open()
        }
    }
}
