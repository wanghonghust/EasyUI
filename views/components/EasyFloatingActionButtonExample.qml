import QtQuick
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: 300

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 16

        Text { text: "悬浮操作按钮 (FAB)"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }
        Text { text: "浮动在主内容上方的圆形按钮，适合主要操作。"; font.pixelSize: 13; color: EasyTheme.color.secondary; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        Flow { Layout.fillWidth: true; spacing: 24
            EasyFloatingActionButton { icon: "＋"; onClicked: console.log("FAB clicked") }
            EasyFloatingActionButton { icon: "✎"; mini: true; bgColor: "#10b981"; onClicked: console.log("Mini FAB clicked") }
            EasyFloatingActionButton { icon: "★"; mini: true; bgColor: "#f59e0b"; onClicked: console.log("Star clicked") }
            EasyFloatingActionButton { icon: "📤"; mini: true; bgColor: "#ef4444"; onClicked: console.log("Share clicked") }
        }
    }
}
