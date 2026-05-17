import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: 350

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 16

        Text { text: "二维码生成"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }
        Text { text: "Canvas 绘制的 QR Code，无需外部库。"; font.pixelSize: 13; color: EasyTheme.color.secondary; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        RowLayout { spacing: 24
            EasyInput {
                id: qrInput
                Layout.fillWidth: true
                placeholder: "输入网址或文本"
                onTextChanged: qrDisplay.text = text
            }
        }

        EasyQRCode {
            id: qrDisplay
            Layout.alignment: Qt.AlignHCenter
            width: 200; height: 200
            text: "https://example.com"; moduleSize: 6
        }
    }
}
