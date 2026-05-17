import QtQuick
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: 350

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 16

        Text { text: "文件拖放上传区域"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }
        Text { text: "支持拖拽文件到区域或点击选择。拖拽时高亮显示。"; font.pixelSize: 13; color: EasyTheme.color.secondary; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        EasyFileDropZone {
            Layout.fillWidth: true; implicitHeight: 200
            onFilesDropped: function(paths) {
                droppedFiles.text = "已选择文件:\n" + paths.join("\n")
            }
        }

        Text {
            id: droppedFiles
            Layout.fillWidth: true; font.pixelSize: 12; color: EasyTheme.color.text
            wrapMode: Text.WordWrap; visible: text.length > 0
        }
    }
}
