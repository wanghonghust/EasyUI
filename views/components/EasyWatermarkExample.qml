import QtQuick
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: 300

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 16

        Text { text: "水印叠加层"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }
        Text { text: "覆盖在内容上方的半透明水印文字，适合防截图场景。"; font.pixelSize: 13; color: EasyTheme.color.secondary; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 200; radius: 12
            color: EasyTheme.color.card; border.color: EasyTheme.color.cardBorder; border.width: 1

            Text {
                anchors.centerIn: parent; text: "受保护的内容区域"
                font.pixelSize: 18; font.bold: true; color: EasyTheme.color.text
            }

            EasyWatermark {
                text: "EasyChat 机密"; watermarkOpacity: 0.06; fontSize: 16
                spacing: 100; rotationAngle: -25
            }
        }
    }
}
